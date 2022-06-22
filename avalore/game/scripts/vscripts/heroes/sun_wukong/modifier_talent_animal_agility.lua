-- tracking modifier for the talent
modifier_talent_animal_agility = class({})

function modifier_talent_animal_agility:IsHidden() 		    return true  end
function modifier_talent_animal_agility:IsPurgable() 		return false end
function modifier_talent_animal_agility:RemoveOnDeath() 	return false end