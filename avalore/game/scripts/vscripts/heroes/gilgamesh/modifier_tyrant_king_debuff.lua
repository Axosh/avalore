modifier_tyrant_king_debuff = class({})

function modifier_tyrant_king_debuff:IsHidden()      return false end
function modifier_tyrant_king_debuff:IsPurgable()    return false end
function modifier_tyrant_king_debuff:IsDebuff()      return true end
function modifier_tyrant_king_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_tyrant_king_debuff:OnCreated()
    self.leech_percent = self:GetAbility():GetSpecialValueFor("leech_percent")
    --if not IsServer() then return end
end

function modifier_tyrant_king_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_tyrant_king_debuff:GetModifierDamageOutgoing_Percentage()
    return (self.leech_percent * -1)
end