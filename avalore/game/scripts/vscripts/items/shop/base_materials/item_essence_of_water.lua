item_essence_of_water = class({})

LinkLuaModifier( "modifier_item_essence_of_water", "items/shop/base_materials/item_essence_of_water.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aquatic_agility", "items/shop/base_materials/item_essence_of_water.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wet", "scripts/vscripts/modifiers/elemental_status/modifier_wet.lua", LUA_MODIFIER_MOTION_NONE )

function item_essence_of_water:GetIntrinsicModifierName()
    return "modifier_item_essence_of_water"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_essence_of_water = modifier_item_essence_of_water or class({})

function modifier_item_essence_of_water:IsHidden()      return true  end
function modifier_item_essence_of_water:IsDebuff()      return false end
function modifier_item_essence_of_water:IsPurgable()    return false end
function modifier_item_essence_of_water:RemoveOnDeath() return false end


function modifier_item_essence_of_water:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_item_essence_of_water:OnCreated(kv)
    self.item_ability       = self:GetAbility()
    self.speed_in_water     = self.item_ability:GetSpecialValueFor("speed_in_water")
    self.douse_duration     = self.item_ability:GetSpecialValueFor("douse_duration")

    if not IsServer() then return end
    self:StartIntervalThink( FrameTime() )
end

-- water is at a low z value, just use that as a shortcut
function modifier_item_essence_of_water:IsActive()
    return self:GetParent():GetAbsOrigin().z <=0.5
end

function modifier_item_essence_of_water:OnIntervalThink()
    if self:IsActive() then
        self:GetParent():AddNewModifier(self:GetParent(), 
                                        self.item_ability, 
                                        "modifier_aquatic_agility", 
                                        { speed_in_water = self.speed_in_water })
    else
        if self:GetParent():HasModifier("modifier_aquatic_agility") then
            self:GetParent():RemoveModifierByName("modifier_aquatic_agility")
        end
    end
end

function modifier_item_essence_of_water:OnAttackLanded(kv)
    if not IsServer() then return end
    
    if kv.attacker == self:GetParent() then
        print("Adding wet modifier to target: " .. kv.target:GetName())
        local wet_mod = kv.target:FindModifierByName("modifier_wet")
        if not wet_mod then
            kv.target:AddNewModifier(
					self:GetCaster(), -- player source
					self.item_ability, -- ability source
					"modifier_wet", -- modifier name
					{ } -- kv
				)
        else
            wet_mod:AddSpellDur(1, self.douse_duration)
        end
        

    end
end

-- ====================================
-- Buff Modifier
-- ====================================

modifier_aquatic_agility = modifier_aquatic_agility or class({})

function modifier_aquatic_agility:IsHidden()      return false end
function modifier_aquatic_agility:IsDebuff()      return false end
function modifier_aquatic_agility:IsPurgable()    return false end
function modifier_aquatic_agility:RemoveOnDeath() return true  end

function modifier_aquatic_agility:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end

function modifier_aquatic_agility:GetTexture()
    return "items/essence_of_water_orig"
end

function modifier_aquatic_agility:OnCreated(kv)
    self.speed_in_water = self:GetAbility():GetSpecialValueFor("speed_in_water")
    --self.speed_in_water = kv.speed_in_water
end

function modifier_aquatic_agility:GetEffectName()
    return "particles/units/heroes/hero_slardar/slardar_sprint_river.vpcf"
end

function modifier_aquatic_agility:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_aquatic_agility:GetModifierMoveSpeedBonus_Constant()
    return self.speed_in_water
end