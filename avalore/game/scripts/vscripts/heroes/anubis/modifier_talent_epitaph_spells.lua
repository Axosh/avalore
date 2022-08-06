-- tracking modifier for the talent
modifier_talent_epitaph_spells = class({})

function modifier_talent_epitaph_spells:IsHidden() 		return true end
function modifier_talent_epitaph_spells:IsPurgable() 		return false end
function modifier_talent_epitaph_spells:RemoveOnDeath() 	return false end