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
	--return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf" --base ability - works
	--return "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_debuff.vpcf" -- attempt 1, doesn't show
	--return "particles/dev/library/base_tracking_projectile_model.vpcf" -- attempt 2, doesn't show
	--return "particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow_model.vpcf"
	return "particles/neutral_fx/prowler_shaman_stomp_debuff_shield.vpcf"
end

function modifier_marksmanship_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end