if managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) and managers.player:player_unit():character_damage() then
	--[[
	-- only recover health
	managers.player:player_unit():character_damage():band_aid_health()
	-- recover health and down count
	managers.player:player_unit():character_damage():recover_health()
	-- recover ammo, hud won't update untill you reload or change weapon
	local inventory = managers.player:player_unit():inventory()
	if inventory then
		for _, weapon in pairs(inventory:available_selections()) do
			weapon.unit:base():add_ammo_from_bag(100)
		end
	end
	]]--

	-- health, down count, ammo
	managers.player:player_unit():base():replenish()
	-- set player state to default state
	managers.player:set_player_state('standard')
	-- body bags
	managers.player:add_body_bags_amount(3)
	-- cable tie
	if (managers.player._global.synced_cable_ties[managers.network:session():local_peer():id()].amount < 5) then
		managers.player:add_special({name = "cable_tie", silent = true, amount = 1})
	end

	-- projectile amount
	managers.player:add_grenade_amount(3, true)

	-- won't give you deployable unless you are the host, because of cheat detecting
	if Network:is_server() then
		-- deployable
		managers.player:clear_equipment()
		managers.player._equipment.selections = {}
		managers.player:add_equipment({silent = true, equipment = managers.player:equipment_in_slot(1), slot = 1})
		if managers.player:has_category_upgrade("player", "second_deployable") then
			managers.player:add_equipment({silent = true, equipment = managers.player:equipment_in_slot(2), slot = 2})
		end
	end

	-- 5s bullet storm
	managers.player:add_to_temporary_property("bullet_storm", 5, 1)
	-- 5s take no dmg
	managers.player:player_unit():character_damage()._next_allowed_dmg_t = Application:digest_value(managers.player:player_timer():time() + 5, true)
	managers.player:player_unit():character_damage()._last_received_dmg = math.huge

	managers.mission._fading_debug_output:script().log('Refresh Equipment',  Color.yellow)
end
