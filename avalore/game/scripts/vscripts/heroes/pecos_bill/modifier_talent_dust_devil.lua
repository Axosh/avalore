modifier_talent_dust_devil = class({})

function modifier_talent_dust_devil:IsHidden() 		    return true  end
function modifier_talent_dust_devil:IsPurgable() 		return false end
function modifier_talent_dust_devil:RemoveOnDeath() 	return false end