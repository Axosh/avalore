require("constants")
--require("../controllers/inventory_manager")
modifier_inventory_manager = class({})

--LinkLuaModifier( "modifier_item_leather_boots", "items/shop/base_materials/item_leather_boots.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_inventory_manager:IsHidden() return true end
function modifier_inventory_manager:IsDebuff() return false end
function modifier_inventory_manager:IsPurgable() return false end
function modifier_inventory_manager:RemoveOnDeath() return false end
function modifier_inventory_manager:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_inventory_manager:OnCreated(kv)
    if not IsServer() then return end
    print("modifier_inventory_manager:OnCreated(kv)")
    -- track (modifier:item) so we can clean up modifiers if the item is null/no longer in backpack
    self.inventory = InventoryManager:GetPlayerInventory(self:GetParent():GetPlayerOwnerID()) --InventoryManager[self:GetParent():GetPlayerOwnerID()]
    --self.inventory = kv.inventory
    PrintTable(self.inventory:GetSlots())
    self.curr_backpack = {}
    self.backpack_mod_count = {}
    self:StartIntervalThink(FrameTime())
end

function modifier_inventory_manager:OnIntervalThink()
    if not IsServer() then return end
    --print("modifier_inventory_manager:OnIntervalThink()")
    local hero = self:GetParent()
    if hero == nil then return end
    -- if not hero:IsAlive() then
    --     print("Inventory Owner is Dead!")
    -- end

    local move_to_stash_or_drop = false
    for inv_slot=0,8 do
        local item = hero:GetItemInSlot(inv_slot)
        if item then
            local avalore_slot = item:GetSpecialValueFor("item_slot")
            if avalore_slot then
                -- if regular item and not in right spot
                if inv_slot < 6 and inv_slot ~= avalore_slot and avalore_slot ~= AVALORE_ITEM_SLOT_MISC then
                    local item_tmp = hero:GetItemInSlot(avalore_slot)
                    -- make sure the item slot isn't filled (e.g. something combined in an odd way)
                    if item_tmp and not item_tmp:IsNull() and item_tmp:GetSpecialValueFor("item_slot") == inv_slot then
                        move_to_stash_or_drop = true
                    else
                        hero:SwapItems(inv_slot, avalore_slot)
                    end
                -- if something is in the backpack that shouldn't be
                elseif inv_slot > 5 and avalore_slot ~= AVALORE_ITEM_SLOT_MISC then
                    hero:SwapItems(inv_slot, avalore_slot)
                -- if something is in main that should be in backpack
                elseif inv_slot < 6 and inv_slot ~= avalore_slot and avalore_slot == AVALORE_ITEM_SLOT_MISC then
                    local swap_target = nil
                    for swap_tmp=6,8 do
                        local item_tmp = hero:GetItemInSlot(swap_tmp)
                        if not item_tmp then
                            swap_target = swap_tmp
                            break
                        elseif item_tmp:GetSpecialValueFor("item_slot") ~= AVALORE_ITEM_SLOT_MISC then
                            swap_target = swap_tmp
                            break
                        end
                    end
                    if swap_target then
                        hero:SwapItems(inv_slot, swap_target)
                    else
                        move_to_stash_or_drop = true
                    end
                end
            end
        end

        -- if we've got no valid options, try to move to the stash, otherwise drop it
        if move_to_stash_or_drop then
            -- if hero is in range of shop, then just move it to the stash
            local moved_to_stash = false
            if hero:IsInRangeOfShop(DOTA_SHOP_HOME, true) then
                for stash_slot=9,14 do
                    if not hero:GetItemInSlot(stash_slot) then
                        print("Swap " .. tostring(inv_slot) .. " to " .. tostring(stash_slot))
                        hero:SwapItems(inv_slot, stash_slot)
                        moved_to_stash = true
                        break
                    end
                end
            end
            if not moved_to_stash then
                hero:DropItemAtPositionImmediate(item, hero:GetOrigin())
                print("Dropping item due to no space")
                -- TODO: error message
            end
        end

        if inv_slot < 6 then
            self.inventory:GetSlots()[inv_slot] = hero:GetItemInSlot(inv_slot)
        else
            self.inventory:GetSlots()[AVALORE_ITEM_SLOT_MISC][inv_slot] = hero:GetItemInSlot(inv_slot)
        end
    end

    -- cycle through slots, make sure they have items in them
    -- local inv_validation = {-1, -1, -1, -1, -1, -1}
    -- --print("=====SEEK")
    -- for inv_slot=0,5 do
    --     local item = hero:GetItemInSlot(inv_slot)
    --     if item then
    --         --print("[" .. tostring(inv_slot) .. "] = " .. item:GetName())
    --         local avalore_slot = item:GetSpecialValueFor("item_slot")
    --         if avalore_slot then
    --             inv_validation[avalore_slot] = 1
    --         end

    --         if string.find(item:GetName(), "item_slot") then
    --             item:SetSellable(false)
    --             item:SetDroppable(false)
    --             item:SetItemState(1)
    --         end
    --     end
    -- end
    --print("======VALIDATE")
    -- for base_slot=0,5 do
    --     --print("[" .. tostring(base_slot) .. "] = " .. tostring(inv_validation[base_slot]))
    --     if inv_validation[base_slot] == -1 or inv_validation[base_slot] == nil then
    --         if base_slot == AVALORE_ITEM_SLOT_HEAD then
    --             hero:AddItemByName("item_slot_head")
    --         elseif base_slot == AVALORE_ITEM_SLOT_CHEST then
    --             hero:AddItemByName("item_slot_chest")
    --         elseif base_slot == AVALORE_ITEM_SLOT_ACCESSORY then
    --             hero:AddItemByName("item_slot_back")
    --         elseif base_slot == AVALORE_ITEM_SLOT_HANDS then
    --             hero:AddItemByName("item_slot_hands")
    --         elseif base_slot == AVALORE_ITEM_SLOT_FEET then
    --             hero:AddItemByName("item_slot_feet")
    --         elseif base_slot == AVALORE_ITEM_SLOT_TRINKET then
    --             hero:AddItemByName("item_slot_trinket")
    --         end
    --     end
    -- end

    -- check for dummy items wrongly placed in the stash (need to fix this upstream some time)
    -- for stash_slot=DOTA_STASH_SLOT_1 ,DOTA_STASH_SLOT_6  do
    --     local item = hero:GetItemInSlot(stash_slot)
    --     -- if item then
    --     --     print("[" .. tostring(stash_slot) .. "][" .. item:GetName() .. "]")
    --     -- end
    --     if item and string.find(item:GetName(), "item_slot") then
    --         print("Found dummy item in stash [" .. tostring(stash_slot) .. "][" .. item:GetName() .. "]" )
    --         -- find the item slot that's nil
    --         for item_slot=0,8 do
    --             local inv_item = hero:GetItemInSlot(item_slot)
    --             if not inv_item then
    --                 print("Trying to Move to Slot: " .. tostring(item_slot))
    --                 local droppable = item:IsDroppable()
    --                 item:SetDroppable(true)
    --                 hero:SwapItems(stash_slot, item_slot)
    --                 item:SetDroppable(droppable)
    --                 break;
    --             end
    --         end
    --     end
    -- end
    
    -- check to see if anything that is in the backpack shouldn't be there
    -- for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
    --     local item = hero:GetItemInSlot(slot)
    --     if item then
    --         if string.find(item:GetName(), "item_slot") then
    --             item:SetSellable(false)
    --             item:SetDroppable(false)
    --             item:SetItemState(1)
    --         end
            
    --         if item:GetSpecialValueFor("item_slot") ~= AVALORE_ITEM_SLOT_MISC then
    --             print("Found Item That Should Not Be in Backpack: " .. item:GetName())
    --             -- see if the item slot it should be in is already empty
    --             -- if string.find(hero:GetItemInSlot(item:GetSpecialValueFor("item_slot")):GetName(), "item_slot") then
    --             --     hero:RemoveItem(hero:GetItemInSlot(item:GetSpecialValueFor("item_slot")))
    --             --     hero:SwapItems()
    --             -- else
    --                 for main_slot=AVALORE_ITEM_SLOT_HEAD,AVALORE_ITEM_SLOT_TRINKET do
    --                     local item_main = hero:GetItemInSlot(main_slot)
    --                     -- found a misplaced item, swap it
    --                     if item_main:GetSpecialValueFor("item_slot") == AVALORE_ITEM_SLOT_MISC then
    --                         print("modifier_inventory_manager > Returning Item to Backpack")
    --                         local droppable = item_main:IsDroppable()
    --                         item_main:SetDroppable(true)
    --                         hero:SwapItems(slot, main_slot)
    --                         item_main:SetDroppable(droppable)
    --                     end
    --                 end
    --             -- end
    --         end
    --     end
    -- end
    
    -- loop through known backpack items to see if they're still in backpack
    --for mod,item in pairs(self.curr_backpack) do
    for itemEntIndex,mod in pairs(self.curr_backpack) do
        local item = EntIndexToHScript(itemEntIndex)
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
                local mod_instance = hero:FindModifierByName(mod)
                if mod_instance then
                    if mod_instance:GetStackCount() > 1 and (not mod == "modifier_item_essence_of_shadow") then
                        mod_instance:DecrementStackCount()
                    else
                        hero:RemoveModifierByName(mod)
                    end
                end
                if self.backpack_mod_count[mod] > 0 then
                    self.backpack_mod_count[mod] = self.backpack_mod_count[mod] - 1
                end
            -- else
            --     -- keep track of how many stacks we have of this
            --     if mod_count[mod] then
            --         mod_count[mod] = mod_count[mod] + 1
            --     else
            --         mod_count[mod] = 1
            --     end
            end
        end
    end

    -- loop through actual backpack (not the Avalore one)
    local backpack_state = {}
    local curr_mods = {}
    local curr_data_driven = {}
    local mod_to_item = {}
    for slot=AVALORE_ITEM_SLOT_MISC1,AVALORE_ITEM_SLOT_MISC3 do
        local item = hero:GetItemInSlot(slot)
        if item then
            --print("modifier_inventory_manager > Found Item in Backpack: " .. item:GetName())
            local intr_mod = item:GetIntrinsicModifierName()
            -- if intr_mod then
            --     print("Intrinsic Mod: " .. intr_mod)
            -- end

            -- check for data-driven
            -- if not intr_mod then
            --     print("Checking for Data Driven")
            --     local has_intr = item:GetSpecialValueFor("HasIntrinsicModifier")
            --     print("Intrinsic Check => " .. tostring(has_intr))
            --     if has_intr and (has_intr == 1) then
            --         intr_mod = "modifier_" .. item:GetName()
            --         print("Generating Modifier Name => " .. intr_mod)
            --     end
            -- end
            if intr_mod then
                curr_mods = IncrementTableKey(curr_mods, intr_mod)
                mod_to_item[intr_mod] = item
                -- if not hero:FindModifierByName(intr_mod)  then
                --     print("modifier_inventory_manager > Adding (" .. item:GetName() .. ", " .. intr_mod .. ")")
                --     curr_mods[intr_mod] = 1
                --     --hero:AddNewModifier(self, item, intr_mod, {})
                --     -- hero:AddNewModifier(hero, item, intr_mod, {})
                --     -- --backpack_state[intr_mod] = item
                --     -- self.backpack_mod_count[intr_mod] = 1
                -- else
                --     -- check to see if this can stack
                --     if hero:FindModifierByName(intr_mod):GetAttributes() == MODIFIER_ATTRIBUTE_MULTIPLE then
                        
                --     end
                -- end

                -- start or continue tracking this backpacked item
                --backpack_state[intr_mod] = item
                backpack_state[item:GetEntityIndex()] = intr_mod
            else
                local data_driven_mod = GetAvaloreDataDrivenIntrinsicModifier(item)
                if data_driven_mod then
                    curr_data_driven = IncrementTableKey(curr_data_driven, data_driven_mod)
                    mod_to_item[data_driven_mod] = item
                    backpack_state[item:GetEntityIndex()] = data_driven_mod
                end
                -- local has_intr = item:GetSpecialValueFor("HasIntrinsicModifier")
                -- if has_intr and (has_intr == 1) then
                --     local data_driven_mod = "modifier_" .. item:GetName()
                --     if not hero:FindModifierByName(data_driven_mod) then
                --         item:ApplyDataDrivenModifier(hero, hero, data_driven_mod, {})
                --         backpack_state[item:GetEntityIndex()] = data_driven_mod
                --     end
                -- end
            end
        end
    end

    -- compare known mods to counted mods
    for currMod, currModCount in pairs(curr_mods) do
        --print("Looking at " .. currMod)
        if self.backpack_mod_count[currMod] and self.backpack_mod_count[currMod] > 0 then
            --print("Found Instance of " .. currMod)
            local tempMod = hero:FindModifierByName(currMod)
            --print(tempMod:GetName())
            --print("Attrs => " .. tostring(tempMod:GetAttributes()))
            -- see if we can stack multiple instances
            if tempMod and tempMod:GetAttributes() == MODIFIER_ATTRIBUTE_MULTIPLE then
                --print("Can Stack")
                -- compare counts
                if tempMod:GetStackCount() ~= currModCount then
                    tempMod:SetStackCount(currModCount)
                    self.backpack_mod_count[currMod] = currModCount
                end
            end
        else
            -- if new, just add it
            local item = mod_to_item[currMod]
            hero:AddNewModifier(self:GetParent(), item, currMod, {})
            self.backpack_mod_count[currMod] = 1
        end
    end

    -- -- compare known mods to counted data-driven mods
    -- for currMod, currModCount in pairs(curr_data_driven) do
    --     --print("CurrMod = " .. currMod)
    --     if self.backpack_mod_count[currMod] and self.backpack_mod_count[currMod] > 0 then
    --         --print("Already Known")
    --         local tempMod = hero:FindModifierByName(currMod)
    --         print("Attrs => " .. tostring(tempMod:GetAttributes()))
    --         -- see if we can stack multiple instances
    --         if tempMod:GetAttributes() == MODIFIER_ATTRIBUTE_MULTIPLE then
    --             print("Can Stack")
    --             -- compare counts
    --             if tempMod:GetStackCount() ~= currModCount then
    --                 tempMod:SetStackCount(currModCount)
    --                 self.backpack_mod_count[currMod] = currModCount
    --             end
    --         end
    --     else
    --         -- if new, just add it
    --         print("New Mod Detected so Adding 1 to " .. currMod)
    --         --hero:AddNewModifier(self, item, currMod, {})
    --         local item = mod_to_item[currMod]
    --         item:ApplyDataDrivenModifier(hero, hero, currMod, {})
    --         self.backpack_mod_count[currMod] = 1
    --     end
    -- end


    -- print("==== BACKPACK STATE ====")
    -- for mod,item in pairs(backpack_state) do
    --     print("Modifier: " .. mod .. ", Item: " .. item:GetName())
    -- end
    -- print("========================")
    
    -- remake the backpack
    self.curr_backpack = nil -- garbage collect
    self.curr_backpack = backpack_state -- set to new object
end

-- Look for the Item's Intrinsic Mod, or Data-Driven Intrinsic Mod
-- returns the name of the modifier, or nil
-- nm this won't work because regular mods and data driven ones are applied differently
function GetIntrinsicOrDataDrivenMod(item)
    local intr_mod = item:GetIntrinsicModifierName()
    if intr_mod then
        return intr_mod
    else
        local has_intr = item:GetSpecialValueFor("HasIntrinsicModifier")
        if has_intr and (has_intr == 1) then
            local data_driven_mod = "modifier_" .. item:GetName()
        else
            return nil
        end
    end
end

function GetAvaloreDataDrivenIntrinsicModifier(item)
    local has_intr = item:GetSpecialValueFor("HasIntrinsicModifier")
    if has_intr and (has_intr == 1) then
        return ("modifier_" .. item:GetName())
    else
        return nil
    end
end

function IncrementTableKey(table, key)
    if table[key] then
        table[key] = table[key] + 1
    else
        table[key] = 1
    end
    return table
end