-- tracking modifier for the talent
modifier_talent_camouflage = class({})

function modifier_talent_camouflage:IsHidden() 		    return true  end
function modifier_talent_camouflage:IsPurgable() 		return false end
function modifier_talent_camouflage:RemoveOnDeath() 	return false end