-- Talent handling
function CDOTA_BaseNPC:HasTalent(talentName)
	if self and self:FindAbilityByName(talentName):GetLevel() > 0 then 
        return true
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

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = self:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName then 
		local talent = self:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
	end
	return base
end

function CDOTA_BaseNPC:HasTalent(talentName)
	if self and not self:IsNull() and self:HasAbility(talentName) then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end

	return false
end

function CDOTA_BaseNPC:FindTalentValue(talentName, key)
	if self:HasAbility(talentName) then
		local value_name = key or "value"
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
	end

	return 0
end