-- tracking modifier for the talent
modifier_talent_ammits_judgement = class({})

function modifier_talent_ammits_judgement:IsHidden() 		return true end
function modifier_talent_ammits_judgement:IsPurgable() 		return false end
function modifier_talent_ammits_judgement:RemoveOnDeath() 	return false end