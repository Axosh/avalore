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

function modifier_item_essence_of_shadow:OnCreated(event)
    self.invis_fade = self:GetAbility():GetSpecialValueFor("invis_delay")
    
    -- local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    -- ParticleManager:ReleaseParticleIndex(particle)
    self:SetStackCount(0) -- start out invis when trigger the spell
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