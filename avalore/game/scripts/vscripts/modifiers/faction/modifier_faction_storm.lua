modifier_faction_storm = class({})

-- stacks with self based on how many allies have it
function modifier_faction_storm:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_storm:IsHidden() return false end
function modifier_faction_storm:IsDebuff() return false end
function modifier_faction_storm:IsPurgable() return false end
function modifier_faction_storm:RemoveOnDeath() return false end

function modifier_faction_storm:GetTexture()
    if self:GetStackCount() < 2 then
        return "factions/storm/modifier_faction_storm_1"
    elseif self:GetStackCount() == 2 then
        return "factions/storm/modifier_faction_storm_2"
    else
        return "factions/storm/modifier_faction_storm_3"
    end

end

function modifier_faction_storm:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_razor/razor_eye_of_the_storm.vpcf", context )
end


function modifier_faction_storm:OnCreated(kv)
    if not IsServer() then return end
    self.parent = self:GetParent()
    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)

    --self.interval = FrameTime()
    self.radius = 500
    self.damage = 10
    self.damage_increment = 10
    self.interval = 5.0

    if not IsServer() then return end
    self.strikes = 1

    self.targets = {}

    self.abilityDamageType = DAMAGE_TYPE_MAGICAL
    self.target_buildings = false

    -- precache damage
	self.damageTable = {
		-- victim = target,
		attacker = self.parent,
		damage = (self.damage + (self.damage_increment * self:GetStackCount())),
		damage_type = self.abilityDamageType,
		--ability = self:GetAbility(), --Optional.
	}

    self:OnIntervalThink()
	self:StartIntervalThink(self.interval)
end

function modifier_faction_storm:RefreshFactionStacks(faction_team, modifier)
    local stack_count = 0
    local faction_heroes = {} -- track heroes in array
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if hero and hero:GetTeam() == faction_team then
                    -- if instance of modifier on team
                    if (hero:FindModifierByName(modifier:GetName())) then
                        --faction_heroes[stack_count] = hero --store ref to hero so we can update later
                        table.insert(faction_heroes, hero)
                        -- max of 3 stacks
                        if stack_count < 3 then
                            stack_count = stack_count + 1
                        end

                        -- refresh damageTable ==> maybe better to do here?
                        -- self.damageTable = {
                        --     -- victim = target,
                        --     attacker = self.parent,
                        --     damage = (self.damage + (self.damage_increment * stack_count)),
                        --     damage_type = self.abilityDamageType,
                        --     --ability = self:GetAbility(), --Optional.
                        -- }
                    end
                end
            end
        end
    end

    -- make sure all heroes of the faction have same stack count
    for _, hero in ipairs(faction_heroes) do
        hero:FindModifierByName(modifier:GetName()):SetStackCount(stack_count)
    end
end

function modifier_faction_storm:OnIntervalThink()
    --print("[modifier_faction_storm] THINKING")
    local targets = {}

	local type_filter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	if self.target_buildings then
		type_filter = type_filter + DOTA_UNIT_TARGET_BUILDING
	end

    -- find enemies
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		type_filter,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	if #enemies<1 then 
        --print("Found no Enemies to Zap")
        return 
    end

    -- sort based on health
	table.sort( enemies, function( left, right )
		return left:GetHealth() < right:GetHealth()
	end)

    -- find enemies based on number of strikes per interval
    for i=1,self.strikes do
		local target
        if target then break end
        -- find target in lowest
		for _,enemy in pairs(enemies) do
			if not targets[enemy] then
				-- check building
				if not enemy:IsBuilding() then
					targets[enemy] = true
					target = enemy
					break
				elseif (enemy:IsAncient() or enemy:IsTower() or enemy:IsBarracks()) then
					targets[enemy] = true
					target = enemy
					break
				end
			end
		end
    end

    self.damageTable.damage = (self.damage + (self.damage_increment * self:GetStackCount()))

    -- strike targets
	for enemy,_ in pairs(targets) do
		-- damage
		self.damageTable.victim = enemy
        --print("Zapping " .. enemy:GetUnitName())
		ApplyDamage( self.damageTable )

		-- play effects
		self:PlayEffects2( enemy )
	end
end

function modifier_faction_storm:PlayEffects2( enemy )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf"
	local sound_cast = "Hero_razor.lightning"

	-- Create Particle
	-- NOTE: Don't know what is the proper effect
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() + Vector(0,0,500) )
	-- ParticleManager:SetParticleControlEnt(
	-- 	effect_cast,
	-- 	0,
	-- 	self.parent,
	-- 	PATTACH_CUSTOMORIGIN,
	-- 	"",
	-- 	self.parent:GetOrigin() + Vector(0,0,300), -- unknown
	-- 	false -- unknown, true
	-- )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		enemy,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, enemy )
end