if not managers or not managers.player or not managers.player:player_unit() or not alive(managers.player:player_unit()) then return end

local PENETRATE = true
local player_unit = managers.player:player_unit()
local camera = player_unit:camera()

local from_pos = camera:position()
local mvec_to = Vector3()
mvector3.set(mvec_to, camera:forward())
mvector3.multiply(mvec_to, 20000)
mvector3.add(mvec_to, from_pos)

local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", managers.slot:get_mask("bullet_impact_targets"))

if col_ray then
	if PENETRATE then
		local offset = Vector3()
		mvector3.set(offset, camera:forward())
		mvector3.multiply(offset, 100)
		mvector3.add(col_ray.hit_position, offset)
	end

	managers.player:warp_to(col_ray.hit_position, player_unit:rotation())
	managers.mission._fading_debug_output:script().log('Teleport',  Color.yellow)
end
