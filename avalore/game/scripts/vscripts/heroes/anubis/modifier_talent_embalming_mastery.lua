-- tracking modifier for the talent
modifier_talent_embalming_mastery = class({})

function modifier_talent_embalming_mastery:IsHidden() 		return true end
function modifier_talent_embalming_mastery:IsPurgable() 		return false end
function modifier_talent_embalming_mastery:RemoveOnDeath() 	return false end