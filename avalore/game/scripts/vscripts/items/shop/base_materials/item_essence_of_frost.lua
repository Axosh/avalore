item_essence_of_frost = class({})

LinkLuaModifier( "modifier_item_essence_of_frost", "items/shop/base_materials/item_essence_of_frost.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frostbite", "items/shop/base_materials/item_essence_of_frost.lua", LUA_MODIFIER_MOTION_NONE )

function item_essence_of_frost:GetIntrinsicModifierName()
    return "modifier_item_essence_of_frost"
end

-- function item_essence_of_frost:GetAbilityTextureName()
--     return "items/essence_of_frost_orig"
-- end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_essence_of_frost = modifier_item_essence_of_frost or class({})

function modifier_item_essence_of_frost:IsHidden() return true end
function modifier_item_essence_of_frost:IsDebuff() return false end
function modifier_item_essence_of_frost:IsPurgable() return false end
function modifier_item_essence_of_frost:RemoveOnDeath() return false end

function modifier_item_essence_of_frost:DeclareFunctions()
    return {    MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_item_essence_of_frost:OnCreated(event)
    self.item_ability       = self:GetAbility()
    self.movespeed_slow     = self.item_ability:GetSpecialValueFor("movespeed_slow")
    self.attackspeed_slow   = self.item_ability:GetSpecialValueFor("attackspeed_slow")
    self.duration           = self.item_ability:GetSpecialValueFor("duration")
end

function modifier_item_essence_of_frost:OnAttackLanded(kv)
    if not IsServer() then return end

    local caster = self:GetCaster();
    if kv.attacker == caster and not kv.target:IsBuilding() then
        local dur_resist = self.duration * (1 - kv.target:GetStatusResistance())
        --kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_frostbite", {duration = dur_resist, as_slow = self.attackspeed_slow, ms_slow = self.movespeed_slow})
        kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_frostbite", {duration = dur_resist})
    end
end

-- ====================================
-- DEBUFF MOD 
-- ====================================

modifier_frostbite = modifier_frostbite or class({})

function modifier_frostbite:IsHidden() return false end
function modifier_frostbite:IsDebuff() return true end
function modifier_frostbite:IsPurgable() return true end
function modifier_frostbite:RemoveOnDeath() return true end

 function modifier_frostbite:GetTexture()
    return "items/essence_of_frost_orig"
--     return self:GetAbility():GetTexture()
--     --return "items/base_materials/essence_of_frost"
end

function modifier_frostbite:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_frostbite:OnCreated(kv)
    print("AS Slow => " .. tostring(self:GetAbility():GetSpecialValueFor("attackspeed_slow")))
    print("MS Slow => " .. tostring(self:GetAbility():GetSpecialValueFor("movespeed_slow")))
    self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")

    if not IsServer() then return end
    
    self.slow_hit_particle 		= ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent());
	ParticleManager:SetParticleControl(self.slow_hit_particle, 0, self:GetParent():GetAbsOrigin());

end

function modifier_frostbite:GetModifierMoveSpeedBonus_Percentage()
    return (-1 * self.ms_slow)
end

function modifier_frostbite:GetModifierAttackSpeedBonus_Constant()
    return (-1 * self.as_slow)
end

function modifier_frostbite:OnRemove()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.slow_hit_particle, false);
end