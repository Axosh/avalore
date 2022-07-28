modifier_anesthesiology_slow = class({})

function modifier_anesthesiology_slow:IsHidden() return false end
function modifier_anesthesiology_slow:IsDebuff() return true end
function modifier_anesthesiology_slow:IsPurgable() return false end


function modifier_anesthesiology_slow:GetTexture()
    return "anubis/anesthesiology_slow"
end

function modifier_anesthesiology_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_anesthesiology_slow:OnCreated(kv)
    self.ms_slow = self:GetCaster():FindTalentValue("talent_anesthesiology", "move_slow")
    --self.duration = self:GetCaster():FindTalentValue("talent_anesthesiology", "duration")
end

function modifier_anesthesiology_slow:GetModifierMoveSpeedBonus_Percentage()
	--return self.ms_slow * self:GetStackCount() * (-1)
    return self.ms_slow * (-1)
end