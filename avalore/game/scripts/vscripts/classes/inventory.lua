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
    local misc1 = (self.hero):AddItemByName("item_slot_misc1")
	misc1:SetDroppable(true);
    (self.hero):SwapItems(0,6); -- put in 1st backpack slot
    self.slots[AVALORE_ITEM_SLOT_MISC1] = misc1
    local misc2 = (self.hero):AddItemByName("item_slot_misc2");
	(self.hero):SwapItems(0,7)
    self.slots[AVALORE_ITEM_SLOT_MISC2] = misc2
	local misc3 = (self.hero):AddItemByName("item_slot_misc3");
	(self.hero):SwapItems(0,8)
    self.slots[AVALORE_ITEM_SLOT_MISC3] = misc3

    self.slots[AVALORE_ITEM_SLOT_HEAD]      = (self.hero):AddItemByName("item_slot_head")
    self.slots[AVALORE_ITEM_SLOT_CHEST]     = (self.hero):AddItemByName("item_slot_chest")
    self.slots[AVALORE_ITEM_SLOT_BACK]      = (self.hero):AddItemByName("item_slot_back")
    self.slots[AVALORE_ITEM_SLOT_HANDS]     = (self.hero):AddItemByName("item_slot_hands")
    self.slots[AVALORE_ITEM_SLOT_FEET]      = (self.hero):AddItemByName("item_slot_feet")
    self.slots[AVALORE_ITEM_SLOT_TRINKET]   = (self.hero):AddItemByName("item_slot_trinket")

    misc1:SetDroppable(false)
	misc2:SetDroppable(false)
	misc3:SetDroppable(false)

    return self
end

function Inventory:GetPlayerID()
    return self.playerId
end

function Inventory:GetHero()
    return self.hero
end

function Inventory:Add(item)
    --print("Adding Item: " .. item:GetName())
    --print("Find result - " .. tostring(string.find("item_slot", item:GetName())))
    -- if we're adding the item slot dummy, just skip
    if item:GetName():find("item_slot") then return end

    local item_slot = item:GetSpecialValueFor("item_slot")
    -- if slot is empty, just swap it out
    if ((self.slots[item_slot]):GetName()):find("item_slot") then
        self.hero:SwapItems(item:GetItemSlot(), self.slots[item_slot]:GetItemSlot())
        self.hero:RemoveItem(self.slots[item_slot])
        self.slots[item_slot] = item
    end
    -- TODO: Other cases
end

function Inventory:Remove(item)
    -- don't do anything special for the placeholders
    if item:GetName():find("item_slot") then return end

    print("Inventory:Remove(item) -- " .. item:GetName())
    local item_slot = item:GetSpecialValueFor("item_slot")
    -- remove item
    self.hero:RemoveItem(self.slots[item_slot])

    -- re-add placeholder
    if item_slot == AVALORE_ITEM_SLOT_HEAD then
        self.slots[AVALORE_ITEM_SLOT_HEAD]      = (self.hero):AddItemByName("item_slot_head")
    elseif item_slot == AVALORE_ITEM_SLOT_CHEST then
        self.slots[AVALORE_ITEM_SLOT_CHEST]     = (self.hero):AddItemByName("item_slot_chest")
    elseif item_slot == AVALORE_ITEM_SLOT_BACK then
        self.slots[AVALORE_ITEM_SLOT_BACK]      = (self.hero):AddItemByName("item_slot_back")
    elseif item_slot == AVALORE_ITEM_SLOT_HANDS then
        self.slots[AVALORE_ITEM_SLOT_HANDS]     = (self.hero):AddItemByName("item_slot_hands")
    elseif item_slot == AVALORE_ITEM_SLOT_FEET then
        self.slots[AVALORE_ITEM_SLOT_FEET]      = (self.hero):AddItemByName("item_slot_feet")
    elseif item_slot == AVALORE_ITEM_SLOT_TRINKET then
        self.slots[AVALORE_ITEM_SLOT_TRINKET]   = (self.hero):AddItemByName("item_slot_trinket")
    else
        -- TODO: handle misc. slots
    end
end