modifier_dust_devil = cl

function modifier_dust_devil:GetTexture()
    return "pecos_bill/dust_devil"
end

function modifier_dust_devil:IsHidden() return false end
function modifier_dust_devil:IsPurgeabl() return false end
function modifier_dust_devil:IsDebuff() return false end

function modifier_dust_devil:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
            MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end
    
function modifier_dust_devil:GetModifierInvisibilityLevel()
    if self:GetStackCount() == 0 then
        return 1 -- invis
    else
        return 0 -- visible
    end
end
