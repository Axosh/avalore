modifier_toothgnashers_counter = class({})

LinkLuaModifier( "modifier_wearable", "scripts/vscripts/modifiers/modifier_wearable", LUA_MODIFIER_MOTION_NONE )

function modifier_toothgnashers_counter:IsHidden() return false end
function modifier_toothgnashers_counter:IsDebuff() return false end
function modifier_toothgnashers_counter:IsPurgable() return false end
function modifier_toothgnashers_counter:RemoveOnDeath() return false end

function modifier_toothgnashers_counter:GetTexture()
    return "thor/toothgnashers"
end

-- make stackable
function modifier_toothgnashers_counter:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_toothgnashers_counter:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    self.speed_per_goat = self.ability:GetSpecialValueFor("speed_per_goat")

    if IsServer() then
        self.goat_units = {}
        self:SetStackCount(1)
    end
end

function modifier_toothgnashers_counter:OnStackCountChanged(iOldStackCount)
    if not IsServer() then return end

    print("iOldStackCount = " .. tostring(iOldStackCount))

    -- consumed a chage
    if iOldStackCount > self:GetStackCount() then
        self.goat_units[iOldStackCount]:Kill()
        table.remove(self.goat_units, iOldStackCount)
    else
        -- summoned a new goat
        local goat = CreateUnitByName(  "npc_avalore_toothgnasher", --unit
                                        self.caster:GetAbsOrigin(), --location
                                        true,                       --findClearSpace
                                        nil,                        --npcOwner
                                        nil,                        --entityOwner
                                        DOTA_TEAM_NEUTRALS)         --team
        --goat:AddNewModifier(nil, nil, "modifier_unselectable", {})
        --goat:AddNewModifier(nil, nil, "modifier_no_healthbar", {})
        --goat:AddNewModifier(nil, nil, "modifier_invulnerable", {})
        goat:AddNewModifier(nil, nil, "modifier_wearable", {is_pet = true})
        --goat:SetParent(self.caster, nil)
        --goat:SetOwner(self.caster)
        table.insert(self.goat_units, goat)
    end
end

function modifier_toothgnashers_counter:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_toothgnashers_counter:GetModifierMoveSpeedBonus_Percentage() 
    return (self.speed_per_goat * self:GetStackCount());
end