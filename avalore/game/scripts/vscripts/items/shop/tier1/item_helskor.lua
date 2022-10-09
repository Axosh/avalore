item_helskor = class({})

LinkLuaModifier( "modifier_avalore_ghost", "scripts/vscripts/modifiers/base_spell/modifier_avalore_ghost.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_helskor", "items/shop/tier1/item_helskor.lua", LUA_MODIFIER_MOTION_NONE )

function item_helskor:GetIntrinsicModifierName()
    return "modifier_item_helskor"
end

function item_helskor:OnSpellStart()
    local caster = self:GetCaster()
	local ability = self
	local sound_cast = "DOTA_Item.PhaseBoots.Activate"
    local phase_duration = ability:GetSpecialValueFor("phase_duration")

    EmitSoundOn(sound_cast, caster)
    caster:AddNewModifier(caster, ability, "modifier_avalore_ghost", {duration = phase_duration})
end


-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_helskor = modifier_item_helskor or class({})

function modifier_item_helskor:IsHidden()      return true  end
function modifier_item_helskor:IsDebuff()      return false end
function modifier_item_helskor:IsPurgable()    return false end
function modifier_item_helskor:RemoveOnDeath() return false end
function modifier_item_helskor:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE -- allow stacking with self
end

function modifier_item_helskor:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
            }
end

function modifier_item_helskor:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_damage = self.item_ability:GetSpecialValueFor("bonus_damage")
end

function modifier_item_helskor:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

function modifier_item_helskor:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end
