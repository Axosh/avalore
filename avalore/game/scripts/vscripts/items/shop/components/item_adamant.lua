item_adamant = class({})

LinkLuaModifier( "modifier_item_adamant", "items/shop/components/item_adamant.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_adamant_debuff", "items/shop/components/item_adamant.lua", LUA_MODIFIER_MOTION_NONE )

function item_adamant:GetIntrinsicModifierName()
    return "modifier_item_adamant"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_adamant = modifier_item_adamant or class({})

function modifier_item_adamant:IsHidden() return true end
function modifier_item_adamant:IsDebuff() return false end
function modifier_item_adamant:IsPurgable() return false end
function modifier_item_adamant:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_adamant:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_adamant:DeclareFunctions()
    return {    MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_item_adamant:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.duration = self.item_ability:GetSpecialValueFor("duration")
end

function modifier_item_adamant:OnAttackLanded( keys )
    if not IsServer() then return end

    local owner = self:GetParent()

    -- If this attack was not performed by the modifier's owner, do nothing
    if owner ~= keys.attacker then
        return end

    -- If this is an illusion, or the wrong team to attack, do nothing either
    local target = keys.target
    if owner:IsIllusion() then
        return end

    --TODO: check for higher priority armor reducers
    
    -- Apply Debuff
    target:AddNewModifier(owner, self.item_ability, "modifier_item_adamant_debuff", {duration = self.duration * (1 - target:GetStatusResistance())})
end

-- ====================================
-- DEBUFF MOD
-- ====================================

modifier_item_adamant_debuff = modifier_item_adamant_debuff or class({})

function modifier_item_adamant_debuff:IsHidden() return false end
function modifier_item_adamant_debuff:IsDebuff() return true end
function modifier_item_adamant_debuff:IsPurgable() return true end

function modifier_item_adamant_debuff:GetTexture()
    return "items/adamant_orig"
end

function modifier_item_adamant_debuff:OnCreated()
    self.armor_reduction = (-1) * self:GetAbility():GetSpecialValueFor("armor_reduction")
end

function modifier_item_adamant_debuff:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS  }
end

function modifier_item_adamant_debuff:GetModifierPhysicalArmorBonus()
	return self.armor_reduction
end