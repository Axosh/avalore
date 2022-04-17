modifier_faction_olympians = class({})

function modifier_faction_olympians:IsHidden() return false end
function modifier_faction_olympians:IsDebuff() return false end
function modifier_faction_olympians:IsPurgable() return false end
function modifier_faction_olympians:RemoveOnDeath() return false end

function modifier_faction_olympians:GetTexture()
    return "modifier_faction_ichor"
end

function modifier_faction_olympians:DeclareFunctions()
	return {
        --MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function modifier_faction_olympians:OnCreated( kv )
	-- references
	self.base_return_dmg = 10
	self.base_hp_regen = 2

    if not IsServer() then return end
    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)
end

function modifier_faction_olympians:RefreshFactionStacks(faction_team, modifier)
    --print()
    local stack_count = 0
    local faction_heroes = {} -- track heroes in array
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()
                if hero:GetTeam() == faction_team then
                    -- if instance of modifier on team
                    if (hero:FindModifierByName(modifier:GetName())) then
                        --print("Found on Hero: " .. hero:GetName())
                        table.insert(faction_heroes, hero)
                        -- max of 3 stacks
                        if stack_count < 3 then
                            stack_count = stack_count + 1
                        end
                    end
                end
            end
        end
    end
    print("Stack Count = " .. tostring(stack_count))

    -- make sure all heroes of the faction have same stack count
    for _, hero in ipairs(faction_heroes) do
        hero:FindModifierByName(modifier:GetName()):SetStackCount(stack_count)
    end
end

--function modifier_faction_olympians:OnAttacked( kv )
function modifier_faction_olympians:OnTakeDamage( kv )
	if IsServer() then
		-- doesn't work on illusions or when broken
		if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then
			return
		end
		-- if kv.unit==self:GetParent() or self:FlagExist( kv.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) then
		-- 	return
		-- end

		-- get damage
		local damage = (self.base_return_dmg * self:GetStackCount())

		local caster = self:GetCaster()
		local parent = self:GetParent()
		--local ability = self:GetAbility()
		local attacker = kv.attacker
		local target = kv.unit
		--local particle_return = "particles/econ/items/lifestealer/ls_ti10_immortal/ls_ti10_immortal_infest_gold_groundfollow_bloodvertical.vpcf"
        --local particle_return = "particles/econ/items/lifestealer/ls_ti10_immortal/ls_ti10_immortal_infest_gold_radial_burst_blood.vpcf"
        local particle_return = "particles/econ/items/storm_spirit/strom_spirit_ti8/gold_storm_spirit_ti8_overload_active_i.vpcf"

        --if target and target:GetName() == "npc_dota_hero_brewmaster" then
        -- if attacker and target then
        -- --if kv.unit == self:GetParent() then
        --    print("Attacker: " .. attacker:GetName()) 
        --    print("Attacker Team: " .. tostring(attacker:GetTeamNumber()))
        --    print("Our Team: " .. tostring(parent:GetTeamNumber()))
        --    print("Target: " .. target:GetName())
        --    print("Parent: " .. parent:GetName())
        -- end

		-- only return on units attacking
		if attacker:GetTeamNumber() ~= parent:GetTeamNumber() and parent == target then --and not attacker:IsOther() then
            --print("Return Damage: " .. tostring(damage))

			-- particles
			local particle_return_fx = ParticleManager:CreateParticle(particle_return, PATTACH_ABSORIGIN_FOLLOW, parent)
			--ParticleManager:SetParticleControlEnt(particle_return_fx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			--ParticleManager:SetParticleControlEnt(particle_return_fx, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
            --ParticleManager:SetParticleControl(particle_return_fx, 0, Vector(0, 0, 0))
            ParticleManager:SetParticleControl(particle_return_fx, 2, Vector(150, 150, 150))
            ParticleManager:SetParticleControlEnt(
                particle_return_fx,
                3,
                self:GetParent(),
                PATTACH_ABSORIGIN_FOLLOW,
                nil,
                self:GetParent():GetOrigin(), -- unknown
                true -- unknown, true
            )
			ParticleManager:ReleaseParticleIndex(particle_return_fx)
			
			-- Apply damage on attacker
			ApplyDamage({
				victim = attacker,
				attacker = parent,
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
				ability = nil
			})
		end

		-- Play effects
		-- if kv.attacker:IsConsideredHero() then
		-- 	self:PlayEffects( kv.attacker )
		-- end
	end
end

function modifier_faction_olympians:GetModifierConstantHealthRegen()
	if self:GetCaster():PassivesDisabled() then return end
	return (self.base_hp_regen * self:GetStackCount())
end

-- Helper: Flag operations
-- function modifier_faction_olympians:FlagExist(a,b)--Bitwise Exist
-- 	local p,c,d=1,0,b
-- 	while a>0 and b>0 do
-- 		local ra,rb=a%2,b%2
-- 		if ra+rb>1 then c=c+p end
-- 		a,b,p=(a-ra)/2,(b-rb)/2,p*2
-- 	end
-- 	return c==d
-- end

-- function modifier_faction_olympians:PlayEffects( target )
-- 	--local particle_cast = "particles/units/heroes/hero_centaur/centaur_return.vpcf"
--     local particle_cast = "particles/econ/items/lifestealer/ls_ti10_immortal/ls_ti10_immortal_infest_gold_groundfollow_bloodvertical.vpcf"
--     --"particles/econ/items/lifestealer/ls_ti10_immortal/ls_ti10_immortal_infest_gold_radial_burst_blood.vpcf"

-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		0,
-- 		self:GetParent(),
-- 		PATTACH_POINT_FOLLOW,
-- 		"attach_hitloc",
-- 		self:GetParent():GetOrigin(), -- unknown
-- 		true -- unknown, true
-- 	)
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		1,
-- 		target,
-- 		PATTACH_POINT_FOLLOW,
-- 		"attach_hitloc",
-- 		target:GetOrigin(), -- unknown
-- 		true -- unknown, true
-- 	)
-- end
