require("constants")
require("references")
require(REQ_UTIL)

-- Initialized in: CAvaloreGameMode:OnHeroFinishSpawn(event)
if InventoryManager == nil then
    InventoryManager = {}
end

-- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Engine_Events
-- dota_item_picked_up
-- 	* itemname ( string )
-- 	* PlayerID ( short )
-- 	* ItemEntityIndex( short )
-- 	* HeroEntityIndex( short )
-- 
function CAvaloreGameMode:OnItemPickUp(event)
	print("CAvaloreGameMode:OnItemPickUp(event)")
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner;
	if event.HeroEntityIndex then
		owner = EntIndexToHScript( event.HeroEntityIndex )
	else
		-- if no hero index, then it's a courier or something
		return
		--owner = nil
	end

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
	-- temporarily commenting this out since it seems added gets claled twice
	-- else
	-- 	-- probably a dropped item so we need to handle it with the dummy slots
	-- 	local inventory = InventoryManager[event.PlayerID]
    -- 	inventory:PickUp(item)
	end -- end if-statement: item picked up was flag

	
end -- end function: CAvaloreGameMode:OnItemPickUp(event)


-- https://moddota.com/api/#!/events/dota_inventory_item_added
-- dota_inventory_item_added
-- * item_slot: short
-- * inventory_player_id: PlayerID
-- * itemname: string
-- * item_entindex: EntityIndex
-- * inventory_parent_entindex: EntityIndex
-- * is_courier: bool ==> NOTE: idk what this tracks, because it seems to ALWAYS BE TRUE
function CAvaloreGameMode:OnItemAdded(event)
	if not IsServer() then return end
	print("[CAvaloreGameMode:OnItemAdded] Start")
	PrintTable(event)
	local item = EntIndexToHScript( event.item_entindex )
	local owner = EntIndexToHScript( event.inventory_parent_entindex )
	-- if owner then
	-- 	print("Owner => " .. owner:GetName())
	-- else
	-- 	print("Owner => nil")
	-- end
	local hero = PlayerResource:GetSelectedHeroEntity(event.inventory_player_id)
	
	if (not hero) or (not hero:IsRealHero()) then return end -- probably merc camp init

	-- this is in the stash or transient slot
	--if (event.item_slot > DOTA_ITEM_SLOT_9 and event.item_slot < DOTA_ITEM_TP_SCROLL) or () then
	-- if event.item_slot > DOTA_ITEM_SLOT_9 then
	-- 	return
	-- end
	-- if event.item_slot == DOTA_ITEM_TRANSIENT_ITEM then
	-- 	return
	-- end

	--print("Inventory Owner: " .. owner:GetName())
	local hEIndex = hero:GetEntityIndex()
	--print("Hero Ent Index => " .. tostring(hEIndex))

	-- this is probably an illusion
	-- seems that when an illusion is created, the inventory is cloned
	-- and we don't want to let that process interfere with Avalore's inventory tracking
	if hEIndex ~= event.inventory_parent_entindex then return end

	-- don't worry about recipes
	if item then
		if (string.find(item:GetName(), "item_recipe")) then return end

		-- don't worry about transitory phase
		if event.item_slot == DOTA_ITEM_TRANSIENT_ITEM then
			print("[CAvaloreGameMode:OnItemAdded] Transient Item - Skipping")
			return
		end

		--print("CAvaloreGameMode:OnItemAdded(event)")
		-- if hero then --could be a spawner or something
		-- 	print("Room for item? => " .. tostring(hero:HasRoomForItem(event.itemname, false, false)))
		-- end
		--print("Item: " .. item:GetName())
		--print("Item Slot: " .. item:GetItemSlot())
		

		local inventory = InventoryManager[event.inventory_player_id]

		-- this actually triggers when hero adds something to anything with slots (building, bear, courier, etc.)
		-- also check this isn't an attempt to add the slot back (seems to keep the courier tag for some reason)
		--if event.is_courier and not string.find(item:GetName(), "item_slot") then
		if string.find(owner:GetName(), "courier") and not string.find(item:GetName(), "item_slot") then
			--print("Added to Courier") -- idk 
			-- if they don't have an inventory, then it's not a hero

			if inventory then
				inventory:Remove(item) -- hero gave to something else, need to update
			end
		else
			-- filter weird situations like trying to give items to buildings by checking for presence of an
			-- avalore inventory
			if inventory then
				local shop_trigger = nil
				if hero:GetTeam() == DOTA_TEAM_BADGUYS then
					shop_trigger = Entities:FindByName(nil, "dire_base")
				else
					shop_trigger = Entities:FindByName(nil, "radiant_base")
				end
				-- if the item is in stash, make sure we're in range
				if (event.item_slot > DOTA_ITEM_SLOT_9 and event.item_slot < DOTA_ITEM_TP_SCROLL) then
					if shop_trigger:IsTouching(hero) then
						print("[CAvaloreGameMode:OnItemAdded] Stash item, but hero in range to transfer")
						inventory:Add(item)
					else
						print("[CAvaloreGameMode:OnItemAdded] can't transfer")
					end
				else
					print("[CAvaloreGameMode:OnItemAdded] adding non-stash item to inventory")
					inventory:Add(item)
				end
			end
		end

		if     event.itemname == OBJECTIVE_FLAG_ITEM_A 
		or event.itemname == OBJECTIVE_FLAG_ITEM_B 
		or event.itemname == OBJECTIVE_FLAG_ITEM_C 
		or event.itemname == OBJECTIVE_FLAG_ITEM_D 
		or event.itemname == OBJECTIVE_FLAG_ITEM_E then
			if inventory:Contains(event.itemname) and (not owner:HasItemInInventory(event.itemname)) then
				print("Item in Avalore Inv, but not in Dota Inv")
				--hero:AddItem(item) -- crashes game
				hero:PickupDroppedItem(item)
			end
		end
	end

	

	-- if item:GetSpecialValueFor("item_slot") == AVALORE_ITEM_SLOT_FEET then
	-- 	if owner:HasItemInInventory("item_slot_feet") then
	-- 		local foot_slot
	-- 		for slot=0,8 do
	-- 			if owner:GetItemInSlot(slot):GetName() == "item_slot_feet" then
	-- 				foot_slot = owner:GetItemInSlot(slot)
	-- 				owner:SwapItems(item:GetItemSlot(), foot_slot:GetItemSlot())
	-- 				owner:RemoveItem(foot_slot)
	-- 			end
	-- 		end
			
	-- 	end
	
	-- end
end

-- https://moddota.com/api/#!/events/dota_hero_inventory_item_change
--dota_hero_inventory_item_change
----player_id: int
----hero_entindex: EntityIndex
----item_entindex: EntityIndex
----removed: bool
function CAvaloreGameMode:OnInventoryChanged(event)
	if not IsServer() then return end
    --print("CAvaloreGameMode:OnInventoryChanged(event)")
    local item = EntIndexToHScript( event.item_entindex )
    --print("Item: " .. item:GetName())
    --print("Item Slot: " .. item:GetItemSlot())
    local inventory = InventoryManager[event.player_id]
	-- removed seems to happen twice, once while it's in the slot and once
	-- after when it has an index of -1, calling it twice creates issues
    if (event.removed and item:GetItemSlot() > -1) then
        inventory:Remove(item)
	elseif item:GetContainer() then
		print("OnInventoryChanged >> Dropped")
		-- if the item has a container, that means it was dropped and now has a physical form
		local phys_item = item:GetContainer()
		if (item:GetName() == OBJECTIVE_FLAG_ITEM_A) or (item:GetName() == OBJECTIVE_FLAG_ITEM_B) then
			RenderFlagMorale(phys_item)
		elseif item:GetName() == OBJECTIVE_FLAG_ITEM_C then
			RenderFlagAgility(phys_item)
		elseif item:GetName() == OBJECTIVE_FLAG_ITEM_D then
			RenderFlagArcane(phys_item)
		elseif item:GetName() == OBJECTIVE_FLAG_ITEM_E then
			RenderFlagRegrowth(phys_item)
		end
		inventory:Remove(item)
    end

	-- handling this with the modifier now
	-- if item:IsInBackpack() then
	-- 	print("Moved to Backpack")
	-- 	item:SetCanBeUsedOutOfInventory(true)
	-- else
	-- 	item:SetCanBeUsedOutOfInventory(false)
	-- end

end

function InventoryManager:DebugDotaSlots(hero)
    print("===== DEBUG DOTA INVENTORY =====")
    --local owner = EntIndexToHScript( event.hero_entindex )
    for slot_num=0,20 do
        local item_name = "nil"
		local item = hero:GetItemInSlot(slot_num)
        if (hero:GetItemInSlot(slot_num)) then
            item_name = hero:GetItemInSlot(slot_num):GetName()
        end

        print("[" .. tostring(slot_num) .. "] = " .. item_name .. "(" .. tostring(item) .. ")")
    end
end

function InventoryManager:DebugAvaloreSlots(player_id)
    print("===== DEBUG AVALORE INVENTORY =====")
    local inventory = InventoryManager[player_id]
    for slot_num=AVALORE_ITEM_SLOT_HEAD,AVALORE_ITEM_SLOT_TRINKET do
        local item_name = "nil"
		local item = inventory.slots[slot_num]
        if (inventory.slots[slot_num]) then
            item_name = inventory.slots[slot_num]:GetName()
        end

        print("[" .. tostring(slot_num) .. "] = " .. item_name .. "(" .. tostring(item) .. ")")
    end
	for misc_slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
		local item_name = "nil"
		local item = inventory.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]
        if (inventory.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]) then
            item_name = inventory.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]:GetName()
        end

        print("[" .. tostring(misc_slot) .. "] = " .. item_name .. "(" .. tostring(item) .. ")")
	end
end


-- https://moddota.com/api/#!/events/dota_courier_transfer_item#item_entindex
-- Fires ONLY when courier transfers to player
-- dota_courier_transfer_item
---- courier_entindex: EntityIndex
---- item_entindex: EntityIndex
---- hero_entindex: EntityIndex
function CAvaloreGameMode:TransferItem(event)
    print("CAvaloreGameMode:TransferItem(event)")
	local item = EntIndexToHScript(event.item_entindex)
	-- if it's a recipe it should combine ok on its own
	if not string.find(item:GetName(), "recipe") then
		local hero = EntIndexToHScript(event.hero_entindex)
		local inventory = InventoryManager[hero:GetPlayerID()]
		inventory:Add(item)
	end
	--PrintTable(event)
end

-- dota_action_item
-- * itemdef: short
function CAvaloreGameMode:ActionItem(event)
    print("CAvaloreGameMode:ActionItem(event)")
end

-- dota_inventory_player_got_item
-- * itemname: string
function CAvaloreGameMode:PlayerGotItem(event)
    print("CAvaloreGameMode:PlayerGotItem(event)")
end

-- dota_item_drag_begin
function CAvaloreGameMode:ItemDragBegin(event)
    print("CAvaloreGameMode:ItemDragBegin(event)")
end

-- dota_item_drag_end
function CAvaloreGameMode:ItemDragEnd(event)
    print("CAvaloreGameMode:ItemDragEnd(event)")
end

-- inventory_updated
-- * itemdef: short
-- * itemid: long
function CAvaloreGameMode:InventoryUpdated(event)
    print("CAvaloreGameMode:InventoryUpdated(event)")
end

function CAvaloreGameMode:InventoryItemChanged(event)
    print("CAvaloreGameMode:InventoryItemChanged(event)")
end

function CAvaloreGameMode:InventoryChanged(event)
    print("CAvaloreGameMode:InventoryChanged(event)")
end

function CAvaloreGameMode:InventoryChangedQueryUnit(event)
    print("CAvaloreGameMode:InventoryChangedQueryUnit(event)")
end

function CAvaloreGameMode:ItemGifted(event)
    print("CAvaloreGameMode:ItemGifted(event)")
end

-- going to comment this out for now, seems as though "Added" gets
-- called already for this
--dota_item_combined
-- * PlayerID: PlayerID
-- * itemname: string
-- * itemcost: short
function CAvaloreGameMode:ItemCombined(event)
	print("CAvaloreGameMode:ItemCombined(event)")
	--local owner = EntIndexToHScript( event.PlayerID )
    local inventory = InventoryManager[event.PlayerID]
	inventory:Combine(event.itemname)
end

-- dota_item_purchased
-- * PlayerID: PlayerID
-- * itemname: string
-- * itemcost: short
function CAvaloreGameMode:ItemPurchased(event)
	if not IsServer() then return end
	print("CAvaloreGameMode:ItemPurchased(event) >> " .. event.itemname)
	-- if event.itemname and event.itemname == "item_ambrosia" then
		
	-- end
	-- local item = EntIndexToHScript( event.item_entindex )
	-- if item then
	-- 	if (string.find(item:GetName(), "item_recipe")) then return end
	-- 	print("CAvaloreGameMode:OnItemAdded(event)")
	-- 	print("Item: " .. item:GetName())
    -- 	print("Item Slot: " .. item:GetItemSlot())
		

	-- 	local inventory = InventoryManager[event.inventory_player_id]
	-- 	inventory:Add(item)
	-- end
end

-- dota_item_spawned
-- * item_ent_index: EntityIndex
-- * player_id: int
function CAvaloreGameMode:OnItemSpawned(event)
	print("CAvaloreGameMode:OnItemSpawned(event) >> " .. tostring(event.item_ent_index))
	-- local item = EntIndexToHScript( event.item_ent_index )
	-- print("Item => " .. item:GetName())
	-- local phys_item = item:GetContainer()
end

-- comes from the panorama UI
function AvaloreTakeStash(index, data)
    local hero = EntIndexToHScript(data.entindex)
	print("AvaloreTakeStash(index, data) => " .. hero:GetName())
	local shop_trigger = nil
	if hero:GetTeam() == DOTA_TEAM_BADGUYS then
		shop_trigger = Entities:FindByName(nil, "dire_base")
	else
		shop_trigger = Entities:FindByName(nil, "radiant_base")
	end

	print(shop_trigger:GetName() .. " | " .. tostring(shop_trigger:GetAbsOrigin()))
	print(hero:GetName() .. " | " .. tostring(hero:GetAbsOrigin()))

	-- only allow taking from stash if close enough
	if shop_trigger:IsTouching(hero) then
		print("In Range to Take From Stash")
		local inventory = InventoryManager[hero:GetPlayerID()]
		for stash_slot=DOTA_STASH_SLOT_1,DOTA_STASH_SLOT_6 do
			local item = hero:GetItemInSlot(stash_slot)
			if item and (not item:IsNull()) then
				print(tostring(stash_slot) .. " | " .. item:GetName())
				inventory:Add(item)
				-- tps and neutral items are managed by dota
				-- if item:GetSpecialValueFor("item_slot") > DOTA_STASH_SLOT_6 then
				-- 	--hero:TakeItem(item) -- this drops it
				-- 	hero:AddItem(item)
				-- end
				--if item:GetSpecialValueFor("item_slot") == AVALORE_ITEM_SLOT_NEUT and hero:HasRoomForItem(item:GetName(), true, false) then

				--make sure we didn't eat the item during stacking already
				if not item:IsNull() then
					if item:GetSpecialValueFor("item_slot") == AVALORE_ITEM_SLOT_NEUT and hero:GetItemInSlot(AVALORE_ITEM_SLOT_NEUT) == nil then
						hero:SwapItems(item:GetItemSlot(), AVALORE_ITEM_SLOT_NEUT)
					elseif item:GetName() == "item_tpscroll" then
						print("Adding TP Scroll")
						hero:AddItem(item)
						--hero:SwapItems(item:GetItemSlot(), AVALORE_ITEM_SLOT_TP)
					end
				end
			end
		end
	end
end