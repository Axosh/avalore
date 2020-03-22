modifier_flagbase = class({})

function modifier_flagbase:DeclareFunctions()
    return {MODIFIER_STATE_UNSELECTABLE,
            MODIFIER_STATE_INVULNERABLE,
            MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
            }
end

function modifier_flagbase:CheckState()
	local state = {}
	if IsServer() then
        state[MODIFIER_STATE_UNSELECTABLE] = true
        state[MODIFIER_STATE_INVULNERABLE] = true
        state[MODIFIER_STATE_INVISIBLE] = false
	end

	return state
end

function modifier_flagbase:GetModifierProvidesFOWVision()
    return 1
end