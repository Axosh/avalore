modifier_benevolence_aura_buff = class({})

function modifier_benevolence_aura_buff:IsPurgable() return false end
function modifier_benevolence_aura_buff:IsAura()     return true  end
function modifier_benevolence_aura_buff:IsDebuff()   return false end

function modifier_benevolence_aura_buff:GetTexture()
    return "gilgamesh/benevolence"
end

function modifier_benevolence_aura_buff:OnCreated()
    self.damage_buff_aura_pct = self:GetCaster():FindTalentValue("talent_benevolence", "damage_buff_aura_pct")
end

function modifier_benevolence_aura_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
    }
end

function modifier_benevolence_aura_buff:GetModifierBaseAttack_BonusDamage()
    return self.damage_buff_aura_pct
end