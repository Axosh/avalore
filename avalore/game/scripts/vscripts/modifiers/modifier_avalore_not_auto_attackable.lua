modifier_avalore_not_auto_attackable = class({})

function modifier_avalore_not_auto_attackable:IsHidden() return true end
function modifier_avalore_not_auto_attackable:IsDebuff() return false end
function modifier_avalore_not_auto_attackable:IsPurgeable() return false end

function modifier_avalore_not_auto_attackable:CanParentBeAutoAttacked()
    return false
end