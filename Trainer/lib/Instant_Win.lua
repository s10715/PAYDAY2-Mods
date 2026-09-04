-- host only
if not Network:is_server() then
	return
end

-- secure some loot
function secure(name)
	managers.loot:secure(name, managers.money:get_bag_value(name))
end
secure("gold")
-- secure("diamonds")
-- secure("coke")
-- secure("meth")
-- secure("weapons")

-- instant win
if managers.network and managers.network._session then
	local num_winners = managers.network:session():amount_of_alive_players()
	managers.network._session:send_to_peers("mission_ended", true, num_winners)
	game_state_machine:change_state_by_name( "victoryscreen", { num_winners = num_winners, personal_win = true } )
end
