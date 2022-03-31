-- tracking modifier for the talent
modifier_talent_escape_artist = class({})

function modifier_talent_escape_artist:IsHidden() 		return true end
function modifier_talent_escape_artist:IsPurgable() 		return false end
function modifier_talent_escape_artist:RemoveOnDeath() 	return false end