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