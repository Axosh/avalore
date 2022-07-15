-- tracking modifier for the talent
modifier_talent_tectonic_force = class({})

function modifier_talent_tectonic_force:IsHidden() 		return true  end
function modifier_talent_tectonic_force:IsPurgable() 	return false end
function modifier_talent_tectonic_force:RemoveOnDeath() 	return false end