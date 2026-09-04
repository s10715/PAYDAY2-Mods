if RequiredScript == "lib/utils/game_state_machine/gamestatemachine" then
	-- fix blackscreen
	local run_on_spawn = true
	Hooks:PostHook(GameStateMachine, "change_state_by_name", "fix_blackscreen", function(self, state_name, params)
		if run_on_spawn and Utils:IsInHeist() then
			DelayedCalls:Add("fix_blackscreen", 3, function()
				managers.overlay_effect:stop_effect()
				run_on_spawn = false
			end)
		end
	end)
end

if RequiredScript == "lib/network/matchmaking/networkaccountsteam" then
	-- fix infinite loading
	Hooks:OverrideFunction(NetworkAccountSTEAM, "is_ready_to_close", function(self)
		return true
	end)

	Hooks:OverrideFunction(NetworkAccountSTEAM, "inventory_outfit_signature", function(self)
		return ""
	end)
end

if RequiredScript == "lib/managers/menu/missionbriefinggui" then
	-- force start after press ready button force_start_threshold times
	local force_start_threshold = 5
	local wait_timeout = 10
	global_ready_up_counter = global_ready_up_counter or 0
	Hooks:PostHook(MissionBriefingGui, "on_ready_pressed", "force_start", function(self, ...)
		if Network:is_server() then
			for _, peer in pairs(managers.network and managers.network:session() and managers.network:session():peers() or {}) do
				if not peer:synched() then
					if managers.chat and managers.chat._receive_message then
						managers.chat:_receive_message(ChatManager.GAME or 1, "[Force Start]", "waiting for " .. tostring(peer:name()), Color.yellow)
					end
				end
			end
			global_ready_up_counter = global_ready_up_counter + 1
			if global_ready_up_counter > force_start_threshold and game_state_machine and game_state_machine:verify_game_state(GameStateFilters.waiting_for_players) and game_state_machine:current_state() and game_state_machine:current_state().blackscreen_started and not game_state_machine:current_state():blackscreen_started() then
				managers.system_menu:show_buttons({
					title = "Teammates all synched",
					text = "Press yes to force start",
					button_list = {
						{ text = managers.localization:text("dialog_yes"), callback_func = function()
							managers.system_menu:force_close_all()
							if game_state_machine and game_state_machine.current_state and game_state_machine:current_state() and game_state_machine:current_state().start_game_intro then
								game_state_machine:current_state():start_game_intro()
							end
							DelayedCalls:Add("kick_desynced_players", wait_timeout, function()
								if Utils:IsInHeist() and Utils:IsInGameState() then return end
								for peer_id, peer in pairs(managers and managers.network and managers.network:session() and managers.network:session():peers() or {}) do
									if not peer:synched() and peer_id ~= managers.network._session:local_peer():id() then
										managers.network._session:on_peer_kicked(peer, peer_id, 1)
									end
								end
							end)
						 end, },
						{ text = managers.localization:text("dialog_cancel"), cancel_button = true, callback_func = function()
							managers.system_menu:force_close_all()
							global_ready_up_counter = 0
						 end, },
					},
					flag = "force_start_dialog",
				})
				local function close_force_start_dialog()
					DelayedCalls:Add("close_force_start_dialog", 0.5, function()
						if managers.system_menu and managers.system_menu._active_dialog and managers.system_menu._active_dialog._data and managers.system_menu._active_dialog._data.flag == "force_start_dialog" then
							if game_state_machine and game_state_machine:current_state() and (not game_state_machine:current_state().blackscreen_started or game_state_machine:current_state():blackscreen_started()) then
								managers.system_menu._active_dialog:fade_out_close()
							else
								close_force_start_dialog()
							end
						elseif managers.system_menu and managers.system_menu._dialog_queue then
							for _, dialog in pairs(managers.system_menu._dialog_queue) do
								if managers.system_menu._active_dialog and managers.system_menu._active_dialog ~= dialog and dialog._data and dialog._data.flag == "force_start_dialog" then
									close_force_start_dialog()
									break
								end
							end
						end
					end)
				end
				close_force_start_dialog()
			end
		end
	end)
end

if RequiredScript == "lib/states/ingamewaitingforplayers" then
	-- skip intro screen
	Hooks:PostHook(IngameWaitingForPlayersState, "update", "skip_intro_screen", function(self, ...)
		if self._skip_promt_shown then
			self:_skip()
		end
	end)
end

if RequiredScript == "lib/tweak_data/timespeedeffecttweakdata" then
	-- no slow motion, disable slow motion during mask up or when getting downed
	Hooks:PostHook(TimeSpeedEffectTweakData, "init", "no_slow_motion", function(self, ...)
		local force_enable = {
			mission_effects = true,
		}

		local function disable_effect(table)
			for name, data in pairs(table) do
				if not force_enable[name] then
					if data.speed and data.sustain then
						data.speed = 1
						data.fade_in_delay = 0
						data.fade_in = 0
						data.sustain = 0
						data.fade_out = 0
					elseif type(data) == "table" then
						disable_effect(data)
					end
				end
			end
		end

		disable_effect(self)
	end)
end

if RequiredScript == "lib/units/enemies/cop/copdamage" or RequiredScript == "lib/units/civilians/civiliandamage" or RequiredScript == "lib/managers/playermanager" then
	-- show damage popup
	local player_only = true -- is damage popup only for yourself or for all friendly unit
	local max_show_distance = 2000

	local max_life_time = 2
	local popup_vertical_offset = 40
	local max_popup_margin = 100

	global_damage_popup_cache = global_damage_popup_cache or {
		-- ["key"] = { panel = nil, position = nil, create_time = nil, life_time = nil, },
	}

	local function get_time()
		return managers.game_play_central and math.abs(managers.game_play_central:get_heist_timer()) or TimerManager:game():time()
	end

	local function update_popup()
		if not managers.hud or not game_state_machine or not game_state_machine:verify_game_state(GameStateFilters.any_ingame_playing) then
			return
		end

		local hud_workspace = managers.hud._workspace
		local viewport_camera = managers.viewport:get_current_camera()

		for key, popup_data in pairs(global_damage_popup_cache) do
			popup_data.life_time = tonumber(string.format("%.2f", math.abs(get_time() - popup_data.create_time)))
			if popup_data.life_time < max_life_time then
				local life_time_percentage = tonumber(string.format("%.2f", (popup_data.life_time / max_life_time)))

				-- make popup panel move up
				local update_position = Vector3()
				mvector3.set(update_position, popup_data.position)
				mvector3.add_scaled(update_position, math.UP, life_time_percentage * max_popup_margin)

				if hud_workspace and viewport_camera then
					-- check if panel is in viewport
					local cam_forward = Vector3()
					local screen_pos = Vector3()
					local world_pos = Vector3()
					mrotation.y(viewport_camera:rotation(), cam_forward)
					mvector3.set(world_pos, update_position)
					mvector3.set(screen_pos, hud_workspace:world_to_screen(viewport_camera, world_pos))
					mvector3.subtract(world_pos, viewport_camera:position())
					mvector3.normalize(world_pos)
					popup_data.panel:set_visible(mvector3.dot(cam_forward, world_pos) >= 0)

					-- update panel position in viewport
					popup_data.panel:set_center(math.round(screen_pos.x), math.round(screen_pos.y - 2 * popup_data.panel:h()))
					popup_data.panel:set_bottom(math.round(screen_pos.y + mvector3.distance(viewport_camera:position(), popup_data.position) / 1000))
				end

				-- check if panel block by wall or unit is out of range
				local is_block_by_wall = true
				local is_out_of_range = true
				local from = managers.player and alive(managers.player:player_unit()) and managers.player:player_unit():camera():position()
				local to = alive(popup_data.unit) and popup_data.unit.movement and popup_data.unit:movement() and popup_data.unit:movement().m_head_pos and popup_data.unit:movement():m_head_pos()
				if from and to then
					local ray = World:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("bullet_impact_targets"), "ignore_unit", {}, "thickness", 20, "thickness_mask", managers.slot:get_mask("world_geometry", "vehicles"))
					if ray and ray.unit and ray.unit.key and popup_data.unit.key and ray.unit:key() == popup_data.unit:key() then
						is_block_by_wall = false
					end
					local distance = mvector3.distance(from, to)
					if distance <= max_show_distance then
						is_out_of_range = false
					end
					popup_data.last_is_block_by_wall = is_block_by_wall
					popup_data.last_is_out_of_range = is_out_of_range
				else
					-- if unit is dead and corpse already disappeared, use last time data
					is_block_by_wall = popup_data.last_is_block_by_wall or true
					is_out_of_range = popup_data.last_is_out_of_range or true
				end
				if is_block_by_wall or is_out_of_range then
					popup_data.panel:set_visible(false)
				end

				popup_data.panel:set_alpha(1 - (life_time_percentage / 4))
			else
				if popup_data.panel:parent() then
					popup_data.panel:parent():remove(popup_data.panel)
				end
				global_damage_popup_cache[key] = nil
			end
		end
	end

	local function create_popup(position, damage_string, color, enemy_unit)
		local hud_panel = managers.hud:panel(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		if not hud_panel then return end

		local popup_panel = hud_panel:panel({
			alpha = 1,
			visible = false
	        })
		local center_x = math.round(popup_panel:w() * 0.5)
		local center_y = math.round(popup_panel:h() * 0.5)

		local damage_text = popup_panel:text({
			name = "damage_text",
			text = damage_string or "",
			font = tweak_data.menu.pd2_medium_font,
			font_size = 35,
			color = color,
			blend_mode = "add"
		})
		local _, _, w, h = damage_text:text_rect()
		damage_text:set_size(w, h)
		damage_text:set_center(center_x, center_y)

		popup_panel:set_h(damage_text:bottom())

		local position_new = Vector3()
		mvector3.set(position_new, position)
		mvector3.add_scaled(position_new, math.UP, popup_vertical_offset)

		global_damage_popup_cache[tostring(popup_panel)] = { panel = popup_panel, position = position_new, create_time = get_time(), life_time = 0, unit = enemy_unit }
		update_popup()
	end

	local function process_damage(attack_data, object_self)
		if not attack_data or not object_self or not alive(object_self._unit) then return end
		local attacker = alive(attack_data.attacker_unit) and attack_data.attacker_unit
		local is_godmode = object_self._unit and object_self._unit.character_damage and object_self._unit:character_damage() and (object_self._unit:character_damage()._immortal or object_self._unit:character_damage()._invulnerable) or false
		local damage = not is_godmode and tonumber(attack_data.damage) and math.round(tonumber(attack_data.damage) * 10) or 0
		local position = attack_data.col_ray and (attack_data.col_ray.position or attack_data.col_ray.hit_position) or object_self._unit and object_self._unit.position and object_self._unit:position()
		local is_dead = object_self._dead
		local body = attack_data.col_ray and attack_data.col_ray.body
		local is_headshot = body and object_self.is_head and object_self:is_head(body) or false
		local is_critical = attack_data.critical_hit or false
		local enemy_unit = object_self._unit
		if not alive(attacker) or not tonumber(damage) or tonumber(damage) < 0.1 or not position then return end

		local killer = nil
		if (attacker:in_slot(3) or attacker:in_slot(5)) and not player_only then
			-- teammates
			killer = attacker
		elseif attacker:in_slot(2) then
			-- player
			killer = attacker
		elseif (attacker:in_slot(16) or attacker:in_slot(22)) and not player_only then
			-- bot/joker
			killer = attacker
		elseif attacker:in_slot(12) then
			-- enemy
		elseif attacker:in_slot(25) and attacker.base and attacker:base() and attacker:base().get_owner_id and not player_only then
			-- turret
			local owner = attacker:base():get_owner_id()
			if owner then
				killer =  managers.criminals:character_unit_by_peer_id(owner)
			end
		elseif attacker.base and attacker:base() and attacker:base().thrower_unit and (not player_only or (player_only and attacker:base():thrower_unit() == managers.player:player_unit())) then
			killer = attacker:base():thrower_unit()
		end

		if alive(killer) then
			local color_id = managers.criminals:character_color_id_by_unit(killer)
			local color = color_id and tweak_data.chat_colors[color_id] or Color.white
			local damage_string = (is_dead and tostring(utf8.char(57372)) .. " " or "") .. tostring(damage) .. (is_headshot and " " .. tostring(utf8.char(57364)) or "") .. (is_critical and " " .. tostring(utf8.char(57368)) or "")
			create_popup(position, damage_string, color, enemy_unit)
		end
	end

	if RequiredScript == "lib/units/enemies/cop/copdamage" then
		Hooks:PostHook(CopDamage, "_on_damage_received", "update_damage_popup_1", function (self, attack_data, ...)
			process_damage(attack_data, self)
		end)
	end

	if RequiredScript == "lib/units/civilians/civiliandamage" then
		Hooks:PostHook(CivilianDamage, "_on_damage_received", "update_damage_popup_2", function (self, attack_data, ...)
			process_damage(attack_data, self)
		end)
	end

	if RequiredScript == "lib/managers/playermanager" then
		Hooks:PostHook(PlayerManager, "update", "update_damage_popup_3", function (self, ...)
			update_popup()
		end)
	end
end

if RequiredScript == "lib/managers/hudmanager" or RequiredScript == "lib/network/base/networkpeer" then
	-- show enemies hp
	local function get_time()
		return managers.game_play_central and math.abs(managers.game_play_central:get_heist_timer()) or TimerManager:game():time()
	end

	local function get_slot(through_walls)
		local slots = {}
		-- teammates
		table.insert(slots, 2)
		table.insert(slots, 3)
		table.insert(slots, 4)
		table.insert(slots, 5)
		-- enemies
		table.insert(slots, 12)
		table.insert(slots, 13)
		-- friendlies, bots(mask on/off)/joker
		table.insert(slots, 16)
		table.insert(slots, 22)
		table.insert(slots, 24)
		-- civilians
		table.insert(slots, 21)
		-- turrets
		table.insert(slots, 25)
		table.insert(slots, 26)
		if through_walls then
			return World:make_slot_mask((table.unpack or unpack)(slots))
		else
			return (World:make_slot_mask((table.unpack or unpack)(slots)) + managers.slot:get_mask("bullet_blank_impact_targets"))
		end
	end

	global_healthbar_teammates_information = global_healthbar_teammates_information or {}
	local function set_teammates_information(peer_id, outfit_string)
		local outfit = managers.blackmarket:unpack_outfit_from_string(outfit_string)
		if peer_id and outfit then
			if global_healthbar_teammates_information[peer_id] then
				global_healthbar_teammates_information[peer_id] = {}
			end
			local primary_string = ""
			local secondary_string = ""
			local specialization_string = ""
			local skill_string = ""
			local is_cheater = false
			if outfit.primary and outfit.primary.factory_id and managers.weapon_factory:get_weapon_name_by_factory_id(outfit.primary.factory_id) then
				local primary_have_silencer = managers.weapon_factory:has_perk("silencer", outfit.primary.factory_id, outfit.primary_blueprint or outfit.primary.blueprint or {})
				if primary_have_silencer then
					primary_string = primary_string .. utf8.char(57363) .. " "
				end
				primary_string = primary_string .. managers.weapon_factory:get_weapon_name_by_factory_id(outfit.primary.factory_id)
			end
			if outfit.secondary and outfit.secondary.factory_id and managers.weapon_factory:get_weapon_name_by_factory_id(outfit.secondary.factory_id) then
				local secondary_have_silencer = managers.weapon_factory:has_perk("silencer", outfit.secondary.factory_id, outfit.secondary_blueprint or outfit.secondary.blueprint or {})
				if secondary_have_silencer then
					secondary_string = secondary_string .. utf8.char(57363) .. " "
				end
				secondary_string = secondary_string .. managers.weapon_factory:get_weapon_name_by_factory_id(outfit.secondary.factory_id)
			end
			if outfit.skills and outfit.skills.specializations and tonumber(outfit.skills.specializations[1]) and tweak_data.skilltree.specializations[tonumber(outfit.skills.specializations[1])] and tweak_data.skilltree.specializations[tonumber(outfit.skills.specializations[1])].name_id then
				specialization_string = specialization_string .. managers.localization:text(tweak_data.skilltree.specializations[tonumber(outfit.skills.specializations[1])].name_id)
				if tonumber(outfit.skills.specializations[2]) then
					specialization_string = specialization_string .. tostring(outfit.skills.specializations[2]) .. "/9"
				end
			end
			if outfit.skills and outfit.skills.skills then
				local skills_categories = { [1]={name="M"}, [2]={name="E"}, [3]={name="T"}, [4]={name="G"}, [5]={name="H"} }
				for idx, skill_point in pairs(outfit.skills.skills) do
					local category_idx, _ = idx%3==0 and math.modf(idx/3) or math.modf(idx/3) + 1
					if skills_categories[category_idx] then
						skills_categories[category_idx].point = (skills_categories[category_idx].point or 0) + skill_point
					end
				end
				for i=1, #skills_categories do
					if skills_categories[i] then
						skill_string = skill_string .. skills_categories[i].name .. ":" .. tostring(skills_categories[i].point)
						if i ~= #skills_categories then
							skill_string = skill_string .. " "
						end
					end
				end

				local peer = managers.network and managers.network._session and managers.network:session():peer(peer_id)
				local peer_level = (peer and peer.level and peer:level()) or (peer and peer._level)
				if peer_level then
					local max_skill_point = peer_level + (math.floor(peer_level / 10) * 2)
					local total_skill_point = 0
					for _, skill_point in pairs(outfit.skills.skills) do
						total_skill_point = total_skill_point + skill_point
					end
					if total_skill_point > max_skill_point then
						is_cheater = true
					end
				end
			end

			global_healthbar_teammates_information[peer_id] = {}
			global_healthbar_teammates_information[peer_id].primary = primary_string
			global_healthbar_teammates_information[peer_id].secondary = secondary_string
			global_healthbar_teammates_information[peer_id].specialization = specialization_string
			global_healthbar_teammates_information[peer_id].skill = skill_string
			global_healthbar_teammates_information[peer_id].is_cheater = is_cheater
		end
	end

	local function get_aim_target_info()
		local max_distance_in_sight = 10000
		local max_distance = 5000

		local player = managers.player:local_player()
		if not alive(player) or not player:camera() then
			return
		end
		local from = player:camera():position()
		local to = Vector3()
		mvector3.set(to, player:camera():forward())
		mvector3.multiply(to, player:movement():current_state():in_steelsight() and max_distance_in_sight or max_distance)
		mvector3.add(to, from)
		local ray1 = World:raycast("ray", from, to, "slot_mask", get_slot(true), "sphere_cast_radius", 30)
		local ray2 = World:raycast("ray", from, to, "slot_mask", get_slot(false))
		local unit = ray1 and (not ray2 or ray2.unit == ray1.unit or ray2.distance > ray1.distance + 60) and ray1.unit or ray2 and ray2.unit
		if unit and unit:in_slot(8) and unit:parent() and unit:parent():in_slot(get_slot(true)) then
			unit = unit:parent()
		end
		if unit and alive(unit) and unit.character_damage and unit:character_damage() and not unit:character_damage()._dead then
			local head_position = nil
			local unit_name = nil
			local unit_name_color = nil
			local max_hp = nil
			local hp_percentage = nil
			local current_hp = nil
			local hp_color = nil

			if unit.movement and unit:movement() and unit:movement()._obj_head and unit:movement()._obj_head.position and unit:movement()._obj_head:position() then
				head_position = Vector3()
				mvector3.set(head_position, unit:movement()._obj_head:position())
			elseif unit.movement and unit:movement() and unit:movement().m_head_pos and unit:movement():m_head_pos() then
				head_position = Vector3()
				mvector3.set(head_position, unit:movement():m_head_pos())
			elseif unit.position and unit:position() then
				head_position = Vector3()
				mvector3.set(head_position, unit:position())
			end

			if managers.network and managers.network.session and managers.network:session() and managers.network:session().peer_by_unit and managers.network:session():peer_by_unit(unit) then
				-- teammates
				if managers.network:session():peer_by_unit(unit).name and managers.network:session():peer_by_unit(unit):name() then
					-- unit_name = managers.network:session():peer_by_unit(unit):name()
				end
				-- show teammates information instead of name and hp
				if managers.network:session():peer_by_unit(unit):id() and global_healthbar_teammates_information[managers.network:session():peer_by_unit(unit):id()] then
					local information = global_healthbar_teammates_information[managers.network:session():peer_by_unit(unit):id()]
					return head_position, information.specialization .. " | " .. information.skill, information.is_cheater and Color.red or nil, information.primary .. " | " .. information.secondary, nil
				end
			elseif unit.unit_data and unit:unit_data() and unit:unit_data().name_label_id and unit:unit_data().mugshot_id then
				-- AI
				unit_name = ((unit.base and unit:base() and unit:base().nick_name and unit:base():nick_name()) or "AI") .. (Network and Network:is_server() and " (" .. tostring(unit:unit_data().mugshot_id) .. ")" or "")
			elseif unit.base and unit:base() and unit:base()._tweak_table then
				-- npc
				unit_name = unit:base()._tweak_table
			else
				-- vehicles, turret and others
				unit_name = ""
			end

			if tonumber(unit:character_damage()._SHIELD_HEALTH_INIT) and tonumber(unit:character_damage()._shield_health) and tonumber(unit:character_damage()._HEALTH_INIT) and tonumber(unit:character_damage()._health) then
				-- turret has shield health and gun health
				if math.round(tonumber(unit:character_damage()._shield_health)) > 1 then
					max_hp = tonumber(unit:character_damage()._SHIELD_HEALTH_INIT) * 10
					current_hp = math.round(tonumber(unit:character_damage()._shield_health) * 10)
				else
					max_hp = tonumber(unit:character_damage()._HEALTH_INIT) * 10
					current_hp = math.round(tonumber(unit:character_damage()._health) * 10)
				end
			elseif tonumber(unit:character_damage()._HEALTH_INIT) and unit:character_damage().health_ratio and tonumber(unit:character_damage():health_ratio()) then
				-- AI, npc
				max_hp = tonumber(unit:character_damage()._HEALTH_INIT) * 10
				hp_percentage = tonumber(unit:character_damage():health_ratio())
				current_hp = math.round(max_hp * hp_percentage)
			elseif tonumber(unit:character_damage()._current_max_health) and tonumber(unit:character_damage()._HEALTH_INIT_PRECENT) and tonumber(unit:character_damage()._health) then
				-- vehicles
				max_hp = tonumber(unit:character_damage()._current_max_health)
				hp_percentage = tonumber(unit:character_damage()._HEALTH_INIT_PRECENT)
				current_hp = math.round(tonumber(unit:character_damage()._health))
			end

			if current_hp and max_hp then
				return head_position, unit_name, unit_name_color, tostring(current_hp) .. "/" .. tostring(max_hp), hp_color
			else
				return head_position, unit_name, unit_name_color, nil, hp_color
			end
		end
	end

	global_healthbar = global_healthbar or {}
	local function update_healthbar()
		local vertical_offset = 40

		local head_position, unit_name, unit_name_color, hp_string, hp_color = get_aim_target_info()
		if not head_position then return end

		if not global_healthbar then global_healthbar = {} end
		local base_panel = managers.hud:panel(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		if not base_panel then return end

		local panel = global_healthbar.panel or base_panel:panel({
			alpha = 0,
			layer = -100
		})
		local center_x = math.round(panel:w() * 0.5)
		local center_y = math.round(panel:h() * 0.5)

		local hp_text = global_healthbar.hp_text or panel:text({
			layer = 3,
			text = "",
			font = tweak_data.menu.pd2_medium_font,
			font_size = 16,
			color = Color.white
		})
		hp_text:set_text(hp_string and tostring(hp_string) or "")
		hp_text:set_color(hp_color or Color.white)
		local _, _, hp_w, hp_h = hp_text:text_rect()
		hp_text:set_size(hp_w, hp_h)
		hp_text:set_center(center_x, center_y)

		local unit_name_text = global_healthbar.unit_name_text or panel:text({
			layer = 3,
			text = "",
			font = tweak_data.menu.pd2_medium_font,
			font_size = 20,
			color = Color.white
		})
		unit_name_text:set_text(unit_name and tostring(unit_name) or "")
		unit_name_text:set_color(unit_name_color or Color.white)
		local _, _, text_w, text_h = unit_name_text:text_rect()
		unit_name_text:set_size(text_w, text_h)
		unit_name_text:set_center(center_x, center_y + hp_h)

		panel:set_h(math.max(unit_name_text:bottom(), hp_text:bottom()))

		global_healthbar.panel = panel
		global_healthbar.hp_text = hp_text
		global_healthbar.unit_name_text = unit_name_text
		global_healthbar.last_time = get_time()

		local hud_workspace = managers.hud._workspace
		local viewport_camera = managers.viewport:get_current_camera()
		if viewport_camera and hud_workspace then
			local panel_pos = Vector3()
			mvector3.set(panel_pos, head_position)
			mvector3.add_scaled(panel_pos, math.UP, vertical_offset)

			local screen_pos = hud_workspace:world_to_screen(viewport_camera, panel_pos)

			panel:set_center_x(math.round(screen_pos.x))
			panel:set_bottom(math.round(screen_pos.y + mvector3.distance(viewport_camera:position(), panel_pos) / 1000))
			panel:set_visible(screen_pos.z > 0)
		end
	end

	local function destroy_healthbar()
		local panel = global_healthbar.panel
		if not panel then return end
		if panel.parent and panel:parent() then
			panel:parent():remove(panel)
		end
		global_healthbar = {}
	end

	local function show_healthbar()
		local panel = global_healthbar.panel
		if not panel then return end
		panel:set_alpha(1)
	end

	local function hide_healthbar()
		local panel = global_healthbar.panel
		if not panel then return end
		panel:set_alpha(0)
	end

	if RequiredScript == "lib/managers/hudmanager" then
		Hooks:PostHook(HUDManager, "update", "update_healthbar", function (self, t)
			local fade_out_time = 0.5

			update_healthbar()
			show_healthbar()
			if global_healthbar.last_time and math.abs(get_time() - global_healthbar.last_time) > fade_out_time then
				hide_healthbar()
			end
		end)
	end

	if RequiredScript == "lib/network/base/networkpeer" then
		Hooks:PostHook(NetworkPeer, "set_outfit_string", "update_teammates_information_1", function(self, outfit_string, outfit_version, outfit_signature)
			if self == managers.network:session():local_peer() then
				return
			end
			if not outfit_string or outfit_string ~= self._profile.outfit_string then
				return
			end
			if not self._unit or not alive(self._unit) or not managers.network or not managers.network:session() or not managers.criminals then
				return
			end
			local peer = managers.network:session():peer_by_unit(self._unit)
			local peer_id = peer and peer.id and peer:id()
			set_teammates_information(peer_id, outfit_string)
		end)

		Hooks:PostHook(NetworkPeer, "set_class", "update_teammates_information_2", function(self)
			if not self._unit or not alive(self._unit) or not managers.network or not managers.network:session() or not managers.criminals then
				return
			end
			if self._profile and self._profile.outfit_string then
				local peer = managers.network:session():peer_by_unit(self._unit)
				local peer_id = peer and peer.id and peer:id()
				set_teammates_information(peer_id, self._profile.outfit_string)
			end
		end)
	end
end

if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" or RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	-- joker contour match owner
	if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
		Hooks:PostHook(GroupAIStateBase, "convert_hostage_to_criminal", "joker_contour_1", function (self, unit, peer_unit, ...)
			if alive(unit) then
				local peer_color_id = managers.criminals:character_color_id_by_unit(peer_unit or managers.player:player_unit())
				local color = tweak_data.peer_vector_colors[peer_color_id] or Color.blue
				unit:contour():change_color("friendly", color)
				managers.occlusion:remove_occlusion(unit)
			end
		end)
	end

	if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
		Hooks:PostHook(UnitNetworkHandler, "mark_minion", "joker_contour_2", function (self, unit, minion_owner_peer_id, ...)
			if alive(unit) then
				local color = tweak_data.peer_vector_colors[minion_owner_peer_id] or Color.blue
				unit:contour():change_color("friendly", color)
				managers.occlusion:remove_occlusion(unit)
			end
		end)
	end
end

--[[if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" or RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	-- add name label for joker
	local function add_joker_name_label(unit, unit_name, unit_color)
		if alive(unit) and unit.unit_data and unit:unit_data() and not unit:unit_data().name_label_id then
			name = unit_name or (unit.base and unit:base() and unit:base()._tweak_table) or "joker"
			color = unit_color or Color.blue

			unit:unit_data().name_label_id = managers.hud:_add_name_label({
				name = name,
				name_color_ranges = {
					{
						start = 0,
						stop = utf8.len(name),
						color = color
					}
				},
				unit = unit
			})
		end
	end

	local function remove_joker_name_label(unit)
		if alive(unit) and unit.unit_data and unit:unit_data() and unit:unit_data().name_label_id then
			managers.hud:_remove_name_label(unit:unit_data().name_label_id)
			unit:unit_data().name_label_id = nil
		end
	end

	if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
		Hooks:PostHook(GroupAIStateBase, "convert_hostage_to_criminal", "joker_name_label_1", function (self, unit, peer_unit, ...)
			if alive(unit) then
				local peer_color_id = managers.criminals:character_color_id_by_unit(peer_unit or managers.player:player_unit())
				local color = tweak_data.peer_vector_colors[peer_color_id] or Color.blue
				add_joker_name_label(unit, nil, color)
			end
		end)

		Hooks:PreHook(GroupAIStateBase, "remove_minion", "joker_name_label_2", function (self, minion_key, ...)
			local unit = self._converted_police[minion_key]
			if alive(unit) then
				remove_joker_name_label(unit)
			end
		end)
	end

	if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
		Hooks:PostHook(UnitNetworkHandler, "mark_minion", "joker_name_label_3", function (self, unit, minion_owner_peer_id, ...)
			if alive(unit) then
				local color = tweak_data.peer_vector_colors[minion_owner_peer_id] or Color.blue
				add_joker_name_label(unit, nil, color)
			end
		end)

		Hooks:PreHook(UnitNetworkHandler, "remove_minion", "joker_name_label_4", function (self, unit, ...)
			if alive(unit) then
				remove_joker_name_label(unit)
			end
		end)
	end
end]]--

if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" or RequiredScript == "lib/network/handlers/unitnetworkhandler" or RequiredScript == "lib/units/interactions/interactionext" then
	-- replace joker
	global_player_joker_list = global_player_joker_list or {}

	if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
		Hooks:PostHook(GroupAIStateBase, "convert_hostage_to_criminal", "replace_joker_1", function (self, unit, peer_unit, ...)
			if alive(unit) and (unit:in_slot(16) or unit:in_slot(22)) and not peer_unit then
				table.insert(global_player_joker_list, unit)
			end
		end)
	end

	if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
		Hooks:PostHook(UnitNetworkHandler, "mark_minion", "replace_joker_2", function (self, unit, minion_owner_peer_id, ...)
			if alive(unit) and (unit:in_slot(16) or unit:in_slot(22)) and minion_owner_peer_id == managers.network:session():local_peer():id() then
				table.insert(global_player_joker_list, unit)
			end
		end)
	end

	if RequiredScript == "lib/units/interactions/interactionext" then
		Hooks:PreHook(IntimitateInteractionExt, "_interact_blocked", "replace_joker_3", function(self, ...)
			if self.tweak_data == "hostage_convert" and managers.player:chk_minion_limit_reached() and not managers.groupai:state():whisper_mode() then
				while #global_player_joker_list > 0 do
					local unit = table.remove(global_player_joker_list, 1)
					if alive(unit) and unit.character_damage and unit:character_damage() then
						unit:character_damage():damage_mission({ damage = unit:character_damage()._HEALTH_INIT + 1 })
						break
					end
				end
			end
		end)
	end
end

if RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" or RequiredScript == "lib/units/beings/player/playerinventory" or RequiredScript == "lib/utils/accelbyte/telemetry" then
	-- add waypoint to ecm and pocket ecm, and show time left
	local jammer_with_upgrade_color = Color(1, 0.1, 0.9, 0.1) --Color.green -- jammer can block pager color
	local jammer_without_upgrade_color = Color(1, 0.9, 0.1, 0.1) --Color.red -- jammer can't block pager color
	local feedback_color = Color(1, 0.1, 0.1, 0.9) --Color.blue -- ecm feedback color

	local function update_ecm_waypoint(unit, end_time, color, show_text)
		local waypoint_name = "ecm_wp_" .. tostring(unit:id())
		local time_left = tonumber(string.format("%.2f", (tonumber(end_time) or 0) - TimerManager:game():time()))
		if not end_time or time_left <= 0 or unit == managers.player:player_unit() then
			managers.hud:remove_waypoint(waypoint_name)
			return
		end

		local waypoint = managers.hud._hud and managers.hud._hud.waypoints and managers.hud._hud.waypoints[waypoint_name]
		if not waypoint or (waypoint.timer and math.abs(waypoint.timer - time_left) > 0.1) then
			managers.hud:remove_waypoint(waypoint_name)
			managers.hud:add_waypoint(
				waypoint_name, {
				icon = "equipment_ecm_jammer",
				distance = false,
				timer = show_text and math.max(time_left, 0) or nil,
				unit = unit,
				no_sync = true,
				present_timer = 0,
				state = "present",
				radius = 50,
				color = color or Color.white,
				blend_mode = "add"
			})
			waypoint = managers.hud._hud and managers.hud._hud.waypoints and managers.hud._hud.waypoints[waypoint_name]
			if waypoint and waypoint.bitmap and waypoint.bitmap.set_color then
				waypoint.bitmap:set_color(color or Color.white)
			end
		end
	end

	if RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
		-- as host, ecm jammer
		Hooks:PostHook(ECMJammerBase, "setup", "ecm_timer_1", function(self, battery_life_upgrade_lvl, ...)
			local ecm_unit = self._unit
			local end_time = TimerManager:game():time() + self:battery_life()
			local can_block_pager = (battery_life_upgrade_lvl == 3)
			local color = can_block_pager and jammer_with_upgrade_color or jammer_without_upgrade_color
			update_ecm_waypoint(ecm_unit, end_time, color, true)
		end)

		-- as client, ecm jammer
		Hooks:PostHook(ECMJammerBase, "sync_setup", "ecm_timer_2", function(self, upgrade_lvl, ...)
			local ecm_unit = self._unit
			local end_time = TimerManager:game():time() + self:battery_life()
			local can_block_pager = (upgrade_lvl == 3)
			local color = can_block_pager and jammer_with_upgrade_color or jammer_without_upgrade_color
			update_ecm_waypoint(ecm_unit, end_time, color, true)
		end)

		-- update ecm jammer end_time, so can remove waypoint after ecm end
		Hooks:PostHook(ECMJammerBase, "update", "ecm_timer_3", function(self, unit, t, ...)
			if self:active() and not self:feedback_active() then
				-- if feedback ended, but jammer didn't end
				local ecm_unit = unit
				local end_time = TimerManager:game():time() + self:battery_life()
				local can_block_pager = alive(self:owner()) and self:owner().base and self:owner():base() and self:owner():base().upgrade_value and self:owner():base():upgrade_value("ecm_jammer", "affects_pagers")
				local color = can_block_pager and jammer_with_upgrade_color or jammer_without_upgrade_color
				update_ecm_waypoint(ecm_unit, end_time, color, true)
			end
			if not self:active() and not self:feedback_active() then
				local ecm_unit = unit
				update_ecm_waypoint(ecm_unit)
			end
		end)

		Hooks:PostHook(ECMJammerBase, "_set_feedback_active", "ecm_timer_4", function(self, state)
			if state then -- ecm feedback start
				if Network:is_server() then
					local ecm_unit = self._unit
					local end_time = self._feedback_expire_t
					update_ecm_waypoint(ecm_unit, end_time, feedback_color, true)
				else
					-- can't get self._feedback_expire_t as client, so use math.huge to make waypoint won't expire, and don't show text
					local ecm_unit = self._unit
					update_ecm_waypoint(ecm_unit, math.huge, feedback_color, false)
				end
			else -- ecm feedback end
				if Network:is_server() then
					local ecm_unit = self._unit
					update_ecm_waypoint(ecm_unit)
				else
					local ecm_unit = self._unit
					update_ecm_waypoint(ecm_unit)
				end
			end
		end)
	end

	if RequiredScript == "lib/units/beings/player/playerinventory" then
		-- pocket ecm jammer start
		Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "ecm_timer_5", function(self, end_time)
			local peer_unit = self._unit
			end_time = end_time or TimerManager:game():time() + self:get_jammer_time()
			local upgrade_value = alive(self._unit) and self._unit.base and self._unit:base() and self._unit:base().upgrade_value and self._unit:base():upgrade_value("player", "pocket_ecm_jammer_base")
			local can_block_pager = upgrade_value and upgrade_value.affects_pagers or false
			local color = can_block_pager and jammer_with_upgrade_color or jammer_without_upgrade_color
			update_ecm_waypoint(peer_unit, end_time, color, true)
		end)

		-- pocket ecm jammer stop
		Hooks:PostHook(PlayerInventory, "_stop_jammer_effect", "ecm_timer_6", function(self, ...)
			local peer_unit = self._unit
			-- self:get_jammer_time() always return max battery_life, so can't get end_time here, set end_time=nil to make waypoint expired
			update_ecm_waypoint(peer_unit)
		end)

		-- pocket ecm feedback start
		Hooks:PostHook(PlayerInventory, "_start_feedback_effect", "ecm_timer_7", function(self, ...)
			local peer_unit = self._unit
			local end_time = TimerManager:game():time() + self:get_jammer_time()
			update_ecm_waypoint(peer_unit, end_time, feedback_color, true)
		end)

		-- pocket ecm feedback stop
		Hooks:PostHook(PlayerInventory, "_stop_feedback_effect", "ecm_timer_8", function(self, ...)
			local peer_unit = self._unit
			update_ecm_waypoint(peer_unit)
		end)
	end

	if RequiredScript == "lib/utils/accelbyte/telemetry" then
		-- if timer still countdown when heist end, will crash the game, need to remove all waypoint before heist end
		Hooks:PostHook(Telemetry, "on_end_heist", "ecm_timer_9", function(self)
			managers.hud:clear_waypoints()
		end)
	end
end

if RequiredScript == "lib/units/interactions/interactionext" or RequiredScript == "lib/units/enemies/cop/copbrain" or RequiredScript == "lib/network/handlers/unitnetworkhandler" or RequiredScript == "lib/utils/accelbyte/telemetry" then
	-- add waypoint to pager, and show time left
	local pager_color = Color.yellow
	local pager_fail_color = Color.red

	local function add_pager_waypoint(unit, end_time)
		local time_left = tonumber(string.format("%.2f", (tonumber(end_time) or 0) - TimerManager:game():time()))
		local waypoint_name = "pager_wp_" .. tostring(unit:id())
		local waypoint = managers.hud._hud and managers.hud._hud.waypoints and managers.hud._hud.waypoints[waypoint_name]
		if waypoint or not end_time or time_left <= 0 then
			return
		end

		managers.hud:add_waypoint(
			waypoint_name, {
			icon = "equipment_ecm_jammer",
			distance = false,
			timer = math.max(time_left, 0),
			unit = unit,
			no_sync = true,
			present_timer = 0,
			state = "present",
			radius = 50,
			color = color or Color.white,
			blend_mode = "add"
		})
		waypoint = managers and managers.hud and managers.hud._hud and managers.hud._hud.waypoints and managers.hud._hud.waypoints[waypoint_name]
		if waypoint and waypoint.bitmap and waypoint.bitmap.set_color then
			waypoint.bitmap:set_color(pager_color or Color.white)
		end

		DelayedCalls:Add("change_pager_waypoint_color_" .. waypoint_name, time_left, function()
			local waypoint = managers and managers.hud and managers.hud._hud and managers.hud._hud.waypoints and managers.hud._hud.waypoints[waypoint_name]
			if waypoint and waypoint.bitmap and waypoint.bitmap.set_color then
				waypoint.bitmap:set_color(pager_fail_color or Color.red)
			end
		end)

		DelayedCalls:Add("remove_pager_waypoint_" .. waypoint_name, time_left + 5, function()
			if managers and managers.hud then
				managers.hud:remove_waypoint(waypoint_name)
			end
		end)
	end

	local function remove_pager_waypoint(unit)
		local waypoint_name = "pager_wp_" .. tostring(unit:id())
		managers.hud:remove_waypoint(waypoint_name)
	end


	if RequiredScript == "lib/units/interactions/interactionext" then
		-- host and client, start pager
		Hooks:PostHook(BaseInteractionExt, "set_tweak_data", "pager_timer_1", function(self, ...)
			if alive(self._unit) and self.tweak_data == "corpse_alarm_pager" then
				local end_time = TimerManager:game():time() + 12
				add_pager_waypoint(self._unit, end_time)
			end
		end)
	end

	if RequiredScript == "lib/units/enemies/cop/copbrain" then
		-- as host, answered pager
		Hooks:PostHook(CopBrain, "on_alarm_pager_interaction", "pager_timer_2", function(self, status, ...)
			if not managers.groupai:state():whisper_mode() then
				return
			end
			if status == "started" or status == "complete" then
				remove_pager_waypoint(self._unit)
			end
		end)
	end

	if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
		-- as client, answered pager
		Hooks:PostHook(UnitNetworkHandler, "interaction_set_active", "pager_timer_3", function(self, unit, u_id, active, tweak_data, flash, sender, ...)
			if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_sender(sender) then
				if tweak_data == "corpse_alarm_pager" then
					if not alive(unit) then
						local u_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
						unit = u_data and u_data.unit
					end

					if alive(unit) then
						if not active then
							remove_pager_waypoint(unit)
						elseif not flash then
							remove_pager_waypoint(unit)
						end
					end
				end
			end
		end)

		Hooks:PostHook(UnitNetworkHandler, "alarm_pager_interaction", "pager_timer_4", function(self, u_id, tweak_table, status, sender, ...)
			if self._verify_gamestate(self._gamestate_filter.any_ingame) then
				local unit_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
				if unit_data and unit_data.unit and unit_data.unit:interaction() and unit_data.unit:interaction():active() and unit_data.unit:interaction().tweak_data == tweak_table and self._verify_sender(sender) then
					if status == 1 then
						remove_pager_waypoint(unit_data.unit)
					else
						remove_pager_waypoint(unit_data.unit)
					end
				end
			end
		end)
	end

	if RequiredScript == "lib/utils/accelbyte/telemetry" then
		-- if timer still countdown when heist end, will crash the game, need to remove all waypoint before heist end
		Hooks:PreHook(Telemetry, "on_end_heist", "pager_timer_5", function(self)
			managers.hud:clear_waypoints()
		end)
	end
end

if RequiredScript == "lib/managers/votemanager" then
	-- instant restart
	Hooks:PostHook(VoteManager, "_restart_counter", "instant_restart", function(self, ...)
		if Network:is_server() then
			self._callback_counter = 0
		end
	end)
end

if RequiredScript == "lib/states/missionendstate" then
	-- skip xp screen
	Hooks:OverrideFunction(MissionEndState, "_continue_blocked", function(...)
		return false
	end)

	Hooks:PostHook(MissionEndState, "setup_controller", "skip_xp_screen_1", function(self, ...)
		self._completion_bonus_done = true
		self._continue_block_timer = nil
	end)

	Hooks:PostHook(MissionEndState, "completion_bonus_done", "skip_xp_screen_2", function(self, ...)
		self._completion_bonus_done = true
	end)

	Hooks:PostHook(StageEndScreenGui, "update", "skip_xp_screen_3", function(self, ...)
		if not self._button_not_clickable and game_state_machine and game_state_machine:current_state() and game_state_machine:current_state()._continue_cb and not (game_state_machine:current_state()._continue_blocked and game_state_machine:current_state():_continue_blocked()) then
			managers.menu_component:post_event("menu_enter")
			game_state_machine:current_state()._continue_cb()
		end
	end)

	Hooks:PostHook(StageEndScreenGui, "init", "speedup_xp_screen", function(self, ...)
		if self._enabled and managers.hud then
			managers.hud:set_speed_up_endscreen_hud(5)
		end
	end)
end

if RequiredScript == "lib/managers/menu/lootdropscreengui" then
	-- auto card picker
	auto_card_picker = nil
	Hooks:PostHook(LootDropScreenGui, "update", "auto_card_picker", function(self, ...)
		if not auto_card_picker then
			auto_card_picker = true
			DelayedCalls:Add("auto_card_picker", 1, function()
				if not self._card_chosen then
					self:_set_selected_and_sync(math.random(3))
					self:confirm_pressed()
				end
				auto_card_picker = nil
			end)
			if not self._button_not_clickable then
				self:continue_to_lobby()
			end
		end
	end)
end

if RequiredScript == "lib/units/beings/player/states/playerstandard" or RequiredScript == "lib/units/beings/player/states/playercivilian" or RequiredScript == "lib/units/beings/player/states/playermaskoff" then
	-- press to hold

	local function check_input(self, input)
		if self._interact_params and self._interact_params.locked then
			if input["btn_use_item_press"] then -- use the equipment key (default 'G') to toggle off active interactions
				input.btn_interact_press = nil
				input.btn_interact_release = true
			elseif input.btn_interact_release then
				input.btn_interact_release = nil
			end
		end
	end

	local function check_interaction_locked_data(self, t)
		local tweak_data = self._interact_params and self._interact_params.tweak_data or ""
		if tweak_data == "corpse_alarm_pager" or string.match(tweak_data, "pick_lock") then
			self._interact_params.lock_t = t
			self._interact_params.locked = true
		end
	end

	local function check_interaction_locked(self, t)
		if self._interact_params and self._interact_params.lock_t and not self._interact_params.locked then
			if t >= self._interact_params.lock_t then
				self._interact_params.locked = true
			end
		end
	end

	if RequiredScript == "lib/units/beings/player/states/playerstandard" then
		Hooks:PreHook(PlayerStandard, "_check_action_interact", "press_to_hold_1", function(self, t, input, ...)
			check_input(self, input)
		end)

		Hooks:PostHook(PlayerStandard, "_start_action_interact", "press_to_hold_2", function(self, t, ...)
			check_interaction_locked_data(self, t)
		end)

		Hooks:PreHook(PlayerStandard, "_update_interaction_timers", "press_to_hold_3", function(self, t, ...)
			check_interaction_locked(self, t)
		end)
	end

	if RequiredScript == "lib/units/beings/player/states/playercivilian" then
		Hooks:PreHook(PlayerCivilian, "_check_action_interact", "press_to_hold_4", function(self, t, input, ...)
			check_input(self, input)
		end)

		Hooks:PostHook(PlayerCivilian, "_start_action_interact", "press_to_hold_5", function(self, t, ...)
			check_interaction_locked_data(self, t)
		end)

		Hooks:PreHook(PlayerCivilian, "_update_interaction_timers", "press_to_hold_6", function(self, t, ...)
			check_interaction_locked(self, t)
		end)
	end

	if RequiredScript == "lib/units/beings/player/states/playermaskoff" then
		Hooks:PreHook(PlayerMaskOff, "_check_action_interact", "press_to_hold_7", function(self, t, input, ...)
			check_input(self, input)
		end)

		Hooks:PostHook(PlayerMaskOff, "_start_action_interact", "press_to_hold_8", function(self, t, ...)
			check_interaction_locked_data(self, t)
		end)
	end
end

if RequiredScript == "lib/managers/objectinteractionmanager" then
	-- hold to pick small loot
	Hooks:PostHook(ObjectInteractionManager, "_update_targeted", "hold_to_pick_small_loot", function(self, player_pos, player_unit, ...)
		if alive(self._active_unit) and not self._active_object_locked_data and self._active_unit:base() and self._active_unit:base().small_loot and alive(player_unit) and managers.menu:get_controller():get_input_bool("interact") then
			self:interact(player_unit)
		end
	end)
end

if RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
	-- disable ecm feedback in stealth
	orig_ECMJammerInteractionExt_can_interact = orig_ECMJammerInteractionExt_can_interact or ECMJammerInteractionExt.can_interact
	function ECMJammerInteractionExt:can_interact(...)
		if managers.groupai and managers.groupai:state() and managers.groupai:state():whisper_mode() then
			return false
		end
		return orig_ECMJammerInteractionExt_can_interact(self, ...)
	end

	orig_ECMJammerInteractionExt_can_select = orig_ECMJammerInteractionExt_can_select or ECMJammerInteractionExt.can_select
	function ECMJammerInteractionExt:can_select(...)
		if managers.groupai and managers.groupai:state() and managers.groupai:state():whisper_mode() then
			return false
		end
		return orig_ECMJammerInteractionExt_can_select(self, ...)
	end
end

if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
	-- change the icon and color of downed civilians
	Hooks:PostHook(GroupAIStateBase, "_upd_criminal_suspicion_progress", "downed_civilians_icon", function(self, ...)
		if self._ai_enabled then
			for obs_key, obs_susp_data in pairs(self._suspicion_hud_data or {}) do
				local unit = obs_susp_data.u_observer
				if managers.enemy:is_civilian(unit) then
					local waypoint = managers.hud._hud.waypoints["susp1" .. tostring(obs_key)]
					if waypoint then
						local color, arrow_color
						if unit:anim_data().drop then
							if not obs_susp_data._subdued_civ then
								obs_susp_data._alerted_civ = nil
								obs_susp_data._subdued_civ = true
								color = Color(0, 0.71, 1)
								arrow_color = Color(0, 0.35, 0.5)
								waypoint.bitmap:set_image("guis/textures/menu_singletick")
							end
						elseif obs_susp_data.alerted then
							if not obs_susp_data._alerted_civ then
								obs_susp_data._subdued_civ = nil
								obs_susp_data._alerted_civ = true
								color = Color.white
								arrow_color = tweak_data.hud.detected_color
								waypoint.bitmap:set_image("guis/textures/hud_icons")
								waypoint.bitmap:set_texture_rect(479, 433, 32, 32)
							end
						end
						if color and arrow_color then
							waypoint.bitmap:set_color(color)
							waypoint.arrow:set_color(arrow_color:with_alpha(0.75))
						end
					end
				end
			end
		end
	end)
end

if RequiredScript == "lib/managers/menumanager" then
	-- dlc buy removal
	Hooks:OverrideFunction(MenuCallbackHandler, "visible_callback_dlc_buy_win32", function(self) end)

	-- offline chat
	Hooks:OverrideFunction(MenuManager, "toggle_chatinput", function(self)
		if Application:editor() or SystemInfo:platform() ~= Idstring("WIN32") or self:active_menu() or not managers.network:session() then
			return
		end
		if managers.hud then
			managers.hud:toggle_chatinput()
			return true
		end
	end)
end

if RequiredScript == "lib/managers/menu/menucomponentmanager" then
	-- dlc buy removal
	Hooks:OverrideFunction(MenuComponentManager, "create_new_heists_gui", function(self)
		self:close_new_heists_gui()
	end)
	Hooks:OverrideFunction(MenuComponentManager, "create_newsfeed_gui", function(self)
		self:close_newsfeed_gui()
	end)
end

if RequiredScript == "lib/managers/menu/blackmarketgui" then
	-- show weapon name in inventory boxes
	Hooks:PreHook(BlackMarketGuiSlotItem, "init", "show_weapon_name", function(self, main_panel, data, ...)
		data.custom_name_text = data.custom_name_text or not data.empty_slot and data.name_localized
	end)

	-- put ghost icon behind silent weapon names, always enable mod mini icons
	Hooks:PostHook(BlackMarketGui, "populate_weapon_category_new", "put_ghost_icon", function(self, data, ...)
		for id, weapon_data in ipairs(data) do
			if tweak_data.weapon[weapon_data.name] then -- filter out locked or empty slots
				local categories = tweak_data.weapon[weapon_data.name].categories
				local is_saw = table.contains(categories, "saw")
				local has_silencer = table.contains(categories, "bow") or table.contains(categories, "crossbow")
				local has_explosive = false
				for id, i_data in pairs(weapon_data.mini_icons) do -- handle silent motor saw
					if i_data.alpha == 1 then -- icon enabled
						if i_data.texture == "guis/textures/pd2/blackmarket/inv_mod_silencer" then
							has_silencer = true
						elseif i_data.texture == "guis/textures/pd2/blackmarket/inv_mod_ammo_explosive" then
							has_explosive = true
						end
					end
				end
				local silent = has_silencer and not has_explosive
				weapon_data.name_localized = tostring(weapon_data.name_localized) .. (not is_saw and (" " .. (silent and utf8.char(57363) or "")) or "")
				weapon_data.hide_unselected_mini_icons = false
			end
		end
	end)

	Hooks:PreHook(BlackMarketGuiItem, "select", "highlight_selected_weapon_1", function(self, instant, ...)
		self._is_selected = true
		self:set_highlight(true, instant)
	end)

	Hooks:PreHook(BlackMarketGuiItem, "deselect", "highlight_selected_weapon_2", function(self, instant, ...)
		self._is_selected = false
		self:set_highlight(false, instant)
	end)

	Hooks:PostHook(BlackMarketGuiSlotItem, "set_highlight", "highlight_selected_weapon_3", function(self, highlight, ...)
		if highlight or self._is_selected or self._data.equipped then
			local name_text = self._panel:child("custom_name_text")
			if name_text then
				name_text:set_alpha(1)
			end
			if self._mini_panel then
				self._mini_panel:set_alpha(1)
			end
		else
			local name_text = self._panel:child("custom_name_text")
			if name_text then
				name_text:set_alpha(0.5)
			end
			if self._mini_panel then
				self._mini_panel:set_alpha(0.4)
			end
		end
	end)
end
