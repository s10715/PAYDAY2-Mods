-- host only
if not Network:is_server() then
	return
end

local civilians_table = {
	"units/payday2/characters/civ_female_bank_1/civ_female_bank_1",
	"units/payday2/characters/civ_female_bank_manager_1/civ_female_bank_manager_1",
	"units/payday2/characters/civ_female_bikini_1/civ_female_bikini_1",
	"units/payday2/characters/civ_female_bikini_2/civ_female_bikini_2",
	"units/payday2/characters/civ_female_casual_1/civ_female_casual_1",
	"units/payday2/characters/civ_female_casual_2/civ_female_casual_2",
	"units/payday2/characters/civ_female_casual_3/civ_female_casual_3",
	"units/payday2/characters/civ_female_casual_4/civ_female_casual_4",
	"units/payday2/characters/civ_female_casual_5/civ_female_casual_5",
	"units/payday2/characters/civ_female_crackwhore_1/civ_female_crackwhore_1",
	"units/payday2/characters/civ_female_hostess_apron_1/civ_female_hostess_apron_1",
	"units/payday2/characters/civ_female_curator_1/civ_female_curator_1",
	"units/payday2/characters/civ_female_curator_2/civ_female_curator_2",
	"units/payday2/characters/civ_female_hostess_jacket_1/civ_female_hostess_jacket_1",
	"units/payday2/characters/civ_female_hostess_shirt_1/civ_female_hostess_shirt_1",
	"units/payday2/characters/civ_female_party_1/civ_female_party_1",
	"units/payday2/characters/civ_female_party_2/civ_female_party_2",
	"units/payday2/characters/civ_female_party_3/civ_female_party_3",
	"units/payday2/characters/civ_female_party_4/civ_female_party_4",
	"units/payday2/characters/civ_female_wife_trophy_1/civ_female_wife_trophy_1",
	"units/payday2/characters/civ_female_wife_trophy_2/civ_female_wife_trophy_2",
	"units/payday2/characters/civ_male_bank_1/civ_male_bank_1",
	"units/payday2/characters/civ_male_bank_2/civ_male_bank_2",
	"units/payday2/characters/civ_male_bank_manager_1/civ_male_bank_manager_1",
	"units/payday2/characters/civ_male_business_1/civ_male_business_1",
	"units/payday2/characters/civ_male_business_2/civ_male_business_2",
	"units/payday2/characters/civ_male_casual_1/civ_male_casual_1",
	"units/payday2/characters/civ_male_casual_2/civ_male_casual_2",
	"units/payday2/characters/civ_male_casual_3/civ_male_casual_3",
	"units/payday2/characters/civ_male_casual_4/civ_male_casual_4",
	"units/payday2/characters/civ_male_casual_5/civ_male_casual_5",
	"units/payday2/characters/civ_male_casual_6/civ_male_casual_6",
	"units/payday2/characters/civ_male_casual_7/civ_male_casual_7",
	"units/payday2/characters/civ_male_casual_8/civ_male_casual_8",
	"units/payday2/characters/civ_male_casual_9/civ_male_casual_9",
	"units/payday2/characters/civ_male_dj_1/civ_male_dj_1",
	"units/payday2/characters/civ_male_italian_robe_1/civ_male_italian_robe_1",
	"units/payday2/characters/civ_male_janitor_1/civ_male_janitor_1",
	"units/payday2/characters/civ_male_meth_cook_1/civ_male_meth_cook_1",
	"units/payday2/characters/civ_male_party_1/civ_male_party_1",
	"units/payday2/characters/civ_male_party_2/civ_male_party_2",
	"units/payday2/characters/civ_male_party_3/civ_male_party_3",
	"units/payday2/characters/civ_male_scientist_1/civ_male_scientist_1",
	"units/payday2/characters/civ_male_trucker_1/civ_male_trucker_1",
	"units/payday2/characters/civ_male_worker_docks_1/civ_male_worker_docks_1",
	"units/payday2/characters/civ_male_worker_docks_2/civ_male_worker_docks_2",
	"units/payday2/characters/civ_male_worker_docks_3/civ_male_worker_docks_3"
}

local enemies_table = {
	"units/payday2/characters/ene_biker_1/ene_biker_1",
	"units/payday2/characters/ene_biker_2/ene_biker_2",
	"units/payday2/characters/ene_biker_3/ene_biker_3",
	"units/payday2/characters/ene_biker_4/ene_biker_4",
	"units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1",
	"units/payday2/characters/ene_cop_1/ene_cop_1",
	"units/payday2/characters/ene_cop_2/ene_cop_2",
	"units/payday2/characters/ene_cop_3/ene_cop_3",
	"units/payday2/characters/ene_cop_4/ene_cop_4",
	"units/payday2/characters/ene_fbi_1/ene_fbi_1",
	"units/payday2/characters/ene_fbi_2/ene_fbi_2",
	"units/payday2/characters/ene_fbi_3/ene_fbi_3",
	"units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1",
	"units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1",
	"units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2",
	"units/payday2/characters/ene_gang_black_1/ene_gang_black_1",
	"units/payday2/characters/ene_gang_black_2/ene_gang_black_2",
	"units/payday2/characters/ene_gang_black_3/ene_gang_black_3",
	"units/payday2/characters/ene_gang_black_4/ene_gang_black_4",
	"units/payday2/characters/ene_gang_mexican_1/ene_gang_mexican_1",
	"units/payday2/characters/ene_gang_mexican_2/ene_gang_mexican_2",
	"units/payday2/characters/ene_gang_mexican_3/ene_gang_mexican_3",
	"units/payday2/characters/ene_gang_mexican_4/ene_gang_mexican_4",
	"units/payday2/characters/ene_gang_russian_1/ene_gang_russian_1",
	"units/payday2/characters/ene_gang_russian_2/ene_gang_russian_2",
	"units/payday2/characters/ene_gang_russian_3/ene_gang_russian_3",
	"units/payday2/characters/ene_gang_russian_4/ene_gang_russian_4",
	"units/payday2/characters/ene_gang_russian_5/ene_gang_russian_5",
	"units/payday2/characters/ene_secret_service_1/ene_secret_service_1",
	"units/payday2/characters/ene_secret_service_2/ene_secret_service_2",
	"units/payday2/characters/ene_security_1/ene_security_1",
	"units/payday2/characters/ene_security_2/ene_security_2",
	"units/payday2/characters/ene_security_3/ene_security_3",
	"units/payday2/characters/ene_shield_1/ene_shield_1",
	"units/payday2/characters/ene_shield_2/ene_shield_2",
	"units/payday2/characters/ene_sniper_1/ene_sniper_1",
	"units/payday2/characters/ene_sniper_2/ene_sniper_2",
	"units/payday2/characters/ene_spook_1/ene_spook_1",
	"units/payday2/characters/ene_swat_1/ene_swat_1",
	"units/payday2/characters/ene_swat_2/ene_swat_2",
	"units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1",
	"units/payday2/characters/ene_tazer_1/ene_tazer_1",
	"units/payday2/characters/ene_biker_escape/ene_biker_escape",
	"units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1",
	"units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2",
	"units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3",
	"units/payday2/characters/ene_medic_m4/ene_medic_m4",
	"units/payday2/characters/ene_medic_r870/ene_medic_r870",
	"units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic",
	"units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun",
	"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2",
	"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3",
	"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer",
	"units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield"
}

global_spawned_unit = global_spawned_unit or {}


-- if you spawn a unit that isn't loaded in current heist, it will crash the game
local function unit_is_allowed(unit_idstring)
	for _,unit in pairs(PackageManager:all_loaded_unit_data()) do
		if unit:name() == unit_idstring then return true end
	end
	return false
end

-- spawn unit, if the unit_id isn't loaded in current heist, do nothing and return nil
local function spawn_unit(unit_idstring)
	if not unit_is_allowed(unit_idstring) then return nil end

	if not managers.player:player_unit() then return nil end
	local spawn_pos = managers.player:player_unit():position()
	local spawn_rot = managers.player:player_unit():rotation()
	-- try to get crosshair position
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 10000
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then spawn_pos  = ray.position end

	local unit = World:spawn_unit(unit_idstring, spawn_pos, spawn_rot)
	if not unit then return nil end

	local team_id = tweak_data.levels:get_default_team_ID("combatant") -- player, combatant, non_combatant, gangster, set non_combatant then they won't attack you
	unit:movement():set_team(managers.groupai:state():team_data(team_id))

	unit:movement():set_character_anim_variables()
	unit:set_active(true)
	managers.network:session():send_to_peers_synched("set_unit", unit, "random", "", 0)

	table.insert(global_spawned_unit, unit)
	return unit
end

-- give animation to the unit, animation just play once, won't loop
local function give_anim_to_unit(unit, anim)
	if CopActionAct and CopActionAct:_get_act_index(anim) and unit and unit.brain and unit:brain() then
		local anim = anim
		local action_data = { type = "act", body_part = 1, variant = anim, align_sync = true }
		if unit:brain() then
			unit:brain():action_request(action_data)
		end
	end
end

-- remove all the unit spawned before, and clear all the corpses in case some unit is dead and can't remove
local function remove_spawned_unit()
	for _, unit in pairs(global_spawned_unit) do
		if alive(unit) then
			World:delete_unit(unit)
		end
		if alive(unit) then
			unit:set_slot(0)
		end
	end
	managers.enemy:dispose_all_corpses()
	global_spawned_unit = {}
end

-- utils function
local function get_random_value(arr)
	local len = 0
	for _,v in pairs(arr) do
		len = len + 1
	end
	local random_num = math.modf(math.random(1, len))
	local i = 0
	for _,v in pairs(arr) do
		i = i + 1
		if i == random_num then
			return v
		end
	end
end

-- spawn random civilian, and give him random entering animation
local function random_spawn_civilian()
	local unit = spawn_unit(Idstring(get_random_value(civilians_table)))
	if not unit then
		local temp_ud = get_random_value(managers.enemy:all_civilians())
		if temp_ud then unit = spawn_unit(temp_ud.unit:name()) end
	end
	if unit then
		give_anim_to_unit(unit, get_random_value(CopActionAct._act_redirects.civilian_spawn))
		managers.mission._fading_debug_output:script().log("Spawn Civilian",  Color.yellow)
	end
end

-- spawn random enemy, and give him random entering animation
local function random_spawn_enemy()
	local unit = spawn_unit(Idstring(get_random_value(enemies_table)))
	if not unit then
		local temp_ud = get_random_value(managers.enemy:all_enemies())
		if temp_ud then unit = spawn_unit(temp_ud.unit:name()) end
	end
	if unit then
		give_anim_to_unit(unit, get_random_value(CopActionAct._act_redirects.enemy_spawn))
		managers.mission._fading_debug_output:script().log("Spawn Enemy",  Color.yellow)
	end
end

if #global_spawned_unit > 20 then
	remove_spawned_unit()
end




-- spawn_unit(Idstring("units/payday2/characters/civ_female_casual_1/civ_female_casual_1"))

-- might need to try a few more times, you can't spawn a unit that isn't loaded in current heist, if this random unit isn't loaded, do nothing
local if_spawn_enemy_in_stealth = true
if math.fmod(math.random(10), 2) == 0 then
	random_spawn_civilian()
else
	if not if_spawn_enemy_in_stealth and managers.groupai:state():whisper_mode() then
		random_spawn_civilian()
	else
		random_spawn_enemy()
	end
end

