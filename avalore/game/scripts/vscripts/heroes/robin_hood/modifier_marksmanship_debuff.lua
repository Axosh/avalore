modifier_marksmanship_debuff = class({})

--------------------------------------------------------------------------------

function modifier_marksmanship_debuff:IsHidden()
	return false
end

function modifier_marksmanship_debuff:IsDebuff()
	return true
end

function modifier_marksmanship_debuff:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_marksmanship_debuff:OnCreated( kv )
	self:SetStackCount(1)
end

function modifier_marksmanship_debuff:OnRefresh( kv )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_marksmanship_debuff:GetEffectName()
	return "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_debuff.vpcf"
end

function modifier_marksmanship_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end