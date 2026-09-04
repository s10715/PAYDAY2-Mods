-- host only
if not Network:is_server() then
	return
end

local function remove_team_ai(enabled)
	if enabled then
		for i = 1, tweak_data.max_players - 1 do
			managers.groupai:state():remove_one_teamAI()
		end
	else
		managers.groupai:state():fill_criminal_team_with_AI()
	end
end

global_disableAI_toggle = not global_disableAI_toggle
if global_disableAI_toggle then
	remove_team_ai(true)
	managers.mission._fading_debug_output:script().log('Disable AI - Activated',  Color.green)
else
	remove_team_ai(false)
	managers.mission._fading_debug_output:script().log('Disable AI - Deactivated',  Color.red)
end
