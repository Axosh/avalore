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
    if vect == nil then
        print(msg .. " | Vector is nil!")
    else
        print(msg .. " | (" .. tostring(vect.x) .. ", " .. tostring(vect.y) .. ", " .. tostring(vect.z) .. ")")
    end
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

function TrueKill(caster, target, ability)
    -- Deals lethal damage in order to trigger death-preventing abilities... Except for Reincarnation
	if not ( target:HasModifier("modifier_wukong_immortality") or target:HasModifier("modifier_necromancy_aura_buff") or target:HasModifier("modifier_necromancy_aura_buff_form") ) then
		target:Kill(ability, caster)
	end

    -- Removes the relevant modifiers
	target:RemoveModifierByName("modifier_invulnerable")

    -- Kills the target
	if not target:HasModifier("modifier_necromancy_aura_buff_form") then
		target:Kill(ability, caster)
	end
end

-- ================================================
-- Vectors
-- ================================================

-- angle (in degrees) between two normalized vectors
function AngleBetween2DVectors(vect_a, vect_b)
    -- print("ATAN2 VECT_A = " .. math.atan2(vect_a.y, vect_a.x))
    -- print("ATAN2 VECT_B = " .. math.atan2(vect_b.y, vect_b.x))
    -- print("Difference Vector Angle = " .. tostring(math.atan2(vect_b.y - vect_a.y, vect_b.x - vect_a.x)))
    local radians = math.atan2(vect_a.y, vect_a.x) - math.atan2(vect_b.y, vect_b.x)
    local abs_radians = math.abs(radians) -- remove negative if applicable
    return (math.deg(abs_radians)) -- convert radians to degrees and return
end

-- https://byjus.com/maths/angle-between-two-vectors/
-- https://devforum.roblox.com/t/best-way-to-get-the-angle-between-two-vectors/208450/2
-- https://stackoverflow.com/questions/10002918/what-is-the-need-for-normalizing-a-vector
function AngleBetween2DVectors_JoyStick(vect)
    -- cosine of dot product of A and B, divided by the magnitudes multiplied
    -- but since these are normalized, both should have magnitude 1
    -- cos((A . B) / (a_magnitude * b_magnitude))
    local vect_a = Vector(0, 1, 0) -- pointing "up"
    local vect_b = vect
    local dot_prod = vect_a:Dot(vect_b)
    print("Dot Prod = " .. tostring(dot_prod))
    local radians = math.acos(dot_prod)
    local degrees = math.deg(radians)
    if vect_b.x < 0 then
        return 360 - degrees
    else
        return degrees
    end
end


-- -----------------------------------------------------------------------------------
-- The idea here is to map the vector targetting a player drags
-- to a direction that can be used (similar to the way the chat wheel works)
-- So to diagram this out with the normalized "forward vector" being (0, 1, 0):
-- -----------------------------------------------------------------------------------
-- 7 0 1
-- 6 * 2
-- 5 4 3
-- -----------------------------------------------------------------------------------
-- so a 90 degree angle would correspond to octant "2"
-- -----------------------------------------------------------------------------------
function MapAngleToOctant(angle)
    --print("Vector Angle = " .. tostring(angle))
    local angle_normalized = angle/45 -- 45-degree chunks of the 360-degrees of a circle ==> 8ths
    angle_normalized = math.floor(angle_normalized)
    -- in case 360 (not sure if this is a concern since we're taking the floor)
    if angle_normalized == 8 then
        angle_normalized = 7
    end

    return angle_normalized
end

function OctantBetween2DVectors(vect_a, vect_b)
    return MapAngleToOctant(AngleBetween2DVectors(vect_a, vect_b))
end


-- -----------------------------------------------------------------------------------
-- Map a vector targetting to a quadrant that's divided up as an "X"
-- -----------------------------------------------------------------------------------
-- \ 0 /
-- 3 X 1
-- / 2 \
-- -----------------------------------------------------------------------------------
-- so a 90 degree angle would correspond to quadrant "1"
-- -----------------------------------------------------------------------------------
function MapAngleToXSlice(angle)
    print("MapAngleToXSlice(" .. tostring(angle) .. ")")

    if angle >= 45 and angle < 135 then
        return 1
    elseif angle >= 135 and angle < 225 then
        return 2
    elseif angle >= 225 and angle < 315 then
        return 3
    else
        return 0
    end
end

function XQuadrantBetween2DVectors_JoyStick(vect)
    print("======XQuadrantBetween2DVectors=====")
    --PrintVector(vect_a, "Vect A")
    --PrintVector(vect_b, "Vect B")
    return MapAngleToXSlice(AngleBetween2DVectors_JoyStick(vect))
end


-- normalizes a vector's length to an intensity value to scale the
-- distance of a spell, etc.
-- Also See: vector_target.lua
function TargetingVectorIntensity(target_vect)
    local xDist = target_vect.end_pos.x - target_vect.init_pos.x
    local yDist = target_vect.end_pos.y - target_vect.init_pos.y
    local len = math.sqrt((xDist ^ 2) + (yDist ^ 2))
    print("Raw Len = " .. tostring(len))
    local intensity = len/500
    if intensity > 1 then
        intensity = 1
    end
    print("Intensity = " .. tostring(intensity))
    return intensity
end

-- starting at a point,
function ResolveEndPoint(starting_point, vector_dir, distance)
    PrintVector(vector_dir:Normalized(), "Dir Vector")
    local add_vect = vector_dir:Normalized() * distance
    return starting_point + add_vect
end

function DistanceBetweenVectors(vect_a, vect_b)
    local xDist = vect_a.x - vect_b.x
    local yDist = vect_a.y - vect_b.y
    local len = math.sqrt((xDist ^ 2) + (yDist ^ 2))
    return len
end

-- ================================================
-- Physical Versions of Flags
-- ================================================

-- Flag A, Flag B
function RenderFlagMorale(unit)
    --unit:SetRenderColor(245, 166, 35) -- pale orange (matches icon)
    unit:SetRenderColor(255, 166, 0) -- orange
    unit:SetRenderAlpha(1.0)
    --unit:SetModelScale(2.0)
end

-- Flag C
function RenderFlagAgility(unit)
    --unit:SetRenderColor(126, 211, 33)
    unit:SetRenderColor(0, 255, 0)
    unit:SetRenderAlpha(1.0)
    --unit:SetModelScale(2.0)
end

-- Flag D
function RenderFlagArcane(unit)
    --unit:SetRenderColor(72, 186, 255)
    --unit:SetRenderColor(72, 186, 255)
    unit:SetRenderColor(0, 0, 255)
    unit:SetRenderAlpha(1.0)
    --unit:SetModelScale(2.0)
end

-- Flag E
function RenderFlagRegrowth(unit)
    --unit:SetRenderColor(65, 116, 5)
    unit:SetRenderColor(0, 128, 5)
    unit:SetRenderAlpha(1.0)
    --unit:SetModelScale(2.0)
end

function SetFlagForward(unit)
    print("skip")
    --unit:SetForwardVector(Vector(0,-1,0))
end


-- GRID NAV

-- very hacky approach because I'm lazy
function IsOnRadiantSide(x, y)
    print("(" .. tostring(x) .. ", " .. tostring(y) .. ")")
    -- check if they're roughly in radiant top lane
    if x < -3900 and y < 3850 then
        print("In Radi Top")
        return true
    -- check if they're roughly in the bottom corner of radiant
    elseif x > 3900 and y < -3850 then
        print("In Radi Bot")
        return true
    -- check to see if they're roughly in the mid-section of radiant
    elseif x > -3900 and x < 3900 then
        -- check if they're under the slope
        local slope = -0.987 -- slope between (-3900, 3850) and (3900, -3850)
        local calc_y = x * slope
        print("Corresponding Y => " .. tostring(calc_y))
        if  y <= calc_y then
            print("In Radi Mid")
            return true
        end
    end
    return false
end