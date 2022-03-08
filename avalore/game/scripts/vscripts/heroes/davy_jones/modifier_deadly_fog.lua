require("references")
require(REQ_ABILITY_AOEDAMAGE)

modifier_deadly_fog = class({})

function modifier_deadly_fog:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_deadly_fog:IsDebuff()
	return false
end

function modifier_deadly_fog:IsHidden()
	return false
end

function modifier_deadly_fog:IsPurgable()
	return true
end

function modifier_deadly_fog:OnCreated(kv)
    if IsServer() then
        print("Got in modifier_deadly_fog:OnCreated()")
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()

        --local particle_deadly_fog       = "particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf"--"particles/units/heroes/hero_visage/visage_grave_chill_fog.vpcf"
        local particle_deadly_fog       = "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_shroud.vpcf"

        -- from config file
        self.damage = self.ability:GetSpecialValueFor("damage")
        self.radius = kv.radius --self.ability:GetSpecialValueFor("radius")
        print("Radius initialized to " .. tostring(self.radius))
        self.damage_interval = self.ability:GetSpecialValueFor("damage_interval")

        -- calculated values
        --self.damage_per_instance = self.damage * self.damage_interval

        -- release old particles if exist
        -- TODO: need to release if die?
        if self.particle_deadly_fog_fx == nil then
            print("Trying to attach particle to: " .. self:GetParent():GetName() .. " at location: (" .. self:GetParent():GetAbsOrigin().x .. ", " .. self:GetParent():GetAbsOrigin().y .. ", " .. self:GetParent():GetAbsOrigin().z .. ")")
            self.particle_deadly_fog_fx = ParticleManager:CreateParticle(particle_deadly_fog, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            --ParticleManager:SetParticleControl(self.particle_deadly_fog_fx, 0, Vector(0, 0, 0))
            --ParticleManager:SetParticleControlEnt( self.particle_deadly_fog_fx, 6, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true )
            ParticleManager:SetParticleControl(self.particle_deadly_fog_fx, 5, Vector(self.radius * 1.2, 0, 0))

            --ParticleManager:SetParticleControl(self.particle_deadly_fog_fx, 5, Vector(self.radius, 0, 0))

            --ParticleManager:SetParticleControl( self.particle_deadly_fog_fx, 0, self:GetCaster():GetAbsOrigin() )
            --ParticleManager:SetParticleControl( self.particle_deadly_fog_fx, 1, Vector( self.radius, 1, 1 ) )
            
            --ParticleManager:DestroyParticle(self.particle_deadly_fog_fx, false)
            --ParticleManager:ReleaseParticleIndex(self.particle_deadly_fog_fx)
        end

        if self.caster:HasTalent("talent_blinding_fog") then
            --local aura_particle = ParticleManager:CreateParticle("particles/hero/sand_king/sandking_sandstorm_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            local aura_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            --ParticleManager:SetParticleControl(aura_particle, 5, Vector(self.radius * 1.1, 0, 0))
            -- ParticleManager:SetParticleControl(aura_particle, 0, self:GetParent():GetAbsOrigin())
            -- ParticleManager:SetParticleControl(aura_particle, 1, Vector(self.radius, self.radius, 1))

            ParticleManager:SetParticleControl(aura_particle, 1, self.caster:GetAbsOrigin())
        	ParticleManager:SetParticleControl(aura_particle, 2, Vector(self.radius, self.radius, self.radius))
            ParticleManager:SetParticleControl(aura_particle, 3, self.caster:GetAbsOrigin())

            -- color (gray)
            --ParticleManager:SetParticleControl(aura_particle, 3, Vector(200, 200, 200))
            
            self:AddParticle(aura_particle, false, false, -1, false, false)
        end

        --self.particle_deadly_fog_fx = ParticleManager:CreateParticle(particle_deadly_fog, PATTACH_ABSORIGIN_FOLLOW, caster)
        --ParticleManager:SetParticleControl(self.particle_deadly_fog_fx, 0, caster:GetAbsOrigin())
        --ParticleManager:SetParticleControl(self.particle_deadly_fog_fx, 1, Vector(radius, radius, 0))

        self:StartIntervalThink( self.damage_interval )
    end
end

function modifier_deadly_fog:OnDestroy(keys)
    if self.particle_deadly_fog_fx ~= nil then
        ParticleManager:DestroyParticle(self.particle_deadly_fog_fx, false)
		ParticleManager:ReleaseParticleIndex(self.particle_deadly_fog_fx)
		self.particle_deadly_fog_fx = nil
    end
end

function modifier_deadly_fog:OnIntervalThink()
    if IsServer() then
        AOEMagicDamage( self.caster,
                        self.ability,
                        self.caster:GetAbsOrigin(),
                        self.radius,
                        self.damage)
    end
end

function modifier_deadly_fog:GetOverrideAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_1
end