global_sentriesautopickup_toggle = not global_sentriesautopickup_toggle

local function sentries_godmod(enable)
	-- invulnerable sentries
	local function is_enemy_turret(unit)
		if not unit or not managers.groupai or not managers.groupai:state() then return false end
		local turrets = managers.groupai:state():turrets()
		return turrets and table.contains(turrets, unit)
	end

	orig_SentryGunDamage_damage_bullet = orig_SentryGunDamage_damage_bullet or SentryGunDamage.damage_bullet
	function SentryGunDamage:damage_bullet(...)
		if enable and not is_enemy_turret(self._unit) then
			return nil
		end
		return orig_SentryGunDamage_damage_bullet(self, ...)
	end

	if SentryGunDamage.damage_fire then
		orig_SentryGunDamage_damage_fire = orig_SentryGunDamage_damage_fire or SentryGunDamage.damage_fire
		function SentryGunDamage:damage_fire(...)
			if enable and not is_enemy_turret(self._unit) then
				return nil
			end
			return orig_SentryGunDamage_damage_fire(self, ...)
		end
	end

	if SentryGunDamage.damage_explosion then
		orig_SentryGunDamage_damage_explosion = orig_SentryGunDamage_damage_explosion or SentryGunDamage.damage_explosion
		function SentryGunDamage:damage_explosion(...)
			if enable and not is_enemy_turret(self._unit) then
				return nil
			end
			return orig_SentryGunDamage_damage_explosion(self, ...)
		end
	end

	if SentryGunDamage.damage_melee then
		orig_SentryGunDamage_damage_melee = orig_SentryGunDamage_damage_melee or SentryGunDamage.damage_melee
		function SentryGunDamage:damage_melee(...)
			if enable and not is_enemy_turret(self._unit) then
				return nil
			end
			return orig_SentryGunDamage_damage_melee(self, ...)
		end
	end

	-- infinite sentries ammo
	if SentryGunWeapon.fire then
		orig_SentryGunWeapon_fire = orig_SentryGunWeapon_fire or SentryGunWeapon.fire
		function SentryGunWeapon:fire(blanks, expend_ammo, ...)
			if enable then
				return orig_SentryGunWeapon_fire(self, blanks, false, ...)
			else
				return orig_SentryGunWeapon_fire(self, blanks, expend_ammo, ...)
			end
		end
	end
end

local function sentries_free_deploy(enable)
	if not SentryGunBase then return end
	if enable then
		SentryGunBase.DEPLOYEMENT_COST_bak = SentryGunBase.DEPLOYEMENT_COST_bak or SentryGunBase.DEPLOYEMENT_COST
		SentryGunBase.DEPLOYEMENT_COST = {1,1,1}
	else
		SentryGunBase.DEPLOYEMENT_COST = SentryGunBase.DEPLOYEMENT_COST_bak
	end

	-- allow you get ammo when pick up sentries even if you didn't cost any ammo when deploy
	orig_SentryGunBase_on_picked_up = orig_SentryGunBase_on_picked_up or SentryGunBase.on_picked_up
	function SentryGunBase.on_picked_up(sentry_type, ammo_ratio, sentry_uid)
		if enable then
			local player_unit = managers.player and managers.player:player_unit()
			local cost_table = SentryGunBase.DEPLOYEMENT_COST_bak or SentryGunBase.DEPLOYEMENT_COST
			if not alive(player_unit) or not cost_table then return end

			local player_equipment = player_unit:equipment()
			local percent = cost_table[managers.player:upgrade_value("sentry_gun", "cost_reduction", 1)]
			for index, weapon in pairs(player_unit:inventory() and player_unit:inventory():available_selections() or {}) do
				if player_equipment._sentry_ammo_cost and player_equipment._sentry_ammo_cost[sentry_uid] and player_equipment._sentry_ammo_cost[sentry_uid][index] == 0 then
					local total_ammo = weapon.unit and weapon.unit:base() and weapon.unit:base():get_ammo_total() or 0
					local ammo = math.floor(total_ammo * percent)
					local ammo_taken = total_ammo - ammo
					player_equipment._sentry_ammo_cost[sentry_uid][index] = ammo_taken
				end
			end
		end
		return orig_SentryGunBase_on_picked_up(sentry_type, ammo_ratio, sentry_uid)
	end
end

local function sentries_auto_pickup(enable)
	-- auto pickup when sentries destroyed
	orig_SentryGunBase_on_death = orig_SentryGunBase_on_death or SentryGunBase.on_death
	function SentryGunBase:on_death(...)
		if enable then
			local peer_id = managers.network:session() and managers.network:session():local_peer() and managers.network:session():local_peer():id() or 1
			local interaction = alive(self._unit) and (self._unit['interaction'] ~= nil) and self._unit:interaction()
			if interaction and peer_id and interaction._owner_id and (interaction._owner_id == peer_id) then
				interaction:interact()
			end
		else
			return orig_SentryGunBase_on_death(self, ...)
		end
	end

	-- auto pickup when sentries ran out of ammo
	orig_SentryGunBrain_switch_off = orig_SentryGunBrain_switch_off or SentryGunBrain.switch_off
	function SentryGunBrain:switch_off(...)
		local result = orig_SentryGunBrain_switch_off(self, ...)
		if enable then
			local peer_id = managers.network:session() and managers.network:session():local_peer() and managers.network:session():local_peer():id() or 1
			local interaction = alive(self._unit) and (self._unit['interaction'] ~= nil) and self._unit:interaction()
			if interaction and peer_id and interaction._owner_id and (interaction._owner_id == peer_id) then
				interaction:interact()
			end
		end
		return result
	end
end

if global_sentriesautopickup_toggle then
	-- sentries_godmod(true)
	sentries_free_deploy(true)
	sentries_auto_pickup(true)
	managers.mission._fading_debug_output:script().log('Sentries Auto Pickup - Activated',  Color.green)
else
	-- sentries_godmod(false)
	sentries_free_deploy(false)
	sentries_auto_pickup(false)
	managers.mission._fading_debug_output:script().log('Sentries Auto Pickup - Deactivated',  Color.red)
end
