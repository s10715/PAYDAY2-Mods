if RequiredScript == "lib/managers/challengemanager" then
	-- complete daily/weekly/monthly challenge
	orig_ChallengeManager_activate_challenge = orig_ChallengeManager_activate_challenge or ChallengeManager.activate_challenge
	function ChallengeManager:activate_challenge(id, key, category)
		if self:has_active_challenges(id, key) then
			local challenge = self:get_challenge(id, key)
			challenge.completed = true
			-- challenge.rewarded = true
			challenge.category = category
			return true
		end
		return orig_ChallengeManager_activate_challenge(self, id, key, category)
	end
elseif RequiredScript == "lib/managers/sidejobeventmanager" then
	-- complete event missions
	orig_SideJobEventManager_load = orig_SideJobEventManager_load or SideJobEventManager.load
	function SideJobEventManager:load(cache, version)
		local state = cache[self.save_table_name]
		if state and state.version == self.save_version then
			for _, saved_challenge in ipairs(state.challenges or {}) do
				saved_challenge.completed = true
			end
		end
		return orig_SideJobEventManager_load(self, cache, version)
	end
elseif RequiredScript == "lib/managers/tangomanager" then
	-- complete Gage spec ops missions
	orig_TangoManager_load = orig_TangoManager_load or TangoManager.load
	function TangoManager:load(cache, version)
		local state = cache.Tango
		if state and state.version == TangoManager.SAVE_DATA_VERSION then
			for _, saved_challenge in ipairs(state.challenges or {}) do
				saved_challenge.completed = true
			end
		end
		return orig_TangoManager_load(self, cache, version)
	end
elseif RequiredScript == "lib/managers/sidejobgenericdlcmanager" then
	-- complete Aldstone's heritage jobs
	orig_SideJobGenericDLCManager_load = orig_SideJobGenericDLCManager_load or SideJobGenericDLCManager.load
	function SideJobGenericDLCManager:load(cache, version)
		local state = cache[self.save_table_name]
		if state and state.version == self.save_version then
			for _, saved_challenge in ipairs(state.challenges or {}) do
				saved_challenge.completed = true
			end
		end
		return orig_SideJobGenericDLCManager_load(self, cache, version)
	end
end
