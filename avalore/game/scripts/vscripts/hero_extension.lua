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

-- function CDOTA_BaseNPC_Hero:HasAnyAvailableInventorySpace()
-- 	print("C_DOTA_BaseBPC_Hero:HasAnyAvailableInventorySpace()")
-- 	return true
-- end

-- function CDOTA_BaseNPC_Hero:GetNumItemsInInventory()
-- 	print("C_DOTA_BaseBPC_Hero:GetNumItemsInInventory()")
-- 	return 0
-- end

-- borrowed from DOTA_IMBA
function CDOTA_BaseNPC:Blink(position, bTeamOnlyParticle, bPlaySound)
	if self:IsNull() then return end

	if bPlaySound == true then EmitSoundOn("DOTA_Item.BlinkDagger.Activate", self) end

	local blink_pfx
	local blink_pfx_name = "particles/econ/events/fall_2022/blink/blink_dagger_start_fall2022.vpcf"

	if bTeamOnlyParticle == true then
		blink_pfx = ParticleManager:CreateParticleForTeam(blink_pfx_name, PATTACH_CUSTOMORIGIN, nil, self:GetTeamNumber())
		ParticleManager:SetParticleControl(blink_pfx, 0, self:GetAbsOrigin())
	else
		blink_pfx = ParticleManager:CreateParticle(blink_pfx_name, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(blink_pfx, 0, self:GetAbsOrigin())
	end

	ParticleManager:ReleaseParticleIndex(blink_pfx)
	FindClearSpaceForUnit(self, position, true)
	ProjectileManager:ProjectileDodge( self )

	local blink_end_pfx
	local blink_end_pfx_name = "particles/econ/events/fall_2022/blink/blink_dagger_end_blur_player_fall2022.vpcf"

	if bTeamOnlyParticle == true then
		blink_end_pfx = ParticleManager:CreateParticleForTeam(blink_end_pfx_name, PATTACH_ABSORIGIN, self, self:GetTeamNumber())
	else
		blink_end_pfx = ParticleManager:CreateParticle(blink_end_pfx_name, PATTACH_ABSORIGIN, self)
	end

	ParticleManager:ReleaseParticleIndex(blink_end_pfx)

	if bPlaySound == true then EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", self) end
end

-- Borrowed from DOTA_IMBA
function CDOTA_BaseNPC:IsHeroDamage(damage)
	if damage > 0 then
		if self:GetName() == "npc_dota_roshan" or self:IsControllableByAnyPlayer() then
			return true
		end
	end

	return false
end