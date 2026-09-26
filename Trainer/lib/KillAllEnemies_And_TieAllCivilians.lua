-- destroy cameras to prevent alarm on stealth
local function destroy_cameras()
	local function dmg_cam(unit)
		local body
		do
			local i = -1
			repeat
				i = i+1
				body = unit:body(i)
			until (body and body:extension()) or (i >= 5)
		end
		if not body then return end
		body:extension().damage:damage_melee(unit, nil, unit:position(), nil, 10000)
		managers.network:session():send_to_peers_synched("sync_body_damage_melee", body, unit, nil, unit:position(), nil, 10000)
	end

	for _,unit in pairs(SecurityCamera.cameras) do
		pcall(dmg_cam, unit)
	end
	managers.mission._fading_debug_output:script().log('Destroy All Cameras',  Color.yellow)
end

-- kill all enemies and steal pager
local function kill_all_enemies()
	local function dmg_melee(unit)
		if unit then
			local action_data = {
				damage = math.huge, --(Ultra * math.huge) damage.
				damage_effect = unit:character_damage()._HEALTH_INIT * 2,
				attacker_unit = managers.player:player_unit(),
				attack_dir = Vector3(0,0,0),
				name_id = 'rambo', --Only in rambo style bulldosers can be killed
				col_ray = {
					position = unit:position(),
					body = unit:body( "body" ),
				}
			}
			unit:unit_data().has_alarm_pager = false
			unit:character_damage():damage_melee(action_data)
		end
	end

	for _,ud in pairs(managers.enemy:all_enemies()) do
		pcall(dmg_melee, ud.unit)
	end
	managers.mission._fading_debug_output:script().log('Kill All Enemies',  Color.yellow)
end

-- tie all civilians
function tie_all_civilians()
	for u_key, u_data in pairs(managers.enemy:all_civilians()) do
		local unit = u_data.unit
		local brain = unit:brain()
		if not brain:is_tied() then
			local action_data = { type = "act", body_part = 1, clamp_to_graph = true, variant = "halt" }
			brain:action_request( action_data )
			brain._current_logic.on_intimidated( brain._logic_data, math.huge, managers.player:player_unit(), true )
			brain:on_tied(managers.player:player_unit())
		end
	end
	managers.mission._fading_debug_output:script().log('Tie All Civilians',  Color.yellow)
end


if managers.groupai:state():whisper_mode() then
	destroy_cameras()
end
kill_all_enemies()
tie_all_civilians()
