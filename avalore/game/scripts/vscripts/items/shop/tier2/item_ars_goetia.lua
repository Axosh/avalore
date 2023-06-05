item_ars_goetia = class({})

LinkLuaModifier( "modifier_item_ars_goetia", "items/shop/components/item_ars_goetia.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arcane_amplification", "items/shop/base_materials/item_essence_of_arcane.lua", LUA_MODIFIER_MOTION_NONE )

function item_ars_goetia:GetIntrinsicModifierName()
    return "modifier_item_ars_goetia"
end

function item_ars_goetia:OnSpellStart()
    self.caster		= self:GetCaster()
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_ars_goetia = modifier_item_ars_goetia or class({})

function modifier_item_ars_goetia:IsHidden() return true end
function modifier_item_ars_goetia:IsDebuff() return false end
function modifier_item_ars_goetia:IsPurgable() return false end
function modifier_item_ars_goetia:RemoveOnDeath() return false end

function modifier_item_ars_goetia:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_item_ars_goetia:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_mana_regen   = self.item_ability:GetSpecialValueFor("passive_mana_regen")
    self.orb_duration           = self.item_ability:GetSpecialValueFor("orb_duration")
    self.magic_dmg_amp      = self.item_ability:GetSpecialValueFor("magic_dmg_amp")
end

function modifier_item_ars_goetia:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_ars_goetia:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_ars_goetia:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_essence_of_arcane:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_essence_of_arcane:OnAttackLanded(kv)
    local caster = self:GetCaster()
    if kv.attacker == caster then
        local dur_resist = self.orb_duration * (1 - kv.target:GetStatusResistance())
        kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_arcane_amplification", {duration = dur_resist, magic_dmg_amp = self.magic_dmg_amp})
    end
end