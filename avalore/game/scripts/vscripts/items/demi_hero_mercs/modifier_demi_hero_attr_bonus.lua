modifier_demi_hero_attr_bonus = class({})

function modifier_demi_hero_attr_bonus:IsHidden() return true end
function modifier_demi_hero_attr_bonus:IsPurgeable() return false end
function modifier_demi_hero_attr_bonus:RemoveOnDeath() return false end


function modifier_demi_hero_attr_bonus:OnCreated(kv)
    --self.manaPerLevel = 200 --kv.manaPerLevel
    self.manaPerLevel = 100
    self.msPerLevel = 25 --kv.msPerLevel
    --print(tostring(self.msPerLevel))
end


function modifier_demi_hero_attr_bonus:DeclareFunctions()
    --return {    MODIFIER_PROPERTY_HEALTH_BONUS,
    return { MODIFIER_PROPERTY_MANA_BONUS,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end

-- function modifier_demi_hero_attr_bonus:GetModifierHealthBonus()

-- end

function modifier_demi_hero_attr_bonus:GetModifierManaBonus()
    return (self:GetParent():GetLevel() - 1) * self.manaPerLevel
end

function modifier_demi_hero_attr_bonus:GetModifierMoveSpeedBonus_Constant()
    return (self:GetParent():GetLevel() - 1)  * self.msPerLevel
end