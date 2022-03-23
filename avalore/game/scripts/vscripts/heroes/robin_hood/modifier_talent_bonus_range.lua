-- tracking modifier for the talent
modifier_talent_bonus_range = class({})

function modifier_talent_bonus_range:IsHidden() 		return true end
function modifier_talent_bonus_range:IsPurgable() 		return false end
function modifier_talent_bonus_range:RemoveOnDeath() 	return false end

function modifier_talent_bonus_range:OnCreated()
    if not IsServer() then return end
    local ranged_mod = self:GetParent():FindModifierByName("modifier_jack_of_all_trades_ranged")
    if ranged_mod then
        ranged_mod:ForceRefresh() --update the range
    end
end