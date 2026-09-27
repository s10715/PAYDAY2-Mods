global_noclip_toggle = not global_noclip_toggle

local axis_move = { x = 0, y = 0, z = 0 }
local speed = 5

local function is_in_chat()
	if managers.hud._chat_focus == true then
		return true
	end
end

local function update_position()
	local camera_rot = managers.player:player_unit():camera():rotation()
	local move_dir = camera_rot:x() * axis_move.y + camera_rot:y() * axis_move.x + camera_rot:z() * axis_move.z
	local move_delta = move_dir * 10
	local pos_new = managers.player:player_unit():position() + move_delta

	managers.player:warp_to(pos_new, camera_rot, 1, Rotation(0, 0, 0))
end

local function noclip_update()
	local kb = Input:keyboard()
	local kb_down = kb.down

	if not managers.player:player_unit() then
		return
	end

	update_position()

	if not is_in_chat() then
		axis_move.x = (kb_down(kb, Idstring("w")) and speed) or (kb_down(kb, Idstring("s")) and -speed) or 0
		axis_move.y = (kb_down(kb, Idstring("d")) and speed) or (kb_down(kb, Idstring("a")) and -speed) or 0
		axis_move.z = (kb_down(kb, Idstring("space")) and speed) or (kb_down(kb, Idstring("left ctrl")) and -speed) or 0
	end
end

orig_PlayerDamage_damage_fall = orig_PlayerDamage_damage_fall or PlayerDamage.damage_fall
function PlayerDamage:damage_fall(data)
	if global_noclip_toggle then
		return false
	end
	return orig_PlayerDamage_damage_fall(self, data)
end

if MenuManager then
	orig_MenuManager_update = orig_MenuManager_update or MenuManager.update
	function MenuManager:update(t, dt)
		orig_MenuManager_update(self, t, dt)
		
		if global_noclip_toggle then
			noclip_update()
		end
	end
end


if global_noclip_toggle then
	managers.mission._fading_debug_output:script().log(string.format("Noclip - Activated"), Color.green)
else
	managers.mission._fading_debug_output:script().log(string.format("Noclip - Deactivated"), Color.red)
end
