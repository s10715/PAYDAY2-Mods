-- deprecated, now only change your name locally, the other still see your real name, need to update




-- doesn't change your name locally in the end-game menu (where you pick cards), though others still see the spoofed name.
local spoof_name = "Unknown"

local function get_real_name()
	if Steam and Steam.username and managers.network and managers.network.session() then
		-- local userid = Steam.userid(Steam)
		return Steam:username(managers.network:session():local_peer()._user_id)
	end
end

local function set_spoof_name()
	if managers.network and managers.network:session() and managers.network:session():local_peer() then
		local my_peer = managers.network:session():local_peer()
		if my_peer then
			my_peer:set_name(spoof_name)
		end
		--[[
		-- deprecated
		for _, peer in pairs(managers.network:session()._peers) do
			if not peer:loaded() or not my_peer:loaded() then
				-- peer:send("request_player_name_reply", spoof_name)
			end
		end
		]]--
	end
end

-- get_real_name()
set_spoof_name()


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

--[[
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
]]--
