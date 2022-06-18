
modifier_dust_devil_debuff = modifier_dust_devil_debuff or class({})

function modifier_dust_devil_debuff:IsHidden() return false end
function modifier_dust_devil_debuff:IsDebuff() return true end

-- function modifier_dust_devil_debuff:GetEffectName()
-- 	return "particles/units/heroes/hero_necrolyte/necrolyte_spirit_debuff.vpcf"
-- end

function modifier_dust_devil_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_dust_devil_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then
		return self:GetCaster():FindTalentValue("talent_dust_devil", "slow_pct") * (-1)
	end
end
