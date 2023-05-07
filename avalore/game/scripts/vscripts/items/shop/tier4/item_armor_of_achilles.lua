item_armor_of_achilles = class({})

LinkLuaModifier( "modifier_item_armor_of_achilles", "items/shop/tier4/item_armor_of_achilles.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_armor_of_achilles_ally_aura", "items/shop/tier4/item_armor_of_achilles.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_armor_of_achilles_ally_aura_buff", "items/shop/tier4/item_armor_of_achilles.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_armor_of_achilles_enemy_aura", "items/shop/tier4/item_armor_of_achilles.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_armor_of_achilles_enemy_aura_debuff", "items/shop/tier4/item_armor_of_achilles.lua", LUA_MODIFIER_MOTION_NONE )

function item_armor_of_achilles:GetIntrinsicModifierName()
    return "modifier_item_armor_of_achilles"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_armor_of_achilles = modifier_item_armor_of_achilles or class({})

function modifier_item_armor_of_achilles:IsHidden() return true end
function modifier_item_armor_of_achilles:IsDebuff() return false end
function modifier_item_armor_of_achilles:IsPurgable() return false end
function modifier_item_armor_of_achilles:RemoveOnDeath() return false end

function modifier_item_armor_of_achilles:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK }
end

function modifier_item_armor_of_achilles:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_as = self.item_ability:GetSpecialValueFor("bonus_as")
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.damage_block = self.item_ability:GetSpecialValueFor("damage_block")

    if not IsServer() then return end
	
	-- future-proofing => check to make sure they aren't able to stack it
	if not self:GetCaster():HasModifier("modifier_item_armor_of_achilles_ally_aura") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_armor_of_achilles_ally_aura", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_armor_of_achilles_enemy_aura", {})
	end
end

function modifier_item_armor_of_achilles:OnDestroy()
	if IsServer() then
		-- If it is the last Assault Cuirass in the inventory, remove the aura
		if not self:GetCaster():HasModifier("modifier_item_armor_of_achilles") then
			self:GetCaster():RemoveModifierByName("modifier_item_armor_of_achilles_ally_aura")
			self:GetCaster():RemoveModifierByName("modifier_item_armor_of_achilles_enemy_aura")
		end
	end
end

function modifier_item_armor_of_achilles:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_armor_of_achilles:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_armor_of_achilles:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_armor_of_achilles:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_item_armor_of_achilles:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

function modifier_item_armor_of_achilles:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_armor_of_achilles:GetModifierPhysical_ConstantBlock()
    return self.damage_block
end

-- ===============================================================================
-- ALLY AURA
-- ===============================================================================

modifier_item_armor_of_achilles_ally_aura = class({})

function modifier_item_armor_of_achilles_ally_aura:IsDebuff() return false end
function modifier_item_armor_of_achilles_ally_aura:AllowIllusionDuplicate() return true end
function modifier_item_armor_of_achilles_ally_aura:IsHidden() return true end
function modifier_item_armor_of_achilles_ally_aura:IsPurgable() return false end

function modifier_item_armor_of_achilles_ally_aura:GetAuraRadius()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("radius")
	end
end

function modifier_item_armor_of_achilles_ally_aura:GetAuraEntityReject(target)
	-- If the target has Siege Aura from Siege Cuirass, ignore it
	if target:HasModifier("modifier_item_armor_of_achilles_ally_aura_buff") then
		return true
	end

	return false
end

function modifier_item_armor_of_achilles_ally_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_armor_of_achilles_ally_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_armor_of_achilles_ally_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_armor_of_achilles_ally_aura:GetModifierAura()
	return "modifier_item_armor_of_achilles_ally_aura_buff"
end

function modifier_item_armor_of_achilles_ally_aura:IsAura()
	return true
end

-- ===============================================================================
-- ALLY BUFF
-- ===============================================================================

modifier_item_armor_of_achilles_ally_aura_buff = class({})

function modifier_item_armor_of_achilles_ally_aura_buff:OnCreated()
	if not self:GetAbility() then
		if IsServer() then
			self:Destroy()
		end

		return
	end

	-- Ability specials
	self.aura_as_ally = self:GetAbility():GetSpecialValueFor("aura_as_ally")
	self.aura_armor_ally = self:GetAbility():GetSpecialValueFor("aura_armor_ally")
end

function modifier_item_armor_of_achilles_ally_aura_buff:IsHidden() return false end
function modifier_item_armor_of_achilles_ally_aura_buff:IsPurgable() return false end
function modifier_item_armor_of_achilles_ally_aura_buff:IsDebuff() return false end

function modifier_item_armor_of_achilles_ally_aura_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_item_armor_of_achilles_ally_aura_buff:GetTexture()
    return "items/armor_of_achilles_orig"
end

function modifier_item_armor_of_achilles_ally_aura_buff:GetModifierAttackSpeedBonus_Constant()
	return self.aura_as_ally
end

function modifier_item_armor_of_achilles_ally_aura_buff:GetModifierPhysicalArmorBonus()
	return self.aura_armor_ally
end

function modifier_item_armor_of_achilles_ally_aura_buff:GetEffectName()
	return "particles/items_fx/aura_assault.vpcf"
end

function modifier_item_armor_of_achilles_ally_aura_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-- ===============================================================================
-- ENEMY AURA
-- ===============================================================================

modifier_item_armor_of_achilles_enemy_aura = class({})

function modifier_item_armor_of_achilles_enemy_aura:IsDebuff() return false end
function modifier_item_armor_of_achilles_enemy_aura:AllowIllusionDuplicate() return true end
function modifier_item_armor_of_achilles_enemy_aura:IsHidden() return true end
function modifier_item_armor_of_achilles_enemy_aura:IsPurgable() return false end

function modifier_item_armor_of_achilles_enemy_aura:GetAuraRadius()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("radius")
	end
end

function modifier_item_armor_of_achilles_enemy_aura:GetAuraEntityReject(target)
	-- If the target has Siege Aura from Siege Cuirass, ignore it
	if target:HasModifier("modifier_item_armor_of_achilles_enemy_aura_debuff") then
		return true
	end

	return false
end

function modifier_item_armor_of_achilles_enemy_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_item_armor_of_achilles_enemy_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_armor_of_achilles_enemy_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_armor_of_achilles_enemy_aura:GetModifierAura()
	return "modifier_item_armor_of_achilles_enemy_aura_debuff"
end

function modifier_item_armor_of_achilles_enemy_aura:IsAura()
	return true
end

-- ===============================================================================
-- ENEMY DEBUFF
-- ===============================================================================
modifier_item_armor_of_achilles_enemy_aura_debuff = class({})

function modifier_item_armor_of_achilles_enemy_aura_debuff:OnCreated()
	if not self:GetAbility() then self:Destroy() return end

	self.aura_armor_reduction_enemy = self:GetAbility():GetSpecialValueFor("aura_armor_reduction_enemy") * (-1)
end

function modifier_item_armor_of_achilles_enemy_aura_debuff:GetTexture()
    return "items/armor_of_achilles_orig"
end

function modifier_item_armor_of_achilles_enemy_aura_debuff:IsHidden() return false end
function modifier_item_armor_of_achilles_enemy_aura_debuff:IsPurgable() return false end
function modifier_item_armor_of_achilles_enemy_aura_debuff:IsDebuff() return true end

function modifier_item_armor_of_achilles_enemy_aura_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_armor_of_achilles_enemy_aura_debuff:GetModifierPhysicalArmorBonus()
	return self.aura_armor_reduction_enemy
end
