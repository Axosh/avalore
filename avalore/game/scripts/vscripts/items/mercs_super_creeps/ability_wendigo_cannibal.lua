ability_wendigo_cannibal = class({})

LinkLuaModifier("modifier_wendigo_cannibal_passive", "items/mercs_super_creeps/ability_wendigo_cannibal.lua", LUA_MODIFIER_MOTION_NONE)


function ability_wendigo_cannibal:GetIntrinsicModifierName()
    return "modifier_wendigo_cannibal_passive"
end

-- =============================
-- INTRINSIC MODIFIER
-- =============================

modifier_wendigo_cannibal_passive = class({})

function modifier_wendigo_cannibal_passive:IsHidden() return false end
function modifier_wendigo_cannibal_passive:IsPurgable() return false end
function modifier_wendigo_cannibal_passive:IsDebuff() return false end

function modifier_wendigo_cannibal_passive:OnCreated()

    self.heal_pct           = self:GetAbility():GetSpecialValueFor( "heal_pct")
    self.bonus_max_hp_pct   = self:GetAbility():GetSpecialValueFor( "bonus_max_hp_pct")

    if IsServer() and self:GetStackCount() == nil then
        self:SetStackCount(0)
   end
end

function modifier_wendigo_cannibal_passive:DeclareFunctions()
	return  {
		MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
    }
end

function modifier_wendigo_cannibal_passive:GetModifierExtraHealthBonus()
    return self:GetStackCount()
end
function modifier_wendigo_cannibal_passive:OnDeath( params )
    if not IsServer() then return end

    local target = params.unit
    local attacker = params.attacker
    if (	attacker == self:GetParent() 
        and target ~= self:GetParent() 
        and attacker:IsAlive() 
        and (not target:IsIllusion()) 
        and (not target:IsBuilding())
        and (not self:GetParent():PassivesDisabled())) then
            self:SetStackCount(self:GetStackCount() + math.floor(target:GetMaxHealth() * (self.bonus_max_hp_pct / 100)))
            attacker:Heal(target:GetMaxHealth() * (self.heal_pct / 100), self:GetAbility())
    end
end