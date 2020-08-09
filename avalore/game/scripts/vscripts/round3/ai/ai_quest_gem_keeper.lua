require("references")
require(REQ_AI_SHARED)
-- EXPORTS = {}

-- EXPORTS.Init = function( self )
-- 	self.aiState = {}
-- 	self:SetContextThink( "init_think", function() 
-- 		self.aiThink = aiThink
--         self:SetContextThink( "ai_base_creature.aiThink", Dynamic_Wrap( self, "aiThink" ), 0 )
-- 	end, 0 )
-- end

-- if GemKeeper == nil then
-- 	GemKeeper = {}
-- end

-- if GemKeeper == nil then
-- 	GemKeeper = class({})
-- end

function Spawn( entityKeyValues )
	--print("TB Entity Keys")
	--PrintTable(entityKeyValues)
	if IsServer() then
		if thisEntity == nil then
			return
		end

		thisEntity.FirstPass = true
		thisEntity.walkingHome = false

		--print("Origin = " .. tostring(thisEntity:GetOrigin()) .. " || Abs Origin = " .. tostring(thisEntity:GetAbsOrigin()))

		hGust = thisEntity:FindAbilityByName("drow_ranger_wave_of_silence")
		hSunder = thisEntity:FindAbilityByName("terrorblade_sunder")
		thisEntity:SetContextThink("GemKeeperAIThink", GemKeeperAIThink, 1)
		--thisEntity.AI = GemKeeper( thisEntity, 1.0 )
		--thisEntity.aiState = {}
		--thisEntity:SetContextThink( "init_think", function() 
		--	thisEntity.aiThink = aiThink
		--	thisEntity:SetContextThink( "ai_base_creature.aiThink", Dynamic_Wrap( thisEntity, "aiThink" ), 0 )
		--end, 0 )
	end
end

-- function GemKeeper:constuctor( hUnit, flInterval )
-- 	self.me:SetThink("aiThink", self, "aiThink", 1.0)
-- end

function GemKeeperAIThink( self )
	if thisEntity.FirstPass then
		--print("Origin = " .. tostring(thisEntity:GetOrigin()) .. " || Abs Origin = " .. tostring(thisEntity:GetAbsOrigin()))
		thisEntity.spawnLocation = thisEntity:GetOrigin() -- location still (0,0,0) when in Spawn function, so set it on first pass here
		thisEntity.FirstPass = false
	end

    if not self:IsAlive() then
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
	end

	local nAggroRange = thisEntity:GetAcquisitionRange()
	-- see if we need to go back home 
	local xDist = thisEntity.spawnLocation.x - thisEntity:GetOrigin().x
	local yDist = thisEntity.spawnLocation.y - thisEntity:GetOrigin().y
	local distanceFromSpawn = math.sqrt( (xDist ^ 2) + (yDist ^ 2) )

	if distanceFromSpawn > (nAggroRange * 2) then
		thisEntity.walkingHome = true
	end

	if thisEntity.walkingHome == false then
		
		-- see if distance

		-- local hClosestPlayer = GetClosestPlayerInRoomOrReturnToSpawn( thisEntity, nAggroRange )
		-- if not hClosestPlayer then
		-- 	return 1
		-- end

		local hVisiblePlayers = GetVisibleEnemyHeroesInRange( thisEntity, nAggroRange )
		if #hVisiblePlayers <= 0 then
			return 0.5
		end

		local hRandomPlayer = hVisiblePlayers[ RandomInt( 1, #hVisiblePlayers ) ]
		if hRandomPlayer == nil then
			return 0.5
		end
		
		-- local ultReady = false
		-- -- if he has spells ready, lets do something
		-- local ReadyAbilities = GetReadyAbilitiesAndItems(self)
		-- if #ReadyAbilities ~= 0 then
		--     for _,Ability in pairs ( ReadyAbilities ) do
		--         print(Ability.GetAbilityName())
		--     end
		--end
		--print("TB HP: " .. tostring(thisEntity:GetHealthPercent()) .. " || Sunder Castable = " .. tostring(hSunder:IsFullyCastable()) )
		if thisEntity:GetHealthPercent() < 25 and hSunder:IsFullyCastable() then
			print("Trying to Sunder")
			CastSunder(hRandomPlayer)
			return 1
		elseif hGust:IsFullyCastable() then
			print("Casting Gust")
			CastGust(hRandomPlayer)
			return 1
		end
	else
		if distanceFromSpawn > 50 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = thisEntity.spawnLocation,
			})
		else
			thisEntity.walkingHome = false
		end
	end

	return RandomFloat( 0.5, 1.5 )
end

function CastSunder( hTarget )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		--Position = hTarget:GetOrigin(),
		AbilityIndex = hSunder:entindex(),
		TargetIndex = hTarget:GetEntityIndex(),
		Queue = false,
	})
end

function CastGust( hTarget )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = hTarget:GetOrigin(),
		AbilityIndex = hGust:entindex(),
		Queue = false,
	})
end