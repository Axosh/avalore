require("references")
require(REQ_LIB_TIMERS)

ability_shapeshift = class({})

LinkLuaModifier("modifier_shapeshift_eagle", "heroes/zeus/modifier_shapeshift_eagle.lua", LUA_MODIFIER_MOTION_NONE)

-- function ability_shapeshift:OnUpgrade()
-- 	if self:GetCaster():HasAbility("ability_shapeshift") then
-- 		self:GetCaster():FindAbilityByName("ability_shapeshift"):SetLevel(self:GetLevel())
-- 	end
-- end

function ability_shapeshift:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- can cast on self if magic immune, but not an enemy if they are
    -- on second thought, let's just not deal with this
    --if caster ~= target and target:IsMagicImmune() then
    if target:IsMagicImmune() then
		return nil
	end

    -- hex if cast on enemy
    if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		if not target:TriggerSpellAbsorb(self) then
            -- "Hex instantly destroys illusions."
			if target:IsIllusion() and not Custom_bIsStrongIllusion(self.parent) then
				target:Kill(target, self:GetCaster())
			else
                print("TODO")
                --target:AddNewModifier(self:GetCaster(), self, "modifier_avalore_hex", {duration = self:GetSpecialValueFor("duration_enemy")})
            end
        end
    -- transform if cast on self
    else
        local particle_cast = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
        local transformation_time = self:GetSpecialValueFor("transformation_time")
        local duration = self:GetSpecialValueFor("duration_self")

        caster:EmitSound("Hero_Beastmaster.Call.Hawk")
        caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)

        -- Add cast particle effects
        local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_cast_fx, 0 , caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_cast_fx, 1 , caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_cast_fx, 2 , caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_cast_fx, 3 , caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_cast_fx)

        -- disable during transform
        --caster:AddNewModifier(caster, ability, "modifier_transform_stun", {duration = transformation_time})

        -- trigger the transformation buff after the Timer expires
        Timers:CreateTimer(transformation_time, function()
            caster:AddNewModifier(caster, self, "modifier_shapeshift_eagle", {duration = duration})
        end)
    end

    
end
