-- won't affect death sentence
-- difficulty level internal names are: normal, hard, overkill, overkill_145, easy_wish, overkill_290, sm_wish
if Global.game_settings and Global.game_settings.difficulty == "sm_wish" then
	return
end

global_hardmod_toggle = not global_hardmod_toggle

local DS_damages = {
	gangster = 67.5,
	biker = 65,
	mobster = 65,
	bolivian = 20,
	bolivian_indoors = 60,
	mobster_boss = 80,
	hector_boss = 75,
	chavez_boss = 30,
	biker_boss = 60,
	drug_lord_boss = 80,

	security = 65,
	gensec = 20,
	cop = 65,
	cop_female = 65,
	fbi = 65,
	fbi_swat =  67.5,
	fbi_heavy_swat = 225,
	swat = 67.5,
	heavy_swat = 225,
	zeal_swat = 67.5,
	zeal_heavy_swat = 225,
	city_swat = 67.5,
	sniper = 240,
	heavy_swat_sniper = 240,
	shield = 70,
	marshal_marksman = 70,
	marshal_shield = 70,
	medic = 60,
	taser = 195,
	spooc = 20,
	cloaker = 20,
	tank = 120,
	tank_medic = 20,
	tank_mini = 80,
	tank_hw = 120,
	phalanx_vip = 20,
	phalanx_minion = 20,
}


orig_PlayerDamage_damage_bullet = orig_PlayerDamage_damage_bullet or PlayerDamage.damage_bullet
global_PlayerDamage__down_time = global_PlayerDamage__down_time or nil
global_PlayerDamage__uppers_elapsed = global_PlayerDamage__uppers_elapsed or nil
function PlayerDamage:damage_bullet(attack_data)

	-- no down, once you die, you go to custoday
	if global_hardmod_toggle then
		if global_PlayerDamage__down_time == nil then
			global_PlayerDamage__down_time = self._down_time
		end
		if global_PlayerDamage__uppers_elapsed == nil then
			global_PlayerDamage__uppers_elapsed = self._uppers_elapsed
		end

		self._down_time = 0
		self._uppers_elapsed = math.huge
		managers.environment_controller:set_last_life(true)
	else
		if global_PlayerDamage__down_time then
			if global_PlayerDamage__down_time > 0 then
				managers.environment_controller:set_last_life(false)
			end
			self._down_time = global_PlayerDamage__down_time
			global_PlayerDamage__down_time = nil
		end
		if global_PlayerDamage__uppers_elapsed then
			self._uppers_elapsed = global_PlayerDamage__uppers_elapsed
			global_PlayerDamage__uppers_elapsed = nil
		end
	end

	if global_hardmod_toggle then
		local distance = mvector3.distance(self._unit:position(), attack_data.attacker_unit:position()) / 100
		local tweak_id = attack_data.attacker_unit and attack_data.attacker_unit.base and attack_data.attacker_unit:base()._tweak_table

		if tweak_id ~= nil and DS_damages[tweak_id] then
			-- hud damage divided by 10 is internal damage
			attack_data.damage = DS_damages[tweak_id] / 10
		else
			attack_data.damage = 225 / 10
		end

		--[[
		-- or you can simply set all damage to 225, except sniper
		if tweak_id == "sniper" then
			attack_data.damage = DS_damages[tweak_id] / 10
		else
			attack_data.damage = 225 / 10
		end
		]]--
	end

	return orig_PlayerDamage_damage_bullet(self, attack_data)
end

if global_hardmod_toggle then
	managers.mission._fading_debug_output:script().log('Death Sentence Damage - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Death Sentence Damage - Deactivated',  Color.red)
end
