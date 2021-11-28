require("references")
require(REQ_UTIL)

modifier_shapeshift_eagle = class({})

function modifier_shapeshift_eagle:IsAura() return true end
function modifier_shapeshift_eagle:IsHidden() return false end
function modifier_shapeshift_eagle:IsPurgable() return false end

function modifier_shapeshift_eagle:GetTexture()
    return "zeus/modifier_shapeshift_eagle"
end

function modifier_shapeshift_eagle:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MODEL_CHANGE,
                MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
                MODIFIER_PROPERTY_BONUS_DAY_VISION,
                MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
                MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS        }
end

function modifier_shapeshift_eagle:CheckState()
	return {    [MODIFIER_STATE_FLYING] = true,
                [MODIFIER_STATE_FORCED_FLYING_VISION] = true,
                [MODIFIER_STATE_DISARMED] = true,
                [MODIFIER_STATE_MUTED] = true
            }
end

function modifier_shapeshift_eagle:GetModifierModelChange()
	return "models/items/beastmaster/hawk/fotw_eagle/fotw_eagle.vmdl"
end

function modifier_shapeshift_eagle:OnCreated()
    --if not IsServer() then return end

    self.movespeed = self:GetAbility():GetSpecialValueFor("speed_self")
    self.vision = self:GetAbility():GetSpecialValueFor("vision")

    print(self:GetCaster():GetName())

    if self:GetCaster():HasTalent("talent_ride_the_stormwinds") then
    --if self:GetCaster():FindAbilityByName("talent_ride_the_stormwinds") then
        self.movespeed = self.movespeed + self:GetCaster():FindAbilityByName("talent_ride_the_stormwinds"):GetTalentSpecialValueFor("bonus_speed")
        self.vision = self.vision + self:GetCaster():FindAbilityByName("talent_ride_the_stormwinds"):GetTalentSpecialValueFor("bonus_vision")
    end

    print("MS = " .. tostring(self.movespeed))

    -- for slot=0,10 do
    --     if self:GetCaster():GetAbilityByIndex(slot) then
    --         print("Slot " .. tostring(slot) .. " = " .. self:GetCaster():GetAbilityByIndex(slot):GetName())
    --     end
    -- end

    if not IsServer() then return end

    self:GetCaster():GetAbilityByIndex(0):SetHidden(true)
    self:GetCaster():GetAbilityByIndex(2):SetHidden(true)
    self:GetCaster():GetAbilityByIndex(5):SetHidden(true) --ults go here in layout 4
end

function modifier_shapeshift_eagle:GetModifierMoveSpeedOverride()
    return self.movespeed
end

function modifier_shapeshift_eagle:GetBonusDayVision()
    return self.vision
end

function modifier_shapeshift_eagle:GetBonusNightVision()
    return self.vision
end

function modifier_shapeshift_eagle:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Beastmaster.Call.Hawk")
    local particle_revert = "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf"
    local particle_revert_fx = ParticleManager:CreateParticle(particle_revert, PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_revert_fx, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_revert_fx, 3, self:GetCaster():GetAbsOrigin())

    -- give back the normal spell
    local spell_slot1 = self:GetCaster():GetAbilityByIndex(1):GetAbilityName() -- 0-indexed
    self:GetCaster():SwapAbilities(spell_slot1, "ability_shapeshift", false, true)
    local curr_level_slot1 = self:GetCaster():FindAbilityByName(spell_slot1):GetLevel()
    self:GetCaster():GetAbilityByIndex(1):SetLevel(curr_level_slot1)
    SwapSpells(self, 1, "ability_shapeshift")

    -- reveal other spells
    self:GetCaster():GetAbilityByIndex(0):SetHidden(false)
    self:GetCaster():GetAbilityByIndex(2):SetHidden(false)
    self:GetCaster():GetAbilityByIndex(5):SetHidden(false)
end

function modifier_shapeshift_eagle:GetActivityTranslationModifiers()
	return "hunter_night"
end