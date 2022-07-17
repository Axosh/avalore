-- tracking modifier for the talent
modifier_talent_toughness = class({})

function modifier_talent_toughness:IsHidden() 		return true  end
function modifier_talent_toughness:IsPurgable() 	return false end
function modifier_talent_toughness:RemoveOnDeath() 	return false end