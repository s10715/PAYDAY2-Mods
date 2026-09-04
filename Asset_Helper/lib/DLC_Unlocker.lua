local unlock_all_dlcs = false
local unlock_characters = false
local unlock_heists = false
local unlock_community_items = false -- unlock twitch drops, starbreeze account rewards, events masks

local character_list = {
	"character_pack_clover",
	"hl_miami",
	"character_pack_dragan",
	"character_pack_sokol",
	"hlm2_deluxe",
	"dragon",
	"chico",
	"opera",
	"wild",
	"ecp",
	"john_wick_character",
}

local heist_list = {
	"big_bank",
	"hope_diamond",
	"the_bomb",
	"arena",
	"kenaz",
	"berry",
	"peta",
	"born",
	"friend",
	"spa",
	"mex",
	"bex",
	"pex",
	"fex",
	"sand",
	"chca",
	"pent",
	"ranc",
	"trai",
	"corp",
	"pal",
	"chas",
	"deep",
	"hl_miami",
	"armored_transport",
}

local function unlock_dlc(dlc_data)
	local dlc_name = ""
	for name, data in pairs(Global and Global.dlc_manager and Global.dlc_manager.all_dlc_data or {}) do
		if dlc_data == data then
			dlc_name = name
		end
	end

	if unlock_all_dlcs then
		return true
	end
	for _, character_name in pairs(unlock_characters and character_list or {}) do
		if dlc_name == character_name then
			return true
		end
	end
	for _, heist_name in pairs(unlock_heists and heist_list or {}) do
		if dlc_name == heist_name then
			return true
		end
	end
	if unlock_community_items and dlc_data then
		if dlc_data.external or not dlc_data.app_id or dlc_data.app_id == "218620" then
			return true
		end
	end
end

orig_WinSteamDLCManager__check_dlc_data = orig_WinSteamDLCManager__check_dlc_data or WinSteamDLCManager._check_dlc_data
function WinSteamDLCManager:_check_dlc_data(dlc_data)
	return unlock_dlc(dlc_data) or orig_WinSteamDLCManager__check_dlc_data(self, dlc_data)
end

orig_WinEpicDLCManager__check_dlc_data = orig_WinEpicDLCManager__check_dlc_data or WinEpicDLCManager._check_dlc_data
function WinEpicDLCManager:_check_dlc_data(dlc_data)
	return unlock_dlc(dlc_data) or orig_WinEpicDLCManager__check_dlc_data(self, dlc_data)
end

orig_WINDLCManager__check_dlc_data = orig_WINDLCManager__check_dlc_data or WINDLCManager._check_dlc_data
function WINDLCManager:_check_dlc_data(dlc_data)
	return unlock_dlc(dlc_data) or orig_WINDLCManager__check_dlc_data(self, dlc_data)
end
