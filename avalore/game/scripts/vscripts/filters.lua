-- taken largely from dota_imba

function CAvaloreGameMode:OrderFilter(keys)
	--print("CAvaloreGameMode:OrderFilter(keys)")
    local units = keys["units"]
	local unit
	if units["0"] then
		unit = EntIndexToHScript(units["0"])
	else
		return nil
	end
	if unit == nil then return end

    -- -- Don't let couriers be controlled when multi-selected
	-- if keys.units then
	-- 	for k, v in pairs(keys.units) do
	-- 		if k ~= "0" and EntIndexToHScript(v) and EntIndexToHScript(v):IsCourier() then
	-- 			return false
	-- 		end
	-- 	end
	-- end

	-- -- Do special handlings if shift-casted only here! The event gets fired another time if the caster
	-- -- is actually doing this order
	-- if keys.queue == 1 then
	-- 	return true
	-- end

    -- local target = keys.entindex_target ~= 0 and EntIndexToHScript(keys.entindex_target) or nil
	-- local ability = keys.entindex_ability ~= 0 and EntIndexToHScript(keys.entindex_ability) or nil

    -- local disableHelpResult = DisableHelp.ExecuteOrderFilter(keys.order_type, ability, target, unit)
	-- if disableHelpResult == false then
	-- 	return false
	-- end

    -- if keys.order_type == DOTA_UNIT_ORDER_GLYPH then
	-- 	CombatEvents("generic", "glyph", unit)
	-- end

    -- -- credits Overthrow 2.0 (Dota2Unofficial)
	-- if keys.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
	-- 	if not target then return true end
	-- 	local pickedItem = target:GetContainedItem()
	-- 	if not pickedItem then return true end

	-- 	local itemName = pickedItem:GetAbilityName()

	-- 	if itemName == "item_aegis" then
	-- 		if not unit:IsRealHero() then
	-- 			DisplayError(keys.issuer_player_id_const, "#dota_hud_error_non_hero_cant_pickup_aegis")
	-- 			return false
	-- 		elseif unit:HasModifier("modifier_item_imba_aegis") then
	-- 			DisplayError(keys.issuer_player_id_const, "#dota_hud_error_already_have_aegis")
	-- 			return false
	-- 		end
	-- 	end
	-- end

    ------------------------------------------------------------------------------------
	-- Prevent Buyback during reincarnation
	------------------------------------------------------------------------------------
	-- if keys.order_type == DOTA_UNIT_ORDER_BUYBACK then
	-- 	if unit:IsReincarnating() then
	-- 		return false
	-- 	else
	-- 		-- Trying to add a custom buyback respawn timer penalty modifier
	-- 		-- Doing a rough safeguard using gold so people don't get the modifier when spamming the buyback button a frame before they respawn like an idiot
	-- 		local gold_before_buyback = unit:GetGold() or -1
			
	-- 		Timers:CreateTimer(FrameTime(), function()
	-- 			-- If these checks pass, this assumes that the person actually bought back
	-- 			if unit:IsAlive() and gold_before_buyback >= (unit:GetGold() or 0) then
	-- 				unit:AddNewModifier(unit, nil, "modifier_buyback_penalty", {})
	-- 			end
	-- 		end)
	-- 	end
	-- end

    -- ===============================================================================
    -- Handle Spells That Don't Require Unit to be Facing The Target/Cursor Location
    -- ===============================================================================
    

    --if keys.order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then
    --if keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET then
    --print("[Filters] keys.order_type = " .. tostring(keys.order_type))
    if keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
        local ability = EntIndexToHScript(keys.entindex_ability)

        -- Sun Wukong - Jingu Stuff
        if ability ~= nil then
            if ability:GetAbilityName() == "ability_ruyi_jingu_bang" or ability:GetAbilityName() == "ability_riptide"then
                print("Hit Filter for ability_ruyi_jingu_bang and ability_riptide")
                unit:AddNewModifier(unit, ability, "modifier_ignore_cast_direction", {duration = 0.41} )
            end
        end
    end

    return true
end