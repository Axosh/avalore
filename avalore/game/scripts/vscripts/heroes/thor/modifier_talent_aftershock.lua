-- tracking modifier for the talent
modifier_talent_aftershock = class({})

function modifier_talent_aftershock:IsHidden() 		    return true  end
function modifier_talent_aftershock:IsPurgable() 		return false end
function modifier_talent_aftershock:RemoveOnDeath() 	return false end