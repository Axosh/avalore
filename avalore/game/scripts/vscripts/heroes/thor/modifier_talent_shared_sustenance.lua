-- tracking modifier for the talent
modifier_talent_shared_sustenance = class({})

function modifier_talent_shared_sustenance:IsHidden() 		return true  end
function modifier_talent_shared_sustenance:IsPurgable() 	return false end
function modifier_talent_shared_sustenance:RemoveOnDeath() 	return false end