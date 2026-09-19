------------------- stack special equipment, host only-------------------
function BaseInteractionExt:can_select() return true end

function PlayerManager:can_pickup_equipment(name)
	local special_equipment = self._equipment.specials[name]
	if special_equipment then
		if special_equipment.amount then
			local equipment = tweak_data.equipments.specials[name]
			local extra = self:_equipped_upgrade_value(equipment)
			return 1
		end
	end	
	return true
end

tweak_data.equipments.specials.bank_manager_key = {
	text_id = "hud_int_equipment_pickup_keycard",
	icon = "equipment_bank_manager_key",
	action_message = "bank_manager_key_obtained",
	sync_possession = true,
	amount = 10,
	quantity = 1,
}
tweak_data.equipments.specials.crowbar = {
	text_id = "debug_equipment_crowbar",
	icon = "equipment_crowbar",
	sync_possession = true,
	amount = 10,
	quantity = 1,
}

tweak_data.equipments.specials.planks = {
	text_id = "debug_equipment_stash_planks",
	icon = "equipment_planks",
	sync_possession = true,
	amount = 10,
	quantity = 1,
}
function PlayerManager:add_special(params)
	local name = params.equipment or params.name
	local unit = managers.player:player_unit()
	local respawn = params.amount and true or false
	local equipment = tweak_data.equipments.specials[name]
	local special_equipment = self._equipment.specials[name]
	local amount = params.amount or equipment.quantity
	local extra = self:_equipped_upgrade_value(equipment) + self:upgrade_value(name, "quantity")
	if special_equipment then
		if equipment.quantity then
			local dedigested_amount = Application:digest_value(special_equipment.amount, false)
			local new_amount = self:has_category_upgrade(name, "quantity_unlimited") and 5 or math.max(dedigested_amount + amount, equipment.quantity + extra)
			special_equipment.amount = Application:digest_value(new_amount, true)
			-- managers.hud:set_special_equipment_amount(name, new_amount)
			managers.player:update_equipment_possession_to_peers(name, new_amount)
		end
	end

	local icon = equipment.icon
	local action_message = equipment.action_message
	local dialog = equipment.dialog_id
	if not params.silent then
		local text = managers.localization:text(equipment.text_id)
		local title = managers.localization:text("present_obtained_mission_equipment_title")
		managers.hud:present_mid_text({
			text = text,
			title = title,
			icon = icon,
			time = 3
		})

		if action_message and alive(unit) then
			managers.network:session():send_to_peers("sync_show_action_message", unit, action_message)
		end
	end

	local quantity = (not self:has_category_upgrade(name, "quantity_unlimited") or not -1) and equipment.quantity and (not respawn or not math.min(params.amount, equipment.quantity + extra)) and equipment.quantity and math.min(amount + extra, equipment.quantity + extra)
	local is_special_equip = name == "bank_manager_key" or "planks"
	if is_special_equip then
		managers.hud:add_special_equipment({
			id = name,
			icon = icon,
			amount = quantity,
		})
		self:update_equipment_possession_to_peers(name, quantity)
	end

	self._equipment.specials[name] = {
		amount = quantity and Application:digest_value(quantity, true),
		is_special_equip = is_special_equip,
	}
	if equipment.player_rule then
		self:set_player_rule(equipment.player_rule, true)
	end
end
------------------- ------------------- ------------------- ------------------

-- host only, only give you the second keycard when stack special equipment enable
if Network:is_server() or not managers.player._equipment.specials["bank_manager_key"] then
	managers.player:add_special( { name = "bank_manager_key", silent = true, amount = 1 } )
	managers.mission._fading_debug_output:script().log('Get Keycard',  Color.yellow)
end
