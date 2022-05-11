modifier_talent_might_of_zeus = modifier_talent_might_of_zeus or class({})

function modifier_talent_might_of_zeus:IsHidden()         return true  end
function modifier_talent_might_of_zeus:IsPurgable()       return false end
function modifier_talent_might_of_zeus:RemoveOnDeath()    return false end

function modifier_talent_might_of_zeus:OnCreated()
    self.bonus_str = self:GetCaster():FindTalentValue("modifier_talent_might_of_zeus", "bonus_str")
    print("bonus str " .. tostring(self.bonus_str))
end

function modifier_talent_might_of_zeus:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_talent_might_of_zeus:GetModifierBonusStats_Strength()
    return self.bonus_str
end