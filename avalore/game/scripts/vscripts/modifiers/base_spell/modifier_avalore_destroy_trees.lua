modifier_avalore_destroy_trees = class({})

function modifier_avalore_destroy_trees:IsDebuff()          return false end
function modifier_avalore_destroy_trees:IsHidden()          return true end
function modifier_avalore_destroy_trees:IsPurgable()        return false end

function modifier_avalore_destroy_trees:OnCreated(kv)
    if not IsServer() then return end

    self.duration = 2.0
    if kv.duration then
        self.duration = kv.duration
    end

    self.destroy_radius = 150
    if kv.destroy_radius then
        self.destroy_radius = kv.destroy_radius
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_avalore_destroy_trees:OnIntervalThink()
    if not IsServer() then return end

    local point = self:GetCaster():GetAbsOrigin()
    GridNav:DestroyTreesAroundPoint(point, self.destroy_radius, true)
end