modifier_wukong_immortality = class({})

function modifier_wukong_immortality:IsHidden() return true end

function modifier_wukong_immortality:OnCreated(kv)
    self.rez_time = self:GetAbility():GetSpecialValueFor("rez_time")
end

function modifier_wukong_immortality:OnRefresh(kv)
    self.rez_time = self:GetAbility():GetSpecialValueFor("rez_time")
end

function modifier_wukong_immortality:OnDestroy(kv)
end

function modifier_wukong_immortality:DeclareFunctions()
	return  {
                MODIFIER_PROPERTY_REINCARNATION
            }
end

function modifier_wukong_immortality:Reincarnate()
    self:GetAbility():UseResources(true, false, true)

    self:PlayEffects()
end

function modifier_wukong_immortality:PlayEffects()
	-- get resources
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf"
	local sound_cast = "Hero_SkeletonKing.Reincarnate"

	-- play particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.reincarnate_time, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- play sound
	EmitSoundOn( sound_cast, self:GetParent() )
end