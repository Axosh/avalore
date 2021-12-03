--require

ability_coyote_howl = class({})

LinkLuaModifier( "modifier_coyote_howl_fear", "scripts/vscripts/heroes/pecos_bill/modifier_coyote_howl_fear.lua", LUA_MODIFIER_MOTION_NONE )

function ability_coyote_howl:IsHiddenWhenStolen()       return false end
function ability_coyote_howl:IsRefreshable()            return true end
function ability_coyote_howl:IsStealable()              return true end
function ability_coyote_howl:IsNetherWardStealable()    return true end

function ability_coyote_howl:OnSpellStart()
	if not IsServer() then return end

    --ensure vector has a length > 0
    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    end

    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()

    -- Parameters
    local damage = self:GetSpecialValueFor("damage")
    local speed = self:GetSpecialValueFor("wave_speed")
    local wave_width = self:GetSpecialValueFor("wave_width")
    local duration = self:GetSpecialValueFor("duration")
    local primary_distance = self:GetCastRange(caster_loc,caster) + GetCastRangeIncrease(caster)

    --TODO: vision talent

    local dummy = CreateModifierThinker(self:GetCaster(), self,	nil, {}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(),	false)
    dummy:EmitSound("Hero_Lycan.Howl")

    -- Distances
		local direction = (target_loc - caster_loc):Normalized()
		local velocity = direction * speed

		local projectile =
			{
				Ability				= self,
				EffectName			= "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf",
				vSpawnOrigin		= caster_loc,
				fDistance			= primary_distance,
				fStartRadius		= wave_width,
				fEndRadius			= wave_width,
				Source				= caster,
				bHasFrontalCone		= false,
				bReplaceExisting	= false,
				iUnitTargetTeam		= self:GetAbilityTargetTeam(),
				iUnitTargetFlags	= self:GetAbilityTargetFlags(),
				iUnitTargetType		= self:GetAbilityTargetType(),
				fExpireTime 		= GameRules:GetGameTime() + 10.0,
				bDeleteOnHit		= false,
				vVelocity			= Vector(velocity.x,velocity.y,0),
				bProvidesVision		= true,
				--iVisionRadius 		= vision_aoe,
				--iVisionTeamNumber 	= caster:GetTeamNumber(),
				ExtraData			= {damage = damage, duration = duration, dummy_entindex = dummy:entindex()}
			}
		ProjectileManager:CreateLinearProjectile(projectile)
end

function ability_coyote_howl:OnProjectileThink_ExtraData(location, ExtraData)
	if ExtraData.dummy_entindex then
		--AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("vision_aoe"), self:GetSpecialValueFor("vision_duration"), false)
		EntIndexToHScript(ExtraData.dummy_entindex):SetAbsOrigin(location)
	end
end


function ability_coyote_howl:OnProjectileHit_ExtraData(target, location, ExtraData)
	if target then
		local caster = self:GetCaster()
		ApplyDamage({victim = target, attacker = caster, ability = self, damage = ExtraData.damage, damage_type = self:GetAbilityDamageType()})
		target:AddNewModifier(caster, self, "modifier_coyote_howl_fear", {duration = ExtraData.duration * (1 - target:GetStatusResistance())})
	else
		-- self:CreateVisibilityNode(location, self:GetSpecialValueFor("vision_aoe"), self:GetSpecialValueFor("vision_duration"))
		
		if ExtraData.dummy_entindex then
			EntIndexToHScript(ExtraData.dummy_entindex):ForceKill(false)
		end
	end
	return false
end