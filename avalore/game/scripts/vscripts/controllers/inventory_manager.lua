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


-- https://moddota.com/api/#!/events/dota_inventory_item_added
-- dota_inventory_item_added
-- * item_slot: short
-- * inventory_player_id: PlayerID
-- * itemname: string
-- * item_entindex: EntityIndex
-- * inventory_parent_entindex: EntityIndex
-- * is_courier: bool
function CAvaloreGameMode:OnItemAdded(event)
	local item = EntIndexToHScript( event.item_entindex )
	local owner = EntIndexToHScript( event.inventory_parent_entindex )

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