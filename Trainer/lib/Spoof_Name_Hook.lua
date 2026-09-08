-- only work as client. (if you're host, then only change your name locally, so make it invalid as host.)

-- doesn't change your name locally in the end-game menu (where you pick cards), though others still see the spoofed name.
local spoof_name = "Unknown"

local function get_real_name()
	if Steam and Steam.username and managers.network and managers.network.session() then
		-- local userid = Steam.userid(Steam)
		return Steam:username(managers.network:session():local_peer()._user_id)
	end
end


if NetworkPeer then
	orig_NetworkPeer_name = orig_NetworkPeer_name or NetworkPeer.name
	function NetworkPeer:name()
		local session = managers.network and managers.network:session()
		if spoof_name and Network:is_client() and session and self == session:local_peer() then
			return spoof_name
		end
		return orig_NetworkPeer_name(self)
	end

	orig_NetworkPeer_set_name = orig_NetworkPeer_set_name or NetworkPeer.set_name
	function NetworkPeer:set_name(name)
		local session = managers.network and managers.network:session()
		if spoof_name and Network:is_client() and session and self == session:local_peer() then
			name = spoof_name
		end
		return orig_NetworkPeer_set_name(self, name)
	end
end

local function set_spoof_name()
	local session = managers.network and managers.network:session()
	if spoof_name and Network:is_client() and session and session:local_peer() then
		session:local_peer():set_name(spoof_name)
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
