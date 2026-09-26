local player = managers.player:local_player()
if not player then return end
local camera = player:camera()
if not camera then return end
local camera_pos = camera:camera_object():position()

managers.chat:_receive_message(1, "Position", tostring(camera_pos), tweak_data.system_chat_color)
