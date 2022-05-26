-- tracking modifier for the talent
modifier_talent_synergy = class({})

function modifier_talent_synergy:IsHidden() 		return true end
function modifier_talent_synergy:IsPurgable() 		return false end
function modifier_talent_synergy:RemoveOnDeath() 	return false end

function modifier_talent_synergy:OnCreated()

    if not IsServer() then return end
    self.bonus_attack_seed

end