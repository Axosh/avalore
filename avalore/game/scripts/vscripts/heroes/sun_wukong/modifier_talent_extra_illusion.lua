-- tracking modifier for the talent
modifier_talent_extra_illusion = class({})

function modifier_talent_extra_illusion:IsHidden() 		    return true  end
function modifier_talent_extra_illusion:IsPurgable() 		return false end
function modifier_talent_extra_illusion:RemoveOnDeath() 	return false end