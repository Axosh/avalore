modifier_deadly_fog_invis = class({})

function modifier_deadly_fog_invis:IsHidden() return false end
function modifier_deadly_fog_invis:IsPurgable() return false end
function modifier_deadly_fog_invis:IsDebuff() return false end

function modifier_deadly_fog_invis:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end

function modifier_deadly_fog_invis:GetModifierInvisibilityLevel()
    return 1
end

function modifier_deadly_fog_invis:CheckState()
    return  {   [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                [MODIFIER_STATE_INVISIBLE] = true
            }
end

function modifier_deadly_fog_invis:GetPriority()
    return MODIFIER_PRIORITY_NORMAL
end