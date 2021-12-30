modifier_boar_gore_debuff = class({})

function modifier_boar_gore_debuff:IsDebuff() return true end
function modifier_boar_gore_debuff:IsHidden() return false end
function modifier_boar_gore_debuff:IsPurgable() return true end

function modifier_boar_gore_debuff:GetTexture()
    return "sun_wukong/boar_gore"
end

function modifier_boar_gore_debuff:OnCreated()
	-- Necessary client-side handling
	-- Ability properties
	local ability		=	self:GetAbility()
	-- Ability paramaters
	self.movespeed_slow		=	ability:GetSpecialValueFor("gore_movespeed_slow")
	--self.attackspeed_slow	=	ability:GetSpecialValueFor("attackspeed_slow")
end

function modifier_boar_gore_debuff:DeclareFunctions()
	local decFuncs ={
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		--MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return decFuncs
end

function modifier_boar_gore_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed_slow * (-1)
end

-- function modifier_boar_gore_debuff:GetModifierAttackSpeedBonus_Constant()
-- 	return self.attackspeed_slow * (-1)
-- end
