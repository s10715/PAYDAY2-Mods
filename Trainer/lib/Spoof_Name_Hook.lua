--[[
-- deprecated
-- doesn't change your name locally in the end-game menu (where you pick cards), though others still see the spoofed name.
local spoof_name = "Unknown"

local function get_real_name()
	if Steam and Steam.username and managers.network and managers.network.session() then
		-- userid = Steam.userid(Steam)
		return Steam:username(managers.network:session():local_peer()._user_id)
	else
		return name
	end
end

local function set_spoof_name()
	if managers.network and managers.network:session() and managers.network:session():local_peer() then
		local session = managers.network:session()
		local my_peer = session:local_peer()
		my_peer:set_name(spoof_name)
		for _, peer in pairs(session._peers) do
			if not peer:loaded() or not my_peer:loaded() then
				peer:send("request_player_name_reply", spoof_name)
			end
		end
	end
end

-- get_real_name()
set_spoof_name()
]]--


--[[
-- spoof mod list
function MenuCallbackHandler:build_mods_list()
    local mods = {
		{"Extra Heist Info", "id1"},
		{"Hotline Miami Hud", "id2"},
	}
    return mods
end
]]--

-- hide mod list
function MenuCallbackHandler:build_mods_list()
	return {}
end
function MenuCallbackHandler:is_modded_client()
	return false
end
function MenuCallbackHandler:is_not_modded_client()
	return true
end
