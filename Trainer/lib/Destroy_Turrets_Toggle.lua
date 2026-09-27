global_destroyturrets_toggle = not global_destroyturrets_toggle

local turret_names = {
	"Idstring(@ID3c4730f4268ada38@)", -- vit celling -- units/pd2_dlc_dah/vehicles/dah_turret_ceiling/dah_turret_ceiling
	"Idstring(@ID56c162b293c88d8d@)", --hell island -- units/pd2_dlc_bph/vehicles/bph_turret/bph_turret
	"Idstring(@ID132676041d28bad4@)", --turret van -- units/payday2/vehicles/gen_vehicle_turret/gen_vehicle_turret
	"Idstring(@IDe6bfc34a5c60c351@)",  --scarface celling -- units/pd2_dlc_friend/vehicles/sfm_turret_ceiling/sfm_turret_ceiling
	"Idstring(@IDb2437dc46fdd6cf4@)", --san martin -- units/payday2/vehicles/gen_vehicle_turret/bex_vehicle_turret
	"Idstring(@IDfc730ad39ff3b1e9@)", --henry rock -- units/pd2_dlc_des/vehicles/des_aa_turret/des_aa_turret
}

local function destroy_turret_module()
	math.randomseed(os.clock()*math.huge)
	DelayedCalls:Add("turret_delay"..tostring(math.random(1, math.huge)), 1.4, function()
		if not managers or not managers.player or not managers.player:player_unit() or not alive(managers.player:player_unit()) then return end
		for _, unit in ipairs(World:find_units_quick("all")) do
			if unit then
				local character_dmg = unit:character_damage()
				local action_data = {
					damage = math.huge,
					attacker_unit = managers.player:player_unit(),
					attack_dir = Vector3(0,0,0),
					variant = "explosion",
					name_id = 'bm_w_ray',
					col_ray = {
						position = unit:position(),
						body = unit:body("body"),
					}
				}
				for _, turret_name in ipairs(turret_names) do
					if (tostring(unit:name()) == turret_name) then
						for i=1,10 do
							character_dmg:damage_explosion(action_data)
							-- managers.network:session():send_to_peers_synched("remove_unit", unit)
							if not alive(unit) then
								return
							end

							if unit:id() ~= -1 then
								Network:detach_unit(unit)
							end

							unit:set_slot(0)
						end
					end
				end
			end
		end
	end)
end

Hooks:PostHook(AnimatedVehicleBase, "spawn_module", "Destroy_Turrets", function (self, module_unit_name, align_obj_name, module_id)
	if global_destroyturrets_toggle then	
		destroy_turret_module()
	end
end)


if global_destroyturrets_toggle then
	destroy_turret_module()
	managers.mission._fading_debug_output:script().log(string.format("%s", "Destroy Turrets - Activated"), Color.green)
else
	managers.mission._fading_debug_output:script().log(string.format("%s", "Destroy Turrets - Deactivated"), Color.red)
end
