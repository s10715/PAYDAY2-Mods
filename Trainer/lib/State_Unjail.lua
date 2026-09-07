-- utils function
local function get_peer_by_id(peer_id)
	if managers.network and managers.network._session then
		return managers.network._session:peer(peer_id)
	end
	return nil
end
local function get_peer_at_crosshair()
	local ray = Utils:GetCrosshairRay(false, false, "all_criminals")
	local unit = ray and ray.unit
	local peer = nil
	if managers.network and managers.network:session() then
		peer = managers.network:session():peer_by_unit(unit)
	end
	return peer
end




-- jail and unjail yourself
local function inCustody_player()
	if alive(managers.player:player_unit()) then
		MenuCallbackHandler:debug_goto_custody()
		managers.mission:call_global_event("player_in_custody")

		-- make you can be traded now
		local player = managers.player
		if player._super_syndrome_count and player._super_syndrome_count > 0 and not player._action_mgr:is_running("stockholm_syndrome_trade") then
			local peer_id = managers.network:session():local_peer():id()
			player._action_mgr:add_action("stockholm_syndrome_trade", StockholmSyndromeTradeAction:new(player:player_unit():position(), peer_id))
		end
		player._listener_holder:call(player._custody_state, player:player_unit())
		managers.hud:remove_interact()
	end
end
local function unCustody_player()
	if not alive(managers.player:player_unit()) then
		IngameWaitingForRespawnState.request_player_spawn()
	end
end
-- inCustody_player()
-- unCustody_player()




-- host only, jail and unjail all bots
local function inCustody_bots()
	if not Network:is_server() then return end
	for id, data in pairs(managers.criminals._characters) do
		if data.data.ai and alive(data.unit) then
			local crim_data = managers.criminals:character_data_by_name(data.name)
			if crim_data then
				managers.hud:set_mugshot_custody(crim_data.mugshot_id)
			end
			data.unit:set_slot(data.name, 0)
		end
	end
end
local function unCustody_bots()
	if not Network:is_server() then return end
	local spawn_on_position = managers.player and managers.player._players[1] and alive(managers.player._players[1]) and (managers.player._players[1]):camera():position()
	for id, data in pairs(managers.criminals._characters) do
		if data.data.ai and not alive(data.unit) and spawn_on_position then
			managers.trade:remove_from_trade(data.name)
			managers.groupai:state():spawn_one_teamAI(false, data.name, spawn_on_position)
		end
	end
end
-- inCustody_bots()
-- unCustody_bots()




-- host only, jail and unjail teammate by peer_id
local function inCustody_teammate(peer_id)
	local peer = get_peer_by_id(peer_id)
	if peer == nil then return end
	peer:unit():network():send("sync_player_movement_state", "standard", 0, peer_id)
	peer:unit():network():send("sync_player_movement_state", "dead", 0, peer_id)
	peer:unit():network():send("set_health", 0)
	peer:unit():network():send("spawn_dropin_penalty", true, nil, 0, nil, nil)
	managers.groupai:state():on_player_criminal_death(peer_id)
end
local function unCustody_teammate(peer_id)
	local peer = get_peer_by_id(peer_id)
	if peer == nil then return end
	IngameWaitingForRespawnState.request_player_spawn(peer_id)
	peer:send("request_spawn_member")
end
-- inCustody_teammate(2)
-- inCustody_teammate(3)
-- inCustody_teammate(4)
-- unCustody_teammate(2)
-- unCustody_teammate(3)
-- unCustody_teammate(4)




-- host only (state won't affect bots, except  incustody or uncustody)
-- state can be one of those string value: standard, arrested, bleed_out, fatal, tased, incapacitated, jerry1, jerry2(jerry2 can't use in the map that doesn't have parachute, or it will crash the game), bipod(need weapon have bipod, or it will crash the game), carry, and some custom string: disconnect, kick, ban, incustody, uncustody
-- peer_id=1 is Green, peer_id=2 is Blue, peer_id=3 is Red, peer_id=4 is Orange, if peer_id isn't given, then get unit from crosshair
local function change_player_state(state, peer_id)
	local peer = nil
	local peer_id = peer_id
	if peer_id ~= nil then
		peer = get_peer_by_id(peer_id)
	else
		peer = get_peer_at_crosshair()
		if peer then peer_id = peer:id() end
	end
	if peer == nil or peer_id == nil or state == nil then return end

	-- custom states
	if state == "disconnect" then
		if peer_id ~= managers.network._session:local_peer():id() then
			-- set peer_id=1 to disconnect from server
			managers.network._session:on_peer_kicked(peer, peer_id, 1)
			managers.network._session:send_to_peers("kick_peer", peer_id, 2)
		end
		return
	end
	if state == "kick" then
		if peer_id ~= managers.network._session:local_peer():id() then
			managers.network._session:send_to_peers("kick_peer", peer_id, 0)
			managers.network._session:on_peer_kicked(peer, peer_id, 0)
		end
		return
	end
	if state == "ban" then
		if peer_id ~= managers.network._session:local_peer():id() then
			local identifier = SystemInfo:platform() == Idstring("WIN32") and peer:account_id() or peer:name()
			if managers.ban_list and managers.ban_list:banned(identifier) then
				managers.ban_list:ban(identifier, peer:name())
			end
		end
		return
	end
	if state == "incustody" then
		if peer_id == managers.network._session:local_peer():id() then
			inCustody_player()
			inCustody_bots()
		else
			inCustody_teammate(peer_id)
		end
		return
	end
	if state == "uncustody" then
		if peer_id == managers.network._session:local_peer():id() then
			if not alive(peer:unit()) then unCustody_player() end
			unCustody_bots()
		else
			if not alive(peer:unit()) then unCustody_teammate(peer_id) end
		end
		return
	end

	-- defult states
	if peer_id == managers.network._session:local_peer():id() then
		managers.player:set_player_state(state)
	else
		peer:unit():network():send("sync_player_movement_state", state, peer:unit():character_damage():down_time(), peer:unit():id())
		if state == "incapacitated" then
			peer:unit():character_damage():clbk_exit_to_dead()
		end
	end
end
local function change_all_player_state(state)
	-- -- if someone is in the custody , this can't get he's peer
	-- for _, peer in pairs(managers.network:session():peers()) do
	-- 	change_player_state(state, peer:id())
	-- end

	for i=1,4 do
		change_player_state(state, i)
	end
end




-- change_player_state("tased", 2) -- blue get electric shock
-- change_player_state("incapacitated") -- the one who at the crosshair get incapacitated
-- change_all_player_state("incustody")

change_all_player_state("uncustody")
managers.mission._fading_debug_output:script().log('Unjail',  Color.yellow)
