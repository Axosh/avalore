modifier_avalore_teleporting = modifier_avalore_teleporting or class({})

function modifier_avalore_teleporting:IsHidden()      return false end
function modifier_avalore_teleporting:IsDebuff()      return false end
function modifier_avalore_teleporting:IsPurgable()    return false end
function modifier_avalore_teleporting:RemoveOnDeath() return true end
function modifier_avalore_teleporting:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_avalore_teleporting:OnCreated()
	if not IsServer() then return end
	self:GetCaster():StartGesture(ACT_DOTA_TELEPORT)
end

function modifier_avalore_teleporting:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():FadeGesture(ACT_DOTA_TELEPORT)
	self:GetCaster():StartGesture(ACT_DOTA_TELEPORT_END)
end