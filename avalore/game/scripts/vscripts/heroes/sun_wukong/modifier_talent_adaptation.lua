-- tracking modifier for the talent
modifier_talent_adaptation = class({})

function modifier_talent_adaptation:IsHidden() 		    return true  end
function modifier_talent_adaptation:IsPurgable() 		return false end
function modifier_talent_adaptation:RemoveOnDeath() 	return false end