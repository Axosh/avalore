-- tracking modifier for the talent
modifier_talent_disarm = class({})

function modifier_talent_disarm:IsHidden() 		return true end
function modifier_talent_disarm:IsPurgable() 		return false end
function modifier_talent_disarm:RemoveOnDeath() 	return false end