ability_rich_poor = ability_rich_poor or class({})

LinkLuaModifier( "modifier_rich_poor", "heroes/robin_hood/modifier_rich_poor", LUA_MODIFIER_MOTION_NONE )

function ability_rich_poor:GetAbilityTextureName()
    return "rich_poor"
end

function ability_rich_poor:GetIntrinsicModifierName()
	return "modifier_rich_poor"
end

function ability_rich_poor:ProcsMagicStick()
	return false
end

function ability_rich_poor:OnToggle()
end

-- ========================================
-- INTRINSIC MODIFIER
-- ========================================

modifier_rich_poor = class({})

function modifier_rich_poor:IsHidden()
    return true
end

function modifier_rich_poor:IsPurgable()
    return false
end

function modifier_rich_poor:OnCreated(kv)
    self.
end