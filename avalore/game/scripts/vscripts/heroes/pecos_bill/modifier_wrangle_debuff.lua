modifier_wrangle_debuff = class({})

function modifier_wrangle_debuff:IsHidden() return false end
function modifier_wrangle_debuff:IsDebuff() return true end
function modifier_wrangle_debuff:IsStunDebuff() return true end
function modifier_wrangle_debuff:IsPurgable() return true end

function modifier_wrangle_debuff:OnCreated(kv)
    if not IsServer() then return end
    self.parent = self:GetParent()

	-- references
	self.height = 0 --self:GetAbility():GetSpecialValueFor( "visual_height" )
	self.rate = self:GetAbility():GetSpecialValueFor( "animation_rate" )

	self.distance = 150
	self.speed = 900
	self.interval = 0.1

--	if not IsServer() then return end

	--PrintTable(kv)

	self.center = Vector(kv.center_x, kv.center_y, kv.center_z)
	self.phase = 1

	--self.center = kv.center --:GetAbsOrigin()  --EntIndexToHScript( kv.center )
    --PrintVector(self.center, "Center")

	-- apply motion controller
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end

    -- TODO: implement drag
	--self:StartIntervalThink( self.interval )

	-- Play Effects
	self:PlayEffects1()
end

function modifier_wrangle_debuff:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_wrangle_debuff:OnRemoved()
end

function modifier_wrangle_debuff:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_wrangle_debuff:DeclareFunctions()
	return {
            MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		    MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
            }
end

function modifier_wrangle_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_wrangle_debuff:GetOverrideAnimationRate()
	return self.rate
end

function modifier_wrangle_debuff:CheckState()
	return  {
                [MODIFIER_STATE_STUNNED] = true,
            }
end

function modifier_wrangle_debuff:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
	-- get data
    --PrintVector(me:GetOrigin(), "Origin")
	local origin = me:GetOrigin()
	local dir = (self.center-origin)
	local dist = dir:Length2D()
	dir.z = 0
	dir = dir:Normalized()

	-- check if close
	if self.phase == 1 and dist<self.distance then
		--self:GetParent():RemoveHorizontalMotionController( self )

		self:PlayEffects2( dir )
		self.phase = 2
		self.speed = 400

		return
	end

	-- move closer to center
	if self.phase == 1 then
		local target = dir * self.speed*dt
		me:SetOrigin( origin + target )
	else
		local caster_loc = self:GetCaster():GetOrigin()
		dir = (caster_loc-origin)
		dist = 128 --dir:Length2D()
		dir.z = 0
		dir = dir:Normalized()
		local target = dir * self.speed*dt
		me:SetOrigin( origin + target )
	end
end

function modifier_wrangle_debuff:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_wrangle_debuff:PlayEffects1()
	if not IsServer() then return end
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_target.vpcf"
	local sound_cast = "Hero_Hoodwink.Bushwhack.Target"

	-- Get Data

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	--ParticleManager:SetParticleControl( effect_cast, 15, self.center )
	ParticleManager:SetParticleControl( effect_cast, 15, self.parent:GetAbsOrigin() )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self.parent )
end


function modifier_wrangle_debuff:PlayEffects2( dir )
	-- Get Resources
	local particle_cast = "particles/tree_fx/tree_simple_explosion.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end