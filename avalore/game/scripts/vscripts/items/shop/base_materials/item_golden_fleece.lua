item_golden_fleece = class({})

LinkLuaModifier( "modifier_item_golden_fleece",      "items/shop/base_materials/item_golden_fleece.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_golden_fleece_aura", "items/shop/base_materials/item_golden_fleece.lua", LUA_MODIFIER_MOTION_NONE )

function item_golden_fleece:GetIntrinsicModifierName()
    return "modifier_item_golden_fleece"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_golden_fleece = class({})

function modifier_item_golden_fleece:IsHidden() return true end
function modifier_item_golden_fleece:IsDebuff() return false end
function modifier_item_golden_fleece:IsPurgable() return false end
function modifier_item_golden_fleece:RemoveOnDeath() return false end
function modifier_item_golden_fleece:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_golden_fleece:IsAura()
	return true
end

function modifier_item_golden_fleece:GetAuraRadius()
	if self.item_ability then
		return self.item_ability:GetSpecialValueFor("aura_radius")
	end
end

function modifier_item_golden_fleece:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_golden_fleece:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_golden_fleece:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_golden_fleece:GetModifierAura()
	return "modifier_item_golden_fleece_aura"
end

function modifier_item_golden_fleece:OnCreated(event)
    self.item_ability = self:GetAbility()
end



-- ====================================
-- AURA MOD
-- ====================================
modifier_item_golden_fleece_aura = class({})

function modifier_item_golden_fleece_aura:IsHidden()    return false end
function modifier_item_golden_fleece_aura:IsPurgable()  return false end
function modifier_item_golden_fleece_aura:IsDebuff()    return false end

function modifier_item_golden_fleece_aura:GetTexture()
    if not self.item_ability then return end --probably dropped the item/it is mid combination

    if self.item_ability:GetName() == "modifier_item_solar_crown" then
        return "items/solar_crown_orig"
    else
        return "items/golden_fleece_orig"
    end
end

function modifier_item_golden_fleece_aura:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE  }
end

function modifier_item_golden_fleece_aura:OnCreated(event)
    if not self:GetAbility() then self:Destroy() return end
    self.item_ability = self:GetAbility()
    print("Golden Fleece Ability => " .. self:GetAbility():GetName())
    self.bonus_as = self.item_ability:GetSpecialValueFor("as_aura")
    self.bonus_ms = self.item_ability:GetSpecialValueFor("ms_aura")
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("dmg_aura")
end

function modifier_item_golden_fleece_aura:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_ms
end

function modifier_item_golden_fleece_aura:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_item_golden_fleece_aura:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end