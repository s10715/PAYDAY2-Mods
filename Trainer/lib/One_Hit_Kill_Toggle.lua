global_onehitkill_toggle = not global_onehitkill_toggle

local function check_and_melee_kill(unit)
	if alive(unit) and global_onehitkill_toggle then
		unit:character_damage():damage_melee({
			damage = unit:character_damage()._HEALTH_INIT,
			attacker_unit = managers.player._players[1],
			attack_dir = Vector3(0,0,0),
			variant = "melee",
			name_id = 'cqc',
			col_ray = {position = unit:position(), body = unit:body("body")}
		})
	end
end

Hooks:PostHook(CopDamage, "damage_bullet", "One_Hit_Kill_damage_bullet", function(self, attack_data, ...)
	check_and_melee_kill(self._unit)
end)

Hooks:PostHook(CopDamage, "damage_fire", "One_Hit_Kill_damage_fire", function(self, attack_data, ...)
	check_and_melee_kill(self._unit)
end)

Hooks:PostHook(CopDamage, "damage_explosion", "One_Hit_Kill_damage_explosion", function(self, attack_data, ...)
	check_and_melee_kill(self._unit)
end)

Hooks:PreHook(CopDamage, "damage_melee", "One_Hit_Kill_damage_melee", function(self, attack_data, ...)
	if global_onehitkill_toggle then attack_data.damage = attack_data.damage * math.huge end
end)


if global_onehitkill_toggle then
	managers.mission._fading_debug_output:script().log('One Hit Kill - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('One Hit Kill - Deactivated',  Color.red)
end
