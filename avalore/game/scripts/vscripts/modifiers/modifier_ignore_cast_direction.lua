modifier_ignore_cast_direction = class({})

function modifier_ignore_cast_direction:DeclareFunctions()
	local decFuncs =
	{
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
	return decFuncs
end

function modifier_ignore_cast_direction:GetModifierIgnoreCastAngle( params )
	return 1
end

function modifier_ignore_cast_direction:GetModifierDisableTurning( params )
	return 1
end

function modifier_ignore_cast_direction:IsHidden()
	return false
end

-- Do a stop order after finish casting to prevent turning to the destination point
function modifier_ignore_cast_direction:OnDestroy( params )
	if IsServer() then
		local stopOrder =
		{
			UnitIndex = self:GetCaster():entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP
		}
		ExecuteOrderFromTable( stopOrder )
	end
end