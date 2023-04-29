item_circes_staff = class({})

LinkLuaModifier( "modifier_item_circes_staff", "items/shop/tier1/item_circes_staff.lua", LUA_MODIFIER_MOTION_NONE )

function item_circes_staff:GetIntrinsicModifierName()
    return "modifier_item_circes_staff"
end

function item_circes_staff:CastFilterResultTarget(target)
	-- Can't cast on allies, except for yourself
	if self:GetCaster():GetTeamNumber() == target:GetTeamNumber() and self:GetCaster() ~= target then
		return UF_FAIL_CUSTOM
	end
	
	return UnitFilter(  target,
                        DOTA_UNIT_TARGET_TEAM_BOTH,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        self:GetCaster():GetTeamNumber() )
end

function item_circes_staff:GetCustomCastErrorTarget(target)
	local caster = self:GetCaster()
	if caster:GetTeamNumber() == target:GetTeamNumber() and caster ~= target then
		return "#dota_hud_error_only_cast_on_self"
	end
end

function item_circes_staff:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local hex_duration = self:GetSpecialValueFor("hex_duration")
    local modified_duration = hex_duration

end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_circes_staff = modifier_item_circes_staff or class({})

function modifier_item_circes_staff:IsHidden() return true end
function modifier_item_circes_staff:IsDebuff() return false end
function modifier_item_circes_staff:IsPurgable() return false end
function modifier_item_circes_staff:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_circes_staff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_circes_staff:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_MANA_BONUS }
end

function modifier_item_circes_staff:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
    self.bonus_mana = self.item_ability:GetSpecialValueFor("bonus_mana")
    self:SetStackCount( 1 )
end

function modifier_item_circes_staff:GetModifierBonusStats_Intellect()
    return self.bonus_int * self:GetStackCount()
end

function modifier_item_circes_staff:GetModifierBonusStats_Strength()
    return self.bonus_str * self:GetStackCount()
end

function modifier_item_circes_staff:GetModifierBonusStats_Agility()
    return self.bonus_agi * self:GetStackCount()
end

function modifier_item_circes_staff:GetModifierConstantManaRegen()
    return self.bonus_mana_regen * self:GetStackCount()
end

function modifier_item_circes_staff:GetModifierManaBonus()
    return self.bonus_mana * self:GetStackCount()
end
