-- tracking modifier for the talent
modifier_talent_ritual_madness = class({})

function modifier_talent_ritual_madness:IsHidden() 		    return true end
function modifier_talent_ritual_madness:IsPurgable() 	    return false end
function modifier_talent_ritual_madness:RemoveOnDeath() 	return false end