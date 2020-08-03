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

function Spawn( entityKeyValues )
	if IsServer() then
		if thisEntity == nil then
			return
		end

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
    if not self:IsAlive() then
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
	end
	
	local nAggroRange = thisEntity:GetAcquisitionRange()

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
	print("TB HP: " .. tostring(thisEntity:GetHealthPercent()) .. " || Sunder Castable = " .. tostring(hSunder:IsFullyCastable()) )
	if thisEntity:GetHealthPercent() < 25 and hSunder:IsFullyCastable() then
		print("Trying to Sunder")
		CastSunder(hRandomPlayer)
		return 1
	elseif hGust:IsFullyCastable() then
		print("Casting Gust")
		CastGust(hRandomPlayer)
		return 1
	end

	return RandomFloat( 0.5, 1.5 )
end

function GetVisibleEnemyHeroesInRange( hUnit , flRange )
	if flRange == nil then
		flRange = 1250
	end
	local enemies = FindUnitsInRadius( hUnit:GetTeamNumber(), hUnit:GetAbsOrigin(), nil, flRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	return enemies
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

function GetReadyAbilitiesAndItems( self )
	local AbilitiesReady = {}
	for n=0,self:GetAbilityCount() - 1 do
		--local hAbility = self.me:GetAbilityByIndex( n )
		local hAbility = self:GetAbilityByIndex( n )
		if hAbility and hAbility:IsFullyCastable() and not hAbility:IsPassive() and not hAbility:IsHidden() and hAbility:IsActivated() then
			--print( 'Adding ABILITY ' .. hAbility:GetAbilityName() )
			if self.AbilityPriority[ hAbility:GetAbilityName() ] ~= nil then
				table.insert( AbilitiesReady, hAbility )
			end
		end
	end

	-- for i = 0, DOTA_ITEM_MAX - 1 do
	-- 	local hItem = self.me:GetItemInSlot( i )
	-- 	if hItem and hItem:IsFullyCastable() and not hItem:IsPassive() and not hItem:IsHidden() and hItem:IsActivated() then
	-- 		--print( 'Adding ITEM ' .. hItem:GetAbilityName() )
	-- 		if self.AbilityPriority[ hItem:GetAbilityName() ] ~= nil then
	-- 			table.insert( AbilitiesReady, hItem )
	-- 		end
	-- 	end
	-- end

	-- if #AbilitiesReady > 1 then
	-- 	table.sort( AbilitiesReady, function( h1, h2 ) 
	-- 			local nAbility1Priority = self.AbilityPriority[ h1:GetAbilityName() ]
	-- 			local nAbility2Priority = self.AbilityPriority[ h2:GetAbilityName() ]
	-- 		return nAbility1Priority > nAbility2Priority 
	-- 	end
	--  )
	-- end

	return AbilitiesReady
end