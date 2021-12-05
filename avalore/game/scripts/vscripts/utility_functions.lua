--[[ Utility Functions ]]

--require "os"


---------------------------------------------------------------------------
-- Broadcast messages to screen
---------------------------------------------------------------------------
function BroadcastMessage( sMessage, fDuration )
    print("Got in BroadcastMessage")
    local centerMessage = {
        message = sMessage,
        duration = fDuration
    }
    FireGameEvent( "show_center_message", centerMessage )
end

function PickRandomShuffle( reference_list, bucket )
    if ( #reference_list == 0 ) then
        return nil
    end
    
    if ( #bucket == 0 ) then
        -- ran out of options, refill the bucket from the reference
        for k, v in pairs(reference_list) do
            bucket[k] = v
        end
    end

    -- pick a value from the bucket and remove it
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

-- apparently can't use os on game servers (probably exploitable)
--https://stackoverflow.com/questions/35572435/how-do-you-do-the-fisher-yates-shuffle-in-lua
--math.randomseed(os.time()) -- so that the results are always different
function FYShuffle( tInput )
    local tReturn = {}
    for i = #tInput, 1, -1 do
        local j = math.random(i)
        tInput[i], tInput[j] = tInput[j], tInput[i]
        table.insert(tReturn, tInput[i])
    end
    return tReturn
end

function TableCount( t )
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end

function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end

function CountdownTimer(time_in_sec)
    --nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    --local t = nCOUNTDOWNTIMER
    --print( t )
    --local minutes = math.floor(t / 60)
    --local seconds = t - (minutes * 60)
    --local m10 = math.floor(minutes / 10)
    --local m01 = minutes - (m10 * 10)
    --local s10 = math.floor(seconds / 10)
    local s10 = 0
    if(time_in_sec > 10) then
        s10 = 1
    end
    local s01 = time_in_sec--seconds - (s10 * 10)
    local broadcast_gametimer = 
        {
            timer_minute_10 = 0,--m10,
            timer_minute_01 = 0,--m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    --CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
    --if t <= 120 then
    CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
    --end
end

function SetTimer( cmdName, time )
    print( "Set the timer to: " .. time )
    nCOUNTDOWNTIMER = time
end

function PrintTable( t, indent )
	--print( "PrintTable( t, indent ): " )

	if type(t) ~= "table" then return end
	
	if indent == nil then
		indent = "   "
	end

	for k,v in pairs( t ) do
		if type( v ) == "table" then
			if ( v ~= t ) then
				print( indent .. tostring( k ) .. ":\n" .. indent .. "{" )
				PrintTable( v, indent .. "  " )
				print( indent .. "}" )
			end
		else
		print( indent .. tostring( k ) .. ":" .. tostring(v) )
		end
	end
end

function PrintVector(vect, msg)
    print(msg .. " | (" .. tostring(vect.x) .. ", " .. tostring(vect.y) .. ", " .. tostring(vect.z) .. ")")
end


-- SPELLS

function SwapSpells(abilityRef, slotNum, newSpell)
    local caster = abilityRef:GetCaster()
    local spell_slot = abilityRef:GetCaster():GetAbilityByIndex(slotNum):GetAbilityName()
    local modifier = abilityRef:GetCaster():GetAbilityByIndex(slotNum):GetIntrinsicModifierName()
    if modifier then
        caster:RemoveModifierByName(modifier) -- remove lingering modifier
    end

    local curr_slot_level = caster:FindAbilityByName(spell_slot):GetLevel()
    caster:SwapAbilities(spell_slot, newSpell, false, true)
    abilityRef:GetCaster():GetAbilityByIndex(slotNum):SetLevel(curr_slot_level)
end

-- lifted from dota_imba
-- Returns an unit's existing increased cast range modifiers
function GetCastRangeIncrease( unit )
	local cast_range_increase = 0
	-- Only the greatefd st increase counts for items, they do not stack
	for _, parent_modifier in pairs(unit:FindAllModifiers()) do        
		if parent_modifier.GetModifierCastRangeBonus then
			cast_range_increase = math.max(cast_range_increase,parent_modifier:GetModifierCastRangeBonus())
		end
	end

	for _, parent_modifier in pairs(unit:FindAllModifiers()) do        
		if parent_modifier.GetModifierCastRangeBonusStacking and parent_modifier:GetModifierCastRangeBonusStacking() then
			cast_range_increase = cast_range_increase + parent_modifier:GetModifierCastRangeBonusStacking()
		end
	end

	return cast_range_increase
end