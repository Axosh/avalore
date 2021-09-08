modifier_wearable_temp_invis = class({})

function modifier_wearable_temp_invis:IsHidden() return true end
function modifier_wearable_temp_invis:IsPurgable() return false end
function modifier_wearable_temp_invis:IsDebuff() return false end

function modifier_wearable_temp_invis:DecalreFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end

function modifier_wearable_temp_invis:GetModifierInvisibilityLevel()
    return 1 --invis
end

function modifier_wearable_temp_invis:CheckState()
    if IsServer() then
        return  {  [MODIFIER_STATE_INVISIBLE] = true }
    end
end