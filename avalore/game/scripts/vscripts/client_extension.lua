-- loaded in addon_init.lua
-- holds functions that the client-side can use (since there is some separation of funcitons
-- that only server side and only client side can see)


-- load all values for later use
local AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

-- function C_DOTA_BaseNPC:HasTalent(talentName)
-- 	if self and not self:IsNull() and self:HasAbility(talentName) then
-- 		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
-- 	end

-- 	return false
-- end

-- function C_DOTA_BaseNPC:HasTalent(talentName)
--     print("Checking Client-Side Talent: " .. talentName)
-- 	if self:HasModifier("modifier_"..talentName) then
--         print("Hero has the talent")
-- 		return true 
-- 	end

-- 	return false
-- end

function C_DOTA_BaseNPC:HasTalent(talentName)
	if self and self:FindAbilityByName(talentName) and self:FindAbilityByName(talentName):GetLevel() > 0 then
        return true
	end

	return false
end

function C_DOTA_BaseNPC:FindTalentValue(talentName, key)
	if self:HasModifier("modifier_"..talentName) then
		local value_name = key or "value"
		local specialVal = AbilityKV[talentName]["AbilitySpecial"]
		for l,m in pairs(specialVal) do
			if m[value_name] then
				return m[value_name]
			end
		end
	end
	return 0
end

function C_DOTABaseAbility:GetTalentSpecialValueFor(value)
    print("Checking Client-Side Talent Value")
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = AbilityKV[self:GetName()]
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName and self:GetCaster():HasModifier("modifier_"..talentName) then
		base = base + self:GetCaster():FindTalentValue(talentName)
	end
	return base
end