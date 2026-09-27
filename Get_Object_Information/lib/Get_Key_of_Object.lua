local ray = Utils:GetCrosshairRay()
if ray and ray.unit and managers.chat then
	local key = ray.unit:name():key()
	managers.chat:_receive_message(1, "Key is ", tostring(key), Color.green)
end
