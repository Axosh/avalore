-- tracking modifier for the talent
modifier_talent_primal_force = class({})

function modifier_talent_primal_force:IsHidden() 		return true end
function modifier_talent_primal_force:IsPurgable() 		return false end
function modifier_talent_primal_force:RemoveOnDeath() 	return false end