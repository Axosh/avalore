modifier_chink_in_the_armor_debuff = class({})

function modifier_chink_in_the_armor_debuff:IsHidden() return false end
function modifier_chink_in_the_armor_debuff:IsDebuff() return true end
function modifier_chink_in_the_armor_debuff:IsPurgable() return true end

function modifier_chink_in_the_armor_debuff:GetTexture()
    return "robin_hood/chink_in_the_armor"
end

function modifier_chink_in_the_armor_debuff:OnCreated(kv)
    self.armor_reduction = self:GetAbility():GetSpecialValueFor( "armor_reduction" )
    
    -- if not IsServer() then return end
    -- self:PlayEffects()
end

function modifier_chink_in_the_armor_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_chink_in_the_armor_debuff:GetModifierPhysicalArmorBonus()
    return -(self.armor_reduction)
end

-- function modifier_chink_in_the_armor_debuff:PlayEffects()

-- end


function modifier_chink_in_the_armor_debuff:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_debuff.vpcf"
end

function modifier_chink_in_the_armor_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
