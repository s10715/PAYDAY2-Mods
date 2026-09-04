global_fastzipline_toggle = not global_fastzipline_toggle

if Network:is_server() then -- change zipline speed, host only
	Hooks:PreHook(ZipLine, "update", "Fast_Zipline", function(self, ...)
		self.speed_bak = self.speed_bak or self:speed()
		if global_fastzipline_toggle then
			self:set_speed(4000)
		else
			self:set_speed(self.speed_bak)
		end
	end)
else -- drop bag at zipline end position directly, as client
	orig_ZipLine_on_interacted = orig_ZipLine_on_interacted or ZipLine.on_interacted
	function ZipLine:on_interacted(...)
		if global_fastzipline_toggle and (self:is_usage_type_bag() or self:is_usage_type_both()) and self:end_pos() and managers and managers.player and managers.player:player_unit() and alive(managers.player:player_unit()) then
			local position = self:end_pos()
			local rotation = Rotation(math.random(-180,180), math.random(-180,180), 0)
			local forward = Vector3(0, 0, 0)
			local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
			local carry_data = managers.player:get_my_carry_data()
			if carry_data and carry_data.carry_id ~= "nail_euphadrine_pills" then
				if Network:is_client() then
					managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, nil)
				else
					managers.player:server_drop_carry(carry_data.carry_id,carry_data.multiplier, carry_data.dye_initiated,carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force, nil, managers.network:session():local_peer())
				end
				managers.player:clear_carry()
				managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
				managers.hud:temp_hide_carry_bag()
				managers.player:update_removed_synced_carry_to_peers()
				return
			else
				return orig_ZipLine_on_interacted(self, ...)
			end
		else
			return orig_ZipLine_on_interacted(self, ...)
		end
	end
end


if global_fastzipline_toggle then
	managers.mission._fading_debug_output:script().log('Fast Zipline - Activated',  Color.green)
else
	managers.mission._fading_debug_output:script().log('Fast Zipline - Deactivated',  Color.red)
end
