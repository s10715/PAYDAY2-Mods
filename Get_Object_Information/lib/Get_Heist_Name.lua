if Global.level_data and Global.level_data.level_id then
	managers.chat:_receive_message(1, "Heist Name", tostring(Global.level_data.level_id), tweak_data.system_chat_color)
end