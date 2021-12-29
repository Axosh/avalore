modifier_wukong_immortality = class({})

function modifier_wukong_immortality:IsHidden() return true end

function modifier_wukong_immortality:OnCreated(kv)
    self.rez_time = self:GetAbility():GetSpecialValueFor("rez_time")
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()

    if IsServer() then
		self.can_die = false

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_wukong_immortality:OnRefresh(kv)
    self.rez_time = self:GetAbility():GetSpecialValueFor("rez_time")
end

function modifier_wukong_immortality:OnDestroy(kv)
end

function modifier_wukong_immortality:OnIntervalThink()
    if not self.ability or self.ability:IsNull() then self:Destroy() return end

    -- If caster has sufficent mana and the ability is ready, apply
	--if (self.ability:IsOwnersManaEnough()) and (self.ability:IsCooldownReady()) and (not self.caster:HasModifier("modifier_item_imba_aegis")) then
    if (self.ability:IsOwnersManaEnough()) and (self.ability:IsCooldownReady()) then
        self.can_die = false
    else
        self.can_die = true
    end
end

function modifier_wukong_immortality:DeclareFunctions()
	return  {
                MODIFIER_PROPERTY_REINCARNATION,
                MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
                MODIFIER_EVENT_ON_DEATH
            }
end

function modifier_wukong_immortality:ReincarnateTime()
    if not IsServer() then return end

    if not self.can_die and self.caster:IsRealHero() then
        return self.rez_time
    end

    return nil
end

function modifier_wukong_immortality:GetActivityTranslationModifiers()
	if self.reincarnation_death then
		return "reincarnate"
	end

	return nil
end


-- function modifier_wukong_immortality:Reincarnate()
--     self:GetAbility():UseResources(true, false, true)

--     self:PlayEffects()
-- end

function modifier_wukong_immortality:OnDeath(kv)
	if not IsServer() then return end

    --print("modifier_wukong_immortality:OnDeath(kv)")

    local unit = kv.unit
    local reincarnate = kv.reincarnate

    --print("reincarnate = " .. tostring(reincarnate))

    -- TODO: add in aegis-check or whatever else is needed
    if reincarnate then
        self.reincarnation_death = true

        if self:GetParent() == unit then
            self:GetAbility():UseResources(true, false, true)
            self:PlayEffects()
        end
    else
        self.reincarnation_death = false
    end
end


function modifier_wukong_immortality:PlayEffects()
	-- get resources
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf"
	local sound_cast = "Hero_SkeletonKing.Reincarnate"

	-- play particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.rez_time, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- play sound
	EmitSoundOn( sound_cast, self:GetParent() )
end