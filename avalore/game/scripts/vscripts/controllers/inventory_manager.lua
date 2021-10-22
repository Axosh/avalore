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

	else
		-- probably a dropped item so we need to handle it with the dummy slots
		local inventory = InventoryManager[event.PlayerID]
    	inventory:PickUp(item)
	end -- end if-statement: item picked up was flag

	
end -- end function: CAvaloreGameMode:OnItemPickUp(event)


-- https://moddota.com/api/#!/events/dota_inventory_item_added
-- dota_inventory_item_added
-- * item_slot: short
-- * inventory_player_id: PlayerID
-- * itemname: string
-- * item_entindex: EntityIndex
-- * inventory_parent_entindex: EntityIndex
-- * is_courier: bool
function CAvaloreGameMode:OnItemAdded(event)
    print("CAvaloreGameMode:OnItemAdded(event)")
	local item = EntIndexToHScript( event.item_entindex )
	--local owner = EntIndexToHScript( event.inventory_parent_entindex )

    local inventory = InventoryManager[event.inventory_player_id]
    inventory:Add(item)

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
    print("CAvaloreGameMode:OnInventoryChanged(event)")
    local item = EntIndexToHScript( event.item_entindex )
    print("Item: " .. item:GetName())
    print("Item Slot: " .. item:GetItemSlot())
    local inventory = InventoryManager[event.player_id]
    if (event.removed) then
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
        if (hero:GetItemInSlot(slot_num)) then
            item_name = hero:GetItemInSlot(slot_num):GetName()
        end

        print("[" .. tostring(slot_num) .. "] = " .. item_name)
    end
end

function InventoryManager:DebugAvaloreSlots(player_id)
    print("===== DEBUG AVALORE INVENTORY =====")
    local inventory = InventoryManager[player_id]
    for slot_num=AVALORE_ITEM_SLOT_HEAD,AVALORE_ITEM_SLOT_TRINKET do
        local item_name = "nil"
        if (inventory.slots[slot_num]) then
            item_name = inventory.slots[slot_num]:GetName()
        end

        print("[" .. tostring(slot_num) .. "] = " .. item_name)
    end
	for misc_slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
		local item_name = "nil"
        if (inventory.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]) then
            item_name = inventory.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]:GetName()
        end

        print("[" .. tostring(misc_slot) .. "] = " .. item_name)
	end
end


-- https://moddota.com/api/#!/events/dota_courier_transfer_item#item_entindex
-- dota_courier_transfer_item
---- item_entindex: EntityIndex
function CAvaloreGameMode:TransferItem(event)
    print("CAvaloreGameMode:TransferItem(event)")
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

function CAvaloreGameMode:InventoryChangedQueryUnit(event)
    print("CAvaloreGameMode:ItemGifted(event)")
end

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