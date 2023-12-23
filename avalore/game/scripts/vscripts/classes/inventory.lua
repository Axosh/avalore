require("constants")
--Inventory = class({})
-- Inventory = {}
-- -- https://stackoverflow.com/questions/40701370/lua-attempt-to-call-method-a-nil-value
-- --Inventory.__index = Inventory

-- -- https://www.lua.org/manual/2.4/node36.html
-- -- create a new instance / default constructor
-- --function Inventory:Create()
-- function Inventory:create(obj)
--     --return self
--     --return {}
--     obj.parent = self
--     return obj
-- end

-- https://stackoverflow.com/questions/40701370/lua-attempt-to-call-method-a-nil-value
Inventory = {}
Inventory.__index = Inventory

function Inventory.Create()
    local obj = {}
    setmetatable(obj, Inventory)
    return obj
end

-- fill everything out after we've got the instance
-- otherwise the lookup in inventory_manager will point
-- to a null
function Inventory:Init(playerID)
    print("Initializing Inventory for Player " ..tostring(playerID))
    -- convenience
    self.playerId = playerID
    self.hero = PlayerResource:GetSelectedHeroEntity(playerID)
    self.courier = PlayerResource:GetPreferredCourierForPlayer(playerID)

    self.slots = {}
    self.slots[AVALORE_ITEM_SLOT_HEAD] = nil
    self.slots[AVALORE_ITEM_SLOT_CHEST] = nil
    self.slots[AVALORE_ITEM_SLOT_ACCESSORY] = nil
    self.slots[AVALORE_ITEM_SLOT_HANDS] = nil
    self.slots[AVALORE_ITEM_SLOT_FEET] = nil
    self.slots[AVALORE_ITEM_SLOT_TRINKET] = nil
    self.slots[AVALORE_ITEM_SLOT_MISC] = {}
    self.slots[AVALORE_ITEM_SLOT_MISC][AVALORE_ITEM_SLOT_MISC1] = nil
    self.slots[AVALORE_ITEM_SLOT_MISC][AVALORE_ITEM_SLOT_MISC2] = nil
    self.slots[AVALORE_ITEM_SLOT_MISC][AVALORE_ITEM_SLOT_MISC3] = nil
    

    return self
end

function Inventory:GetSlots()
    return self.slots
end

function Inventory:GetPlayerID()
    return self.playerId
end

function Inventory:GetHero()
    return self.hero
end

function Inventory:Add(item)
    if not IsServer() then return end
    -- case where item still exists in lua, but not in underlying C++ (e.g. moved to stack)
    if not item or item:IsNull() then return end

    local item_slot = item:GetSpecialValueFor("item_slot")
    local player = PlayerResource:GetPlayer(self.hero:GetOwner():GetPlayerID())
    print("Item Slot > " .. tostring(item_slot))

    -- See if we've got something in the slot already or not
    if item_slot < 6 then
        -- make sure this hasn't already been somehow indexed
        if self.slots[item_slot] == item then
            if item:IsStackable() then
                self.hero:AddItem(item)
            else
                return --assume this is dota engine doing whatever it does
            end
        elseif self.slots[item_slot] ~= nil then
            local broadcast_obj = 
			{
				msg = ("#error_slot_" .. tostring(item_slot)),
				time = 10,
				elaboration = "",
				type = MSG_TYPE_ERROR
			}
			CustomGameEventManager:Send_ServerToPlayer(player, "broadcast_message", broadcast_obj )
        else
            self.slots[item_slot] = item
            self.hero:SwapItems(item:GetItemSlot(), item_slot) --make sure this is in parity with the virtual item slot
        end
    elseif item_slot == AVALORE_ITEM_SLOT_MISC then
        -- find an empty slot
        local placed = false
        for misc_slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
            if not placed and self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot] == nil then -- == nil and (not self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]:IsNull()) then
                --self.hero:SwapItems(item:GetItemSlot(), self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]:GetItemSlot())
                --self.hero:RemoveItem(self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot])
                self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot] = item
                self.hero:SwapItems(item:GetItemSlot(), misc_slot) --make sure this is in parity with the virtual item slot
                placed = true
                break
            end
        end
        -- if not placed then
            
        -- end
    end
end

-- seems like item pickups come from here too so guess we'll have to handle it
function Inventory:Add_old(item)
    if not IsServer() then return end

    -- case where item still exists in lua, but not in underlying C++ (e.g. moved to stack)
    if item:IsNull() then return end

    print("Adding item : " .. item:GetName() .. " | for player: " .. self.hero:GetUnitName())

    -- try to disable base items from being able to be sold here
    if string.find(item:GetName(), "item_slot") then
        item:SetSellable(false)
    end

    -- make sure we haven't added it already (dota's inventory system is whack)
    for dota_slot=0,8 do
        local item_in_slot = self.hero:GetItemInSlot(dota_slot)
        if item_in_slot and (not item_in_slot:IsNull()) then
            if item_in_slot == item then
                return
            elseif (not item:IsNull()) and item_in_slot:GetName() == item:GetName() then
                if item:IsStackable() then
                    print("Found stack in inventory - trying to stack")
                    self.hero:AddItem(item)
                    return
                end
            else
                if dota_slot < AVALORE_ITEM_SLOT_MISC1 and self.slots[dota_slot] == item then
                    return
                elseif self.slots[AVALORE_ITEM_SLOT_MISC][dota_slot] == item then
                    return
                end
            end
        end
    end

    -- if we're adding the item slot dummy, just make sure the slot becomes aware
    -- (only need to do this for 0-5 because some base dota items go in those positions and screw up everything)
    if item:GetName():find("item_slot") then
        local avalore_slot = item:GetSpecialValueFor("item_slot")
        if avalore_slot < 6 then
            self.slots[avalore_slot] = item
        end
        return
    end

    local item_slot = item:GetSpecialValueFor("item_slot")

    -- we shouldn't be hitting this, but just in case
    if item_slot == nil then
        item_slot = AVALORE_ITEM_SLOT_MISC
    end

    -- these go in a special slot
    if item_slot == AVALORE_ITEM_SLOT_NEUT then
        return
    end

    print("Trying to add item " .. item:GetName() .. " to Slot: " .. tostring(item_slot))

    -- handle misc/backpack
    if item_slot == AVALORE_ITEM_SLOT_MISC then
        -- find an empty slot
        local placed = false
        for misc_slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
            if not placed and (not self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]:IsNull()) and self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]:GetName() == "item_slot_misc" then
                self.hero:SwapItems(item:GetItemSlot(), self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot]:GetItemSlot())
                self.hero:RemoveItem(self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot])
                self.slots[AVALORE_ITEM_SLOT_MISC][misc_slot] = item
                placed = true
                break
            end
        end
    -- if slot is empty, just swap it out
    -- null check is due to items like obs + sents (i.e. ward dispensor) that can lose charges and change into a different item
    elseif self.slots[item_slot] and (not self.slots[item_slot]:IsNull()) and ((self.slots[item_slot]):GetName()):find("item_slot") then
        --local slot_backup = self.slots[item_slot]:GetItemSlot()
        self.hero:SwapItems(item:GetItemSlot(), self.slots[item_slot]:GetItemSlot())
        -- if the item is no longer in the stash (9-14 or -1?), then the swap succeeded
        -- and is now in our inventory. If it didn't, then we weren't able to grab it
        -- because we were too far away;

            -- validate we actually got it (and it's not too far away/in stash) => only applicable for certain core dota items
            if item:GetName() == "item_ward_observer" or item:GetName() == "item_bottle" then
                print("Special Item at loc: " .. tostring(item:GetItemSlot()))
                print("Dummy in Slot: " .. tostring(self.slots[item_slot]:GetItemSlot()))
                print("Find Item Result => " .. tostring(self.hero:FindItemInInventory(item:GetName())))
                if item:GetItemSlot() > DOTA_ITEM_SLOT_9 then
                    -- if we get here, then the item is still in stash
                    return
                end
            end

            self.hero:RemoveItem(self.slots[item_slot])
            self.slots[item_slot] = item
        
    end
    -- -- TODO: Other cases
end

function Inventory:PickUp(item)
    print("Inventory:PickUp(item) > " .. item:GetName())

    -- make sure we haven't added it already (dota's inventory system is whack)
    for dota_slot=0,8 do
        if self.hero:GetItemInSlot(dota_slot) == item then
            return
        else
            if dota_slot < AVALORE_ITEM_SLOT_MISC1 and self.slots[dota_slot] == item then
                return
            elseif self.slots[AVALORE_ITEM_SLOT_MISC][dota_slot] == item then
                return
            end
        end
    end
    
    local item_slot = item:GetSpecialValueFor("item_slot")
    
    -- we shouldn't be hitting this, but just in case
    if item_slot == nil then
        item_slot = AVALORE_ITEM_SLOT_MISC
    end

    print("Item Added to Slot: " .. tostring(item:GetItemSlot()))

    -- if slot is empty, just swap it out
    if ((self.slots[item_slot]):GetName()):find("item_slot") then
        local slot_backup = self.slots[item_slot]:GetItemSlot()
        self.hero:SwapItems(item:GetItemSlot(), self.slots[item_slot]:GetItemSlot())
        -- if the item is no longer in the stash (9-14 or -1?), then the swap succeeded
        -- and is now in our inventory. If it didn't, then we weren't able to grab it
        -- because we were too far away;
        --if not (item:GetItemSlot() == -1 or (item:GetItemSlot() > 8 and item:GetItemSlot() < 15))  then
            print("Item is now in slot: " .. tostring(item:GetItemSlot()))
            print("Dummy is now in slot: " .. tostring(self.slots[item_slot]:GetItemSlot()))
            print("Item in Dummy's Old Slot: " .. self.hero:GetItemInSlot(slot_backup):GetName())
            self.hero:RemoveItem(self.slots[item_slot])
            self.slots[item_slot] = item
        --else
            --print("Couldn't Put in Inventory, at slot: " .. tostring(self.slots[item_slot]:GetItemSlot()))
        --     self.slots[item_slot]:slot
        --end
        
    end
end

function Inventory:Remove(item)
    self:Remove(item, false)
end

function Inventory:Remove(item, destroyOnRemove)
    if not IsServer() then return end
    -- don't do anything special for the placeholders
    if not item or item:GetName():find("item_slot") then return end

    print("Inventory:Remove(item) -- " .. item:GetName())
    local item_slot = item:GetSpecialValueFor("item_slot")

    -- if item:GetName() == "item_bottle" then
    --     item_slot = AVALORE_ITEM_SLOT_TRINKET
    -- end

    -- we shouldn't be hitting this, but just in case
    if item_slot == nil then
        item_slot = AVALORE_ITEM_SLOT_MISC
    end

    -- these go in a special slot
    if item_slot == AVALORE_ITEM_SLOT_NEUT then
        return
    end
    -- remove item
    --self.hero:RemoveItem(self.slots[item_slot])

    -- if not item:GetContainer() then
    --     (self.slots[item_slot]):RemoveSelf()
    -- end

    -- destroy item before adding in other slot
    -- should only be applicable to items that can be cast (ie. main inventory slots)
    if item_slot >= 0 and item_slot <= 5 then
        if destroyOnRemove then
            item:Destroy()
            -- not sure if there's junk data or a race condition, but the "GetName" statement will get called if this
            -- is not explicitly garbage collected right here
            self.slots[item_slot] = nil
        end
    end

    -- MOVING THIS TO modifier_inventory_manager
    -- re-add placeholder (also check if it's not already been re-added since server seems to call this twice)
    -- if item_slot == AVALORE_ITEM_SLOT_HEAD and (self.slots[AVALORE_ITEM_SLOT_HEAD] == nil or (self.slots[AVALORE_ITEM_SLOT_HEAD]):GetName() ~= "item_slot_head") then
    --     self.slots[AVALORE_ITEM_SLOT_HEAD]      = (self.hero):AddItemByName("item_slot_head")
    -- elseif item_slot == AVALORE_ITEM_SLOT_CHEST and (self.slots[AVALORE_ITEM_SLOT_CHEST] == nil or (self.slots[AVALORE_ITEM_SLOT_CHEST]):GetName() ~= "item_slot_chest") then
    --     self.slots[AVALORE_ITEM_SLOT_CHEST]     = (self.hero):AddItemByName("item_slot_chest")
    -- elseif item_slot == AVALORE_ITEM_SLOT_ACCESSORY and (self.slots[AVALORE_ITEM_SLOT_ACCESSORY] == nil or (self.slots[AVALORE_ITEM_SLOT_ACCESSORY]):GetName() ~= "item_slot_back") then
    --     self.slots[AVALORE_ITEM_SLOT_ACCESSORY]      = (self.hero):AddItemByName("item_slot_back")
    -- elseif item_slot == AVALORE_ITEM_SLOT_HANDS and (self.slots[AVALORE_ITEM_SLOT_HANDS] == nil or (self.slots[AVALORE_ITEM_SLOT_HANDS]):GetName() ~= "item_slot_hands") then
    --     self.slots[AVALORE_ITEM_SLOT_HANDS]     = (self.hero):AddItemByName("item_slot_hands")
    -- elseif item_slot == AVALORE_ITEM_SLOT_FEET and (self.slots[AVALORE_ITEM_SLOT_FEET] == nil or (self.slots[AVALORE_ITEM_SLOT_FEET]):GetName() ~= "item_slot_feet") then
    --     self.slots[AVALORE_ITEM_SLOT_FEET]      = (self.hero):AddItemByName("item_slot_feet")
    -- elseif item_slot == AVALORE_ITEM_SLOT_TRINKET and (self.slots[AVALORE_ITEM_SLOT_TRINKET] == nil or (self.slots[AVALORE_ITEM_SLOT_TRINKET]):GetName() ~= "item_slot_trinket") then
    --     self.slots[AVALORE_ITEM_SLOT_TRINKET]   = (self.hero):AddItemByName("item_slot_trinket")
    -- elseif item_slot == AVALORE_ITEM_SLOT_MISC then
    if item_slot == AVALORE_ITEM_SLOT_MISC then
        --print("RemoveFromMisc")
        self:RemoveFromMisc(item)
    end
    
    -- force move into inventory if in stash (also let misc items handle themselves)
    if item_slot < AVALORE_ITEM_SLOT_MISC1 and self.slots[item_slot]:GetItemSlot() > AVALORE_ITEM_SLOT_MISC3 then
        print("Moving Dummy to Inventory")
        self.slots[item_slot]:SetDroppable(true)
        local owner = self.slots[item_slot]:GetOwner()
        for tmp_slot=0,AVALORE_ITEM_SLOT_TRINKET do
            if owner:GetItemInSlot(tmp_slot) == nil then
                print("Found empty inventory slot: " .. tostring(tmp_slot))
                owner:SwapItems(tmp_slot, self.slots[item_slot]:GetItemSlot())
                break
            end
        end
    end
    -- if item_slot < AVALORE_ITEM_SLOT_MISC1 then
    --     self.slots[item_slot]:SetDroppable(false)
    -- end

end

-- function Inventory:Combine(item_name)
--     print("Inventory:Combine(item_name) > " .. item_name)
--     local key_to_remove = nil
--     for key,value in pairs(self.slots[AVALORE_ITEM_SLOT_TEMP]) do
--         -- found the item, put it in its appropriate slot
--         if not value then
--             print("broken slot")
--         elseif value:GetName() == item_name then
--             local item_slot = value:GetSpecialValueFor("item_slot")

--             -- we shouldn't be hitting this, but just in case
--             if item_slot == nil then
--                 item_slot = AVALORE_ITEM_SLOT_MISC
--             end

--             -- make the Avalore inventory aware
--             self.slots[item_slot] = value
--             key_to_remove = key
--             break
--         end
--     end
--     -- remove from temp list (after iterating) if we found something
--     if key_to_remove then
--         print("Removing from temp table: " .. self.slots[AVALORE_ITEM_SLOT_TEMP][key_to_remove]:GetName())
--         table.remove(self.slots[AVALORE_ITEM_SLOT_TEMP], key_to_remove)
--         --self.slots[AVALORE_ITEM_SLOT_TEMP][key_to_remove] = nil
--     end
-- end

function Inventory:Combine(item_name)
    print("Inventory:Combine(item_name) > " .. item_name)
    for slot=0,15 do
        local item = self:GetHero():GetItemInSlot(slot) --note: they have some ability to move item slots around
        if item and item:GetName() == item_name then
            local item_slot = item:GetSpecialValueFor("item_slot")
            -- we shouldn't be hitting this, but just in case
            if item_slot == nil then
                item_slot = AVALORE_ITEM_SLOT_MISC
            end
            -- make the Avalore inventory aware
            if item_slot == AVALORE_ITEM_SLOT_MISC then
                self:AddToMisc(item)
                --return
            else
                self.slots[item_slot] = item
                --return
            end

            -- Check to see if they completed an Artifact
            if item:GetSpecialValueFor("IsArtifact") == 1 then
                print("Someone Completed: " .. item:GetName())
                -- find all instances of purchased recipes for this artifact
                local recipe_name = string.gsub(item:GetName(), "item_", "item_recipe_")
                print("Recipe => " .. recipe_name)
                local artifact_recipes = Entities:FindAllByName(recipe_name)
                for _,recipe in pairs(artifact_recipes) do
                    recipe:RemoveSelf()
                end

                -- TODO: SetItemStockCount(count: int, team: DOTATeam_t, itemName: string, playerId: PlayerID): nil

            end
        end
    end
    -- make sure we didn't eat items while combining and not give the base slot back
    for slot=0,5 do
        local item = self.slots[slot]
        if not item or item:IsNull() or item:GetItemSlot() == -1 then
            self:Remove(item)
        end
    end
    for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        local item = self.slots[AVALORE_ITEM_SLOT_MISC][slot]
        if not item or item:IsNull() or item:GetItemSlot() == -1 then
            self:Remove(item)
        end
    end
end

function Inventory:AddToMisc(item)
    -- make sure we haven't already added this (dota's inventory system is whack and calls things twice)
    for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        if self.slots[AVALORE_ITEM_SLOT_MISC][slot] and self.slots[AVALORE_ITEM_SLOT_MISC][slot] == item then
            return
        end
    end
    print("Inventory:AddToMisc(item) >> " .. item:GetName())
    for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        -- find empty slot
        if self.slots[AVALORE_ITEM_SLOT_MISC][slot] == nil or self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetName() == "item_slot_misc" then

        -- since we're using recipes, the item should already have combined in that slot
        --if self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetName() == item:GetName() then
            self.slots[AVALORE_ITEM_SLOT_MISC][slot] = item
            return
        end
    end
    print("Failed to Add to Misc")
end

function Inventory:RemoveFromMisc(item)
    print("Inventory:RemoveFromMisc(item) >> " .. item:GetName())
    for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        if (self.slots[AVALORE_ITEM_SLOT_MISC][slot]
            and not self.slots[AVALORE_ITEM_SLOT_MISC][slot]:IsNull()
            and not item:IsNull() 
            and self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetName() == item:GetName()
        ) then
            --self.slots[AVALORE_ITEM_SLOT_MISC][slot]   = (self.hero):AddItemByName("item_slot_misc")
            -- trying to fix a potential race condition
            if self.slots[AVALORE_ITEM_SLOT_MISC][slot]:IsSellable() then
                self.slots[AVALORE_ITEM_SLOT_MISC][slot]:SetSellable(false)
            end
            --self.slots[AVALORE_ITEM_SLOT_MISC][slot]:SetDroppable(false)
            self.slots[AVALORE_ITEM_SLOT_MISC][slot]:SetItemState(1) -- ready?
            print("Added item_slot_misc to " .. tostring(slot))
            print("IsSellable? " .. tostring(self.slots[AVALORE_ITEM_SLOT_MISC][slot]:IsSellable()))
            -- move to inventory if in stash
            if self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetItemSlot() > AVALORE_ITEM_SLOT_MISC3 then
                local droppable = self.slots[AVALORE_ITEM_SLOT_MISC][slot]:IsDroppable()
                self.slots[AVALORE_ITEM_SLOT_MISC][slot]:SetDroppable(true)
                local owner = self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetOwner()
                for tmp_slot=0,AVALORE_ITEM_SLOT_TRINKET do
                    if owner:GetItemInSlot(tmp_slot) == nil then
                        print("Found empty inventory slot: " .. tostring(tmp_slot))
                        owner:SwapItems(tmp_slot, self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetItemSlot())
                    end
                end
                self.slots[AVALORE_ITEM_SLOT_MISC][slot]:SetDroppable(droppable)
            end
            return
        end
    end
end


function Inventory:Contains(item_name)
    print("Inventory:Contains(item)" .. item_name)
    -- check main inv
    for avalore_slot=AVALORE_ITEM_SLOT_HEAD,AVALORE_ITEM_SLOT_TRINKET do
        if self.slots[avalore_slot] ~= nil then -- sanity check for bugged inventory
            if self.slots[avalore_slot]:GetName() == item_name then
                return true
            end
        end
    end

    -- check backpack/misc
    for avalore_slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        if self.slots[AVALORE_ITEM_SLOT_MISC][avalore_slot] ~= nil then -- sanity check for bugged inventory
            if self.slots[AVALORE_ITEM_SLOT_MISC][avalore_slot]:GetName() == item_name then
                return true
            end
        end
    end

    return false
end