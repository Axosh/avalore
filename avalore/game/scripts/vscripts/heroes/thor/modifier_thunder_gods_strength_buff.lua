modifier_thunder_gods_strength_buff = class({})

function modifier_thunder_gods_strength_buff:IsPurgable() return false end

function modifier_thunder_gods_strength_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_thunder_gods_strength_buff:StatusEffectPriority()
	return 1000
end

function modifier_thunder_gods_strength_buff:GetHeroEffectName()
	return "particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf"
end

function modifier_thunder_gods_strength_buff:HeroEffectPriority()
	return 100
end

function modifier_thunder_gods_strength_buff:OnCreated( kv )
	self.gods_strength_damage = self:GetAbility():GetSpecialValueFor( "damage_amp" )

	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_gods_strength_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon" , self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head" , self:GetParent():GetOrigin(), true )
		self:AddParticle( nFXIndex, false, false, -1, false, true )
	end
end

function modifier_thunder_gods_strength_buff:OnRefresh( kv )
	self.gods_strength_damage = self:GetAbility():GetSpecialValueFor( "damage_amp" )
end

function modifier_thunder_gods_strength_buff:DeclareFunctions()
	return  {
                MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
            }
end

function modifier_thunder_gods_strength_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self.gods_strength_damage
end