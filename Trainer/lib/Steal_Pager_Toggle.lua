-- host only
if not Network:is_server() or not managers.groupai:state():whisper_mode() then
	return
end

global_stealpager_toggle = not global_stealpager_toggle

for _,ud in pairs(managers.enemy:all_enemies()) do
	ud.unit:unit_data().has_alarm_pager = not global_stealpager_toggle
end

if global_stealpager_toggle then 
	managers.mission._fading_debug_output:script().log('Steal Pager - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Steal Pager - Deactivated',  Color.red)
end
