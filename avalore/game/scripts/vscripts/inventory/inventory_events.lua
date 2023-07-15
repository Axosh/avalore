require("constants")
require("references")
require(REQ_UTIL)

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


-- ===========================================================================
-- dota_inventory_item_added
-- ===========================================================================
-- item_slot: short
-- inventory_player_id: PlayerID
-- itemname: string
-- item_entindex: EntityIndex
-- inventory_parent_entindex: EntityIndex
-- is_courier: bool
function CAvaloreGameMode:OnItemAdded(event)

end