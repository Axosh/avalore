-- tracking modifier for talent
modifier_talent_scent_of_fear = class({})

function modifier_talent_scent_of_fear:IsHidden() 		return true  end
function modifier_talent_scent_of_fear:IsPurgable()     return false end
function modifier_talent_scent_of_fear:RemoveOnDeath() 	return false end