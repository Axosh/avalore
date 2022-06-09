modifier_avalore_fear = class({})

function modifier_avalore_fear:IsHidden()     return false end
function modifier_avalore_fear:IsPurgable()   return true  end
function modifier_avalore_fear:IsDebuff()     return true  end

function modifier_avalore_fear:CheckState()
    return {
                [MODIFIER_STATE_FEARED ]    = true,
                [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }
end

function modifier_avalore_fear:GetTexture()
    return "generic/fear"
end

function modifier_avalore_fear:OnCreated()
    if not IsServer() then return end
    self.fear_origin = self:GetCaster():GetAbsOrigin()
    self.distance = 150
    self.direction = self.fear_origin - self:GetParent():GetAbsOrigin()
    self.direction.z = 0
    self.direction = -self.direction:Normalized()

    -- Start interval
    self:StartIntervalThink( 0.2 )
    self:OnIntervalThink()
end

function modifier_avalore_fear:OnDestroy( kv )
	if not IsServer() then return end
    self:GetParent():Stop()
end

function modifier_avalore_fear:OnIntervalThink()
	-- run direction
	self.direction = self.fear_origin - self:GetParent():GetAbsOrigin()
	self.direction.z = 0
	self.direction = -self.direction:Normalized()

	-- forced run
	self:GetParent():MoveToPosition( self:GetParent():GetAbsOrigin() + self.direction * self.distance )
end