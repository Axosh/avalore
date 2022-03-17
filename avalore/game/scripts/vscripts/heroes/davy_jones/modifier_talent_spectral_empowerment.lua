-- tracking modifier for the talent
modifier_talent_spectral_empowerment = class({})

function modifier_talent_spectral_empowerment:IsHidden() 		return true end
function modifier_talent_spectral_empowerment:IsPurgable() 		return false end
function modifier_talent_spectral_empowerment:RemoveOnDeath() 	return false end

function modifier_talent_spectral_empowerment:OnCreated()
    if not IsServer() then return end

    -- force it to refresh to update bonus soul damage
    print("modifier_talent_spectral_empowerment:OnCreated()")
    self:GetParent():FindModifierByName("modifier_lost_souls"):ForceRefresh()
end