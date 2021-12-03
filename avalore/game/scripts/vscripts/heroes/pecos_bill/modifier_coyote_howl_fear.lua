modifier_coyote_howl_fear = class({})
function modifier_coyote_howl_fear:IsDebuff() return true end
function modifier_coyote_howl_fear:IsHidden() return false end
function modifier_coyote_howl_fear:IsPurgable() return true end
function modifier_coyote_howl_fear:IsStunDebuff() return false end
function modifier_coyote_howl_fear:RemoveOnDeath() return true end
-------------------------------------------

function modifier_coyote_howl_fear:OnCreated( params )
	local ability = self:GetAbility()
	
	if not ability then self:Destroy() return end
	
	self.armor_reduction = ability:GetTalentSpecialValueFor("armor_reduction") * (-1)
end

function modifier_coyote_howl_fear:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_coyote_howl_fear:GetModifierPhysicalArmorBonus()
	return self.armor_reduction
end

function modifier_coyote_howl_fear:GetEffectName()
	return "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf"
end

function modifier_coyote_howl_fear:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end