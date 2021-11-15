modifier_erect_wall_thinker = class({})

function modifier_erect_wall_thinker:IsHidden()     return true end
--function modifier_erect_wall_thinker:IsDebuff()     return false end
--function modifier_erect_wall_thinker:IsStunDebuff() return false end
function modifier_erect_wall_thinker:IsPurgable()   return false end

function modifier_erect_wall_thinker:OnCreated(kv)
    -- self.caster     = self:GetCaster()
    -- self.ability    = self:GetAbility()
    -- self.team       = self.caster:GetTeamNumber()

    -- local length = self:GetAbility():GetSpecialValueFor("width")

    -- if not IsServer() then return end
end

function modifier_erect_wall_thinker:OnRefresh(kv)

end

function modifier_erect_wall_thinker:OnDestroy(kv)
    if IsServer() then
		-- Effects
		local sound_cast = "Hero_EarthShaker.FissureDestroy"
		EmitSoundOnLocationWithCaster(self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
		UTIL_Remove(self:GetParent())
	end
end

-- function modifier_erect_wall_thinker:PlayEffects()
--     local particle = "particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_gravelmaw.vpcf"

--     local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
-- 	ParticleManager:SetParticleControl( effect_cast, 0, self.origin )
-- 	ParticleManager:SetParticleControl( effect_cast, 1, self.target )
-- 	-- ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- buff particle
-- 	self:AddParticle(
-- 		effect_cast,
-- 		false, -- bDestroyImmediately
-- 		false, -- bStatusEffect
-- 		-1, -- iPriority
-- 		false, -- bHeroEffect
-- 		false -- bOverheadEffect
-- 	)
-- end