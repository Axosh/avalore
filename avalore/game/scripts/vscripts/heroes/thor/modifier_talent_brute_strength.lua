-- tracking modifier for the talent
modifier_talent_brute_strength = class({})

function modifier_talent_brute_strength:IsHidden() 		return true  end
function modifier_talent_brute_strength:IsPurgable() 		return false end
function modifier_talent_brute_strength:RemoveOnDeath() 	return false end