-- host only
if not Network:is_server() then
	return
end

-- end/start assault on all heists including holdout and skip waves, on holdout, you need to wait 25 sec after heist start to activate it or it bugs a wave
if Utils:IsInHeist() then
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