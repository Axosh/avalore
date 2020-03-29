require("constants")
modifier_flag_morale = class({})

function modifier_flag_morale:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_flag_morale:IsHidden() return false end
function modifier_flag_morale:IsDebuff() return false end
function modifier_flag_morale:IsPurgable() return false end

function modifier_flag_morale:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    if IsServer() then
        self:SetStackCount(1)
        print("Morale Aura Created for " .. self:GetParent():GetName() .. "|| Stack Count = " .. self:GetStackCount())
    end
    
    --self.bonus_self = self.ability:GetSpecialValueFor("bonus_self")

    -- if IsServer() then
    --     existing_modifier = self:GetParent():FindModifierByName("modifier_flag_morale")
    --     if existing_modifier then
    --         print("Found modifier_flag_morale -- incrementing stack")
    --         existing_modifier:IncrementStackCount()
    --     else
    --         print("Creating new modifier_flag_morale")
    --         self:StartIntervalThink(0.2)
            
    --         -- since there are 2 morale flags, can stack 
    --         self:IncrementStackCount()
    --         -- if self:GetStackCount() ~= nil then
    --         --     self:SetStackCount(self:GetStackCount() + 1)
    --         -- else
    --         --     self:SetStackCount(1)
    --         -- end
    --         print("Stack count = " .. tostring(self:GetStackCount()))
    --     end
	-- end
end

-- function modifier_flag_morale:OnRefresh()
--     print("modifier_flag_morale:OnRefresh()")
--     self:IncrementStackCount()
-- end

-- function modifier_flag_morale:OnDestroy(keys)
--     print("destroying modifier_flag_morale")
--     self:DecrementStackCount()
-- end

function modifier_flag_morale:GetTexture()
    --print("Texture = " .. MODIFIER_FLAG_MORALE_TEXTURE)
    --return MODIFIER_FLAG_MORALE_TEXTURE
    --return "items/morale_aura"
    return "legion_commander_press_the_attack"
end


-- function modifier_imba_crystal_maiden_brilliance_aura:OnIntervalThink()
--     if IsServer() then
--         --self:SetStackCount(0)
--     end
-- end

-- function modifier_flag_morale:OnRefresh()
--     self:OnCreated()
-- end

function modifier_flag_morale:DeclareFunctions()
    local functs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        --MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_ABILITY_BEHAVIOR_PASSIVE,
        DOTA_ABILITY_BEHAVIOR_AURA
    }
    return functs
end

function modifier_flag_morale:GetModifierBaseDamageOutgoing_Percentage()
    --print("setting percentage to " .. tostring(self:GetStackCount() * 5))
    return self:GetStackCount() * 5
end

-- 5% bonus per stack
-- function modifier_flag_morale:GetModifierBaseAttack_BonusDamage()
--     print("Bonus dmg: " .. tostring(self:GetStackCount() * 5))
--     return self:GetStackCount() * 5
-- end

function modifier_flag_morale:GetModifierPhysicalArmorBonus()
    return self:GetStackCount() * 5
end