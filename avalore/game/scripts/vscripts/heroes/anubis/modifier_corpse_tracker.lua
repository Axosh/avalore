modifier_corpse_tracker = class({})

function modifier_corpse_tracker:IsHidden() return true end
function modifier_corpse_tracker:IsPurgable() return false end
function modifier_corpse_tracker:RemoveOnDeath() return false end

function modifier_corpse_tracker:OnCreated(kv)

end