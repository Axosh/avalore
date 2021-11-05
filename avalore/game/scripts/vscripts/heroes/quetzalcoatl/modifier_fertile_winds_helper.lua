modifier_fertile_winds_helper = modifier_fertile_winds_helper or class({})

function modifier_fertile_winds_helper:IsDebuff()			return false end
function modifier_fertile_winds_helper:IsHidden() 			return true  end
function modifier_fertile_winds_helper:IsPurgable() 		return false end
function modifier_fertile_winds_helper:IsPurgeException() 	return false end
function modifier_fertile_winds_helper:IsStunDebuff() 		return false end
function modifier_fertile_winds_helper:RemoveOnDeath() 		return true  end

function modifier_fertile_winds_helper:DeclareFunctions()
	return  { MODIFIER_PROPERTY_IGNORE_CAST_ANGLE }
end

function modifier_fertile_winds_helper:GetModifierIgnoreCastAngle() return 360 end

function modifier_fertile_winds_helper:GetTexture()
	return "queztalcoatl/fertile_winds"
end

function modifier_fertile_winds_helper:OnCreated()
    if not IsServer() then return end

    local caster = self:GetCaster()
	EmitSoundOn("Hero_Phoenix.IcarusDive.Cast", caster)
end

function modifier_fertile_winds_helper:OnDestroy()
	if not IsServer() then return end

    local caster    = self:GetCaster()
	local point     = caster:GetAbsOrigin()
	local ability   = self:GetAbility()
    local radius    = ability:GetSpecialValueFor("stop_radius")
end