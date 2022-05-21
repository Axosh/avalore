-- tracking modifier for the talent
modifier_talent_culture_hero = class({})

function modifier_talent_culture_hero:IsHidden() 		return true end
function modifier_talent_culture_hero:IsPurgable() 		return false end
function modifier_talent_culture_hero:RemoveOnDeath() 	return false end