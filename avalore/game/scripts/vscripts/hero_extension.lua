-- Talent handling
function CDOTA_BaseNPC:HasTalent(talentName)
	if self and not self:IsNull() and self:HasAbility(talentName) then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end

	return false
end

function CDOTA_BaseNPC:GetAbilityByName(ability_name)
    if self and not self:IsNull() then
        for ability_num=0,17 do
            local ability_ref = self:GetAbilityByIndex(ability_num)
            if ability_ref and ability_ref:GetName() == ability_name then
                return ability_ref
            end
        end
    end

    return nil
end