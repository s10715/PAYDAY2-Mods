global_dmg_reflect_toggle = not global_dmg_reflect_toggle 

local reflection_damage_percent = 25	--higher = higher unit dmg%
local reflection_damage_special_percent = 50	--higher = higher unit dmg%
local unit_table = {"spooc","taser","cloaker","shield","tank","tank_mini","tank_medic","tank_hw","piggydozer","sniper","heavy_swat_sniper","gangster","cop","cop_female","security","medic","gensec","swat","heavy_swat","zeal_swat","zeal_heavy_swat","fbi","fbi_swat","fbi_heavy_swat","marshal_marksman","marshal_shield","city_swat","mobster_boss","mobster","hector_boss","hector_boss_no_armor","biker_boss","chavez_boss","biker","bolivian","bolivian_indoors_mex","bolivians","phalanx_vip","phalanx_minion","shadow_spooc","drug_lord_boss","drug_lord_boss_stealth","drunk_pilot","spa_vip","spa_vip_hurt","captain","captain_female","civilian_mariachi","mute_security_undominatable","security_undominatable","escort","escort_criminal","escort_undercover","triad","triad_boss","deep_boss","snowman_boss","biker_escape"}


local function check_is_enemy(check_unit)
	local all_enemies = managers.enemy:all_enemies()
	for _,data in pairs(all_enemies or {}) do
		local unit = data and data.unit
		if check_unit == unit then
			return true
		end
	end
	return false
end

local function reflect_enemy_damage(attack_data)
	local attacker_unit = attack_data.attacker_unit
	local attacker_unit_dmg = attack_data.damage
	if not attacker_unit or not alive(attacker_unit) or not attacker_unit_dmg or not check_is_enemy(attacker_unit) then
		return false
	end

	local enemy_name = attacker_unit:base()._tweak_table
	for _,v in pairs(unit_table) do
		if v == enemy_name then
			local reflect_damage = 0
			if tweak_data.character[enemy_name] and tweak_data.character[enemy_name].tags and tweak_data.character[enemy_name].tags[3] and (tweak_data.character[enemy_name].tags[3] == "special") then
				reflect_damage = (attacker_unit_dmg * reflection_damage_special_percent) / 100
			else
				reflect_damage = (attacker_unit_dmg * reflection_damage_percent) / 100
			end
			local action_data = {
				damage = reflect_damage,
				attacker_unit = managers.player:player_unit(),
				attack_dir = Vector3(0,0,0),
				variant = "melee", 
				name_id = 'cqc',
				col_ray = {
					position = attacker_unit:position(),
					body = attacker_unit:body("body"),
				}
			}
			attacker_unit:character_damage():damage_melee(action_data)
			return true
		end
	end
	return false
end


local function check_is_turret(check_unit)
	return check_unit and check_unit:in_slot(managers.slot:get_mask("sentry_gun"))
end

local function reflect_turret_damage(attack_data)
	local attacker_unit = attack_data.attacker_unit
	local attacker_unit_dmg = attack_data.damage
	if not attacker_unit or not alive(attacker_unit) or not attacker_unit_dmg or not check_is_turret(attacker_unit) then
		return false
	end

	local reflect_damage = (attacker_unit_dmg * reflection_damage_special_percent) / 100
	local action_data = {
		damage = reflect_damage,
		attacker_unit = managers.player:player_unit(),
		attack_dir = Vector3(0,0,0),
		variant = "explosion",
		name_id = 'bm_w_ray',
		col_ray = {
			position = attacker_unit:position(),
			body = attacker_unit:body("body"),
		}
	}
	attacker_unit:character_damage():damage_explosion(action_data)
	return true
end

orig_PlayerDamage_damage_bullet = orig_PlayerDamage_damage_bullet or PlayerDamage.damage_bullet
function PlayerDamage.damage_bullet(self, attack_data)
	local result = nil
	if global_dmg_reflect_toggle then	
		result = reflect_enemy_damage(attack_data) or reflect_turret_damage(attack_data)
	end
	if not result then
		return orig_PlayerDamage_damage_bullet(self, attack_data)
	end
end

if global_dmg_reflect_toggle then
	managers.mission._fading_debug_output:script().log('Reflect Enemy Damage - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Reflect Enemy Damage - Deactivated',  Color.red)
end
