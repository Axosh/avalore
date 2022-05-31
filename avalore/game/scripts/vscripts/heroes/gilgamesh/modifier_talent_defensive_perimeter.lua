-- tracking modifier for the talent
modifier_talent_defensive_perimeter = class({})

function modifier_talent_defensive_perimeter:IsHidden() 		return true end
function modifier_talent_defensive_perimeter:IsPurgable() 	return false end
function modifier_talent_defensive_perimeter:RemoveOnDeath() 	return false end