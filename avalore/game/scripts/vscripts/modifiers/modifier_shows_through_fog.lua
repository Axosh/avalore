modifier_shows_through_fog = class({})

function modifier_shows_through_fog:DeclareFunctions()
    return { MODIFIER_PROPERTY_PROVIDES_FOW_POSITION }
end

function modifier_shows_through_fog:CheckState()
    local state = {}
	if IsServer() then
        state[MODIFIER_STATE_INVISIBLE] = false
    end
    return state
end

function modifier_shows_through_fog:GetModifierProvidesFOWVision()
    return 1
end