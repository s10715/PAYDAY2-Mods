-- set true to enable this script
local unlock_skins = false

if not unlock_skins then
	return
end


-- set the unowned skins amount to 1
orig_BlackMarketManager_get_item_amount = orig_BlackMarketManager_get_item_amount or BlackMarketManager.get_item_amount
function BlackMarketManager:get_item_amount(global_value, category, item_id, ...)
	if category == "weapon_skins" then
		local skin_data = tweak_data and tweak_data.blackmarket and tweak_data.blackmarket.weapon_skins and tweak_data.blackmarket.weapon_skins[item_id] or nil
		if skin_data and not skin_data.is_template and not skin_data.is_a_color_skin then
			if managers and managers.blackmarket and not managers.blackmarket:have_inventory_tradable_item("weapon_skins", item_id) then
				return 1
			end
		end
	end
	return orig_BlackMarketManager_get_item_amount(self, global_value, category, item_id, ...)
end

-- create skin instance that unowned when equip weapons
orig_BlackMarketManager_on_equip_weapon_cosmetics = orig_BlackMarketManager_on_equip_weapon_cosmetics or BlackMarketManager.on_equip_weapon_cosmetics
function BlackMarketManager:on_equip_weapon_cosmetics(category, slot, instance_id)
	local is_inventory_item = self._global and self._global.inventory_tradable and self._global.inventory_tradable[instance_id]
	local skin_data = tweak_data and tweak_data.blackmarket and tweak_data.blackmarket.weapon_skins and tweak_data.blackmarket.weapon_skins[item_id] or nil
	if not is_inventory_item and skin_data and not skin_data.is_template then
		local cosmetic_data = {
			instance_id = instance_id,
			id = instance_id,
			quality = "mint",
			bonus = false
		}
		self:_set_weapon_cosmetics(category, slot, cosmetic_data, true)
		return
	end
	return orig_BlackMarketManager_on_equip_weapon_cosmetics(self, category, slot, instance_id)
end

-- make weapons that using skin can be modified, but some modification still causing game crash
Hooks:PostHook(BlackMarketManager, "init_finalize", "Weapon_Skin_Unlocker", function(self)
	for _, data in pairs(tweak_data and tweak_data.blackmarket and tweak_data.blackmarket.weapon_skins or {}) do
		if not data.is_template then
			data.locked = false
			data.is_a_unlockable = true
			data.skip_cheat_verification = true
		end
	end

	if self._global and self._global.crafted_items then
		for _, category in ipairs({ "primaries", "secondaries" }) do
			for _, weapon in pairs(self._global.crafted_items[category] or {}) do
				if weapon.cosmetics then
					weapon.customize_locked = nil
				end
			end
		end
	end
end)


-- for debug, clear weapon's skin cache, no weapon_name means clear all skins' cache
local function delete_skin(weapon_name)
	if not unlock_skins then return end
	if weapon_name then
		for instance_id, data in pairs(managers.blackmarket._global.inventory_tradable or {}) do
			if instance_id and data and data.entry and tweak_data.blackmarket.weapon_skins[data.entry] and tweak_data.blackmarket.weapon_skins[data.entry].weapon_id == weapon_name then
				managers.blackmarket._global.inventory_tradable[instance_id] = nil
			end
		end
	else
		for instance_id, data in pairs(managers.blackmarket._global.inventory_tradable or {}) do
			managers.blackmarket._global.inventory_tradable[instance_id] = nil
		end
	end
end

local function get_current_weapon_name()
	for _, category in pairs({ "primaries", "secondaries" }) do
		local slot = managers.blackmarket:equipped_weapon_slot(category)
		local weapon = managers and managers.blackmarket and managers.blackmarket:get_crafted_category_slot(category, slot)
		local weapon_name = weapon and weapon.weapon_id
		if managers and managers.chat then
			managers.chat:feed_system_message(ChatManager.GAME, string.format("%s: %s", category, weapon_name))
		end
	end
end
