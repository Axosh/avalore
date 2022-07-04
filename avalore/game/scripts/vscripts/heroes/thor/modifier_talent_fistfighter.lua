-- tracking modifier for the talent
modifier_talent_fistfighter = class({})

function modifier_talent_fistfighter:IsHidden() 		return true  end
function modifier_talent_fistfighter:IsPurgable() 		return false end
function modifier_talent_fistfighter:RemoveOnDeath() 	return false end