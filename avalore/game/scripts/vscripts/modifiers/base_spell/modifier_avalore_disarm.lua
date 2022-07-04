modifier_avalore_disarm = class({})

LinkLuaModifier("modifier_talent_fistfighter", "heroes/thor/modifier_talent_fistfighter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_no_hammer", "heroes/thor/modifier_no_hammer.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_avalore_disarm:IsHidden() return false end
function modifier_avalore_disarm:IsPurgeable() return true end
function modifier_avalore_disarm:IsDebuff() return true end

function modifier_avalore_disarm:GetTexture()
    return "generic/disarm"
end

function modifier_avalore_disarm:OnCreated(kv)
    if not IsServer() then return end
    if self:GetParent():HasTalent("talent_fistfighter") then
        print("Has Fistfighter")
        print("Duration => " .. tostring(kv.duration))
        -- if they have the fistfighter talent, let that handle whether disarms affect them
        self:GetParent():AddNewModifier(self:GetCaster(), nil, "modifier_no_hammer", {duration = kv.duration})
        --self:GetParent():AddNewModifier(self:GetCaster(), nil, "modifier_no_hammer_debuff", {duration = kv.duration, disarm_debuff = true})
        self:Destroy()
    end
end

function modifier_avalore_disarm:CheckState()
    return  {
                [MODIFIER_STATE_DISARMED] = true
            }
end

function modifier_avalore_disarm:GetEffectName()
	return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_avalore_disarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end