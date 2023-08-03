item_frost_fair_blade = class({})

LinkLuaModifier( "modifier_item_frost_fair_blade", "items/shop/tier5/item_frost_fair_blade.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_frost_fair_blade_debuff", "items/shop/tier5/item_frost_fair_blade.lua", LUA_MODIFIER_MOTION_NONE )

function item_frost_fair_blade:GetIntrinsicModifierName()
    return "modifier_item_frost_fair_blade"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_frost_fair_blade = modifier_item_frost_fair_blade or class({})

function modifier_item_frost_fair_blade:IsHidden() return true end
function modifier_item_frost_fair_blade:IsDebuff() return false end
function modifier_item_frost_fair_blade:IsPurgable() return false end
function modifier_item_frost_fair_blade:RemoveOnDeath() return false end

function modifier_item_frost_fair_blade:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_EVENT_ON_DEATH }
end

function modifier_item_frost_fair_blade:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self.bonus_per_kill = self.item_ability:GetSpecialValueFor("bonus_per_kill")
    self.tracker_mod = self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_item_frost_fair_blade_kill_tracker", nil )
    self.tracker_mod:SetStackCount(_G.frost_fair_stacks)
end

function modifier_item_frost_fair_blade:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg + (self.tracker_mod:GetStackCount() * self.bonus_per_kill)
end

function modifier_item_frost_fair_blade:OnRemove()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.slow_hit_particle, false);
end

function modifier_item_frost_fair_blade:OnDeath(params)
    local caster = self:GetCaster()
	local target = params.unit
    local attacker = params.attacker

    -- if item owner killed a real hero increment stacks
    if (caster:IsRealHero() and 
        target:IsRealHero() and 
        caster:GetTeamNumber() ~= target:GetTeamNumber() 
        and attacker == self:GetParent() 
        and target ~= self:GetParent()
        and (not params.unit.IsReincarnating or not params.unit:IsReincarnating()) 
    ) then
        _G.frost_fair_stacks = _G.frost_fair_stacks + 1
        self.tracker_mod:IncrementStackCount()
    end
end

-- ====================================
-- DEBUFF MOD 
-- ====================================

modifier_item_frost_fair_blade_debuff = modifier_item_frost_fair_blade_debuff or class({})

function modifier_item_frost_fair_blade_debuff:IsHidden() return false end
function modifier_item_frost_fair_blade_debuff:IsDebuff() return true end
function modifier_item_frost_fair_blade_debuff:IsPurgable() return true end
function modifier_item_frost_fair_blade_debuff:RemoveOnDeath() return true end

 function modifier_item_frost_fair_blade_debuff:GetTexture()
    return "items/essence_of_frost_orig"
end

function modifier_item_frost_fair_blade_debuff:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_item_frost_fair_blade_debuff:OnCreated(kv)
    self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")

    if not IsServer() then return end
    
    self.slow_hit_particle 		= ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent());
	ParticleManager:SetParticleControl(self.slow_hit_particle, 0, self:GetParent():GetAbsOrigin());

end

function modifier_item_frost_fair_blade_debuff:GetModifierMoveSpeedBonus_Percentage()
    return (-1 * self.ms_slow)
end

function modifier_item_frost_fair_blade_debuff:GetModifierAttackSpeedBonus_Constant()
    return (-1 * self.as_slow)
end

function modifier_item_frost_fair_blade_debuff:OnRemove()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.slow_hit_particle, false);
end

-- ===========================================
-- KILL TRACKER
-- ===========================================

modifier_item_frost_fair_blade_kill_tracker = modifier_item_frost_fair_blade_kill_tracker or class({})

function modifier_item_frost_fair_blade_kill_tracker:IsHidden() return false end
function modifier_item_frost_fair_blade_kill_tracker:IsDebuff() return true end
function modifier_item_frost_fair_blade_kill_tracker:IsPurgable() return true end
function modifier_item_frost_fair_blade_kill_tracker:RemoveOnDeath() return true end


function modifier_item_frost_fair_blade_kill_tracker:OnCreated(kv)

end