modifier_movespeed_max = class({})

--Set which functions we're overriding
function modifier_movespeed_max:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_MAX,
    		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    		DOTA_ABILITY_BEHAVIOR_HIDDEN}
end

function modifier_movespeed_max:GetModifierMoveSpeed_Max( params )
	return 1000
end

function modifier_movespeed_max:GetModifierMoveSpeed_Limit(params)
	return 1000
end

function modifier_movespeed_max:IsHidden()
	return true
end