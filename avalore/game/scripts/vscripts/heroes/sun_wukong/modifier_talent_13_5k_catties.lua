-- tracking modifier for the talent
modifier_talent_13_5k_catties = class({})

function modifier_talent_13_5k_catties:IsHidden() 		return true  end
function modifier_talent_13_5k_catties:IsPurgable() 		return false end
function modifier_talent_13_5k_catties:RemoveOnDeath() 	return false end