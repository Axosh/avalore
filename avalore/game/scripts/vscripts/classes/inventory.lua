require("constants")
Inventory = class({})

-- create a new instance / default constructor
function Inventory:Create()
    return self
end

-- fill everything out after we've got the instance
-- otherwise the lookup in inventory_manager will point
-- to a null
function Inventory:Init(playerID)
    -- convenience
    self.playerId = playerID
    self.hero = PlayerResource:GetSelectedHeroEntity(playerID)

    self.slots = {}
    self.slots[AVALORE_ITEM_SLOT_MISC] = {}
    
    local misc1 = (self.hero):AddItemByName("item_slot_misc")
	misc1:SetDroppable(true);
    (self.hero):SwapItems(0,6); -- put in 1st backpack slot
    --self.slots[AVALORE_ITEM_SLOT_MISC1] = misc1
    self.slots[AVALORE_ITEM_SLOT_MISC][AVALORE_ITEM_SLOT_MISC1] = misc1
    local misc2 = (self.hero):AddItemByName("item_slot_misc");
	(self.hero):SwapItems(0,7)
    --self.slots[AVALORE_ITEM_SLOT_MISC2] = misc2
    self.slots[AVALORE_ITEM_SLOT_MISC][AVALORE_ITEM_SLOT_MISC2] = misc2
	local misc3 = (self.hero):AddItemByName("item_slot_misc");
	(self.hero):SwapItems(0,8)
    --self.slots[AVALORE_ITEM_SLOT_MISC3] = misc3
    self.slots[AVALORE_ITEM_SLOT_MISC][AVALORE_ITEM_SLOT_MISC3] = misc3

    self.slots[AVALORE_ITEM_SLOT_HEAD]      = (self.hero):AddItemByName("item_slot_head")
    self.slots[AVALORE_ITEM_SLOT_CHEST]     = (self.hero):AddItemByName("item_slot_chest")
    self.slots[AVALORE_ITEM_SLOT_BACK]      = (self.hero):AddItemByName("item_slot_back")
    self.slots[AVALORE_ITEM_SLOT_HANDS]     = (self.hero):AddItemByName("item_slot_hands")
    self.slots[AVALORE_ITEM_SLOT_FEET]      = (self.hero):AddItemByName("item_slot_feet")
    self.slots[AVALORE_ITEM_SLOT_TRINKET]   = (self.hero):AddItemByName("item_slot_trinket")

    -- reset this, needed to clear it earlier to move them to the right starting spots
    misc1:SetDroppable(false)
	misc2:SetDroppable(false)
	misc3:SetDroppable(false)

    --self.slots[AVALORE_ITEM_SLOT_TEMP] = {}

    return self
end

function Inventory:GetPlayerID()
    return self.playerId
end

function Inventory:GetHero()
    return self.hero
end

function Inventory:Add(item)
    if not IsServer() then return end
    print("Adding Item: " .. item:GetName())
    --print("Find result - " .. tostring(string.find("item_slot", item:GetName())))
    -- if we're adding the item slot dummy, just skip
    if item:GetName():find("item_slot") then return end

    --item:SetCanBeUsedOutOfInventory(true) -- temp test

    -- add here for now, let combine sort it out ==> this doesn't work with new
    -- recipe focused system
    --table.insert(self.slots[AVALORE_ITEM_SLOT_TEMP], item)

    -- local item_slot = item:GetSpecialValueFor("item_slot")

    -- -- we shouldn't be hitting this, but just in case
    -- if item_slot == nil then
    --     item_slot = AVALORE_ITEM_SLOT_MISC
    -- end

    -- print("Item Added to Slot: " .. tostring(item:GetItemSlot()))

    -- -- if slot is empty, just swap it out
    -- if ((self.slots[item_slot]):GetName()):find("item_slot") then
    --     local slot_backup = self.slots[item_slot]:GetItemSlot()
    --     self.hero:SwapItems(item:GetItemSlot(), self.slots[item_slot]:GetItemSlot())
    --     -- if the item is no longer in the stash (9-14 or -1?), then the swap succeeded
    --     -- and is now in our inventory. If it didn't, then we weren't able to grab it
    --     -- because we were too far away;
    --     --if not (item:GetItemSlot() == -1 or (item:GetItemSlot() > 8 and item:GetItemSlot() < 15))  then
    --         print("Item is now in slot: " .. tostring(item:GetItemSlot()))
    --         print("Dummy is now in slot: " .. tostring(self.slots[item_slot]:GetItemSlot()))
    --         print("Item in Dummy's Old Slot: " .. self.hero:GetItemInSlot(slot_backup):GetName())
    --         self.hero:RemoveItem(self.slots[item_slot])
    --         self.slots[item_slot] = item
    --     --else
    --         --print("Couldn't Put in Inventory, at slot: " .. tostring(self.slots[item_slot]:GetItemSlot()))
    --     --     self.slots[item_slot]:slot
    --     --end
        
    -- end
    -- -- TODO: Other cases
end

function Inventory:PickUp(item)
    print("Inventory:PickUp(item) > " .. item:GetName())
    
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
    if not IsServer() then return end
    -- don't do anything special for the placeholders
    if item:GetName():find("item_slot") then return end

    print("Inventory:Remove(item) -- " .. item:GetName())
    local item_slot = item:GetSpecialValueFor("item_slot")

    -- we shouldn't be hitting this, but just in case
    if item_slot == nil then
        item_slot = AVALORE_ITEM_SLOT_MISC
    end
    -- remove item
    --self.hero:RemoveItem(self.slots[item_slot])

    -- if not item:GetContainer() then
    --     (self.slots[item_slot]):RemoveSelf()
    -- end

    -- re-add placeholder (also check if it's not already been re-added since server seems to call this twice)
    if item_slot == AVALORE_ITEM_SLOT_HEAD and (self.slots[AVALORE_ITEM_SLOT_HEAD] == nil or (self.slots[AVALORE_ITEM_SLOT_HEAD]):GetName() ~= "item_slot_head") then
        self.slots[AVALORE_ITEM_SLOT_HEAD]      = (self.hero):AddItemByName("item_slot_head")
    elseif item_slot == AVALORE_ITEM_SLOT_CHEST and (self.slots[AVALORE_ITEM_SLOT_CHEST] == nil or (self.slots[AVALORE_ITEM_SLOT_CHEST]):GetName() ~= "item_slot_chest") then
        self.slots[AVALORE_ITEM_SLOT_CHEST]     = (self.hero):AddItemByName("item_slot_chest")
    elseif item_slot == AVALORE_ITEM_SLOT_BACK and (self.slots[AVALORE_ITEM_SLOT_BACK] == nil or (self.slots[AVALORE_ITEM_SLOT_BACK]):GetName() ~= "item_slot_back") then
        self.slots[AVALORE_ITEM_SLOT_BACK]      = (self.hero):AddItemByName("item_slot_back")
    elseif item_slot == AVALORE_ITEM_SLOT_HANDS and (self.slots[AVALORE_ITEM_SLOT_HANDS] == nil or (self.slots[AVALORE_ITEM_SLOT_HANDS]):GetName() ~= "item_slot_hands") then
        self.slots[AVALORE_ITEM_SLOT_HANDS]     = (self.hero):AddItemByName("item_slot_hands")
    elseif item_slot == AVALORE_ITEM_SLOT_FEET and (self.slots[AVALORE_ITEM_SLOT_FEET] == nil or (self.slots[AVALORE_ITEM_SLOT_FEET]):GetName() ~= "item_slot_feet") then
        self.slots[AVALORE_ITEM_SLOT_FEET]      = (self.hero):AddItemByName("item_slot_feet")
    elseif item_slot == AVALORE_ITEM_SLOT_TRINKET and (self.slots[AVALORE_ITEM_SLOT_TRINKET] == nil or (self.slots[AVALORE_ITEM_SLOT_TRINKET]):GetName() ~= "item_slot_trinket") then
        self.slots[AVALORE_ITEM_SLOT_TRINKET]   = (self.hero):AddItemByName("item_slot_trinket")
    elseif item_slot == AVALORE_ITEM_SLOT_MISC then
        print("RemoveFromMisc")
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
    if item_slot < AVALORE_ITEM_SLOT_MISC1 then
        self.slots[item_slot]:SetDroppable(false)
    end
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
        local item = self:GetHero():GetItemInSlot(slot)
        if item and item:GetName() == item_name then
            local item_slot = item:GetSpecialValueFor("item_slot")
            -- we shouldn't be hitting this, but just in case
            if item_slot == nil then
                item_slot = AVALORE_ITEM_SLOT_MISC
            end
            -- make the Avalore inventory aware
            if item_slot == AVALORE_ITEM_SLOT_MISC then
                self:AddToMisc(item)
            else
                self.slots[item_slot] = item
            end
        end
    end
end

function Inventory:AddToMisc(item)
    print("Inventory:AddToMisc(item) >> " .. item:GetName())
    for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        -- find empty slot
        --if self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetName() == "item_slot_misc" then

        -- since we're using recipes, the item should already have combined in that slot
        if self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetName() == item:GetName() then
            self.slots[AVALORE_ITEM_SLOT_MISC][slot] = item
            return
        end
    end
    print("Failed to Add to Misc")
end

function Inventory:RemoveFromMisc(item)
    for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        if self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetName() == item:GetName() then
            self.slots[AVALORE_ITEM_SLOT_MISC][slot]   = (self.hero):AddItemByName("item_slot_misc")
            -- move to inventory if in stash
            if self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetItemSlot() > AVALORE_ITEM_SLOT_MISC3 then
                self.slots[AVALORE_ITEM_SLOT_MISC][slot]:SetDroppable(true)
                local owner = self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetOwner()
                for tmp_slot=0,AVALORE_ITEM_SLOT_TRINKET do
                    if owner:GetItemInSlot(tmp_slot) == nil then
                        print("Found empty inventory slot: " .. tostring(tmp_slot))
                        owner:SwapItems(tmp_slot, self.slots[AVALORE_ITEM_SLOT_MISC][slot]:GetItemSlot())
                        break
                    end
                end
            end
        end
    end
end