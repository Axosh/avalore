-- tracking modifier for the talent
modifier_talent_riptide_cast_range = class({})

function modifier_talent_riptide_cast_range:IsHidden() 		return true end
function modifier_talent_riptide_cast_range:IsPurgable() 		return false end
function modifier_talent_riptide_cast_range:RemoveOnDeath() 	return false end