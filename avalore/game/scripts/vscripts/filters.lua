-- taken largely from dota_imba


-- entindex_caster_const: EntityIndex
-- entindex_ability_const: EntityIndex
-- value_name_const: string
-- value: int
function CAvaloreGameMode:AbilityTuningFilter(keys)
	-- local ability = EntIndexToHScript(keys["entindex_ability_const"])
	-- if ability:GetName() == "item_slot_misc" then return end
	-- --print("CAvaloreGameMode:AbilityTuningFilter(keys)")
	-- --print(ability:GetName())
	-- if string.find(ability:GetName(), "merc") then
	-- 	PrintTable(keys)
	-- end
	return true
end


-- ExecuteOrderFilterEvent
-- *  units: { [string]: EntityIndex }
-- * entindex_target: EntityIndex
-- * entindex_ability: EntityIndex
-- * issuer_player_id_const: PlayerID
-- * sequence_number_const: uint
-- * queue: 0 | 1
-- * order_type: dotaunitorder_t
-- * position_x: float
-- * position_y: float
-- * position_z: float
function CAvaloreGameMode:OrderFilter(keys)
	-- print("CAvaloreGameMode:OrderFilter(keys)")
	-- PrintTable(keys)


	local ability = EntIndexToHScript(keys.entindex_ability)
	if ability ~= nil then
		--print("Ability => " .. ability:GetName())
		if (	ability:GetName() == "item_merc_super_djinn" 
			or 	ability:GetName() == "item_merc_skeletons" 
			or 	ability:GetName() == "item_merc_pyromancer" 
			or 	ability:GetName() == "item_merc_wendigo" 
			or 	ability:GetName() == "item_merc_imp_archers" 
			or 	ability:GetName() == "item_merc_ent"
			or 	ability:GetName() == "item_merc_tower"
			or 	ability:GetName() == "ability_merc_train_yeti"
			or 	ability:GetName() == "ability_arcanery_fireball"
		) then
			--ability = EntIndexToHScript(keys["entindex_ability"])
			--print(ability:GetName())
			--PrintTable(ability)
			--print("keys issued by: " .. tostring(keys.issuer_player_id_const))
			--print("unit issued by: " .. tostring(unit.issuer_player_id_const))
			-- temporarily set owner to player to capture caster correctly
			local unit = ability:GetOwner() -- should be the merc camp
			--print("ABility Owner = > " .. ability:GetOwner():GetName())
			--unit:SetOwner(PlayerResource:GetPlayer(keys.issuer_player_id_const):GetAssignedHero())
			-- --unit.issuer_player_id_const = keys.issuer_player_id_const
			-- -- local keys = {}
			-- -- keys["caster"]
			unit.PlayerCaster = keys.issuer_player_id_const
			unit.target_x = keys.position_x
			unit.target_y = keys.position_y
			ability:OnSpellStart()
			return true
		end
	end

	local units = keys["units"]
	local unit
	if units["0"] then
		unit = EntIndexToHScript(units["0"])
		--print("Unit => " .. unit:GetClassname())
	else
		return nil
	end
	

    -- -- Don't let couriers be controlled when multi-selected
	-- if keys.units then
	-- 	for k, v in pairs(keys.units) do
	-- 		if k ~= "0" and EntIndexToHScript(v) and EntIndexToHScript(v):IsCourier() then
	-- 			return false
	-- 		end
	-- 	end
	-- end

	-- -- Do special handlings if shift-casted only here! The event gets fired another time if the caster
	-- -- is actually doing this order
	-- if keys.queue == 1 then
	-- 	return true
	-- end

    -- local target = keys.entindex_target ~= 0 and EntIndexToHScript(keys.entindex_target) or nil
	-- local ability = keys.entindex_ability ~= 0 and EntIndexToHScript(keys.entindex_ability) or nil

    -- local disableHelpResult = DisableHelp.ExecuteOrderFilter(keys.order_type, ability, target, unit)
	-- if disableHelpResult == false then
	-- 	return false
	-- end

    -- if keys.order_type == DOTA_UNIT_ORDER_GLYPH then
	-- 	CombatEvents("generic", "glyph", unit)
	-- end

    -- -- credits Overthrow 2.0 (Dota2Unofficial)
	-- if keys.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
	-- 	if not target then return true end
	-- 	local pickedItem = target:GetContainedItem()
	-- 	if not pickedItem then return true end

	-- 	local itemName = pickedItem:GetAbilityName()

	-- 	if itemName == "item_aegis" then
	-- 		if not unit:IsRealHero() then
	-- 			DisplayError(keys.issuer_player_id_const, "#dota_hud_error_non_hero_cant_pickup_aegis")
	-- 			return false
	-- 		elseif unit:HasModifier("modifier_item_imba_aegis") then
	-- 			DisplayError(keys.issuer_player_id_const, "#dota_hud_error_already_have_aegis")
	-- 			return false
	-- 		end
	-- 	end
	-- end

    ------------------------------------------------------------------------------------
	-- Prevent Buyback during reincarnation
	------------------------------------------------------------------------------------
	-- if keys.order_type == DOTA_UNIT_ORDER_BUYBACK then
	-- 	if unit:IsReincarnating() then
	-- 		return false
	-- 	else
	-- 		-- Trying to add a custom buyback respawn timer penalty modifier
	-- 		-- Doing a rough safeguard using gold so people don't get the modifier when spamming the buyback button a frame before they respawn like an idiot
	-- 		local gold_before_buyback = unit:GetGold() or -1
			
	-- 		Timers:CreateTimer(FrameTime(), function()
	-- 			-- If these checks pass, this assumes that the person actually bought back
	-- 			if unit:IsAlive() and gold_before_buyback >= (unit:GetGold() or 0) then
	-- 				unit:AddNewModifier(unit, nil, "modifier_buyback_penalty", {})
	-- 			end
	-- 		end)
	-- 	end
	-- end

    -- ===============================================================================
    -- Handle Spells That Don't Require Unit to be Facing The Target/Cursor Location
    -- ===============================================================================
    

    --if keys.order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then
    --if keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET then
    --print("[Filters] keys.order_type = " .. tostring(keys.order_type))
    if keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
        --local ability = EntIndexToHScript(keys.entindex_ability)

        -- Sun Wukong - Jingu Stuff
        if ability ~= nil then
            if ability:GetAbilityName() == "ability_ruyi_jingu_bang" or ability:GetAbilityName() == "ability_riptide"then
                print("Hit Filter for ability_ruyi_jingu_bang and ability_riptide")
                unit:AddNewModifier(unit, ability, "modifier_ignore_cast_direction", {duration = 0.41} )
            end
        end
    end

    return true
end


-- ===============================================================================
-- Handle Special Cases Involving Gold
-- ===============================================================================
-- USAGE: Modify the table and Return true to use new values, return false to cancel the event
-- =============================================
-- ModifyGoldFilterEvent
-- * player_id_const: PlayerID
-- * reason_const: EDOTA_ModifyGold_Reason
-- * reliable: 0 | 1
-- * gold: uint
-- ============================================
function CAvaloreGameMode:GoldFilter(keys)
	-- if keys.gold <= 0 then
	-- 	return false
	-- end

	if PlayerResource:GetPlayer(keys.player_id_const) == nil then return end
	local player = PlayerResource:GetPlayer(keys.player_id_const)
	if player then
		local hero = player:GetAssignedHero()
		if hero == nil then return end

		local mod_bleed_their_purse = hero:FindModifierByName("modifier_bleed_their_purse_debuff")
		if mod_bleed_their_purse then
			keys.gold = (keys.gold * (1 - mod_bleed_their_purse:GoldReduction()))
			return true
		end
	end
	return true
end

-- DamageFilterEvent
-- * entindex_attacker_const: EntityIndex
-- * entindex_victim_const: EntityIndex
-- * entindex_inflictor_const?: EntityIndex
-- * damagetype_const: DAMAGE_TYPES
-- * damage: float
function CAvaloreGameMode:DamageFilter(keys)
	if IsServer() then
		local attacker
		local victim
		local inflictor

		if keys.entindex_attacker_const and keys.entindex_victim_const then
			attacker = EntIndexToHScript(keys.entindex_attacker_const)
			victim = EntIndexToHScript(keys.entindex_victim_const)
		else
			return false
		end

		if keys.entindex_inflictor_const then
			inflictor = EntIndexToHScript(keys.entindex_inflictor_const)
		end

		-- we're just looking for Abilities/Items here
		if inflictor and (inflictor:IsNPC() or inflictor:IsDOTANPC() or inflictor:IsBaseNPC()) then return true end

		--if keys.damagetype_const == AVALORE_DAMAGE_TYPE_FIRE then
		if keys.damagetype_const == DAMAGE_TYPE_MAGICAL then
			local inflictor_name = "NONE"
			if inflictor then
				inflictor_name = inflictor:GetName()
			end
			print(attacker:GetName() .. " Attacked " .. victim:GetName())
			print("[" .. inflictor_name  .. "]" .. " MAGIC DAMAGE OF " .. tostring(keys.damage))
			--keys.damagetype_const = DAMAGE_TYPE_MAGICAL

			--if inflictor and inflictor:IsItem() then
			if inflictor then
				print("INFLICTOR => " .. inflictor:GetName())

				local item_kvs = inflictor:GetAbilityKeyValues()
				
				-- only do anything if this is a special magic damage type
				if item_kvs["AvaloreDamageType"] then
					-- find out whether the victim can resist any magic damage
					local mods = victim:FindAllModifiers()
					local fire_resist = 0
					local water_resist = 0

					local lightning_amplify = 0
					for key, value in pairs(mods) do
						print("Working on Modifier..." .. value:GetName())
						if value["GetFireResist"] then
							fire_resist = fire_resist + value:GetFireResist()
						end

						if value["GetWaterResist"] then
							water_resist = water_resist + value:GetWaterResist()
						end

						if value["GetLightningAmplify"] then
							lightning_amplify = lightning_amplify + value:GetLightningAmplify()
						end
					end

					local resist = 0
					if item_kvs["AvaloreDamageType"] == AVALORE_DAMAGE_TYPE_FIRE then
						print("FIRE DAMAGE")
						if fire_resist > 0 then
							print("Before => " .. tostring(keys.damage))
							keys.damage = keys.damage * (fire_resist/100)
							print("After => " .. tostring(keys.damage))
							SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, victim, keys.damage, nil)
						end
					elseif item_kvs["AvaloreDamageType"] == AVALORE_DAMAGE_TYPE_LIGHTNING then
						print("LIGHTNING DAMAGE")
						if lightning_amplify > 0 then
							print("Before => " .. tostring(keys.damage))
							keys.damage = keys.damage * lightning_amplify
							print("After => " .. tostring(keys.damage))
							SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, victim, keys.damage, nil)
						end
					end
				end
			end
		end
	end
	return true
end

-- ==================================================
-- ItemAddedToInventoryFilterEvent
-- ==================================================
-- inventory_parent_entindex_const: EntityIndex
-- item_parent_entindex_const: EntityIndex
-- item_entindex_const: EntityIndex
-- suggested_slot: -1 | DOTAScriptInventorySlot_t
-- ==================================================
-- Set a filter function to control what happens to 
-- items that are added to an inventory, return false to cancel the event.
function CAvaloreGameMode:ItemAddedToInventoryFilter(event)
	print("===============")
	print("CAvaloreGameMode:ItemAddedToInventoryFilter(kv)")
	--PrintTable(kv)
	local item = EntIndexToHScript(event.item_entindex_const)
	local item_slot = item:GetSpecialValueFor("item_slot")
	print("Item " .. item:GetName() .. " | Slot > " .. tostring(item_slot))
	local parent = EntIndexToHScript(event.inventory_parent_entindex_const)
	if (not parent) then
		return true
	end
	print("Parent > " .. parent:GetName())
	PrintTable(parent)
	if (parent:IsBaseNPC() and not (parent:IsRealHero() and parent:IsOwnedByAnyPlayer())) then
		print("no parent / not player")
		return true
	end
	print("Owner > " .. parent:GetOwner():GetName())
	local inventory = InventoryManager[parent:GetOwner():GetPlayerID()]
	local slots = inventory:GetSlots()

	if item_slot < 6 then
        -- make sure this hasn't already been somehow indexed
        if slots[item_slot] == item then
			print("item already in place!")
            if item:IsStackable() then
                return true
            end
        elseif slots[item_slot] ~= nil then
			print("Slot already used!")
            local broadcast_obj = 
			{
				msg = ("#error_slot_" .. tostring(item_slot)),
				time = 10,
				elaboration = "",
				type = MSG_TYPE_ERROR
			}
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(item:GetOwner():GetPlayerID()), "broadcast_message", broadcast_obj )
			return false
        else
			print("suggesting slot: " .. tostring(item_slot))
			event.suggested_slot = item_slot
			PrintTable(event)
			return true
		end
	elseif item_slot == AVALORE_ITEM_SLOT_MISC then
		for misc_slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
			if slots[AVALORE_ITEM_SLOT_MISC][misc_slot] == nil then
				event.suggested_slot = misc_slot
				PrintTable(event)
				return true
			end
		end
	end

	return true
end