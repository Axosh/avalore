-- tracking modifier for the talent
modifier_talent_tag_team = class({})

function modifier_talent_tag_team:IsHidden() 		return true end
function modifier_talent_tag_team:IsPurgable() 		return false end
function modifier_talent_tag_team:RemoveOnDeath() 	return false end