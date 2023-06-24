item_chrysaor = class({})

LinkLuaModifier( "modifier_item_chrysaor", "items/shop/tier4/item_chrysaor.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_chrysaor_debuff", "items/shop/tier4/item_chrysaor.lua", LUA_MODIFIER_MOTION_NONE )

function item_chrysaor:GetIntrinsicModifierName()
    return "modifier_item_chrysaor"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_chrysaor = modifier_item_chrysaor or class({})

function modifier_item_chrysaor:IsHidden() return true end
function modifier_item_chrysaor:IsDebuff() return false end
function modifier_item_chrysaor:IsPurgable() return false end
function modifier_item_chrysaor:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_chrysaor:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_chrysaor:DeclareFunctions()
    return {    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_item_chrysaor:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.duration = self.item_ability:GetSpecialValueFor("duration")
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
end

function modifier_item_chrysaor:OnAttackLanded( keys )
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
    target:AddNewModifier(owner, self.item_ability, "modifier_item_chrysaor_debuff", {duration = self.duration * (1 - target:GetStatusResistance())})
end

function modifier_item_chrysaor:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

-- ====================================
-- DEBUFF MOD
-- ====================================

modifier_item_chrysaor_debuff = modifier_item_chrysaor_debuff or class({})

function modifier_item_chrysaor_debuff:IsHidden() return false end
function modifier_item_chrysaor_debuff:IsDebuff() return true end
function modifier_item_chrysaor_debuff:IsPurgable() return true end

function modifier_item_chrysaor_debuff:GetTexture()
    return "items/chrysaor_orig"
end

function modifier_item_chrysaor_debuff:OnCreated()
    self.armor_reduction = (-1) * self:GetAbility():GetSpecialValueFor("armor_reduction")
end

function modifier_item_chrysaor_debuff:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS  }
end

function modifier_item_chrysaor_debuff:GetModifierPhysicalArmorBonus()
	return self.armor_reduction
end