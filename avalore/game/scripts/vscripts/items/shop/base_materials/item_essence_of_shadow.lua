item_essence_of_shadow = class({})

LinkLuaModifier( "modifier_item_essence_of_shadow", "items/shop/base_materials/item_essence_of_shadow.lua", LUA_MODIFIER_MOTION_NONE )

function item_essence_of_shadow:GetIntrinsicModifierName()
    return "modifier_item_essence_of_shadow"
end

modifier_item_essence_of_shadow = modifier_item_essence_of_shadow or class({})

function modifier_item_essence_of_shadow:IsHidden() return true end
function modifier_item_essence_of_shadow:IsDebuff() return false end
function modifier_item_essence_of_shadow:IsPurgable() return false end
function modifier_item_essence_of_shadow:RemoveOnDeath() return false end

function modifier_item_essence_of_shadow:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
            MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_item_essence_of_shadow:GetModifierInvisibilityLevel()
    if self:GetStackCount() == 0 then
        return 1 -- invis
    else
        return 0 -- visible
    end
end

function modifier_item_essence_of_shadow:OnCreated(kv)
    self.invis_fade = self:GetAbility():GetSpecialValueFor("invis_delay")
    self.prev_loc = self:GetCaster():GetAbsOrigin()

    if not IsServer() then return end
    if kv.isCosmetic then
        -- if we're a cosmetic, try to keep up with the stack count on the hero (particularly because Robin Hood can change cosmetics)
        if self:GetCaster():GetOwnerEntity():FindModifierByName(self:GetName()) then
            self.cooldown = self:GetCaster():GetOwnerEntity():FindModifierByName(self:GetName()):GetStackCount()
        else
            self.cooldown = self:GetCaster():GetOwnerEntity():FindModifierByName("modifier_item_essence_of_shadow"):GetStackCount()
        end
    else
        self.cooldown = self.invis_fade - self:GetParent():FindModifierByName("modifier_item_essence_of_shadow"):GetStackCount()
    end

    self:SetStackCount(self.invis_fade)
    self:StartIntervalThink( 1 )
end

-- break on right-click attack
function modifier_item_essence_of_shadow:OnAttack(keys)
    if not IsServer() then return end

    local attacker = keys.attacker
    -- Only apply if the parent is the one attacking
    if self:GetParent() == attacker then
        self:SetStackCount(self.cooldown)
    end
    
end

-- break on spell cast
function modifier_item_essence_of_shadow:OnAbilityFullyCast(keys)
    if not IsServer() then return end

    local caster = keys.unit
    -- Only apply if the parent is the one attacking
    if self:GetParent() == caster then
        self:SetStackCount(self.cooldown)
    end
end

function modifier_item_essence_of_shadow:OnIntervalThink()
    if not IsServer() then return end

    local stacks = self:GetStackCount()
    if stacks > 0 and (self.prev_loc == self:GetCaster():GetAbsOrigin()) then
        self:SetStackCount(stacks - 1)
        if (stacks - 1 ) == 0 then
            local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
            ParticleManager:ReleaseParticleIndex(particle)
        end
    elseif self.prev_loc ~= self:GetCaster():GetAbsOrigin() then
        self:SetStackCount(self.invis_fade)
    end
    self.prev_loc = self:GetCaster():GetAbsOrigin()
end