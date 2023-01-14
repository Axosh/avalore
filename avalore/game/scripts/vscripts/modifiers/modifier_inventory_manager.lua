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
    -- if not hero:IsAlive() then
    --     print("Inventory Owner is Dead!")
    -- end

    -- cycle through slots, make sure they have items in them
    local inv_validation = {-1, -1, -1, -1, -1, -1}
    --print("=====SEEK")
    for inv_slot=0,5 do
        local item = hero:GetItemInSlot(inv_slot)
        if item then
            --print("[" .. tostring(inv_slot) .. "] = " .. item:GetName())
            local avalore_slot = item:GetSpecialValueFor("item_slot")
            if avalore_slot then
                inv_validation[avalore_slot] = 1
            end
        end
    end
    --print("======VALIDATE")
    for base_slot=0,5 do
        --print("[" .. tostring(base_slot) .. "] = " .. tostring(inv_validation[base_slot]))
        if inv_validation[base_slot] == -1 or inv_validation[base_slot] == nil then
            if base_slot == AVALORE_ITEM_SLOT_HEAD then
                hero:AddItemByName("item_slot_head")
            elseif base_slot == AVALORE_ITEM_SLOT_CHEST then
                hero:AddItemByName("item_slot_chest")
            elseif base_slot == AVALORE_ITEM_SLOT_ACCESSORY then
                hero:AddItemByName("item_slot_back")
            elseif base_slot == AVALORE_ITEM_SLOT_HANDS then
                hero:AddItemByName("item_slot_hands")
            elseif base_slot == AVALORE_ITEM_SLOT_FEET then
                hero:AddItemByName("item_slot_feet")
            elseif base_slot == AVALORE_ITEM_SLOT_TRINKET then
                hero:AddItemByName("item_slot_trinket")
            end
        end
    end

    -- check for dummy items wrongly placed in the stash (need to fix this upstream some time)
    for stash_slot=9,14 do
        local item = hero:GetItemInSlot(stash_slot)
        -- if item then
        --     print("[" .. tostring(stash_slot) .. "][" .. item:GetName() .. "]")
        -- end
        if item and string.find(item:GetName(), "item_slot") then
            print("Found dummy item in stash [" .. tostring(stash_slot) .. "][" .. item:GetName() .. "]" )
            -- find the item slot that's nil
            for item_slot=0,8 do
                local inv_item = hero:GetItemInSlot(item_slot)
                if not inv_item then
                    print("Trying to Move to Slot: " .. tostring(item_slot))
                    local droppable = item:IsDroppable()
                    item:SetDroppable(true)
                    hero:SwapItems(stash_slot, item_slot)
                    item:SetDroppable(droppable)
                end
            end
        end
    end
    
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
                --print(tostring(item))
                -- double check the C++ object exists before checking the backpack
                -- happens when selling
                if not item:IsNull() and (not item:IsInBackpack()) then
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
            -- if intr_mod then
            --     print("Intrinsic Mod: " .. intr_mod)
            -- end
            if intr_mod then
                if not hero:FindModifierByName(intr_mod) then
                    print("modifier_inventory_manager > Adding (" .. item:GetName() .. ", " .. intr_mod .. ")")
                    --hero:AddNewModifier(self, item, intr_mod, {})
                    hero:AddNewModifier(hero, item, intr_mod, {})
                    --backpack_state[intr_mod] = item
                end

                -- start or continue tracking this backpacked item
                backpack_state[intr_mod] = item
            end
        end
    end

    -- print("==== BACKPACK STATE ====")
    -- for mod,item in pairs(backpack_state) do
    --     print("Modifier: " .. mod .. ", Item: " .. item:GetName())
    -- end
    -- print("========================")
    
    -- remake the backpack
    self.curr_backpack = nil -- garbage collect
    self.curr_backpack = backpack_state -- set to new object
end