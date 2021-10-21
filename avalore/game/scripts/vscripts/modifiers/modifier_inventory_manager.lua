require("constants")
modifier_inventory_manager = class({})

--LinkLuaModifier( "modifier_item_leather_boots", "items/shop/base_materials/item_leather_boots.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_inventory_manager:IsHidden() return true end
function modifier_inventory_manager:IsDebuff() return false end
function modifier_inventory_manager:IsPurgable() return false end
function modifier_inventory_manager:RemoveOnDeath() return false end
function modifier_inventory_manager:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_inventory_manager:OnCreated()
	if not IsServer() then return end
    -- track (modifier:item) so we can clean up modifiers if the item is null/no longer in backpack
    self.curr_backpack = {}
    self:StartIntervalThink(FrameTime())
end

function modifier_inventory_manager:OnIntervalThink()
    --print("modifier_inventory_manager:OnIntervalThink()")
    local hero = self:GetParent()
    if hero == nil then return end
    
    -- check to see if anything that is in the backpack shouldn't be there
    for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        local item = hero:GetItemInSlot(slot)
        if item then
            if item:GetSpecialValueFor("item_slot") ~= AVALORE_ITEM_SLOT_MISC then
                for main_slot=AVALORE_ITEM_SLOT_HEAD,AVALORE_ITEM_SLOT_TRINKET do
                    local item_main = hero:GetItemInSlot(main_slot)
                    -- found a misplaced item, swap it
                    if item_main:GetSpecialValueFor("item_slot") == AVALORE_ITEM_SLOT_MISC then
                        print("modifier_inventory_manager > Returning Item to Backpack")
                        local droppable = item_main:IsDroppable()
                        item_main:SetDroppable(true)
                        hero:SwapItems(slot, main_slot)
                        item_main:SetDroppable(droppable)
                    end
                end
            end
        end
    end
    
    -- loop through known backpack items to see if they're still in backpack
    for mod,item in pairs(self.curr_backpack) do
        -- only worry about this if it has a modifier
        if mod then
            -- make sure the item still exists
            local remove_modifier = false
            if item then
                if not item:IsInBackpack() then
                    print("modifier_inventory_manager > Item " .. item:GetName() .. " no longer in backpack")
                    remove_modifier = true
                end
            else
                print("modifier_inventory_manager > Item No Longer Exists")
                remove_modifier = true
            end

            if remove_modifier then
                print("modifier_inventory_manager > Removing Modifier " .. mod)
                hero:RemoveModifierByName(mod)
            end
        end
    end

    -- loop through actual backpack (not the Avalore one)
    local backpack_state = {}
    for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        local item = hero:GetItemInSlot(slot)
        if item then
            --print("modifier_inventory_manager > Found Item in Backpack: " .. item:GetName())
            local intr_mod = item:GetIntrinsicModifierName()
            if intr_mod and not hero:FindModifierByName(intr_mod) then
                print("modifier_inventory_manager > Adding (" .. item:GetName() .. ", " .. intr_mod .. ")")
                --hero:AddNewModifier(self, item, intr_mod, {})
                hero:AddNewModifier(hero, item, intr_mod, {})
                backpack_state[intr_mod] = item
            end
        end
    end
    
    -- remake the backpack
    self.curr_backpack = nil -- garbage collect
    self.curr_backpack = backpack_state -- set to new object
end