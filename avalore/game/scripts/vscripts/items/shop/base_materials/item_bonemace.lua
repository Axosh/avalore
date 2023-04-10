item_bonemace = class({})

LinkLuaModifier( "modifier_item_bonemace_ready", "items/shop/base_materials/item_bonemace.lua", LUA_MODIFIER_MOTION_NONE )

function item_bonemace:GetIntrinsicModifierName()
    return "modifier_item_bonemace_ready"
end

function item_bonemace:GetCooldown(level)
    return self:GetSpecialValueFor("cooldown")
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_bonemace_ready = modifier_item_bonemace_ready or class({})

function modifier_item_bonemace_ready:IsHidden() return true end
function modifier_item_bonemace_ready:IsDebuff() return false end
function modifier_item_bonemace_ready:IsPurgable() return false end
function modifier_item_bonemace_ready:RemoveOnDeath() return false end
function modifier_item_bonemace_ready:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_bonemace_ready:DeclareFunctions()
    return {  MODIFIER_EVENT_ON_ATTACK,
    MODIFIER_EVENT_ON_ATTACK_LANDED      }
end

function modifier_item_bonemace_ready:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.mini_bash = self.item_ability:GetSpecialValueFor("mini_bash")
    self.bash_dmg = self.item_ability:GetSpecialValueFor("bash_dmg")

    if IsServer() then
        self:SetStackCount( 1 )
    end
end

-- function modifier_item_bonemace_ready:OnAttackLanded()
--     if self.item_ability:IsCooldownReady()
-- end
