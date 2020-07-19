---------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------
require("constants")
require("references")
require("score")
require("utility_functions")

LinkLuaModifier( MODIFIER_ROUND1_WISP_REGEN, REF_MODIFIER_ROUND1_WISP_REGEN, LUA_MODIFIER_MOTION_NONE )

--initialized with ListenToGameEvent("entity_killed", Dynamic_Wrap(CustomGameMode, "OnEntityKilled"), self)
function CAvaloreGameMode:OnEntityKilled(event)
	--print("OnEntityKilled - Started")
	local killedEntity 		= EntIndexToHScript(event.entindex_killed)
	local killedTeam 		= killedEntity:GetTeam()
	local attackerEntity 	= EntIndexToHScript( event.entindex_attacker )
	local attackerTeam 		= nil --attackerEntity:GetTeam()
	local curr_gametime 	= GameRules:GetDOTATime(false, false)
	local isPlayer 			= attackerEntity:GetPlayerOwnerID() > -1 -- TODO: Test for summons/illu
	local isDeny			= false
	local teamString 		= ""
	local winnning_team 	= nil -- setting our own variable to update the scores one last time before game ends

	if killedTeam == DOTA_TEAM_BADGUYS then
		teamString = "dire"
	elseif killedTeam == DOTA_TEAM_GOODGUYS then
		teamString = "radi"
	end

	local refreshScores = false

	if attackerEntity ~= nil then
		attackerTeam = attackerEntity:GetTeam()
		if attackerTeam == killedTeam then
			isDeny = true
		end
	end

	if attackerEntity:IsRealHero() then
		print("Killed Entity: " .. killedEntity:GetUnitName())
	end

	--Check for bonus points due to quest objective
	local objectivePoints = 0

	-- ==========================
	-- ROUND 1 OBJECTIVES
	-- ==========================

	if killedEntity:GetUnitName() == ROUND1_WISP_UNIT then
		--objectivePoints = 3
		refreshScores = true
		local first_wisp = false
		if attackerTeam == DOTA_TEAM_GOODGUYS then
			if Score.round1.radi_wisp_count == 0 then
				first_wisp = true
			end
			Score.round1.radi_wisp_count = Score.round1.radi_wisp_count + 1
		elseif attackerTeam == DOTA_TEAM_BADGUYS then
			if Score.round1.dire_wisp_count == 0 then
				first_wisp = true
			end
			Score.round1.dire_wisp_count = Score.round1.dire_wisp_count + 1
		end
		Score.playerStats[attackerEntity:GetPlayerOwnerID()].wisps = Score.playerStats[attackerEntity:GetPlayerOwnerID()].wisps + 1
		-- give everyone the modifier if this is the first wisp capture
		if first_wisp then
			for playerID = 0, DOTA_MAX_PLAYERS do
				if PlayerResource:IsValidPlayerID(playerID) then
					if not PlayerResource:IsBroadcaster(playerID) then
						local hero = PlayerResource:GetSelectedHeroEntity(playerID)
						if hero:GetTeam() == attackerTeam then
							print("Adding Wisp Aura for Player " .. tostring(playerID) .. " (" .. hero:GetName() .. ")")
							hero:AddNewModifier(hero, nil, MODIFIER_ROUND1_WISP_REGEN, {})
						end
					end -- end IsBroadcaster
				end -- end IsValidPlayerID
			end -- end for-loop
		end
	end

	-- ==========================
	-- ROUND 3 OBJECTIVES
	-- ==========================

	-- check for gem drop in round 3
	if curr_gametime > Constants.TIME_ROUND_3_START and curr_gametime < Constants.TIME_ROUND_4_START then
		--print("Checking for Gem Drop..")
		if attackerTeam == DOTA_TEAM_GOODGUYS and not Score.round3.radi_gem_ref then
			--print("Radiant has not had gem drop || " .. killedEntity:GetUnitLabel() .. " || " .. killedEntity:GetUnitName())
			--check for ancient creep
			if IsAncientCreep(killedEntity:GetUnitName()) then
				--print("IS BIG ANCIENT, coordinates are: (" .. tostring(killedEntity:GetOrigin().x) .. ", " .. tostring(killedEntity:GetOrigin().y) .. ")")
				--check to see if on (roughly) radiant side
				if killedEntity:GetOrigin().y <= (killedEntity:GetOrigin().x * -1) then
					Score.round3.radi_gem_ref = CreateItem( OBJECTIVE_GEM_ITEM, nil , nil )
					Score.round3.radi_gem_drop_ref = CreateItemOnPositionSync( killedEntity:GetOrigin(), Score.round3.radi_gem_ref )
					--local testEquality = (Score.round3.radi_gem_ref:GetContainer() == Score.round3.radi_gem_drop_ref)
					--print("Was equal? " .. tostring(testEquality))
					--local testEquality2 = (Score.round3.radi_gem_ref:GetContainedItem() == Score.round3.radi_gem_drop_ref)
					--print("Gem Drop Ref")
					--PrintTable(Score.round3.radi_gem_drop_ref)
					--print("Gem Parent")
					
				end
			end
		elseif attackerTeam == DOTA_TEAM_BADGUYS and not Score.round3.dire_gem_ref then
			--check for ancient creep
			if IsAncientCreep(killedEntity:GetName()) then
				--check to see if on (roughly) dire side
				if killedEntity:GetOrigin().y >= (killedEntity:GetOrigin().x * -1) then
					Score.round3.dire_gem_ref = CreateItem( OBJECTIVE_GEM_ITEM, nil , nil )
					Score.round3.dire_gem_drop_ref = CreateItemOnPositionSync( killedEntity:GetOrigin(), Score.round3.radi_gem_ref )
				end
			end
		end
	end
	if killedEntity:GetUnitName() == ROUND3_BOSS_UNIT then
		refreshScores = true
		if attackerTeam == DOTA_TEAM_GOODGUYS then
			Score.round3.radi_boss_kills = Score.round3.radi_boss_kills + 1
		elseif attackerTeam == DOTA_TEAM_BADGUYS then
			Score.round3.dire_boss_kills = Score.round3.dire_boss_kills + 1
		end
	end

	-- ==========================
	-- HERO KILLS
	-- ==========================

	--Hero Kills, excluding denies
	if killedEntity:IsRealHero() and attackerTeam ~= killedTeam then
		--objectivePoints = 1
		refreshScores = true
	end

	--============================
	-- BUILDING KILLS
	--============================

	-- ***** TOWER ****
	if string.find(string.lower(killedEntity:GetUnitName()), "tower") then
		refreshScores = true
		print("Tower Killed: " .. killedEntity:GetUnitName())
		if string.find(killedEntity:GetUnitName(), "1") then
			Score.towers[teamString][BuildingLaneLocation(killedEntity:GetUnitName()) .. "1"] = false
			if isPlayer and not isDeny then
				Score.playerStats[attackerEntity:GetPlayerOwnerID()].t1 = Score.playerStats[attackerEntity:GetPlayerOwnerID()].t1 + 1
			end
		elseif string.find(killedEntity:GetUnitName(), "2") then
			Score.towers[teamString][BuildingLaneLocation(killedEntity:GetUnitName()) .. "2"] = false
			if isPlayer and not isDeny then
				Score.playerStats[attackerEntity:GetPlayerOwnerID()].t2 = Score.playerStats[attackerEntity:GetPlayerOwnerID()].t2 + 1
			end
		elseif string.find(killedEntity:GetUnitName(), "3") then
			Score.towers[teamString][BuildingLaneLocation(killedEntity:GetUnitName()) .. "3"] = false
			if isPlayer and not isDeny then
				Score.playerStats[attackerEntity:GetPlayerOwnerID()].t3 = Score.playerStats[attackerEntity:GetPlayerOwnerID()].t3 + 1
			end
		elseif string.find(killedEntity:GetUnitName(), "4") then
			Score.towers[teamString]["t4" .. BuildingLaneLocation(killedEntity:GetUnitName())] = false
			if isPlayer and not isDeny then
				Score.playerStats[attackerEntity:GetPlayerOwnerID()].t4 = Score.playerStats[attackerEntity:GetPlayerOwnerID()].t4 + 1
			end
		end
	end

	-- ***** RAX *****
	if string.find(string.lower(killedEntity:GetUnitName()), "rax") then
		refreshScores = true
		print("Rax Killed: " .. killedEntity:GetUnitName())
		if string.find(killedEntity:GetUnitName(), "melee") then
			Score.raxes[teamString][BuildingLaneLocation(killedEntity:GetUnitName()) .. "melee"] = false
			if isPlayer and not isDeny then
				Score.playerStats[attackerEntity:GetPlayerOwnerID()].meleeRax = Score.playerStats[attackerEntity:GetPlayerOwnerID()].meleeRax + 1
			end
		elseif string.find(killedEntity:GetUnitName(), "ranged") then
			Score.raxes[teamString][BuildingLaneLocation(killedEntity:GetUnitName()) .. "ranged"] = false
			if isPlayer and not isDeny then
				Score.playerStats[attackerEntity:GetPlayerOwnerID()].rangeRax = Score.playerStats[attackerEntity:GetPlayerOwnerID()].rangeRax + 1
			end
		end
	end
	--end

	-- ***** ANCIENT *****
	if killedEntity:GetUnitName() == OBJECTIVE_DIRE_BASE then
		winnning_team = DOTA_TEAM_GOODGUYS
		refreshScores = true
	elseif killedEntity:GetUnitName() == OBJECTIVE_RADI_BASE then
		winnning_team = DOTA_TEAM_BADGUYS
		refreshScores = true
	end

	-- only update front-end if score changed
	if refreshScores then
		if winnning_team ~= nil then
			print("Winning Team = " .. tostring(winnning_team))
			if isPlayer and not isDeny then
				-- this should only ever be 0 or 1
				Score.playerStats[attackerEntity:GetPlayerOwnerID()].base_kill = 1
			end
		end

		Score:RecalculateScores()

		-- this will immediately end the game
		if winnning_team ~= nil then
			GAME_WINNER_TEAM = winnning_team
		end
	-- if objectivePoints > 0 then 
	-- 	if attackerTeam == DOTA_TEAM_GOODGUYS then
	-- 		Score.RadiScore = Score.RadiScore + objectivePoints
	-- 		local score = 
	-- 		{
	-- 			team_id = DOTA_TEAM_GOODGUYS,
	-- 			team_score = Score.RadiScore
	-- 		}
	-- 	elseif attackerTeam == DOTA_TEAM_BADGUYS then
	-- 		Score.DireScore = Score.DireScore + objectivePoints
	-- 		local score = 
	-- 		{
	-- 			team_id = DOTA_TEAM_BADGUYS,
	-- 			team_score = Score.DireScore
	-- 		}
	-- 	end

		--print( "radi score = " .. _G.GoodScore)
		--print( "radi score 2 = " .. GetTeamHeroKills(DOTA_TEAM_GOODGUYS))
		--print( "dire score = " .. _G.BadScore)

		-- local score_obj = 
		-- {
		-- 	radi_score = Score.RadiScore,
		-- 	dire_score = Score.DireScore
		-- }
		-- CustomGameEventManager:Send_ServerToAllClients( "refresh_score", score_obj )

		--GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS))
		--GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS))
	end

	--print("OnEntityKilled - Ended")
end

function BuildingLaneLocation(building_unit_name)
	local result = ""
	
	-- check top/bot first since there are more of those (tier4s)
	if string.find(building_unit_name, "top") then
		result = "top"
	elseif string.find(building_unit_name, "bot") then
		result = "bot"
	elseif string.find(building_unit_name, "mid") then
		result = "mid"
	end

	return result
end

function IsAncientCreep(creep_name)
	if (creep_name == "npc_dota_neutral_big_thunder_lizard" or
		creep_name == "npc_dota_neutral_black_dragon" or
		creep_name == "npc_dota_neutral_granite_golem" or
		creep_name == "npc_dota_neutral_prowler_shaman" 
		) then
			return true
		end
	return false
end

function CAvaloreGameMode:OnHeroFinishSpawn(event)
	PrintTable(event)
	local hPlayerHero = EntIndexToHScript( event.heroindex )
	if hPlayerHero ~= nil and hPlayerHero:IsRealHero() then
		if hPlayerHero.bFirstSpawnComplete == nil then
			hPlayerHero.bFirstSpawnComplete = true
			Score:InsertPlayerStatsRecord(hPlayerHero:GetPlayerOwnerID())
		end
	end
end

function CAvaloreGameMode:OnItemPickUp(event)
	print("OnItemPickup - Start")
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )

	-- can only hold one flag, so check if this is a flag 
	-- then if they have another; if so, dump the old flag
	if     event.itemname == OBJECTIVE_FLAG_ITEM_A 
		or event.itemname == OBJECTIVE_FLAG_ITEM_B 
		or event.itemname == OBJECTIVE_FLAG_ITEM_C 
		or event.itemname == OBJECTIVE_FLAG_ITEM_D 
		or event.itemname == OBJECTIVE_FLAG_ITEM_E then

		local show_message = false
			
		if(owner:HasItemInInventory(OBJECTIVE_FLAG_ITEM_A)
			and event.itemname ~= OBJECTIVE_FLAG_ITEM_A) then
			owner:DropItemAtPositionImmediate(owner:FindItemInInventory(OBJECTIVE_FLAG_ITEM_A), owner:GetOrigin())
			show_message = true
		elseif(owner:HasItemInInventory(OBJECTIVE_FLAG_ITEM_B)
				and event.itemname ~= OBJECTIVE_FLAG_ITEM_B) then
			owner:DropItemAtPositionImmediate(owner:FindItemInInventory(OBJECTIVE_FLAG_ITEM_B), owner:GetOrigin())
			show_message = true
		elseif(owner:HasItemInInventory(OBJECTIVE_FLAG_ITEM_C)
				and event.itemname ~= OBJECTIVE_FLAG_ITEM_C) then
			owner:DropItemAtPositionImmediate(owner:FindItemInInventory(OBJECTIVE_FLAG_ITEM_C), owner:GetOrigin())
			show_message = true
		elseif(owner:HasItemInInventory(OBJECTIVE_FLAG_ITEM_D)
			and event.itemname ~= OBJECTIVE_FLAG_ITEM_D) then
			owner:DropItemAtPositionImmediate(owner:FindItemInInventory(OBJECTIVE_FLAG_ITEM_D), owner:GetOrigin())
			show_message = true
		elseif(owner:HasItemInInventory(OBJECTIVE_FLAG_ITEM_E)
			and event.itemname ~= OBJECTIVE_FLAG_ITEM_E) then
			owner:DropItemAtPositionImmediate(owner:FindItemInInventory(OBJECTIVE_FLAG_ITEM_E), owner:GetOrigin())
			show_message = true
		end

		if(show_message) then
			local broadcast_obj = 
			{
				msg = "#multi_flag",
				time = 10,
				elaboration = "",
				type = MSG_TYPE_ERROR
			}
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(owner:GetPlayerID()), "broadcast_message", broadcast_obj )
		end
	end -- end if-statement: item picked up was flag
end -- end function: CAvaloreGameMode:OnItemPickUp(event)

-- function CAvaloreGameMode:OnItemSlotChanged(event)
-- 	print("OnItemSlotChanged")
-- 	PrintTable(event)
-- end

-- function CAvaloreGameMode:OnInventoryUpdated(event)
-- 	print("OnInventoryUpdated")
-- 	PrintTable(event)
-- end

-- function CAvaloreGameMode:OnItemGifted(event)
-- 	print("OnItemGifted")
-- 	PrintTable(event)
-- end

-- function CAvaloreGameMode:OnInventoryChanged(event)
-- 	print("OnInventoryChanged")
-- 	PrintTable(event)
-- end

-- ---------------------------------------------------------
-- -- dota_item-spawned
-- -- * player_id
-- -- * item_ent_index
-- ---------------------------------------------------------

-- function CAvaloreGameMode:OnItemSpawned( event )
-- 	print("OnItemSpawned")
-- 	PrintTable(event)
-- 	local item = EntIndexToHScript( event.item_ent_index )
-- end