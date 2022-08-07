modifier_tomb_aura = modifier_tomb_aura or class({})

LinkLuaModifier("modifier_tomb_aura_buff",    "scripts/vscripts/heroes/anubis/modifier_tomb_aura_buff.lua", LUA_MODIFIER_MOTION_NONE)
-- TALENTS
LinkLuaModifier("modifier_talent_great_pyramid",    		  "scripts/vscripts/heroes/anubis/modifier_talent_great_pyramid.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_tomb_aura:IsHidden() return false end
function modifier_tomb_aura:IsPurgable() return false end 
function modifier_tomb_aura:IsDebuff() return false end
function modifier_tomb_aura:IsAura() return true end

function modifier_tomb_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_tomb_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO
end

function modifier_tomb_aura:GetModifierAura()
    return "modifier_tomb_aura_buff"
end

function modifier_tomb_aura:GetAuraRadius()
    if self:GetCaster():HasModifier("modifier_talent_great_pyramid") then
		return self.range + self.talent_range
	end

	return self.range
end

function modifier_tomb_aura:OnCreated()
    self.range = self:GetAbility():GetSpecialValueFor("radius")
    self.talent_range = self:GetAbility():GetSpecialValueFor("talent_bonus_radius")

    if not IsServer() then return end
    -- if the hero has the talent, then it also gets added to the pyramid so the value is available
    --print("Caster => " .. self:GetAbility():GetCaster():GetName())
    --self.radius			= self:GetAbility():GetSpecialValueFor("radius") --+ self:GetAbility():GetCaster():FindTalentValue("talent_great_pyramid", "bonus_radius")
    -- if self:GetAbility():GetCaster():HasModifier("modifier_talent_great_pyramid") then
    --     print("has talent")
    --     self.radius = self.radius + 
    -- end
    --self.radius = self:GetAbility():GetCastRange()
    if self:GetCaster():GetOwner() then
        print("Owner => " .. self:GetCaster():GetOwner():GetName())
    end

--    if not IsServer() then return end
    local aura_particle = ParticleManager:CreateParticle("particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_ring_spiral.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(aura_particle, 0, Vector(self:GetParent():GetAbsOrigin().x,self:GetParent():GetAbsOrigin().y,self:GetParent():GetAbsOrigin().z+64))
	ParticleManager:SetParticleControl(aura_particle, 10, Vector(self.radius, self.radius, 0))
    self:AddParticle(aura_particle, false, false, -1, false, false)

    aura_particle = ParticleManager:CreateParticle("particles/hero/sand_king/sandking_sandstorm_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	--ParticleManager:SetParticleControl(aura_particle, 5, Vector(self.radius * 1.1, 0, 0))
    ParticleManager:SetParticleControl(aura_particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(aura_particle, 1, Vector(self.radius, self.radius, 1))
    
	self:AddParticle(aura_particle, false, false, -1, false, false)

    -- add a visual if they have the talent
    if self:GetCaster():GetOwner():HasTalent("talent_epitaph_spells") then
        --aura_particle = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_ti6/dazzle_ti6_shallow_grave_glyph.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        aura_particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_echoslam_start_v2_glyphs.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleAlwaysSimulate(aura_particle)
        ParticleManager:SetParticleControl(aura_particle, 0, self:GetParent():GetAbsOrigin())
	    ParticleManager:SetParticleControl(aura_particle, 1, Vector(self.radius, self.radius, 1))
        self.epitaph_fx = aura_particle


        --aura_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shallow_grave_glyph.vpcff", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        aura_particle = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_ti6/dazzle_ti6_shallow_grave_glyph.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(aura_particle, 0, self:GetParent():GetAbsOrigin())
	    ParticleManager:SetParticleControl(aura_particle, 1, Vector(self.radius, self.radius, 1))
        
    end
end

function modifier_tomb_aura:OnDestroy()
    if self.epitaph_fx then
        ParticleManager:DestroyParticle(self.epitaph_fx, true)
    end
end

--function modifier_tomb_aura:

-- this is so you can't literally spawn the tomb on top of someone and keep them trapped under it
function modifier_tomb_aura:CheckState()
	return {
	    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

function modifier_tomb_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_tomb_aura:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_tomb_aura:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_tomb_aura:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_tomb_aura:OnAttackLanded(kv)
    -- make sure this is the tomb being attacked
    if kv.target == self:GetCaster() then
        local damage = 1 --creep damage
        if kv.attacker:IsRealHero() then
            damage = 4 --hero damage
        end

        --apply damage
        -- check if we need to kill tomb
		if (self:GetCaster():GetHealth() - damage) <= 0 then
            -- deal damage to the owner for failing to "protect" this tomb
            if IsServer() then
                local player_owner = self:GetCaster():GetOwner()
                player_owner:SetHealth(player_owner:GetHealth() - 400)
            end

			self:GetCaster():Kill(nil, kv.attacker)
			self:Destroy()
		else
			-- If the damage would not kill it, then simply reduce the Tombstone's health.
			self:GetCaster():SetHealth(self:GetCaster():GetHealth() - damage)
		end
    end
end