local function is_playing()
	if not BaseNetworkHandler then
		return false
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

if not is_playing() then
	return
end


global_instantdrill_toggle = not global_instantdrill_toggle

if global_instantdrill_toggle then	
	local player = managers.player:player_unit()
	if not alive(player) then return end
	
	--set drill timer
	local function start_drill()
		for _,unit in pairs(World:find_units_quick("all", 1)) do
			local timer = unit:base() and unit:timer_gui() and unit:timer_gui()._current_timer
			if timer and math.floor(timer) ~= -1 then
				local newvalue = 0.1
				unit:timer_gui():_start(newvalue)
				if managers.network:session() then
					managers.network:session():send_to_peers_synched("start_timer_gui", unit:timer_gui()._unit, newvalue)
				end
				if not unit:timer_gui()._jammed then
					unit:timer_gui():set_jammed(true)
				end
				if unit:timer_gui()._jammed then
					unit:timer_gui():set_jammed(false)
				end
			end
		end
	end

	--drill doesnt jam
	orig_TimerGui__set_jamming_values = orig_TimerGui__set_jamming_values or TimerGui._set_jamming_values
	function TimerGui:_set_jamming_values() return end

	--drill timer started
	orig_TimerGui_start = orig_TimerGui_start or TimerGui.start
	function TimerGui:start(timer)
		orig_TimerGui_start(self, timer)

		timer = 0.5
		DelayedCalls:Add( "antidrill_stackoverflow2", 0.25, function() start_drill() end)
		if self._jammed then
			self:_set_jammed(false)
			return
		end
		if not self._powered then
			self:_set_powered(true)
			return
		end
		if self._started then
			return
		end
		self:_start(timer)
		if managers.network:session() then
			managers.network:session():send_to_peers_synched("start_timer_gui", self._unit, timer)
		end 
	end

	--unjam drill
	orig_Drill_set_jammed = orig_Drill_set_jammed or Drill.set_jammed
	function Drill:set_jammed(jammed)
		orig_Drill_set_jammed(self, jammed)
		if not Network:is_server() then
			DelayedCalls:Add( "antidrill_stackoverflow", 0.75, function() start_drill() end)
		end
	end
	DelayedCalls:Add( "antidrill_stackoverflow2", 0.25, function() start_drill() end)
	managers.mission._fading_debug_output:script().log('Instant Drill - Activated',  Color.green)
else
	if orig_TimerGui__set_jamming_values then TimerGui._set_jamming_values = orig_TimerGui__set_jamming_values end
	if orig_TimerGui_start then TimerGui.start = orig_TimerGui_start end
	if orig_Drill_set_jammed then Drill.set_jammed = orig_Drill_set_jammed end
	managers.mission._fading_debug_output:script().log('Instant Drill - Deactivated',  Color.red)
end
