item_zoster_of_hippolyta = class({})

LinkLuaModifier( "modifier_item_zoster_of_hippolyta",        "items/shop/tier3/item_zoster_of_hippolyta.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_zoster_of_hippolyta_active", "items/shop/tier3/item_zoster_of_hippolyta.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_amazon_aura",                     "items/shop/tier3/item_zoster_of_hippolyta.lua", LUA_MODIFIER_MOTION_NONE )

function item_zoster_of_hippolyta:GetIntrinsicModifierName()
    return "modifier_item_zoster_of_hippolyta"
end

function item_zoster_of_hippolyta:GetBehavior() 
    return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
end

function item_zoster_of_hippolyta:OnSpellStart()
    EmitSoundOn("DOTA_Item.DoE.Activate", self:GetCaster())

    local allies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
		self:GetCaster():GetAbsOrigin(),
		nil,
		self:GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
		FIND_ANY_ORDER,
		false)

    for _,ally in pairs(allies) do
        local modifier_active_handler = ally:AddNewModifier(self:GetCaster(), self, "modifier_item_zoster_of_hippolyta_active", {duration = self:GetSpecialValueFor("aura_mult_duration")})
    end
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_zoster_of_hippolyta = class({})

function modifier_item_zoster_of_hippolyta:IsHidden() return true end
function modifier_item_zoster_of_hippolyta:IsDebuff() return false end
function modifier_item_zoster_of_hippolyta:IsPurgable() return false end
function modifier_item_zoster_of_hippolyta:RemoveOnDeath() return false end

function modifier_item_zoster_of_hippolyta:IsAura()
	return true
end

function modifier_item_zoster_of_hippolyta:GetAuraRadius()
	if self.item_ability then
		return self.item_ability:GetSpecialValueFor("aura_radius")
	end
end

function modifier_item_zoster_of_hippolyta:GetModifierAura()
	return "modifier_amazon_aura"
end


function modifier_item_zoster_of_hippolyta:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_zoster_of_hippolyta:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_zoster_of_hippolyta:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_zoster_of_hippolyta:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT      }
end

function modifier_item_zoster_of_hippolyta:OnCreated(event)
    self.item_ability       = self:GetAbility()
    self.bonus_str          = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi          = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_ms           = self.item_ability:GetSpecialValueFor("bonus_ms")
end

function modifier_item_zoster_of_hippolyta:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_zoster_of_hippolyta:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_zoster_of_hippolyta:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_ms
end

-- ====================================
-- ACTIVE: BATTLECRY
-- ====================================
modifier_item_zoster_of_hippolyta_active = class({})

function modifier_item_zoster_of_hippolyta_active:IsHidden()   return true end
function modifier_item_zoster_of_hippolyta_active:IsDebuff()   return false end
function modifier_item_zoster_of_hippolyta_active:IsPurgable() return true end

function modifier_item_zoster_of_hippolyta_active:GetEffectName()
	return "particles/items_fx/drum_of_endurance_buff.vpcf"
end

-- ====================================
-- PASSIVE: AMAZON AURA
-- ====================================
modifier_amazon_aura = class({})

function modifier_amazon_aura:IsHidden()    return false end
function modifier_amazon_aura:IsPurgable()  return false end
function modifier_amazon_aura:IsDebuff()    return false end

function modifier_amazon_aura:GetTexture()
    return "items/battlecry"
end

function modifier_amazon_aura:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE  }
end

function modifier_amazon_aura:OnCreated(event)
    if not self:GetAbility() then self:Destroy() return end
    self.item_ability = self:GetAbility()
    
    self.bonus_as   = self.item_ability:GetSpecialValueFor("as_aura")
    self.bonus_ms   = self.item_ability:GetSpecialValueFor("ms_aura")
    self.bonus_dmg  = self.item_ability:GetSpecialValueFor("dmg_aura")
    self.mult       = self.item_ability:GetSpecialValueFor("aura_multiplier")
end

function modifier_amazon_aura:GetModifierMoveSpeedBonus_Constant()
    local mult = 1
    if self:GetParent():HasModifier("modifier_item_zoster_of_hippolyta_active") then mult = self.mult end
    return (self.bonus_ms * mult)
end

function modifier_amazon_aura:GetModifierAttackSpeedBonus_Constant()
    local mult = 1
    if self:GetParent():HasModifier("modifier_item_zoster_of_hippolyta_active") then mult = self.mult end
	return (self.bonus_as * mult)
end

function modifier_amazon_aura:GetModifierPreAttack_BonusDamage()
    local mult = 1
    if self:GetParent():HasModifier("modifier_item_zoster_of_hippolyta_active") then mult = self.mult end
	return (self.bonus_dmg * mult)
end