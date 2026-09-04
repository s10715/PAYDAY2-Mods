global_autoheal_toggle = not global_autoheal_toggle


local function trigger_berserker()
	if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier") then
		local player_unit = managers.player:player_unit()
		local character_damage = player_unit:character_damage()
		local armor_broken = character_damage:_max_armor() > 0 and character_damage:get_real_armor() <= 0
		character_damage:damage_killzone({
			ignore_suppression = true,
			range = 1000,
			attacker_unit = player_unit,
			damage = armor_broken and character_damage:get_real_health()-0.1 or character_damage:_max_armor(),
			variant = "killzone",
			col_ray = {
				position = player_unit:position()
			},
			push_vel = Vector3()
		})
	end
end

-- auto heal
down_counter = down_counter or 0
orig_PlayerDamage__check_bleed_out = orig_PlayerDamage__check_bleed_out or PlayerDamage._check_bleed_out
function PlayerDamage:_check_bleed_out(...)
	if global_autoheal_toggle and self:get_real_health() == 0 then 
		if managers.player and managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier") then
			-- set health to 1% if you have berserker skill
			--self:change_health(self:_max_health() * self._healing_reduction / 100)
			trigger_berserker()
			self:_send_set_health()
			-- start regenerate armor process
			-- self:_on_damage_event()
			-- regenerate armor instantly
			self:set_armor(self:_max_armor())
			self:_send_set_armor()
		else
			-- or else fully health yourself
			self:band_aid_health()
		end
		if self._unit and alive(self._unit) and self._unit:movement() and self._unit:movement():current_state_name() == "jerry1" and managers and managers.player then
			managers.player:set_player_state('jerry2') -- end parachuting state
			-- self._unit:base():replenish()
		end
		down_counter = down_counter +1
		managers.chat:_receive_message(1, "host", "down: " .. tostring(down_counter) .. " times", Color.green)
	end
	return orig_PlayerDamage__check_bleed_out(self, ...)
end


--[[
-- multiply damage
orig_RaycastWeaponBase__get_current_damage = orig_RaycastWeaponBase__get_current_damage or RaycastWeaponBase._get_current_damage
function RaycastWeaponBase:_get_current_damage(...)
	if global_autoheal_toggle then
		return orig_RaycastWeaponBase__get_current_damage(self, ...) * 2 -- 2x damage
	else
		return orig_RaycastWeaponBase__get_current_damage(self, ...)
	end
end
]]--


-- remove screen shake effect when get hit
orig_PlayerCamera_play_shaker = orig_PlayerCamera_play_shaker or PlayerCamera.play_shaker
function PlayerCamera:play_shaker(...)
	if global_autoheal_toggle then
		return
	else
		return orig_PlayerCamera_play_shaker(self, ...)
	end
end

-- removes red screen effect on health damage
orig_PlayerDamage__set_health_effect = orig_PlayerDamage__set_health_effect or PlayerDamage._set_health_effect
function PlayerDamage:_set_health_effect()
	if global_autoheal_toggle then
		return
	else
		return orig_PlayerDamage__set_health_effect(self)
	end
end

-- removes grey screen when you are on your last down
orig_CoreEnvironmentControllerManager_set_post_composite = orig_CoreEnvironmentControllerManager_set_post_composite or CoreEnvironmentControllerManager.set_post_composite
function CoreEnvironmentControllerManager:set_post_composite(...)
	if global_autoheal_toggle then
		self._last_life = false
	end
	return orig_CoreEnvironmentControllerManager_set_post_composite(self, ...)
end

-- remove the blur when get close to the meth lab, you should trigger this code before go to the lab
orig_ElementBlurZone_on_executed = orig_ElementBlurZone_on_executed or ElementBlurZone.on_executed
function ElementBlurZone:on_executed(...)
	if global_autoheal_toggle then
		return
	else
		return orig_ElementBlurZone_on_executed(self, ...)
	end
end

-- remove criminal concussion grenades tinnitus effcet
orig_PlayerDamage_on_concussion = orig_PlayerDamage_on_concussion or PlayerDamage.on_concussion
function PlayerDamage:on_concussion(...)
	if global_autoheal_toggle then
		return
	else
		return orig_PlayerDamage_on_concussion(self, ...)
	end
end

-- remove criminal concussion grenade visual effects
orig_CoreEnvironmentControllerManager_set_concussion_grenade = orig_CoreEnvironmentControllerManager_set_concussion_grenade or CoreEnvironmentControllerManager.set_concussion_grenade
function CoreEnvironmentControllerManager:set_concussion_grenade(...)
	if global_autoheal_toggle then
		return
	else
		return orig_CoreEnvironmentControllerManager_set_concussion_grenade(self, ...)
	end
end

-- remove cop flashbang tinnitus effcet
orig_PlayerDamage_on_flashbanged = orig_PlayerDamage_on_flashbanged or PlayerDamage.on_flashbanged
function PlayerDamage:on_flashbanged(...)
	if global_autoheal_toggle then
		return
	else
		return orig_PlayerDamage_on_flashbanged(self, ...)
	end
end

-- remove flashbang visual effects
orig_CoreEnvironmentControllerManager_set_flashbang = orig_CoreEnvironmentControllerManager_set_flashbang or CoreEnvironmentControllerManager.set_flashbang
function CoreEnvironmentControllerManager:set_flashbang(...)
	if global_autoheal_toggle then
		return
	else
		return orig_CoreEnvironmentControllerManager_set_flashbang(self, ...)
	end
end

-- auto counter cloaker's SPOOC
orig_PlayerMovement_on_SPOOCed = orig_PlayerMovement_on_SPOOCed or PlayerMovement.on_SPOOCed
function PlayerMovement:on_SPOOCed(...)
	if global_autoheal_toggle then
		return "countered"
	else
		return orig_PlayerMovement_on_SPOOCed(self, ...)
	end
end

-- host only, for bots, auto counter cloaker's SPOOC
orig_TeamAIMovement_on_SPOOCed = orig_TeamAIMovement_on_SPOOCed or TeamAIMovement.on_SPOOCed
function TeamAIMovement:on_SPOOCed(...)
	if global_autoheal_toggle then
		return "countered"
	else
		return orig_TeamAIMovement_on_SPOOCed(self, ...)
	end
end

-- cloaker's SPOOC no longer force your camera to face them
orig_FPCameraPlayerBase_clbk_aim_assist = orig_FPCameraPlayerBase_clbk_aim_assist or FPCameraPlayerBase.clbk_aim_assist
function FPCameraPlayerBase:clbk_aim_assist(col_ray)
	if global_autoheal_toggle then
		if managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("aim_assist") then
			self:_start_aim_assist(col_ray, self._aim_assist)
		end
	else
		return orig_FPCameraPlayerBase_clbk_aim_assist(self, col_ray)
	end
end

-- host only, taser won't choose you as tase target
orig_PlayerMovement_is_taser_attack_allowed = orig_PlayerMovement_is_taser_attack_allowed or PlayerMovement.is_taser_attack_allowed
function PlayerMovement:is_taser_attack_allowed()
	if global_autoheal_toggle then
		return false
	else
		return orig_PlayerMovement_is_taser_attack_allowed(self)
	end
end

-- this can run as client, auto exit tase state in about 2 seconds after get tased by taser
orig_PlayerTased__on_tased_event = orig_PlayerTased__on_tased_event or PlayerTased._on_tased_event
function PlayerTased:_on_tased_event(...)
	orig_PlayerTased__on_tased_event(self, ...)
	if global_autoheal_toggle then
		-- self:give_shock_to_taser_no_damage() -- this will play sound and don't know how to stop it
		-- self:give_shock_to_taser()
		self:on_tase_ended()
	end
end

-- prevent get tase in Safe House Nightmare
orig_PlayerManager_set_player_state = orig_PlayerManager_set_player_state or PlayerManager.set_player_state
function PlayerManager:set_player_state(state)
	if global_autoheal_toggle and state == "tased" and Global.level_data and Global.level_data.level_id == "haunted" then
		return
	end
	return orig_PlayerManager_set_player_state(self, state)
end


-- always knockback when shooting at shield
orig_RaycastWeaponBase_chk_shield_knock = orig_RaycastWeaponBase_chk_shield_knock or RaycastWeaponBase.chk_shield_knock
function RaycastWeaponBase:chk_shield_knock(hit_unit, col_ray, ...)
	if global_autoheal_toggle then
		local enemy_unit = hit_unit.parent and hit_unit:parent()
		if not hit_unit:in_slot(self.shield_mask) or not enemy_unit or not alive(enemy_unit) or not enemy_unit.character_damage or not enemy_unit:character_damage() or not enemy_unit:character_damage().force_hurt then
			return false
		end
		enemy_unit:character_damage().is_immune_to_shield_knockback = enemy_unit:character_damage().is_immune_to_shield_knockback and function() return false end or nil -- allow all shield units to get knockback
		enemy_unit:character_damage():force_hurt({
			damage = 0,
			type = "shield_knock",
			variant = "melee",
			col_ray = col_ray,
			result = {
				variant = "melee",
				type = "shield_knock"
			}
		})
		return true
	else
		return orig_RaycastWeaponBase_chk_shield_knock(hit_unit, col_ray, ...)
	end
end


-- night vision for all masks
local function night_vision_for_all_masks()
	for k, v in pairs(tweak_data.blackmarket.masks) do
		if global_autoheal_toggle then
			v.night_vision = {
				effect = "color_night_vision",
				light = not _G.IS_VR and 0.3 or 0.1
			}
		else
			v.night_vision = nil
		end
	end
end
night_vision_for_all_masks()


if global_autoheal_toggle then
	managers.mission._fading_debug_output:script().log('Auto Heal - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Auto Heal - Deactivated',  Color.red)
end
