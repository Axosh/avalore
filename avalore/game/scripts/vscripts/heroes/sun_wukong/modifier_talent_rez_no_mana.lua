-- tracking modifier for the talent
modifier_talent_rez_no_mana = class({})

function modifier_talent_rez_no_mana:IsHidden() 		return true  end
function modifier_talent_rez_no_mana:IsPurgable() 		return false end
function modifier_talent_rez_no_mana:RemoveOnDeath() 	return false end