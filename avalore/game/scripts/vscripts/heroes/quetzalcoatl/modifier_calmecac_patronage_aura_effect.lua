modifier_calmecac_patronage_aura_effect = class({})

function modifier_calmecac_patronage_aura_effect:IsHidden() return false end
function modifier_calmecac_patronage_aura_effect:IsDebuff() return false end
function modifier_calmecac_patronage_aura_effect:IsPurgable() return false end


function modifier_calmecac_patronage_aura_effect:OnCreated( kv )
	self.int_bonus = self:GetAbility():GetSpecialValueFor("int_bonus")
    -- might implement this later as a talent
	-- self.regen_self = self:GetAbility():GetSpecialValueFor( "mana_regen_self" ) -- special value
	-- self.regen_ally = self:GetAbility():GetSpecialValueFor( "mana_regen" ) -- special value

end

function modifier_calmecac_patronage_aura_effect:OnRefresh( kv )
	self.int_bonus = self:GetAbility():GetSpecialValueFor("int_bonus")
	-- might implement this later as a talent
	-- self.regen_self = self:GetAbility():GetSpecialValueFor( "mana_regen_self" ) -- special value
	-- self.regen_ally = self:GetAbility():GetSpecialValueFor( "mana_regen" ) -- special value
end

function modifier_calmecac_patronage_aura_effect:OnDestroy( kv )

end


function modifier_calmecac_patronage_aura_effect:DeclareFunctions()
	return {
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
				MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
				MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
                --MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
            }
end

function modifier_calmecac_patronage_aura_effect:GetModifierBonusStats_Intellect()
    return self.int_bonus
end

function modifier_calmecac_patronage_aura_effect:GetModifierSpellAmplify_Percentage()
	--print("Calmecac Patronage Magic Amp - " .. tostring(self:GetCaster():FindTalentValue("talent_culture_hero", "magic_amp")))
	return self:GetCaster():FindTalentValue("talent_culture_hero", "magic_amp")
end

-- function modifier_calmecac_patronage_aura_effect:GetModifierConstantManaRegen()
-- 	if self:GetParent()==self:GetCaster() then return self.regen_self end
-- 	return self.regen_ally
-- end

function modifier_calmecac_patronage_aura_effect:GetModifierConstantManaRegen()
	return self:GetCaster():FindTalentValue("talent_brilliance_aura", "mana_regen")
end