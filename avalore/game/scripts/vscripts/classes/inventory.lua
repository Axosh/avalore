require("constants")
Inventory = class({})

function Inventory:Create(playerID)
    -- convenience
    self.playerId = playerID
    self.hero = PlayerResource:GetSelectedHeroEntity(playerID)

    self.slots = {}
    local misc1 = self.hero:AddItemByName("item_slot_misc1")
	misc1:SetDroppable(true)
    self.hero:SwapItems(0,6) -- put in 1st backpack slot
    self.slots[AVALORE_ITEM_SLOT_MISC1] = misc1
    local misc2 = self.hero:AddItemByName("item_slot_misc2")
	self.hero:SwapItems(0,7)
    self.slots[AVALORE_ITEM_SLOT_MISC2] = misc2
	local misc3 = self.hero:AddItemByName("item_slot_misc3")
	self.hero:SwapItems(0,8)
    self.slots[AVALORE_ITEM_SLOT_MISC3] = misc3

    self.slots[AVALORE_ITEM_SLOT_HEAD]      = self.hero:AddItemByName("item_slot_head")
    self.slots[AVALORE_ITEM_SLOT_CHEST]     = self.hero:AddItemByName("item_slot_chest")
    self.slots[AVALORE_ITEM_SLOT_BACK]      = self.hero:AddItemByName("item_slot_back")
    self.slots[AVALORE_ITEM_SLOT_HANDS]     = self.hero:AddItemByName("item_slot_hands")
    self.slots[AVALORE_ITEM_SLOT_FEET]      = self.hero:AddItemByName("item_slot_feet")
    self.slots[AVALORE_ITEM_SLOT_TRINKET]   = self.hero:AddItemByName("item_slot_trinket")

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
    local item_slot = item:GetSpecialValueFor("item_slot")
    -- if slot is empty, just swap it out
    if string.find("item_slot", (self.slots[item_slot]):GetName()) then
        self.hero:SwapItems(item:GetItemSlot(), self.slots[item_slot]:GetItemSlot())
        self.hero:RemoveItem(self.slots[item_slot])
        self.slots[item_slot] = item
    end
end