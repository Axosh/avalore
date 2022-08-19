-- tracking modifier for the talent
modifier_talent_demotic_spells = class({})

function modifier_talent_demotic_spells:IsHidden() 		    return true end
function modifier_talent_demotic_spells:IsPurgable() 		return false end
function modifier_talent_demotic_spells:RemoveOnDeath() 	return false end