-- tracking modifier for the talent
modifier_talent_overgrowth = class({})

function modifier_talent_overgrowth:IsHidden() 		return true end
function modifier_talent_overgrowth:IsPurgable() 		return false end
function modifier_talent_overgrowth:RemoveOnDeath() 	return false end