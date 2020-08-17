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

function GetVisibleEnemyHeroesInRange( hUnit , flRange )
	if flRange == nil then
		flRange = 1250
	end
	--local enemies = FindUnitsInRadius( hUnit:GetTeamNumber(), hUnit:GetAbsOrigin(), nil, flRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	local enemies = FindUnitsInRadius( hUnit:GetTeamNumber(), hUnit:GetAbsOrigin(), nil, flRange, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_CLOSEST, false )
	--local radiant_heroes = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, hUnit:GetAbsOrigin(), nil, flRange, )
	return enemies
end