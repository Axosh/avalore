-- tracking modifier for the talent
modifier_talent_parry = class({})

function modifier_talent_parry:IsHidden() 		return true end
function modifier_talent_parry:IsPurgable() 		return false end
function modifier_talent_parry:RemoveOnDeath() 	return false end

function modifier_talent_parry:OnCreated()
    if not IsServer() then return end
    local melee_mod = self:GetParent():FindModifierByName("modifier_jack_of_all_trades_melee")
    if melee_mod then
        melee_mod:ForceRefresh() --update the armor
    end
end