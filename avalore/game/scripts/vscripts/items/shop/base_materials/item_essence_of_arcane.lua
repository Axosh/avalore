item_essence_of_arcane = class({})

LinkLuaModifier( "modifier_item_essence_of_arcane", "items/shop/base_materials/item_essence_of_arcane.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arcane_amplification", "items/shop/base_materials/item_essence_of_arcane.lua", LUA_MODIFIER_MOTION_NONE )

function item_essence_of_arcane:GetIntrinsicModifierName()
    return "modifier_item_essence_of_arcane"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_essence_of_arcane = modifier_item_essence_of_arcane or class({})

function modifier_item_essence_of_arcane:IsHidden()      return true  end
function modifier_item_essence_of_arcane:IsDebuff()      return false end
function modifier_item_essence_of_arcane:IsPurgable()    return false end
function modifier_item_essence_of_arcane:RemoveOnDeath() return false end

function modifier_item_essence_of_arcane:DeclareFunctions()
    return {    MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_item_essence_of_arcane:OnCreated(kv)
    self.item_ability       = self:GetAbility()
    self.bonus_mana_regen   = self.item_ability:GetSpecialValueFor("passive_mana_regen")
    self.duration           = self.item_ability:GetSpecialValueFor("duration")
    self.magic_dmg_amp      = self.item_ability:GetSpecialValueFor("magic_dmg_amp")
end

function modifier_item_essence_of_arcane:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_essence_of_arcane:OnAttackLanded(kv)
    --if not IsServer() then return end

    local caster = self:GetCaster();
    if kv.attacker == caster then
        local dur_resist = self.duration * (1 - kv.target:GetStatusResistance())
        kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_arcane_amplification", {duration = dur_resist, magic_dmg_amp = self.magic_dmg_amp})
    end
end

-- ====================================
-- DEBUFF MOD 
-- ====================================

modifier_arcane_amplification = modifier_arcane_amplification or class({})

function modifier_arcane_amplification:IsHidden()      return false end
function modifier_arcane_amplification:IsDebuff()      return true  end
function modifier_arcane_amplification:IsPurgable()    return true  end
function modifier_arcane_amplification:RemoveOnDeath() return true  end

function modifier_arcane_amplification:GetTexture()
    return "items/essence_of_arcane_orig"
end

function modifier_arcane_amplification:GetEffectName()
	return "particles/items2_fx/veil_of_discord_debuff.vpcf"
end

function modifier_arcane_amplification:DeclareFunctions()
    return {    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
                MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_arcane_amplification:OnCreated(kv)
    self.magic_dmg_amp = self:GetAbility():GetSpecialValueFor("magic_dmg_amp")
    --self.magic_dmg_amp = kv.magic_dmg_amp
end

function modifier_arcane_amplification:GetModifierIncomingDamage_Percentage(kv)
	if kv.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		return self.magic_dmg_amp
	end
end

function modifier_arcane_amplification:OnTooltip()
	return self.magic_dmg_amp
end