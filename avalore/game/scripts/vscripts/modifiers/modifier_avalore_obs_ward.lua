modifier_avalore_obs_ward = class({})


function modifier_avalore_obs_ward:IsHidden() return true end
function modifier_avalore_obs_ward:IsPurgable() return false end

function modifier_avalore_obs_ward:OnCreated(kv)

end

function modifier_avalore_obs_ward:DeclareFunctions()
    return { MODIFIER_PROPERTY_MODEL_CHANGE }
end

-- Note: I think this only works because the model gets precached in npc_units_custom.txt
function modifier_avalore_obs_ward:GetModifierModelChange()
    return "models/items/wards/skywrath_sentinel/skywrath_sentinel.vmdl"
end