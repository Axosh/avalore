ability_whirlpool = class({})

LinkLuaModifier( "modifier_ability_whirlpool_thinker",  "heroes/davy_jones/ability_whirlpool.lua",  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_whirlpool_pull",     "heroes/davy_jones/ability_whirlpool.lua",  LUA_MODIFIER_MOTION_NONE )

function ability_whirlpool:Precache( context )
    PrecacheResource("particle", "particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_skills/kunkka_spell_torrent_bubbles_fxset.vpcf",    context)
end

function ability_whirlpool:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        local cursor_pos = self:GetCursorPosition()

        local bubbles_pfx = ParticleManager:CreateParticleForTeam("particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_skills/kunkka_spell_torrent_bubbles_fxset.vpcf", PATTACH_ABSORIGIN, caster, caster:GetTeam())
		ParticleManager:SetParticleControl(bubbles_pfx, 0, cursor_pos)
        ParticleManager:SetParticleControl(bubbles_pfx, 1, Vector(radius,0,0))
        
        EmitSoundOnLocationWithCaster(cursor_pos, "Ability.pre.Torrent", caster)

        self.thinker = CreateModifierThinker(caster, self, "modifier_ability_whirlpool_thinker", {duration = duration}, cursor_pos, caster:GetTeamNumber(), false)
    end
end

function ability_whirlpool:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

-- ====================================================================
-- MODIFIER: modifier_ability_whirlpool_thinker
-- ====================================================================

modifier_ability_whirlpool_thinker = modifier_ability_whirlpool_thinker or class({})

function modifier_ability_whirlpool_thinker:OnCreated(keys)
    if IsServer() then
        self.radius = self:GetAbility():GetAOERadius()

        local enemies = FindUnitsInRadius(  self:GetCaster():GetTeamNumber(),
                                            self:GetParent():GetAbsOrigin(),
                                            nil,
                                            self.radius,
                                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                                            DOTA_UNIT_TARGET_HERO,
                                            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                                            FIND_ANY_ORDER,
                                            false)
        
        GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.radius, false)

        self:StartIntervalThink(FrameTime())
    end
end

function modifier_ability_whirlpool_thinker:OnIntervalThink()
    if IsServer() then
        --self.think_time = self.think_time + FrameTime()

        -- Pull effect
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _,enemy in pairs(enemies) do
            if not enemy:IsBoss() then
                print("Added pull modifier to " .. enemy:GetName())
                enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ability_whirlpool_pull", {})
            end
        end
    end
end

-- ====================================================================
-- MODIFIER: modifier_ability_whirlpool_pull
-- ====================================================================

modifier_ability_whirlpool_pull = modifier_ability_whirlpool_pull or class({})

function modifier_ability_whirlpool_pull:IsDebuff()		                return true end
function modifier_ability_whirlpool_pull:IsHidden() 		            return false end
function modifier_ability_whirlpool_pull:IsPurgable() 		            return false end
function modifier_ability_whirlpool_pull:IsPurgeException()             return false end
function modifier_ability_whirlpool_pull:RemoveOnDeath()	            return false end
function modifier_ability_whirlpool_pull:IsStunDebuff() 	            return true end
function modifier_ability_whirlpool_pull:IsMotionController()           return true end
function modifier_ability_whirlpool_pull:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_LOWEST end

function modifier_ability_whirlpool_pull:OnCreated()
	if IsServer() then
        if self:GetParent():IsBoss() then self:Destroy() end
        self:StartIntervalThink(FrameTime())
        self.pull_radius = 1200
    end
end

function modifier_ability_whirlpool_pull:OnIntervalThink()
    local ability = self:GetAbility()
	if not ability:IsInAbilityPhase() then
		self:Destroy()
	end
	if ability.thinker then
		local distance = CalcDistanceBetweenEntityOBB(ability.thinker, self:GetParent())
		if distance > self.pull_radius then
			self:Destroy()
		end
	end
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_ability_whirlpool_pull:HorizontalMotion(unit, time)
	self.pull_distance =  400 / (1.0 / FrameTime())
	local thinker = self:GetAbility().thinker
	local pos = unit:GetAbsOrigin()
	if thinker and not thinker:IsNull() then
		local thinker_pos = thinker:GetAbsOrigin()
		local next_pos = GetGroundPosition((pos + (thinker_pos - pos):Normalized() * self.pull_distance), unit)
		unit:SetAbsOrigin(next_pos)
	end
end

function modifier_ability_whirlpool_pull:OnDestroy()
	if not IsServer() then return end
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end