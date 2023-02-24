ability_wendigo_psychosis = class({})

LinkLuaModifier("modifier_wendigo_psychosis_passive", "items/mercs_super_creeps/ability_wendigo_psychosis.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wendigo_psychosis_debuff", "items/mercs_super_creeps/ability_wendigo_psychosis.lua", LUA_MODIFIER_MOTION_NONE)


function ability_wendigo_psychosis:GetIntrinsicModifierName()
    return "modifier_wendigo_psychosis_passive"
end

-- =============================
-- INTRINSIC MODIFIER
-- =============================

modifier_wendigo_psychosis_passive = class({})

function modifier_wendigo_psychosis_passive:IsHidden() return true end
function modifier_wendigo_psychosis_passive:IsPurgable() return false end
function modifier_wendigo_psychosis_passive:IsDebuff() return false end
--function modifier_wendigo_psychosis_passive:IsAura() return true end

function modifier_wendigo_psychosis_passive:OnCreated()
    self.radius         = self:GetAbility():GetSpecialValueFor( "radius" )
    self.duration       = self:GetAbility():GetSpecialValueFor( "duration" )
    --self.damage_per_second = self:GetAbility():GetSpecialValueFor( "damage_per_second" )
    self.pulse_cooldown = self:GetAbility():GetSpecialValueFor( "pulse_cooldown" )

    --self.emp_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_emp_explode.vpcf", PATTACH_CUSTOMORIGIN, nil)

    if not IsServer() then return end
    self:StartIntervalThink( self.pulse_cooldown )
	self:OnIntervalThink()
end

function modifier_wendigo_psychosis_passive:OnIntervalThink()
    -- Create EMP Effect
    local emp_explosion_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_emp_explode.vpcf",  PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(emp_explosion_effect, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(emp_explosion_effect, 1, Vector(self.radius, 0, 0))

    local nearby_enemy_units = FindUnitsInRadius(
					self:GetParent():GetTeam(),                         -- TEAM
					self:GetParent():GetAbsOrigin(),                    -- LOCATION
                    nil,                                                -- CACHE UNIT
                    self.radius,                                        -- RADIUS
					DOTA_UNIT_TARGET_TEAM_ENEMY,                        -- TEAM FILTER
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,     -- TYPE FILTER
					DOTA_UNIT_TARGET_FLAG_NONE,                         -- FLAG FILTER
					FIND_ANY_ORDER,                                     -- FIND ORDER
					false)                                              -- CAN GROW CACHE

    for i,unit in ipairs(nearby_enemy_units) do
        unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_wendigo_psychosis_debuff", {duration = self.duration})
    end
end

-- =============================
-- DEBUFF
-- =============================
modifier_wendigo_psychosis_debuff = class({})

function modifier_wendigo_psychosis_debuff:IsHidden() return false end
function modifier_wendigo_psychosis_debuff:IsPurgable() return true end
function modifier_wendigo_psychosis_debuff:IsDebuff() return true end

function modifier_wendigo_psychosis_debuff:OnCreated(kv)
    local damage = self:GetAbility():GetSpecialValueFor( "damage_per_second" )
    local interval = 1

    if not IsServer() then return end
    -- precache damage
    self.damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(), --Optional.
        damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
    }

    -- Start interval
    self:StartIntervalThink( interval )
    self:OnIntervalThink()
end

function modifier_wendigo_psychosis_debuff:DeclareFunctions()
	return { MODIFIER_EVENT_ON_DEATH }
end

function modifier_wendigo_psychosis_debuff:OnDeath( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		self:Destroy()
	end
end

function modifier_wendigo_psychosis_debuff:GetTexture()
    return "wendigo_psychosis"
end

function modifier_wendigo_psychosis_debuff:OnIntervalThink()
	-- apply damage
	ApplyDamage( self.damageTable )
end

function modifier_wendigo_psychosis_debuff:GetEffectName()
	return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end

function modifier_wendigo_psychosis_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end