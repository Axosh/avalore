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
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function modifier_faction_olympians:OnCreated( kv )
	-- references
	self.base_return_dmg = 10
	self.base_hp_regen = 2
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

function modifier_faction_olympians:OnAttacked( kv )
	if IsServer() then
		if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then
			return
		end
		if kv.unit==self:GetParent() or self:FlagExist( kv.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) then
			return
		end

		-- get damage
		local damage = (self.base_return_dmg * self:GetStackCount())

		-- Apply Damage
		local damageTable = {
			victim          = kv.attacker,
			attacker        = self:GetParent(),
			damage          = damage,
			damage_type     = DAMAGE_TYPE_PHYSICAL,
			damage_flags    = DOTA_DAMAGE_FLAG_REFLECTION,
			ability         = self:GetAbility(), --Optional.
		}
		ApplyDamage(damageTable)

		-- Play effects
		if kv.attacker:IsConsideredHero() then
			self:PlayEffects( kv.attacker )
		end
	end
end

function modifier_faction_olympians:GetModifierConstantHealthRegen()
	if self:GetCaster():PassivesDisabled() then return end
	return (self.base_hp_regen * self:GetStackCount())
end

-- Helper: Flag operations
function modifier_faction_olympians:FlagExist(a,b)--Bitwise Exist
	local p,c,d=1,0,b
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c==d
end

function modifier_faction_olympians:PlayEffects( target )
	--local particle_cast = "particles/units/heroes/hero_centaur/centaur_return.vpcf"
    local particle_cast = "particles/econ/items/lifestealer/ls_ti10_immortal/ls_ti10_immortal_infest_gold_groundfollow_bloodvertical.vpcf"
    --"particles/econ/items/lifestealer/ls_ti10_immortal/ls_ti10_immortal_infest_gold_radial_burst_blood.vpcf"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(), -- unknown
		true -- unknown, true
	)
end
