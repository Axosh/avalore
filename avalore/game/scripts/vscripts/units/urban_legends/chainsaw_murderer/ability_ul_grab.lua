
function ability_ul_grab:OnSpellStart()
	local target = self:GetCursorTarget()
	
	if target:TriggerSpellAbsorb(self) then return end

    target:AddNewModifier(self:GetCaster(), self, "modifier_ul_grab", {})
	
	self:GetCaster():EmitSound("Hero_Batrider.FlamingLasso.Cast")

    --self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ul_grab_self", {})
end

-- ===============================================
-- MODIFIER - GRAB
-- ===============================================

modifier_ul_grab = modifier_ul_grab or class({})

function modifier_ul_grab:IsDebuff() return true end

function modifier_ul_grab:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_flaming_lasso_generic_smoke.vpcf"
end