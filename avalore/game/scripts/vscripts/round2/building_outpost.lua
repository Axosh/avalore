modifier_unselectable = class({})

function modifier_unselectable:DeclareFunctions()
    return {MODIFIER_STATE_UNSELECTABLE}
end

function modifier_unselectable:CheckState()
	local state = {}
	if IsServer() then
		state[MODIFIER_STATE_UNSELECTABLE] = true
	end

	return state
end

--[[
"ability_capture"
	{
		// General
		//-------------------------------------------------------------------------------------------------------------
		"AbilityBehavior"				"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_CHANNELLED | DOTA_ABILITY_BEHAVIOR_HIDDEN"
		"AbilityUnitTargetTeam"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityCastAnimation"			"ACT_DOTA_GENERIC_CHANNEL_1"
		"MaxLevel"						"1"

		// Casting
		//-------------------------------------------------------------------------------------------------------------
		"AbilityCastRange"				"300"

		// Special	
		//-------------------------------------------------------------------------------------------------------------
		"AbilitySpecial"
		{
			"01"
			{
				"var_type"					"FIELD_FLOAT"
				"enemy_channel_time"		"5.0"
			}
		}
	}
--]]

modifier_capturable = class({})

function modifier_capturable:DeclareFunctions()
    return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, 
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, 
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
            MODIFIER_EVENT_ON_ATTACK_START,
            MODIFIER_STATE_INVULNERABLE,
            MODIFIER_EVENT_ON_ATTACKED}
end

function modifier_capturable:GetAbsoluteNoDamageMagical( params )
	return 1
end

function modifier_capturable:GetAbsoluteNoDamagePhysical( params )
	return 1
end

function modifier_capturable:GetAbsoluteNoDamagePure( params )
	return 1
end

function modifier_capturable:OnAttacked(params)
    --CastAbilityOnTarget
    if params.attacker:IsHero() then
        print("On Attacked")

        ExecuteOrderFromTable({
            UnitIndex = params.attacker:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
            TargetIndex = params.target:entindex(),
            AbilityIndex = params.attacker:FindAbilityByName("ability_capture"):entindex(),
            Position = nil,
            Queue = false,
        })
    end
end

function modifier_capturable:OnAttackStart( params )
    params.attacker:Stop()
    if params.attacker:IsHero() then
        print("OnAttackStart")
        --print(params.attacker:FindAbilityByName("ability_capture"):GetName())
        --CastAbilityOnTarget
        params.attacker:CastAbilityOnTarget(params.target, params.attacker:FindAbilityByName("ability_capture"), params.attacker:GetPlayerID())
        --[[ExecuteOrderFromTable({
            UnitIndex = params.attacker:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
            TargetIndex = params.target:entindex(),
            AbilityIndex = params.attacker:FindAbilityByName("ability_capture"):entindex(),
            Position = nil,
            Queue = false,
        })
        --]]
    end
end

function modifier_capturable:CheckState()
    --print("CheckState")
    if IsServer() then
        local state = {
            [MODIFIER_STATE_INVULNERABLE] = false
        }
        return state
    end
end

function modifier_capturable:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_capturable:CanParentBeAutoAttacked()
    --print("CanBeAutoAttacked")
	return false
end

--------------------------------------------------------------------------------

function modifier_capturable:IsPurgable()
	return false
end