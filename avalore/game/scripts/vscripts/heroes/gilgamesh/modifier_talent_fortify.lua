-- tracking modifier for the talent
modifier_talent_fortify = class({})

function modifier_talent_fortify:IsHidden() 		return true end
function modifier_talent_fortify:IsPurgable() 	    return false end
function modifier_talent_fortify:RemoveOnDeath() 	return false end

function modifier_talent_fortify:OnCreated()
    if not IsServer() then return end

    --self:GetCaster():AddAbility("ability_fortify")

    -- swap ability4 (empty slot) with ability8 (fortify), disable empty, enable fortify
    -- self:GetCaster():SwapAbilities(3, 7, false, true)
    self:GetCaster():UnHideAbilityToSlot("ability_fortify", "generic_hidden")
    self:GetCaster():FindAbilityByName("ability_fortify"):SetLevel(1)
    --self:GetCaster()GetAbilityByIndex(3)

end