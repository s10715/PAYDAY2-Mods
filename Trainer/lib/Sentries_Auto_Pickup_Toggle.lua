global_sentriesautopickup_toggle = not global_sentriesautopickup_toggle

orig_SentryGunBase_on_death = orig_SentryGunBase_on_death or SentryGunBase.on_death
function SentryGunBase:on_death(...)
	if global_sentriesautopickup_toggle then
		local session = managers.network:session()
		local peer_id = session and (session:local_peer():id() or 1)
		local interaction = (alive(self._unit) and (self._unit['interaction'] ~= nil)) and self._unit:interaction()
		if interaction and peer_id and interaction._owner_id and (interaction._owner_id == peer_id) then
			interaction:interact()
		end
	else
		orig_SentryGunBase_on_death(self, ...)
	end
end

orig_SentryGunBrain_switch_off = orig_SentryGunBrain_switch_off or SentryGunBrain.switch_off
function SentryGunBrain:switch_off(...)
	if global_sentriesautopickup_toggle then
		local is_server = Network:is_server()
		local session = managers.network:session()
		local peer_id = session and (session:local_peer():id() or 1)
		local interaction = (alive(self._unit) and (self._unit['interaction'] ~= nil)) and self._unit:interaction()
		local groupai = managers.groupai:state()
		
		if is_server then
			self._ext_movement:set_attention()
		end

		self:set_active(false)
		self._ext_movement:switch_off()
		self._unit:set_slot(26)

		if groupai:all_criminals()[self._unit:key()] then
			groupai:on_criminal_neutralized(self._unit)
		end

		if is_server then
			PlayerMovement.set_attention_settings(self, nil)
		end

		if interaction and peer_id and interaction._owner_id and (interaction._owner_id == peer_id) then
			interaction:interact()
		end 
		
		self._unit:base():unregister()
		self._attention_obj = nil
	else
		orig_SentryGunBrain_switch_off(self, ...)
	end
end

if global_sentriesautopickup_toggle then
	if SentryGunBase then SentryGunBase.DEPLOYEMENT_COST = {1,1,1} end -- not cost ammo
	managers.mission._fading_debug_output:script().log('Sentries Auto Pickup - Activated',  Color.green)
else
	if SentryGunBase then SentryGunBase.DEPLOYEMENT_COST = {0.7,0.75,0.8} end -- default is {0.7,0.75,0.8}
	managers.mission._fading_debug_output:script().log('Sentries Auto Pickup - Deactivated',  Color.red)
end

