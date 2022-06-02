-- tracking modifier for the talent
modifier_talent_fortify = class({})

function modifier_talent_fortify:IsHidden() 		return true end
function modifier_talent_fortify:IsPurgable() 	return false end
function modifier_talent_fortify:RemoveOnDeath() 	return false end

function modifier_talent_fortify:OnCreated()
    if not IsServer() then return end

    self:GetCaster():AddAbility("ability_fortify")
end