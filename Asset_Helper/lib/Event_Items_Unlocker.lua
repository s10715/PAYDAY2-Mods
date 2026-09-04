Hooks:PostHook(PerpetualEventManager, "init_finalize", "PerpetualEventManager_init_finalize", function(self)
	local events = Global.perpetual_manager.events
	for event_id, event_data in pairs(events or {}) do
		local upgrades = event_data and event_data.upgrades
		for _, upgrade in ipairs(upgrades or {}) do
			managers.upgrades:aquire(upgrade, false, "PerpetualEventManager")
		end
	end
end)

function PerpetualEventManager:has_event_upgrade(upgrade)
	return true
end
