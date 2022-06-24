-- tracking modifier for the talent
modifier_talent_shepherds_leap = class({})

function modifier_talent_shepherds_leap:IsHidden() 		    return true  end
function modifier_talent_shepherds_leap:IsPurgable() 		return false end
function modifier_talent_shepherds_leap:RemoveOnDeath() 	return false end