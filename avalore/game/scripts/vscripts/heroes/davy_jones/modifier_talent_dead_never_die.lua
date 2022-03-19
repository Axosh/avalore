-- tracking modifier for the talent
modifier_talent_dead_never_die = class({})

function modifier_talent_dead_never_die:IsHidden() 		return true end
function modifier_talent_dead_never_die:IsPurgable() 		return false end
function modifier_talent_dead_never_die:RemoveOnDeath() 	return false end