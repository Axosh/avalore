
function ability_ul_grab:OnSpellStart()
	local target = self:GetCursorTarget()
	
	if target:TriggerSpellAbsorb(self) then return end
	
	self:GetCaster():EmitSound("Hero_Batrider.FlamingLasso.Cast")
end