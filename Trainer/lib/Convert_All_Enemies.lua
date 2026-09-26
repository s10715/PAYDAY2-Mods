-- host only
if not Network:is_server() then
	return
end

local function convert_all_enemies()
	-- add 100 max count of convert enemies each time
	local orig_PlayerManager_upgrade_value = PlayerManager.upgrade_value
	function PlayerManager:upgrade_value(category, upgrade, default)
		local value = orig_PlayerManager_upgrade_value(self, category, upgrade, default)
		if category == "player" and upgrade == "convert_enemies" then
			return true
		elseif category == "player" and upgrade == "convert_enemies_max_minions" then
			return value + 100
		else
			return value
		end
	end

	-- convert enemies
	for _, ud in pairs(managers.enemy:all_enemies()) do
		if alive(ud.unit) and not ud.unit:brain()._logic_data.is_converted then
			managers.groupai:state():convert_hostage_to_criminal(ud.unit)
			managers.groupai:state():sync_converted_enemy(ud.unit)
			ud.unit:contour():add("friendly", true)
		end
	end
	managers.mission._fading_debug_output:script().log('Convert All Enemies',  Color.yellow)
end
convert_all_enemies()
