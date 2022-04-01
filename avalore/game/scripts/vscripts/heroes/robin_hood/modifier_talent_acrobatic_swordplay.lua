-- tracking modifier for the talent
modifier_talent_acrobatic_swordplay = class({})

function modifier_talent_acrobatic_swordplay:IsHidden() 		return true end
function modifier_talent_acrobatic_swordplay:IsPurgable() 		return false end
function modifier_talent_acrobatic_swordplay:RemoveOnDeath() 	return false end