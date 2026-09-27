-- host only
if not Utils:IsInHeist() then return end
if not Network:is_server() then return end

local function assault_wave_toggle()
	-- end/start assault on all heists including holdout and skip waves, on holdout, you need to wait 25 sec after heist start to activate it or it bugs a wave
	local time_to_wait = 25
	local timer = managers.game_play_central and math.abs(managers.game_play_central:get_heist_timer()) or TimerManager:game():time()
	local groupai = managers.groupai:state()
	local current = groupai and groupai:get_assault_number()
	local task_data = groupai._task_data.assault
	local skirmish = managers.skirmish:is_skirmish()
	if current and current < 9 and task_data and (skirmish and timer > time_to_wait or not skirmish) then
		if groupai._assault_mode then
			groupai:_end_regroup_task()
			groupai:_assign_recon_groups_to_retire()
			groupai:_police_announce_retreat()
			task_data.active = nil
			task_data.phase = nil
			task_data.said_retreat = nil
			task_data.force_end = nil
			local force_regroup = task_data.force_regroup
			task_data.force_regroup = nil
 
			if groupai._draw_drama then
				groupai._draw_drama.assault_hist[#groupai._draw_drama.assault_hist][2] = (skirmish and 0.1 or timer)
			end
			
			managers.mission:call_global_event("end_assault")
			groupai:_begin_regroup_task(true)

			managers.mission._fading_debug_output:script().log(string.format("End Assault Wave"), Color.red)
		else
			groupai:_assign_recon_groups_to_retire()
			groupai._assault_number = groupai._assault_number + 1
 
			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(groupai._assault_number)
			managers.groupai:dispatch_event("start_assault", groupai._assault_number)
			groupai:_set_rescue_state(false)
 
			task_data.phase = "build"
			task_data.phase_end_t = (skirmish and 0.1 or timer + groupai._tweak_data.assault.build_duration)
			task_data.is_hesitating = nil
 
			groupai:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)

			managers.mission._fading_debug_output:script().log(string.format("Start Assault Wave"), Color.green)
		end
	end
end

local function instant_win()
	-- secure some loot
	local function secure(name)
		managers.loot:secure(name, managers.money:get_bag_value(name))
	end
	-- secure("gold")
	-- secure("diamonds")
	-- secure("coke")
	-- secure("meth")
	-- secure("weapons")

	if managers.network and managers.network._session then
		local num_winners = managers.network:session():amount_of_alive_players()
		managers.network._session:send_to_peers("mission_ended", true, num_winners)
		game_state_machine:change_state_by_name( "victoryscreen", { num_winners = num_winners, personal_win = true } )
		managers.mission._fading_debug_output:script().log(string.format("Instant Win"), Color.yellow)
	end
end

-- enable/disable bots
local function bot_toggle()
	local function check_if_having_ai()
		for _, ai in pairs(managers.groupai:state():all_AI_criminals()) do
			return true
		end
	end

	if check_if_having_ai() then
		for i = 1, tweak_data.max_players - 1 do
			managers.groupai:state():remove_one_teamAI()
		end
		managers.mission._fading_debug_output:script().log(string.format("Disable Bots"), Color.red)
	else
		Global.game_settings.team_ai = true -- prevent choosing no bot when creating heist
		managers.groupai:state():fill_criminal_team_with_AI()
		if check_if_having_ai() then
			managers.mission._fading_debug_output:script().log(string.format("Enable Bots"), Color.green)
		else
			managers.mission._fading_debug_output:script().log(string.format("Bots are Forbidden By Heist"), Color.red)
		end
	end
end

local function trigger_alarm()
	managers.groupai:state():on_police_called("empty")
	managers.mission._fading_debug_output:script().log(string.format("Trigger Alarm"), Color.yellow)
end

-- make the calling police action fail, and won't raising the alarm even if you don't answer pagers, but suspicion will still grow
-- there're many other ways to raising the alarm like not answering phone, touching laser, breaking glass, detecting by metal detector, and so on, you should still be care of those special mechanisms
global_disablealarm_toggle = global_disablealarm_toggle or nil
local function disable_alarm_toggle()
	global_disablealarm_toggle = not global_disablealarm_toggle

	if global_disablealarm_toggle then
		-- allow infinite pagers, and won't raising the alarm even if you don't answer pagers
		orig_GroupAIStateBase_on_successful_alarm_pager_bluff = orig_GroupAIStateBase_on_successful_alarm_pager_bluff or GroupAIStateBase.on_successful_alarm_pager_bluff
		function GroupAIStateBase:on_successful_alarm_pager_bluff() end

		-- makes guards & people in general stop calling the cops
		orig_GroupAIStateBase_on_police_called = orig_GroupAIStateBase_on_police_called or GroupAIStateBase.on_police_called
		function GroupAIStateBase:on_police_called() end

		-- stops police from saying they are calling the police all the time
		orig_CopLogicArrest__say_call_the_police = orig_CopLogicArrest__say_call_the_police or CopLogicArrest._say_call_the_police
		function CopLogicArrest:_say_call_the_police(data, my_data) end

		-- make cops don't shoot
		orig_CopMovement_set_allow_fire = orig_CopMovement_set_allow_fire or CopMovement.set_allow_fire
		function CopMovement:set_allow_fire(state) end

		-- make cops don't shoot
		orig_CopMovement_set_allow_fire_on_client = orig_CopMovement_set_allow_fire_on_client or CopMovement.set_allow_fire_on_client
		function CopMovement:set_allow_fire_on_client(state, unit) end

		-- prevents panic buttons & intel burning (intercepting the 'run' action is the only way; for example, if you intercept events such as 'e_so_alarm_under_table' to prevent intel burning, the animation will not happen but the fire will still appear)
		orig_CopMovement_action_request = orig_CopMovement_action_request or CopMovement.action_request
		function CopMovement:action_request(action_desc)
			if action_desc and action_desc.variant == "run" then return false end
			return orig_CopMovement_action_request(self, action_desc)
		end

		-- stops civs from reporting you
		orig_CivilianLogicFlee_clbk_chk_call_the_police = orig_CivilianLogicFlee_clbk_chk_call_the_police or CivilianLogicFlee.clbk_chk_call_the_police
		function CivilianLogicFlee:clbk_chk_call_the_police(ignore_this, data) end

		-- stops cameras from reporting you
		orig_SecurityCamera__sound_the_alarm = orig_SecurityCamera__sound_the_alarm or SecurityCamera._sound_the_alarm
		function SecurityCamera:_sound_the_alarm(detected_unit) end

		-- gets rid of the sound of the camera seeing you
		orig_SecurityCamera__set_suspicion_sound = orig_SecurityCamera__set_suspicion_sound or SecurityCamera._set_suspicion_sound
		function SecurityCamera:_set_suspicion_sound(suspicion_level) end

		-- no alarm laser, but only work in some map, not all map, better don't touch laser
		orig_ElementLaserTrigger_on_executed = orig_ElementLaserTrigger_on_executed or ElementLaserTrigger.on_executed
		function ElementLaserTrigger:on_executed(instigator, alternative) end

		for _, unit in pairs(SecurityCamera and SecurityCamera.cameras or {}) do
			if alive(unit) and unit:base()._last_detect_t ~= nil and unit:base().set_update_enabled then
				unit:base():set_update_enabled(false)
			end
		end

		managers.mission._fading_debug_output:script().log(string.format("Disable Alarm"), Color.green)
	else
		if orig_GroupAIStateBase_on_successful_alarm_pager_bluff then GroupAIStateBase.on_successful_alarm_pager_bluff = orig_GroupAIStateBase_on_successful_alarm_pager_bluff end
		if orig_GroupAIStateBase_on_police_called then GroupAIStateBase.on_police_called = orig_GroupAIStateBase_on_police_called end
		if orig_CopLogicArrest__say_call_the_police then CopLogicArrest._say_call_the_police = orig_CopLogicArrest__say_call_the_police end
		if orig_CopMovement_set_allow_fire then CopMovement.set_allow_fire = orig_CopMovement_set_allow_fire end
		if orig_CopMovement_set_allow_fire_on_client then CopMovement.set_allow_fire_on_client = orig_CopMovement_set_allow_fire_on_client end
		if orig_CopMovement_action_request then CopMovement.action_request = orig_CopMovement_action_request end
		if orig_CivilianLogicFlee_clbk_chk_call_the_police then CivilianLogicFlee.clbk_chk_call_the_police = orig_CivilianLogicFlee_clbk_chk_call_the_police end
		if orig_SecurityCamera__sound_the_alarm then SecurityCamera._sound_the_alarm = orig_SecurityCamera__sound_the_alarm end
		if orig_SecurityCamera__set_suspicion_sound then SecurityCamera._set_suspicion_sound = orig_SecurityCamera__set_suspicion_sound end
		if orig_ElementLaserTrigger_on_executed then ElementLaserTrigger.on_executed = orig_ElementLaserTrigger_on_executed end

		for _, unit in pairs(SecurityCamera and SecurityCamera.cameras or {}) do
			if alive(unit) and unit:base()._last_detect_t ~= nil and unit:base().set_update_enabled then
				unit:base():set_update_enabled(true)
			end
		end

		managers.mission._fading_debug_output:script().log(string.format("Enable Alarm"), Color.red)
	end
end

-- freeze/unfreeze AI, you can't shout or tie civilians, and suspicion won't grow(except cameras if camera already see you), AI will keep doing the previous action before script active like calling the police and raising alarm if suspicion already full
-- doesn't work on newly spawned AI
global_freezeai_toggle = global_freezeai_toggle or nil
local function freeze_ai_toggle()
	global_freezeai_toggle = not global_freezeai_toggle

	if global_freezeai_toggle then
		for u_key, u_data in pairs(managers.enemy:all_civilians() or {}) do
			if alive(u_data.unit) and u_data.unit.brain and u_data.unit:brain() and u_data.unit:brain().is_active and u_data.unit:brain():is_active() and u_data.unit:brain().set_active then u_data.unit:brain():set_active(false) end
		end
		for u_key, u_data in pairs(managers.enemy:all_enemies() or {}) do
			if alive(u_data.unit) and u_data.unit.brain and u_data.unit:brain() and u_data.unit:brain().is_active and u_data.unit:brain():is_active() and u_data.unit:brain().set_active then u_data.unit:brain():set_active(false) end
		end
		for key, unit in pairs(managers.groupai:state():turrets() or {}) do
			if alive(unit) and unit.brain and unit:brain() and unit:brain().is_active and unit:brain():is_active() and unit:brain().set_active then unit:brain():set_active(false) end
		end
		for key, unit in pairs(SecurityCamera and SecurityCamera.cameras or {}) do
			-- make detection very slow
			if alive(unit) and unit.base and unit:base() then unit:base()._detection_interval = 100000 end
		end

		managers.mission._fading_debug_output:script().log(string.format("Freeze AI"), Color.green)
	else
		for u_key, u_data in pairs(managers.enemy:all_civilians() or {}) do
			if alive(u_data.unit) and u_data.unit.brain and u_data.unit:brain() and u_data.unit:brain().set_active then u_data.unit:brain():set_active(true) end
		end
		for u_key, u_data in pairs(managers.enemy:all_enemies() or {}) do
			if alive(u_data.unit) and u_data.unit.brain and u_data.unit:brain() and u_data.unit:brain().set_active then u_data.unit:brain():set_active(true) end
		end
		for key, unit in pairs(managers.groupai:state():turrets() or {}) do
			if alive(unit) and unit.brain and unit:brain() and unit:brain().set_active then unit:brain():set_active(true) end
		end
		for key, unit in pairs(SecurityCamera and SecurityCamera.cameras or {}) do
			if alive(unit) and unit.base and unit:base() then unit:base()._detection_interval = 0.1 end
		end

		managers.mission._fading_debug_output:script().log(string.format("Unfreeze AI"), Color.red)
	end
end

local function access_cameras_toggle()
	if game_state_machine:current_state() and game_state_machine:current_state()._name == "ingame_access_camera" then
		local old_state = game_state_machine:current_state()._old_state
		if game_state_machine:can_change_state_by_name(old_state) then
			game_state_machine:change_state_by_name(old_state)
		else
			game_state_machine:change_state_by_name("ingame_standard")
		end
	else
		game_state_machine:change_state_by_name("ingame_access_camera")
		managers.mission._fading_debug_output:script().log(string.format("Access Camera"), Color.yellow)
	end
end


-- assault_wave_toggle()
-- instant_win()
-- bot_toggle()
-- trigger_alarm()
disable_alarm_toggle()
-- freeze_ai_toggle()
-- access_cameras_toggle()

