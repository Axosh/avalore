---------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------
require("constants")
require("references")
require("score")
require("utility_functions")
require("scripts/vscripts/libraries/map_and_nav")
require(REQ_LIB_COSMETICS)
require(REQ_SPAWNERS)
require(REQ_CTRL_INV_MNGR)
require(REQ_CLASS_INV)
--require("scripts/vscripts/modifiers/modifier_wearable")

LinkLuaModifier( "modifier_inventory_manager", "scripts/vscripts/modifiers/modifier_inventory_manager", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( MODIFIER_ROUND1_WISP_REGEN, REF_MODIFIER_ROUND1_WISP_REGEN, LUA_MODIFIER_MOTION_NONE )

-- Faction Stuff
LinkLuaModifier("modifier_faction_forest",     "modifiers/faction/modifier_faction_forest.lua",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_faction_water",      "modifiers/faction/modifier_faction_water.lua",        LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_faction_olympians",      "modifiers/faction/modifier_faction_olympians.lua",    LUA_MODIFIER_MOTION_NONE)

-- Talents that can be activated later
LinkLuaModifier("modifier_talent_static_field",       "heroes/zeus/modifier_talent_static_field.lua",       LUA_MODIFIER_MOTION_NONE)

-- Inventory Debug
LinkLuaModifier( "modifier_wearable", "scripts/vscripts/modifiers/modifier_wearable", LUA_MODIFIER_MOTION_NONE )

--initialized with ListenToGameEvent("entity_killed", Dynamic_Wrap(CustomGameMode, "OnEntityKilled"), self)
function CAvaloreGameMode:OnEntityKilled(event)
	--print("OnEntityKilled - Started")
	local killedEntity 		= EntIndexToHScript(event.entindex_killed)
	local killedTeam 		= killedEntity:GetTeam()
	local attackerEntity 	= EntIndexToHScript( event.entindex_attacker )
	local attackerTeam 		= nil --attackerEntity:GetTeam()
	local curr_gametime 	= (GameRules:GetDOTATime(false, false) + _G.time_offset)
	local isPlayer 			= attackerEntity:GetPlayerOwnerID() > -1 -- TODO: Test for summons/illu
	local isDeny			= false
	local killedTeamString 	= "" -- radi/dire
	local winnning_team 	= nil -- setting our own variable to update the scores one last time before game ends
	local objectiveMsg 		= nil -- if set, will broadcast whatever message key is stored in it
	
	-- if isPlayer then
	-- 	print("Player Died!")
	-- end

	-- used to navigate Score tables
	if killedTeam == DOTA_TEAM_BADGUYS then
		killedTeamString = "dire"
	elseif killedTeam == DOTA_TEAM_GOODGUYS then
		killedTeamString = "radi"
	end

	local refreshScores = false

	if attackerEntity ~= nil then
		attackerTeam = attackerEntity:GetTeam()
		if attackerTeam == killedTeam then
			isDeny = true
		end

		-- if Radiant/Dire killed a unit, then add to shared gold (ignore things killed by neuts)
		if not isPlayer then
			local new_gold = 0
			if attackerTeam == DOTA_TEAM_GOODGUYS then
				Score.RadiSharedGoldCurr  =  Score.RadiSharedGoldCurr  + killedEntity:GetGoldBounty()
				Score.RadiSharedGoldTotal =  Score.RadiSharedGoldTotal + killedEntity:GetGoldBounty()
				--print("Radiant Shared Gold = " .. tostring(Score.RadiSharedGoldCurr) .. "g")
				new_gold = Score.RadiSharedGoldCurr
			elseif attackerTeam == DOTA_TEAM_BADGUYS then
				Score.DireSharedGoldCurr  =  Score.DireSharedGoldCurr  + killedEntity:GetGoldBounty()
				Score.DireSharedGoldTotal =  Score.DireSharedGoldTotal + killedEntity:GetGoldBounty()
				--print("Dire Shared Gold = " .. tostring(Score.DireSharedGoldCurr) .. "g")
				new_gold = Score.DireSharedGoldCurr
			end

			-- check if team-associated NPCs killed a hero
			if killedEntity:IsRealHero() then
				-- filter out neutral kills
				if attackerTeam == DOTA_TEAM_GOODGUYS or attackerTeam == DOTA_TEAM_BADGUYS then
					Score[attackerTeam].Kills = Score[attackerTeam].Kills + 1
					refreshScores = true
				end
			end

			local team_gold = 
			{
				gold = new_gold
			}
			CustomGameEventManager:Send_ServerToTeam(attackerTeam, "update_team_gold", team_gold)
			--CustomGameEventManager:Send_ServerToAllClients( "refresh_score", score_obj )
		end
	end


	if attackerEntity:IsRealHero() then
		print("[Events] Killed Entity: " .. killedEntity:GetUnitName())

		-- Check if CS triggered score update
		if attackerEntity:GetLastHits() > 0 and attackerEntity:GetLastHits() % SCORE_DIVIDEND_LASTHITS == 0 then
			print("[Events] Hit CS Theshold to trigger score update")
			refreshScores = true
		end
	end

	--Check for bonus points due to quest objective
	local objectivePoints = 0

	-- ==========================
	-- ROUND 1 OBJECTIVES
	-- ==========================

	if killedEntity:GetUnitName() == ROUND1_WISP_UNIT then
		--objectivePoints = 3
		local skip_wisps = false -- used when end of round kills remaining wisps
		local first_wisp = true--false
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
		else
			-- probably force killed by round end
			skip_wisps = true
		end
		if not skip_wisps then
			refreshScores = true
			objectiveMsg = "objective_wisp" -- see addon_english.txt (panorama/localization)

			Score.playerStats[attackerEntity:GetPlayerOwnerID()].wisps = Score.playerStats[attackerEntity:GetPlayerOwnerID()].wisps + 1
			-- give everyone the modifier if this is the first wisp capture
			if first_wisp then
				for playerID = 0, DOTA_MAX_PLAYERS do
					if PlayerResource:IsValidPlayerID(playerID) then
						if not PlayerResource:IsBroadcaster(playerID) then
							local hero = PlayerResource:GetSelectedHeroEntity(playerID)
							if hero:GetTeam() == attackerTeam then
								print("[Events] Adding Wisp Aura for Player " .. tostring(playerID) .. " (" .. hero:GetName() .. ")")
								hero:AddNewModifier(hero, nil, MODIFIER_ROUND1_WISP_REGEN, {})
							end
						end -- end IsBroadcaster
					end -- end IsValidPlayerID
				end -- end for-loop
			end
		end
	end

	-- ==========================
	-- ROUND 3 OBJECTIVES
	-- ==========================

	-- check for gem drop in round 3
	local gem_trigger = nil
	local gem_broadcast_team = nil
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
					gem_trigger = Entities:FindByName(nil, ROUND3_GEM_ACTIVATE_DIRE_SIDE)
					gem_broadcast_team = DOTA_TEAM_GOODGUYS
				end
			end
		elseif attackerTeam == DOTA_TEAM_BADGUYS and not Score.round3.dire_gem_ref then
			--check for ancient creep
			if IsAncientCreep(killedEntity:GetName()) then
				--check to see if on (roughly) dire side
				if killedEntity:GetOrigin().y >= (killedEntity:GetOrigin().x * -1) then
					Score.round3.dire_gem_ref = CreateItem( OBJECTIVE_GEM_ITEM, nil , nil )
					Score.round3.dire_gem_drop_ref = CreateItemOnPositionSync( killedEntity:GetOrigin(), Score.round3.radi_gem_ref )

					gem_trigger = Entities:FindByName(nil, ROUND3_GEM_ACTIVATE_RADI_SIDE)
					gem_broadcast_team = DOTA_TEAM_BADGUYS
				end
			end
		end
	end

	-- if gem was dropped, broadcast some info about what to do with it
	if gem_trigger ~= nil then
		for playerId = 0,19 do
			local player = PlayerResource:GetPlayer(playerId)
			if player ~= nil then
				if player:GetAssignedHero() then
					if player:GetTeam() == gem_broadcast_team then
						MinimapEvent(gem_broadcast_team, player:GetAssignedHero(), gem_trigger:GetOrigin().x,  gem_trigger:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 3)
					end
				end
			end
		end
		local broadcast_obj =
		{
			msg = "objective_round3_part2_intro",
			time = 10,
			elaboration = "objective_round3_part2_elaboration"
		}
		CustomGameEventManager:Send_ServerToTeam(gem_broadcast_team, MESSAGE_EVENT_BROADCAST, broadcast_obj )
	end

	if killedEntity:GetUnitName() == ROUND3_BOSS_UNIT then
		refreshScores = true
		objectiveMsg = "objective_round3_boss" -- see addon_english.txt (panorama/localization)
		if attackerTeam == DOTA_TEAM_GOODGUYS then
			Score.round3.radi_boss_kills = Score.round3.radi_boss_kills + 1
			-- TODO: augment player stats
		elseif attackerTeam == DOTA_TEAM_BADGUYS then
			Score.round3.dire_boss_kills = Score.round3.dire_boss_kills + 1
		end
	end

	-- ==========================
	-- ROUND 4 OBJECTIVES
	-- ==========================

	if killedEntity:GetUnitName() == ROUND4_BOSS_UNIT then
		refreshScores = true
		objectiveMsg = "objective_round4_boss" -- see addon_english.txt (panorama/localization)
		if attackerTeam == DOTA_TEAM_GOODGUYS then
			Score.round4.boss = DOTA_TEAM_GOODGUYS
			-- TODO: augment player stats
		elseif attackerTeam == DOTA_TEAM_BADGUYS then
			Score.round4.boss = DOTA_TEAM_BADGUYS
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
		-- Round 4 Towers
		if string.find(string.lower(killedEntity:GetUnitName()), "round4") then
			local side = ""
			local tower = ""
			if string.find(killedEntity:GetUnitName(), "dire") then 
				side = "dire"
			else
				side = "radi"
			end

			if string.find(killedEntity:GetUnitName(), "tower_a") then
				tower = "towerA"
			else
				tower = "towerB"
			end
			print("Setting " .. side .. " " .. tower .. " to nil")
			Score.round4[side][tower] = nil -- set to nil so we can bring down the boss shields

			local shieldsDown = nil
			if Score.round4.radi.towerA == nil and Score.round4.radi.towerB == nil then
				shieldsDown = DOTA_TEAM_GOODGUYS
			elseif Score.round4.dire.towerA == nil and Score.round4.dire.towerB == nil then
				shieldsDown = DOTA_TEAM_BADGUYS
			end

			if shieldsDown ~= nil then
				local broadcast_obj =  {
					msg = "objective_round4_shields_down",
					time = 10,
					elaboration = ""
				}
				CustomGameEventManager:Send_ServerToTeam(shieldsDown, MESSAGE_EVENT_BROADCAST, broadcast_obj)
			end

		else
			refreshScores = true
			objectiveMsg = "objective_tower" -- see addon_english.txt (panorama/localization)
			print("[Events] Tower Killed: " .. killedEntity:GetUnitName())
			if string.find(killedEntity:GetUnitName(), "1") then
				Score.towers[killedTeamString][BuildingLaneLocation(killedEntity:GetUnitName()) .. "1"] = false
				if isPlayer and not isDeny then
					Score.playerStats[attackerEntity:GetPlayerOwnerID()].t1 = Score.playerStats[attackerEntity:GetPlayerOwnerID()].t1 + 1
				end
			elseif string.find(killedEntity:GetUnitName(), "2") then
				Score.towers[killedTeamString][BuildingLaneLocation(killedEntity:GetUnitName()) .. "2"] = false
				if isPlayer and not isDeny then
					Score.playerStats[attackerEntity:GetPlayerOwnerID()].t2 = Score.playerStats[attackerEntity:GetPlayerOwnerID()].t2 + 1
				end
			elseif string.find(killedEntity:GetUnitName(), "3") then
				Score.towers[killedTeamString][BuildingLaneLocation(killedEntity:GetUnitName()) .. "3"] = false
				if isPlayer and not isDeny then
					Score.playerStats[attackerEntity:GetPlayerOwnerID()].t3 = Score.playerStats[attackerEntity:GetPlayerOwnerID()].t3 + 1
				end
			elseif string.find(killedEntity:GetUnitName(), "4") then
				Score.towers[killedTeamString]["t4" .. BuildingLaneLocation(killedEntity:GetUnitName())] = false
				if isPlayer and not isDeny then
					Score.playerStats[attackerEntity:GetPlayerOwnerID()].t4 = Score.playerStats[attackerEntity:GetPlayerOwnerID()].t4 + 1
				end
			end
		end
	end

	-- ***** RAX *****
	if string.find(string.lower(killedEntity:GetUnitName()), "rax") then
		refreshScores = true
		objectiveMsg = "objective_rax" -- see addon_english.txt (panorama/localization)
		local scoring_team = DOTA_TEAM_BADGUYS
		if (killedTeam == DOTA_TEAM_BADGUYS) then
			scoring_team = DOTA_TEAM_GOODGUYS
		end
		local lane_id = BuildingLaneLocation(killedEntity:GetUnitName())

		print("[Events] Rax Killed: " .. killedEntity:GetUnitName())
		if string.find(killedEntity:GetUnitName(), "melee") then
			Score.raxes[killedTeam][lane_id]["melee"] = false
			-- update to super
			Spawners:UpgradeToSuper(scoring_team, lane_id, "Melee")
			--Spawners.raxes[scoring_team][lane_id]["melee"] = (Spawners.raxes[scoring_team][lane_id]["melee"] .. "_super")
			if isPlayer and not isDeny then
				Score.playerStats[attackerEntity:GetPlayerOwnerID()].meleeRax = Score.playerStats[attackerEntity:GetPlayerOwnerID()].meleeRax + 1
			end
		elseif string.find(killedEntity:GetUnitName(), "range") then
			Score.raxes[killedTeam][lane_id]["ranged"] = false
			-- update to super
			Spawners:UpgradeToSuper(scoring_team, lane_id, "Ranged")
			--Spawners.raxes[scoring_team][lane_id]["ranged"] = (Spawners.raxes[scoring_team][lane_id]["ranged"] .. "_super")
			if isPlayer and not isDeny then
				Score.playerStats[attackerEntity:GetPlayerOwnerID()].rangeRax = Score.playerStats[attackerEntity:GetPlayerOwnerID()].rangeRax + 1
			end
		end

		-- check for super siege
		if (not Score.raxes[killedTeam][lane_id]["melee"]) and (not Score.raxes[killedTeam][lane_id]["ranged"]) then
			Spawners:UpgradeToSuper(scoring_team, lane_id, "Siege")
			--Spawners.raxes[scoring_team][lane_id]["siege"] = (Spawners.raxes[scoring_team][lane_id]["siege"] .. "_super")
			Score.raxes[killedTeam]["super_lanes"] = Score.raxes[killedTeam]["super_lanes"] + 1
			-- check for mega
			if Score.raxes[killedTeam]["super_lanes"] == 3 then
				Spawners:UpgradeToMega(scoring_team)
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

	-- broadcast some message
	if objectiveMsg ~= nil then
		local broadcast_obj =
		{
			msg = "#" .. objectiveMsg,
			time = 10,
			elaboration = ""
		}
		CustomGameEventManager:Send_ServerToAllClients( MESSAGE_EVENT_BROADCAST, broadcast_obj )
	end

	--============================
	-- REFRESH SCORES?
	--============================

	-- only update front-end if score changed
	if refreshScores then
		if winnning_team ~= nil then
			print("[Events] Winning Team = " .. tostring(winnning_team))
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
	
	--DEBUG GOLD
	-- print("<<<<< DEBUG GOLD >>>>>")
	-- for playerID = 0, DOTA_MAX_PLAYERS do
	-- 	if PlayerResource:IsValidPlayerID(playerID) then
	-- 		if not PlayerResource:IsBroadcaster(playerID) then
	-- 			local gold = PlayerResource:GetGold(playerID)
	-- 			print("PID " .. tostring(playerID) .. ": " .. tostring(gold) .. "g")
	-- 		end -- end IsBroadcaster
	-- 	end -- end IsValidPlayerID
	-- end -- end for-loop

	--print("OnEntityKilled - Ended")
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

-- "dota_on_hero_finish_spawn"
-- 	{
-- 		"heroindex"		"int"
-- 		"hero"			"string"
-- 	}
function CAvaloreGameMode:OnHeroFinishSpawn(event)
	-- print("==== OnHeroFinishSpawn ====")
	-- PrintTable(event)
	local hPlayerHero = EntIndexToHScript( event.heroindex )
	if hPlayerHero ~= nil and hPlayerHero:IsRealHero() then
		if hPlayerHero.bFirstSpawnComplete == nil then
			-- init score tracking
			hPlayerHero.bFirstSpawnComplete = true
			Score:InsertPlayerStatsRecord(hPlayerHero:GetPlayerOwnerID())
		end
		-- Init cosmetics
		CAvaloreGameMode:InitCosmetics(hPlayerHero)
		-- init inventory
		--InventoryManager[hPlayerHero:GetPlayerOwnerID()] = Inventory:Create(hPlayerHero:GetPlayerOwnerID())
		print("Creating Inventory for Player: " .. tostring(hPlayerHero:GetPlayerOwnerID()))
		InventoryManager[hPlayerHero:GetPlayerOwnerID()] = Inventory:Create()
		InventoryManager[hPlayerHero:GetPlayerOwnerID()]:Init(hPlayerHero:GetPlayerOwnerID())

		-- Init shared control of Merc Camps
		-- print("---- Give Shared Control to Merc Camps ----")
		-- print("Player Team: " .. tostring(hPlayerHero:GetTeam()))
		-- PrintTable(Spawners.MercCamps[hPlayerHero:GetTeam()])
		for key, value in pairs(Spawners.MercCamps[hPlayerHero:GetTeam()]) do
			--print("Giving Player " .. tostring(hPlayerHero:GetPlayerOwnerID()) .. " shared control of " .. tostring(key))
			value:SetControllableByPlayer(hPlayerHero:GetPlayerOwnerID(), false)
		end
	end

	-- print("[CAvaloreGameMode:OnHeroFinishSpawn] hero name: " .. hPlayerHero:GetUnitName())
	-- if hPlayerHero:GetUnitName() == "npc_dota_hero_windrunner" then -- robin_hood
	-- 	local ability_name = hPlayerHero:GetAbilityByIndex(10):GetAbilityName()
	-- 	hPlayerHero:SwapAbilities(ability_name, ability_name, false, false)
	-- end
end





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


-- hero = EntIndexToHScript( event.heroindex )
function CAvaloreGameMode:InitCosmetics(unit)
	local playernum = 0
	local hero = PlayerResource:GetSelectedHeroEntity(playernum)

	local hero_name = PlayerResource:GetSelectedHeroName(playernum)
	--print("Cosmetics Init for: " .. hero_name)

	-- -- Test - remove effects
	-- for sSlotName, hWear in pairs(unit.Slots) do
	-- 	if hWear["model"] then
	-- 		hWear["model"]:AddEffects(EF_NODRAW)
	-- 	end
	-- 	for p_name, p in pairs(hWear["particles"]) do
	-- 		if p ~= false then
	-- 			ParticleManager:DestroyParticle(p, true)
	-- 			ParticleManager:ReleaseParticleIndex(p)
	-- 		end
	-- 		if hUnit["prismatic_particles"] and hUnit["prismatic_particles"][p_name] then
	-- 			hUnit["prismatic_particles"][p_name].hidden = true
	-- 		end
	-- 	end
	-- 	if hWear["additional_wearable"] then
	-- 		for _, prop in pairs(hWear["additional_wearable"]) do
	-- 			if prop and IsValidEntity(prop) then
	-- 				prop:AddEffects(EF_NODRAW)
	-- 			end
	-- 		end
	-- 	end
	-- end
	--local hero = PlayerResource:GetPlayer( hPlayerHero:GetPlayerOwnerID() ):GetAssignedHero()
	--CosmeticLib:PrintItemsFromPlayer(PlayerResource:GetPlayer(0))
	if hero_name ~= "npc_dota_hero_rubick" then
		CosmeticLib:RemoveParticles(PlayerResource:GetPlayer(0))
		--CAvaloreGameMode:RemoveAll(hero)
		CosmeticLib:RemoveFromSlot( hero, DOTA_LOADOUT_TYPE_HEAD )
		CosmeticLib:RemoveFromSlot( hero, DOTA_LOADOUT_TYPE_BODY_HEAD )
		CosmeticLib:RemoveFromSlot( hero, DOTA_LOADOUT_TYPE_SHOULDER )
	end

	--local selected_item = CosmeticLib._AllItemsByID[ "" .. CosmeticID ]
	--print(">>>>><<<<<")
	--CosmeticLib:PrintItemsFromPlayer(PlayerResource:GetPlayer(0))
	--if()
	--CAvaloreGameMode:InitDavyJones(hero)
	if CAvaloreGameMode.player_cosmetics == nil then
		CAvaloreGameMode.player_cosmetics = {}
	end

	if hero_name == "npc_dota_hero_davy_jones" or hero_name == "npc_dota_hero_kunkka" then
		--CosmeticLib:ReplaceDefault( hero, "npc_dota_hero_kunkka" )
		CAvaloreGameMode:InitDavyJones(hero)
	elseif hero_name == "npc_dota_hero_robin_hood" or hero_name == "npc_dota_hero_windrunner" then
		CAvaloreGameMode:InitRobinHood(hero,playernum)
	elseif hero_name == "avalore_hero_dionysus" or hero_name == "npc_dota_hero_brewmaster" then
		CAvaloreGameMode:InitDionysus(hero, playernum)
	elseif hero_name == "npc_avalore_hero_zeus" or hero_name == "npc_dota_hero_zuus" then
		CAvaloreGameMode:InitZeus(hero, playernum)
	elseif hero_name == "npc_avalore_hero_quetzalcoatl" or hero_name == "npc_dota_hero_viper" then
		CAvaloreGameMode:InitQuetalcoatl(hero, playernum)
	elseif hero_name == "npc_avalore_hero_gilgamesh" or hero_name == "npc_dota_hero_lone_druid" then
		CAvaloreGameMode:InitGilgamesh(hero, playernum)
	elseif hero_name == "npc_dota_hero_pecos_bill" or hero_name == "npc_dota_hero_sniper" then
		CAvaloreGameMode:InitPecosBill(hero, playernum)
	elseif hero_name == "npc_avalore_hero_sun_wukong" or hero_name == "npc_dota_hero_monkey_king" then
		CAvaloreGameMode:InitSunWukong(hero, playernum, false)
	--elseif hero_name == "npc_avalore_hero_thor" or hero_name == "npc_dota_hero_sven" then
	elseif hero_name == "npc_avalore_hero_thor" or hero_name == "npc_dota_hero_dawnbreaker" then
		CAvaloreGameMode:InitThor(hero, playernum)
	elseif hero_name == "npc_dota_hero_dragon_knight"	or hero_name == "npc_avalore_hero_king_arthur" then
		CAvaloreGameMode:InitKingArthur(hero, playernum)
	elseif hero_name == "npc_dota_hero_phantom_lancer"	or hero_name == "npc_avalore_hero_anubis" then
		CAvaloreGameMode:InitAnubis(hero, playernum)
	end

	hero:AddNewModifier(hero, nil, "modifier_inventory_manager", nil)

	-- -- populate inventory with placeholders
	-- local misc1 = hero:AddItemByName("item_slot_misc1")
	-- misc1:SetDroppable(true)
	-- for slot=0,8 do
	-- 	local item = hero:GetItemInSlot(slot)
	-- 	if item then
	-- 		print("Slot " .. tostring(slot) .. " => " .. item:GetName())
	-- 	end
	-- end
	-- hero:SwapItems(0,6)
	-- for slot=0,8 do
	-- 	local item = hero:GetItemInSlot(slot)
	-- 	if item then
	-- 		print("Slot " .. tostring(slot) .. " => " .. item:GetName())
	-- 	end
	-- end
	-- local misc2 = hero:AddItemByName("item_slot_misc2")
	-- hero:SwapItems(0,7)
	-- local misc3 = hero:AddItemByName("item_slot_misc3")
	-- hero:SwapItems(0,8)

	-- hero:AddItemByName("item_slot_head")
	-- hero:AddItemByName("item_slot_chest")
	-- hero:AddItemByName("item_slot_back")
	-- hero:AddItemByName("item_slot_hands")
	-- hero:AddItemByName("item_slot_feet")
	-- hero:AddItemByName("item_slot_trinket")

	-- misc1:SetDroppable(false)
	-- misc2:SetDroppable(false)
	-- misc3:SetDroppable(false)
	-- -- hero:AddItemByName("item_slot_misc1")
	-- -- hero:AddItemByName("item_slot_misc2")
	-- -- hero:AddItemByName("item_slot_misc3")
end

function CAvaloreGameMode:RemoveAll( unit )
	if unit and CosmeticLib:_Identify( unit ) then
		-- Start force replacing
		for slot_name, handle_table in pairs( unit._cosmeticlib_wearables_slots ) do
			CosmeticLib:_Replace( handle_table, "-1" )
		end
		return
	end
	
	print( "[CosmeticLib:Remove] Error: Invalid input." )
end

function CAvaloreGameMode:InitDavyJones(unit)
	unit:AddNewModifier(unit, nil, "modifier_faction_water", nil)
	local davy_jones_cosmetics = {}
	davy_jones_cosmetics[0] = "models/items/kunkka/medallion_of_the_divine_anchor/medallion_of_the_divine_anchor.vmdl"
	davy_jones_cosmetics[1] = "models/items/kunkka/vengeful_ghost_captain_shoulder/vengeful_ghost_captain_shoulder.vmdl"
	davy_jones_cosmetics[2] = "models/items/kunkka/arm_lev_admiral_shawl/arm_lev_admiral_shawl.vmdl"
	davy_jones_cosmetics[3] = "models/items/kunkka/whaleblade/ti8_kunkka_whaleblade.vmdl"
	davy_jones_cosmetics[4] = "models/items/kunkka/kunkka_shoes/kunkka_shoes.vmdl"
	davy_jones_cosmetics[5] = "models/items/kunkka/vengeful_ghost_captain_head/vengeful_ghost_captain_head.vmdl"
	davy_jones_cosmetics[6] = "models/items/kunkka/vengeful_ghost_captain_back/vengeful_ghost_captain_back.vmdl"
	davy_jones_cosmetics[7] = "models/items/kunkka/vengeful_ghost_captain_gloves/vengeful_ghost_captain_gloves.vmdl"
	
	for k,wearable in pairs(davy_jones_cosmetics) do
		--print("Creating Cosmetic " .. wearable)
		local cosmetic = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
	end
end

function CAvaloreGameMode:InitRobinHood(unit_temp, playernum)
	local unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	unit:AddNewModifier(unit, nil, "modifier_faction_forest", nil)
	local robin_hood_cosmetics = {}
	--robin_hood_cosmetics[0] = "models/items/windrunner/sparrowhawk_cape/sparrowhawk_cape.vmdl"
	robin_hood_cosmetics[0] = "models/items/windrunner/ti6_windranger_back/ti6_windranger_back_refit.vmdl"
	robin_hood_cosmetics[1] = "models/items/windrunner/the_swift_pathfinder_swift_pathfinders_bow/the_swift_pathfinder_swift_pathfinders_bow.vmdl"
	robin_hood_cosmetics[2] = "models/items/windrunner/quiver_of_the_northern_wind/quiver_of_the_northern_wind.vmdl"
	robin_hood_cosmetics[3] = "models/items/windrunner/the_swift_pathfinder_swift_pathfinders_hat_v2/the_swift_pathfinder_swift_pathfinders_hat_v2.vmdl"
	--robin_hood_cosmetics[4] = "models/items/windrunner/the_swift_pathfinder_swift_pathfinders_coat/the_swift_pathfinder_swift_pathfinders_coat.vmdl"
	robin_hood_cosmetics[4] = "models/items/windrunner/ti6_windranger_shoulder/ti6_windranger_shoulder_arc_refit.vmdl"
	robin_hood_cosmetics[5] = "models/items/kunkka/ti9_cache_kunkka_kunkkquistador_weapon/ti9_cache_kunkka_kunkkquistador_weapon.vmdl"
	
	for k,wearable in pairs(robin_hood_cosmetics) do
		--print("Creating Cosmetic " .. wearable)
		local cosmetic = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
		if wearable == "models/items/windrunner/the_swift_pathfinder_swift_pathfinders_bow/the_swift_pathfinder_swift_pathfinders_bow.vmdl" then
			unit_temp.weapon_model = cosmetic
			--print("Set Initial weapon_model")
		end
		if wearable == "models/items/kunkka/ti9_cache_kunkka_kunkkquistador_weapon/ti9_cache_kunkka_kunkkquistador_weapon.vmdl" then
			cosmetic:AddEffects(EF_NODRAW) -- start out invis
			unit_temp.weapon_model_alt = cosmetic

		end
		if k == 1 then
			local bow_string = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_bowstring.vpcf", PATTACH_CUSTOMORIGIN, cosmetic)
			ParticleManager:SetParticleControlEnt(bow_string, 0, cosmetic, PATTACH_POINT_FOLLOW, "bow_bot", cosmetic:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(bow_string, 1, cosmetic, PATTACH_POINT_FOLLOW, "bow_mid", cosmetic:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(bow_string, 2, cosmetic, PATTACH_POINT_FOLLOW, "bow_top", cosmetic:GetAbsOrigin(), true)
		end
	end
	
end

function CAvaloreGameMode:InitDionysus(hero, playernum)
	local unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	unit:AddNewModifier(unit, nil, "modifier_faction_olympians", nil)
	local dionysus_cosmetics = {}
	dionysus_cosmetics[0] = "models/items/brewmaster/barrel_vice.vmdl"
	dionysus_cosmetics[1] = "models/items/brewmaster/coffeemaster_weapon/coffeemaster_weapon.vmdl"
	dionysus_cosmetics[2] = "models/items/brewmaster/honorable_brawler_shoulder/honorable_brawler_shoulder.vmdl"
	dionysus_cosmetics[3] = "models/items/brewmaster/honorable_brawler_arms/honorable_brawler_arms.vmdl"
	dionysus_cosmetics[4] = "models/items/brewmaster/honorable_brawler_back/honorable_brawler_back.vmdl"

	for k,wearable in pairs(dionysus_cosmetics) do
		--print("Creating Cosmetic " .. wearable)
		local cosmetic = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
	end
end

function CAvaloreGameMode:InitZeus(hero, playernum)
	--print("Ability Index 10: " .. hero:GetAbilityByIndex(10):GetName())
	local unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	unit:AddNewModifier(unit, nil, "modifier_faction_olympians", nil)

	local talent_static_field = hero:GetAbilityByName("talent_static_field")
	print("Found Static Field - " .. talent_static_field:GetName())
	unit:AddNewModifier(unit, talent_static_field, "modifier_talent_static_field", nil)
	local zeus_cosmetics = {}
	--zeus_cosmetics[0] = "models/heroes/pedestal/mesh/effigy_zeus_arcana.vmdl"
	zeus_cosmetics[0] = "models/heroes/zeus/zeus_hair_arcana.vmdl"
	zeus_cosmetics[1] = "models/items/zeus/zeus_ti8_immortal_arms/zeus_ti8_immortal_arms.vmdl"
	zeus_cosmetics[2] = "models/heroes/zeus/zeus_belt.vmdl"
	zeus_cosmetics[3] = "models/items/zeus/lightning_weapon/mesh/zeus_lightning_weapon_model.vmdl"

	-- -- cloud cosmetic/particle
	-- local cloud = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_chariot.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	-- ParticleManager:SetParticleControlEnt(cloud, 0, hero, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", hero:GetAbsOrigin(), true)
	

	for k,wearable in pairs(zeus_cosmetics) do
		--print("Creating Cosmetic " .. wearable)
		local cosmetic = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
		if k == 2 then
			-- cloud cosmetic/particle
			local cloud = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_chariot.vpcf", PATTACH_ABSORIGIN_FOLLOW, cosmetic)
			ParticleManager:SetParticleControlEnt(cloud, 0, cosmetic, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", cosmetic:GetAbsOrigin(), true)
		end
		if k == 3 then
			-- see dota_imba's control_points.txt
			local electricity = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zues_immortal_lightning_weapon.vpcf", PATTACH_CUSTOMORIGIN, cosmetic)
			--ParticleManager:SetParticleControl(electricity, 0, hero:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(electricity, 0, cosmetic, PATTACH_POINT_FOLLOW, "attach_attack1", cosmetic:GetAbsOrigin(), true)
			--ParticleManager:SetParticleControlEnt(electricity, 4, hero, PATTACH_POINT_FOLLOW, "attach_attack1", hero:GetAbsOrigin(), true)
			--ParticleManager:SetParticleControlEnt(electricity, 5, hero, PATTACH_POINT_FOLLOW, "attach_attack1", hero:GetAbsOrigin(), true)
			-- ParticleManager:SetParticleControl(electricity, 4, hero:GetAbsOrigin())
			-- ParticleManager:SetParticleControl(electricity, 5, hero:GetAbsOrigin())
		end
	end
end

function CAvaloreGameMode:InitQuetalcoatl(hero, playernum)
	local unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	--unit:AddNewModifier(unit, nil, "modifier_faction_olympians", nil)
	local quetzalcoatl_cosmetics = {}
	quetzalcoatl_cosmetics[0] = "models/items/viper/blight_wyrm_back/blight_wyrm_back.vmdl"
	quetzalcoatl_cosmetics[1] = "models/items/viper/spring2021_king_of_corrupted_nest_head/spring2021_king_of_corrupted_nest_head.vmdl"
	quetzalcoatl_cosmetics[2] = "models/items/viper/viper_immortal_head_ti7/viper_immortal_head_ti7.vmdl"
	quetzalcoatl_cosmetics[3] ="models/items/viper/viper_beetle_tail/viper_beetle_tail.vmdl"
	
	for k,wearable in pairs(quetzalcoatl_cosmetics) do
		--print("Creating Cosmetic " .. wearable)
		local cosmetic = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
	end
end

function CAvaloreGameMode:InitGilgamesh(hero, playernum)
	local unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	--unit:AddNewModifier(unit, nil, "modifier_faction_olympians", nil)
	local gilgamesh_cosmetics = {}
	gilgamesh_cosmetics[0] = "models/items/beastmaster/beast_heart_marauder_belt/beast_heart_marauder_belt.vmdl"
	gilgamesh_cosmetics[1] = "models/items/beastmaster/chimeras_anger_head/chimeras_anger_head.vmdl"
	--gilgamesh_cosmetics[1] = "models/items/axe/undefeated_general_head/undefeated_general_head.vmdl"
	gilgamesh_cosmetics[2] = "models/items/beastmaster/bm_2021_immortal/bm_2021_single_axe.vmdl"
	--gilgamesh_cosmetics[2] ="models/heroes/beastmaster/bmaxe.vmdl"
	gilgamesh_cosmetics[3] = "models/items/beastmaster/fotw_shoulders/fotw_shoulders.vmdl"
	gilgamesh_cosmetics[4] = "models/items/beastmaster/ti9_cache_bm_chieftain_of_the_primal_tribes_arms/ti9_cache_bm_chieftain_of_the_primal_tribes_arms.vmdl"
	--gilgamesh_cosmetics[5] = "models/items/beastmaster/ram_karroch/ram_karroch.vmdl"
	gilgamesh_cosmetics[5] = "models/items/beastmaster/red_talon_shoulder/red_talon_shoulder.vmdl"
	
	for k,wearable in pairs(gilgamesh_cosmetics) do
		--print("Creating Cosmetic " .. wearable)
		local cosmetic = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
	end
end

function CAvaloreGameMode:InitPecosBill(hero, playernum)
	local unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	--unit:AddNewModifier(unit, nil, "modifier_faction_olympians", nil)
	local pecos_bill_cosmetics = {}
	pecos_bill_cosmetics[0] = "models/items/sniper/the_marksman_arms/the_marksman_arms.vmdl"
	pecos_bill_cosmetics[1] = "models/items/sniper/wildwest_head/wildwest_head.vmdl"
	pecos_bill_cosmetics[2] = "models/items/sniper/wildwest_shoulders/wildwest_shoulders.vmdl"
	pecos_bill_cosmetics[3] = "models/items/sniper/wildwest_back/wildwest_back.vmdl"
	pecos_bill_cosmetics[4] = "models/items/sniper/wildwest_weapon/wildwest_weapon.vmdl"
	pecos_bill_cosmetics[5] = "models/items/sniper/wildwest_arms/wildwest_arms.vmdl"
	pecos_bill_cosmetics[6] = "models/items/sniper/mlg_hunters_origin_shoulder/mlg_hunters_origin_shoulder.vmdl"
	
	
	for k,wearable in pairs(pecos_bill_cosmetics) do
		--print("Creating Cosmetic " .. wearable)
		local cosmetic = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
	end
end

function CAvaloreGameMode:InitSunWukong(hero, playernum, isIllu)
	local unit = hero
	if unit == nil and playernum ~= nil then
		unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	end

	--unit:AddNewModifier(unit, nil, "modifier_faction_olympians", nil)
	local sun_wukong_cosmetics = {}
	--sun_wukong_cosmetics[0] = "models/items/siren/luminous_warrior_head/luminous_warrior_head.vmdl"
	sun_wukong_cosmetics[0] = "models/items/monkey_king/monkey_king_arcana_head/mesh/monkey_king_arcana.vmdl"
	sun_wukong_cosmetics[1] = "models/items/monkey_king/mk_ti9_immortal_armor/mk_ti9_immortal_armor.vmdl"
	sun_wukong_cosmetics[2] = "models/heroes/monkey_king/monkey_king_base_weapon.vmdl"
	sun_wukong_cosmetics[3] = "models/items/monkey_king/mk_ti9_immortal_shoulder/mk_ti9_immortal_shoulder.vmdl"

	--transformations
	--sun_wukong_cosmetics[4] = "models/items/siren/tail_of_the_slithereen_knight/tail_of_the_slithereen_knight.vmdl"
	sun_wukong_cosmetics[4] = "models/items/siren/naga_ti8_immortal_tail/naga_ti8_immortal_tail.vmdl"
	sun_wukong_cosmetics[5] = "models/items/siren/luminous_warrior_head/luminous_warrior_head.vmdl"
	
	for k,wearable in pairs(sun_wukong_cosmetics) do
		print("Creating Cosmetic [" .. tostring(k) .. "] => " .. wearable)
		local cosmetic = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
		if isIllu then
			cosmetic:MakeIllusion()
			cosmetic:SetRenderColor(0,0,255)
		end
		
		if k > 3 then
			print("No Draw added to: " .. cosmetic:GetModelName())
			cosmetic:AddNoDraw()
			--cosmetic:AddEffects(EF_NODRAW) -- start out invis
		end
		-- if unit:IsIllusion() then
		-- 	cosmetic:AddNewModifier(nil, nil, "modifier_illusion", {}) -- built-in modifier to dota
		-- end
	end
end

function CAvaloreGameMode:InitThor(hero, playernum)
	local unit = hero
	if unit == nil and playernum ~= nil then
		unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	end
	local HEAD = 2
	local HAT = 4

	local thor_cosmetics = {}
	thor_cosmetics[0] = "models/heroes/dawnbreaker/dawnbreaker_weapon.vmdl"
	thor_cosmetics[1] = "models/items/dawnbreaker/first_light_armor/first_light_armor.vmdl"
	--thor_cosmetics[2] = "models/items/tuskarr/harmful_iron_fist_head/harmful_iron_fist_head.vmdl"
	--thor_cosmetics[2] = "models/items/omniknight/winged_helmet/winged_helmet.vmdl"
	--thor_cosmetics[2] = "models/items/omniknight/helmet_winged.vmdl"
	--thor_cosmetics[2] = "models/items/omniknight/thunderwraths_helm/thunderwraths_helm.vmdl"
	--thor_cosmetics[2] = "models/items/omniknight/light_helmet/light_helmet.vmdl"
	--thor_cosmetics[HEAD] = "models/heroes/legion_commander/legion_commander_head.vmdl"
	thor_cosmetics[2] = "models/items/dawnbreaker/first_light_head/first_light_head.vmdl"
	--thor_cosmetics[HAT] = "models/items/legion_commander/immortalspride_head/immortalspride_head.vmdl"
	--thor_cosmetics[3] = "models/items/omniknight/cape_hierophant.vmdl"
	thor_cosmetics[3] = "models/heroes/dawnbreaker/dawnbreaker_arms.vmdl"
	--thor_cosmetics[4] = "models/items/legion_commander/valkyrie_shoulder/valkyrie_shoulder.vmdl"
	--thor_cosmetics[4] = "models/items/phantom_assassin/valkyries_shade_shoulder/valkyries_shade_shoulder.vmdl"
	--thor_cosmetics[4] = "models/items/sven/the_watcher_of_the_north_shoulder/the_watcher_of_the_north_shoulder.vmdl"
	--thor_cosmetics[4] = "models/items/crystal_maiden/frosty_valkyrie_shoulder/frosty_valkyrie_shoulder.vmdl"
	thor_cosmetics[4] = "models/items/omniknight/omni_fall20_immortal_shoulders/omni_fall20_immortal_shoulders.vmdl"
	
	-- gods strength transformation
	thor_cosmetics[5] = "models/heroes/dawnbreaker/dawnbreaker_head.vmdl"

	local wearables = {}
	for k,wearable in pairs(thor_cosmetics) do
		--print("Creating Cosmetic " .. wearable)
		wearables[k] = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		local cosmetic = wearables[k]
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		local wearable_kvs = {}
		-- hammer model
		if k == 0 then
			print("Weapon Wearable => " .. wearable)
			wearable_kvs["no_draw_mod"] = "modifier_no_hammer"
		end
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", wearable_kvs)
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
		-- if k == HEAD then
		-- 	cosmetic:FollowEntity(unit, true)
		-- -- elseif k == HAT then
		-- -- 	cosmetic:FollowEntity(wearables[HEAD], true)
		-- else
		-- 	cosmetic:FollowEntity(unit, true)
		-- end

		if k > 4 then
			print("No Draw added to: " .. cosmetic:GetModelName())
			cosmetic:AddNoDraw()
		end
	end
end

function CAvaloreGameMode:InitKingArthur(hero, playernum)
	local unit = hero
	if unit == nil and playernum ~= nil then
		unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	end

	local king_arthur_cosmetics = {}
	king_arthur_cosmetics[0] = "models/heroes/dragon_knight_persona/dk_persona_shoulder_pauldrons.vmdl"
	king_arthur_cosmetics[1] = "models/heroes/dragon_knight_persona/dk_persona_weapon.vmdl"
	--king_arthur_cosmetics[1] = "models/items/dragon_knight/ascension_weapon/ascension_weapon.vmdl"
	king_arthur_cosmetics[2] = "models/heroes/dragon_knight_persona/dk_persona_head_hair.vmdl"
	king_arthur_cosmetics[3] = "models/heroes/dragon_knight_persona/dk_persona_shoulder_cape.vmdl"
	--king_arthur_cosmetics[4] = "models/items/dragon_knight/fire_tribunal_tabard/fire_tribunal_tabard.vmdl"

	local wearables = {}
	for k,wearable in pairs(king_arthur_cosmetics) do
		wearables[k] = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		local cosmetic = wearables[k]
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
	end
end

function CAvaloreGameMode:InitAnubis(hero, playernum)
	local unit = hero
	if unit == nil and playernum ~= nil then
		unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	end

	local anubis_cosmetics = {}
	anubis_cosmetics[0] = "models/items/phantom_lancer/anubis_phantom_lancer_head/anubis_phantom_lancer_head.vmdl"
	anubis_cosmetics[1] = "models/items/phantom_lancer/anubis_phantom_lancer_arms/anubis_phantom_lancer_arms.vmdl"
	anubis_cosmetics[2] = "models/items/phantom_lancer/anubis_phantom_lancer_belt/anubis_phantom_lancer_belt.vmdl"
	anubis_cosmetics[3] = "models/items/phantom_lancer/anubis_phantom_lancer_shoulder/anubis_phantom_lancer_shoulder.vmdl"
	anubis_cosmetics[4] = "models/items/phantom_lancer/anubis_phantom_lancer_weapon/anubis_phantom_lancer_weapon.vmdl"

	local wearables = {}
	for k,wearable in pairs(anubis_cosmetics) do
		wearables[k] = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		local cosmetic = wearables[k]
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		cosmetic:FollowEntity(unit, true)
	end
	unit:SetRenderColor(0,0,0)
end

function CAvaloreGameMode:InitThor_old(hero, playernum)
	local unit = hero
	if unit == nil and playernum ~= nil then
		unit = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	end
	local HEAD = 0
	local HELM = 1
	local HAMMER = 2
	local HANDS = 3
	local CAPE = 5
	local BRACER = 8

	local thor_cosmetics = {}
	thor_cosmetics[HEAD] = "models/heroes/omniknight/head.vmdl"
	--thor_cosmetics[HELM] = "models/items/tuskarr/harmful_iron_fist_head/harmful_iron_fist_head.vmdl"
	thor_cosmetics[HELM] = "models/items/omniknight/thunderwraths_helm/thunderwraths_helm.vmdl"
	--thor_cosmetics[HAMMER] = "models/items/faceless_void/voidhammer/voidhammer.vmdl"
	--thor_cosmetics[HAMMER] = "models/items/omniknight/weapon_rune_hammer.vmdl"
	--thor_cosmetics[HAMMER] = "models/heroes/dawnbreaker/dawnbreaker_weapon.vmdl"
	--thor_cosmetics[HAMMER] = "models/items/disruptor/disruptor_rider_storm_hammer/disruptor_rider_storm_hammer.vmdl"
	--thor_cosmetics[HAMMER] = "models/items/sven/greatsword_cyclopean_marauder/greatsword_cyclopean_marauder.vmdl"
	thor_cosmetics[HAMMER] = "models/heroes/elder_titan/elder_titan_hammer.vmdl"
	--thor_cosmetics[HANDS] = "models/items/sven/guardian_of_the_holy_flame_arms/guardian_of_the_holy_flame_arms.vmdl"
	thor_cosmetics[HANDS] = "models/items/sven/spartan_gauntlet.vmdl"
	thor_cosmetics[4] = "models/items/sven/outcast_knight_belt/outcast_knight_belt.vmdl"
	thor_cosmetics[5] = "models/items/sven/guise_of_belligerent_ram_back/guise_of_belligerent_ram_back.vmdl"
	thor_cosmetics[6] = "models/items/sven/guise_of_belligerent_ram_shoulder/guise_of_belligerent_ram_shoulder.vmdl"
	thor_cosmetics[7] = "models/items/sven/outcast_knight_back/outcast_knight_back.vmdl"
	--thor_cosmetics[BRACER] = "models/heroes/faceless_void/faceless_void_bracer.vmdl"
	--thor_cosmetics[BRACER] = "models/heroes/dawnbreaker/dawnbreaker_arms.vmdl"
	--thor_cosmetics[CAPE] = "models/items/omniknight/cape_hierophant.vmdl"
	--thor_cosmetics[CAPE] = "models/items/invoker/exort_cape.vmdl"

	local wearables = {}

	-- local ghost_body = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
	-- ghost_body:SetModel("models/heroes/faceless_void/faceless_void.vmdl")
	-- ghost_body:SetOriginalModel("models/heroes/faceless_void/faceless_void.vmdl")
	-- ghost_body:AddNoDraw()
	-- ghost_body:FollowEntity(unit, true)
	-- ghost_body:SetParent(unit, nil)
	-- ghost_body:SetOwner(unit)
	-- ghost_body:AddNewModifier(nil, nil, "modifier_wearable", {})

	
	for k,wearable in pairs(thor_cosmetics) do
		--print("Creating Cosmetic " .. wearable)
		wearables[k] = CreateUnitByName("wearable_dummy", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
		local cosmetic = wearables[k]
		cosmetic:SetOriginalModel(wearable)
		cosmetic:SetModel(wearable)
		cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
		cosmetic:SetParent(unit, nil)
		cosmetic:SetOwner(unit)
		-- if k == CAPE then
		-- 	cosmetic:SetAbsScale(2.0)
		-- end
		--if k == HELM or k == CAPE then
		if k == HELM then
			cosmetic:FollowEntity(wearables[HEAD], true)
		-- elseif k == HAMMER then
		-- 	cosmetic:FollowEntity(wearables[BRACER], true)
		-- 	--cosmetic:FollowEntity(ghost_body, true)
		else
			cosmetic:FollowEntity(unit, true)
		end

		-- if k == HAMMER then
		-- 	cosmetic:SetModel("models/items/faceless_void/voidhammer/voidhammer.vmdl")
		-- end
	end
end

function CAvaloreGameMode:InitRobinHood_old(unit, playernum)
	CAvaloreGameMode.player_cosmetics[playernum] = {}
	local hero = PlayerResource:GetPlayer(playernum):GetAssignedHero()
	-- Sparrowhawk Cape (DOTA_LOADOUT_TYPE_BACK)
	local SomeModel = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/windrunner/sparrowhawk_cape/sparrowhawk_cape.vmdl"})
	SomeModel:FollowEntity(unit, true)
	SomeModel:AddNewModifier(nil, nil, "modifier_wearable", {})
	CAvaloreGameMode.player_cosmetics[playernum][DOTA_LOADOUT_TYPE_BACK] = SomeModel

	-- Longbow of the Roving Pathfinder (DOTA_LOADOUT_TYPE_WEAPON)
	local SomeModel = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/windrunner/the_swift_pathfinder_swift_pathfinders_bow/the_swift_pathfinder_swift_pathfinders_bow.vmdl"})
	SomeModel:FollowEntity(unit, true)
	unit.weapon_model = SomeModel
	--table.insert(unit.cosmetics, SomeModel)

	-- Quiver of the Northern Wind
	local SomeModel = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/windrunner/quiver_of_the_northern_wind/quiver_of_the_northern_wind.vmdl"})
	SomeModel:FollowEntity(unit, true)
	CAvaloreGameMode.player_cosmetics[playernum][DOTA_LOADOUT_TYPE_SHOULDER] = SomeModel

	-- Tricorn of the Roving Pathfinder
	local SomeModel = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/windrunner/the_swift_pathfinder_swift_pathfinders_hat_v2/the_swift_pathfinder_swift_pathfinders_hat_v2.vmdl"})
	SomeModel:FollowEntity(unit, true)
	CAvaloreGameMode.player_cosmetics[playernum][DOTA_LOADOUT_TYPE_HEAD] = SomeModel

	-- Mantle of the Roving Pathfinder
	local SomeModel = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/windrunner/the_swift_pathfinder_swift_pathfinders_coat/the_swift_pathfinder_swift_pathfinders_coat.vmdl"})
	SomeModel:FollowEntity(unit, true)
	CAvaloreGameMode.player_cosmetics[playernum][DOTA_LOADOUT_TYPE_ARMOR] = SomeModel


	-- print("Print player_cosmetics")
	-- for key,value in pairs(CAvaloreGameMode.player_cosmetics) do
	-- 	print(tostring(key))
	-- end

	-- print("Print player_cosmetics[playernum]")
	-- for key,value in pairs(CAvaloreGameMode.player_cosmetics[playernum]) do
	-- 	print(tostring(key))
	-- end
end

-- =================================
-- TALENTS
-- =================================

--LinkLuaModifier( "modifier_talent_parry", "heroes/robin_hood/modifier_talent_parry.lua", LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "modifier_talent_bonus_range", "heroes/robin_hood/modifier_talent_bonus_range.lua", LUA_MODIFIER_MOTION_NONE )

-- event: dota_player_learned_ability
-- > PlayerID: PlayerID
-- > player: short
-- > abilityname: string
function CAvaloreGameMode:OnPlayerLearnedAbility(event)
	-- print("Ability was learned! ==> " .. event.abilityname)
	-- if event.abilityname == "ability_toothgnashers" then
	-- 	local player = EntIndexToHScript(event.player)
	-- 	local hero = player:GetAssignedHero()
	-- 	if hero:FindAbilityByName("ability_consume_goat") == nil then
	-- 		hero:AddAbility("ability_consume_goat")
	-- 	end
	-- end
	--print("CAvaloreGameMode:OnPlayerLearnedAbility(event)")
	local player = EntIndexToHScript(event.player)
	local hero = player:GetAssignedHero()
	local abilityname = event.abilityname

	-- print(abilityname)
	-- print(hero:GetName())
	-- print(tostring(abilityname:find("talent")))

	-- add dummy modifiers so some of the special value lookups (e.g. range increases) will work
	-- NOTE: not all talents have/need these tracking modifiers, but it won't cause errors if the attempt 
	--       to add them fails
	if abilityname:find("talent") == 1 then
		print("Adding modifier: " .. "modifier_" .. abilityname)
		local modif = hero:AddNewModifier(hero, nil, "modifier_" .. abilityname, {})
		--print()
	end

	-- print("===== Debug Modifiers =====")
	-- for _,mod in pairs(hero:FindAllModifiers()) do
	-- 	print(mod:GetName())
	--end
end