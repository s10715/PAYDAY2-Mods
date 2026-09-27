local enable = false -- set true to enable replace enemy
local replace_unit_name = "cloaker" -- change the name of unit you want to replace with

---------------------------------------------------------------------------


if not enable or Network:is_client() then
	return
end

local all_units_idstring = {
	guard = {
		Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
		Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
		Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
		Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"),
		Idstring("units/payday2/characters/ene_security_1/ene_security_1"),
		Idstring("units/payday2/characters/ene_security_2/ene_security_2"),
		Idstring("units/payday2/characters/ene_security_3/ene_security_3"),
		Idstring("units/payday2/characters/ene_security_4/ene_security_4"),
		Idstring("units/payday2/characters/ene_security_5/ene_security_5"),
		Idstring("units/payday2/characters/ene_security_6/ene_security_6"),
		Idstring("units/payday2/characters/ene_security_7/ene_security_7"),
		Idstring("units/payday2/characters/ene_security_8/ene_security_8"),
		Idstring("units/pd2_dlc1/characters/ene_security_gensec_1/ene_security_gensec_1"),
		Idstring("units/pd2_dlc1/characters/ene_security_gensec_2/ene_security_gensec_2"),
		Idstring("units/pd2_dlc_arena/characters/ene_guard_security_heavy_1/ene_guard_security_heavy_1"),
		Idstring("units/pd2_dlc_arena/characters/ene_guard_security_heavy_2/ene_guard_security_heavy_2"),
		Idstring("units/payday2/characters/ene_secret_service_1/ene_secret_service_1"),
		Idstring("units/payday2/characters/ene_secret_service_2/ene_secret_service_2"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
		Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
		Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
		Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
		Idstring("units/payday2/characters/ene_fbi_female_1/ene_fbi_female_1"),
		Idstring("units/payday2/characters/ene_fbi_female_2/ene_fbi_female_2"),
		Idstring("units/payday2/characters/ene_fbi_female_3/ene_fbi_female_3"),
		Idstring("units/payday2/characters/ene_fbi_female_4/ene_fbi_female_4")
	},
	swat = {
		Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"),
		Idstring("units/payday2/characters/ene_swat_2/ene_swat_2"),
		Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"),
		Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
		Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
		Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
		Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),
		Idstring("units/payday2/characters/ene_sm_heavy_g36/ene_sm_heavy_g36"),
		Idstring("units/payday2/characters/ene_sm_heavy_r870/ene_sm_heavy_r870"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"),
		Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
		Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2"),
		Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
		Idstring("units/payday2/characters/ene_sm_swat_1/ene_sm_swat_1"),
		Idstring("units/payday2/characters/ene_sm_swat_r870/ene_sm_swat_r870"),
		Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36"),
		Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy")
	},
	sniper = {
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_sniper/ene_murkywater_sniper"),
		Idstring("units/payday2/characters/ene_sniper_1/ene_sniper_1"),
		Idstring("units/payday2/characters/ene_sniper_2/ene_sniper_2"),
		Idstring("units/pd2_dlc_spa/characters/ene_sniper_3/ene_sniper_3"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_sniper_svd_snp/ene_akan_cs_swat_sniper_svd_snp"),
		Idstring("units/pd2_dlc_drm/characters/ene_zeal_swat_heavy_sniper/ene_zeal_swat_heavy_sniper"),
		Idstring("units/pd2_dlc_hvh/characters/ene_sniper_hvh_2/ene_sniper_hvh_2"),
		Idstring("units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_1/ene_male_marshal_marksman_1"),
		Idstring("units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_2/ene_male_marshal_marksman_2")
	},
	shield = {
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield"),
		Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
		Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield"),
		Idstring("units/pd2_dlc_mad/characters/ene_acc_shield_akan/ene_acc_shield_akan"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_dw_sr2_smg/ene_akan_fbi_shield_dw_sr2_smg"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45"),
		Idstring("units/payday2/characters/ene_city_shield/ene_city_shield"),
		Idstring("units/payday2/characters/ene_sm_shield/ene_sm_shield"),
		Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1"),
		Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2")
	},
	marshal = {
		Idstring("units/pd2_dlc_usm2/characters/ene_male_marshal_shield_1/ene_male_marshal_shield_1"),
		Idstring("units/pd2_dlc_usm2/characters/ene_male_marshal_shield_2/ene_male_marshal_shield_2")
	},
	medic = {
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870"),
		Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4"),
		Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass/ene_akan_medic_ak47_ass"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870"),
		Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4")
	},
	taser = {
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer"),
		Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer"),
		Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1")
	},
	cloaker = {
		Idstring("units/payday2/characters/ene_spook_1/ene_spook_1"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker"),
		Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_1/ene_shadow_cloaker_1"),
		Idstring("units/pd2_dlc_hvh/characters/ene_spook_hvh_1/ene_spook_hvh_1")
	},
	dozer = {
		Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
		Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
		Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
		Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun"),
		Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun"),
		Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
		Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic"),
		Idstring("units/pd2_dlc_help/characters/ene_zeal_bulldozer_halloween/ene_zeal_bulldozer_halloween"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga")
	},
	captain = {
		Idstring("units/pd2_dlc_wwh/characters/ene_captain/ene_captain"),
		Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
	}
}

-- if you spawn a unit that isn't loaded in current heist, it will crash the game
local function unit_is_allowed(unit_idstring)
	for _,unit in pairs(PackageManager:all_loaded_unit_data()) do
		if unit:name() == unit_idstring then return true end
	end
	return false
end

local function get_replace_unit_idstrings(name)
	local replace_unit_idstrings = {}
	for _,unit_idstring in pairs(all_units_idstring[name] or {}) do
		if unit_is_allowed(unit_idstring) then
			table.insert(replace_unit_idstrings, unit_idstring)
		end
	end
	return replace_unit_idstrings
end

local replace_unit_idstrings = get_replace_unit_idstrings(replace_unit_name)

if next(replace_unit_idstrings) ~= nil then
	Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "Replace_All_Spawning_Units", function(self, difficulty_index, ...)
		for k, v in pairs(self.unit_categories or {}) do
			-- won't replace captain winters
			if v.unit_types and v.unit_types.america and v.unit_types.russia and v.unit_types.murkywater and k ~= "Phalanx_vip" and k ~= "Phalanx_minion" then
				self.unit_categories[k].unit_types.america = replace_unit_idstrings
				self.unit_categories[k].unit_types.russia = replace_unit_idstrings
				self.unit_categories[k].unit_types.murkywater = replace_unit_idstrings
			end
		end
	end)
end
