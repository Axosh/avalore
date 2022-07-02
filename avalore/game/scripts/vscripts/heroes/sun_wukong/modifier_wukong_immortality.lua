modifier_wukong_immortality = class({})

function modifier_wukong_immortality:IsHidden()
    -- hide normally, reveal if they have talent for stacks
    return not self:GetCaster():HasTalent("talent_multiple_immortality")
end
function modifier_wukong_immortality:IsPurgeable() return false end
function modifier_wukong_immortality:RemoveOnDeath() return false end
function modifier_wukong_immortality:IsPermanent() return true end

-- allow stacking
function modifier_wukong_immortality:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_wukong_immortality:OnCreated(kv)
    self.rez_time = self:GetAbility():GetSpecialValueFor("rez_time")
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    -- multiple immortality stuff
    self.restock_timer = 0 --init to 0, count up in thinker
    self.has_multiple_immortality_talent = false -- this is to track when they get it
    self.max_stacks = 0
    self:SetStackCount(0) -- 0 = use the ability, otherwise use the charge

    if IsServer() then
		self.can_die = false

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_wukong_immortality:OnStackCountChanged(stackCount)
    if not IsServer() then return end

    local max_charges = self:GetCaster():FindTalentValue("talent_multiple_immortality", "extra_rez_count")
    if self:GetStackCount() > max_charges then
        self:SetStackCount(max_charges)
    end
end

function modifier_wukong_immortality:OnRefresh(kv)
    self.rez_time = self:GetAbility():GetSpecialValueFor("rez_time")
end

function modifier_wukong_immortality:OnDestroy(kv)
end

function modifier_wukong_immortality:OnIntervalThink()
    if not self.ability or self.ability:IsNull() then self:Destroy() return end
    --print("Dur? => " .. tostring(self:GetDuration()))

    -- if they just learned the talent, initialize it
    if (not self.has_multiple_immortality_talent) and self:GetCaster():HasTalent("talent_multiple_immortality") then
        self.has_multiple_immortality_talent = true
        self.max_stacks = self:GetCaster():FindTalentValue("talent_multiple_immortality", "extra_rez_count")
        self:SetStackCount(1) -- give a charge upon learning
        --self:GetAbility():SetCurrentAbilityCharges(1)
    end

    -- if they have the talent and aren't full on stacks, then start counting up
    if self.has_multiple_immortality_talent and self:GetStackCount() < self.max_stacks then
        print("Dur Left => " .. tostring(self:GetRemainingTime()))
        if self:GetRemainingTime() <= 0.1  then -- need to approximate this, or use multiple modifiers to track it
            self:SetDuration(-1, true) --clear duration tracking
            self:IncrementStackCount()
        end
    end

    -- If caster has sufficent mana and the ability is ready, apply
	--if (self.ability:IsOwnersManaEnough()) and (self.ability:IsCooldownReady()) and (not self.caster:HasModifier("modifier_item_imba_aegis")) then
    
    if (self:GetStackCount() >= 1) or (self.ability:IsOwnersManaEnough()) and (self.ability:IsCooldownReady()) then
    --if (self:GetAbility():GetCurrentAbilityCharges() >= 1) or (self.ability:IsOwnersManaEnough()) and (self.ability:IsCooldownReady()) then
        self.can_die = false
    else
        self.can_die = true
    end
end

function modifier_wukong_immortality:CanDie()
    return self.can_die
end

function modifier_wukong_immortality:DeclareFunctions()
	return  {
                MODIFIER_PROPERTY_REINCARNATION, --links to ReincarnateTime()
                MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
                MODIFIER_EVENT_ON_DEATH,
                --MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
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
            -- NOTE: UseResources(mana: bool, gold: bool, cooldown: bool): nil
            if self:GetStackCount() >= 1 then
            --if self.has_multiple_immortality_talent and self:GetAbility():GetCurrentAbilityCharges() >= 1 then
                self:DecrementStackCount()
                local stack_cd = self:GetAbility():GetCooldown(self:GetAbility():GetLevel())
                print("Stack CD = > " .. tostring(stack_cd))
                self:SetDuration(stack_cd, true) -- start counting down stack replenish time
                --self:GetAbility():SetCurrentAbilityCharges(self:GetAbility():GetCurrentAbilityCharges() - 1)
                -- use mana, don't start the cooldown though
                self:GetAbility():UseResources(true, false, false)
            else
                -- use mana and cooldown
                self:GetAbility():UseResources(true, false, true)
            end
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