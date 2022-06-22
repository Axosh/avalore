modifier_72_bian_fish = class({})

function modifier_72_bian_fish:IsHidden() return false end
function modifier_72_bian_fish:IsPurgable() return false end
function modifier_72_bian_fish:IsDebuff() return false end
function modifier_72_bian_fish:RemoveOnDeath() return true end

function modifier_72_bian_fish:GetTexture()
    return "sun_wukong/fish_form"
end

function modifier_72_bian_fish:OnCreated(kv)
    self.bonus_speed = kv.bonus_speed
    self.speed_change = self:GetAbility():GetSpecialValueFor("speed_fish_rel")

    if not IsServer() then return end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_water_fade", {})
end

function modifier_72_bian_fish:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

-- function modifier_72_bian_fish:CheckState()
-- 	local state = {
-- 	    [MODIFIER_STATE_NO_UNIT_COLLISION] = (self:GetParent():GetAbsOrigin().z <=0.5),
-- 	}

-- 	return state
-- end

function modifier_72_bian_fish:GetModifierMoveSpeedBonus_Percentage()
    -- speed amp in water
    if self:GetParent():GetAbsOrigin().z <=0.5 then
        return self.speed_change  + self.bonus_speed
    end
    -- slow on land
    return (self.speed_change * -1)  + self.bonus_speed
end


function modifier_72_bian_fish:GetEffectName()
    if self:GetParent():GetAbsOrigin().z <=0.5 then
        return "particles/units/heroes/hero_slardar/slardar_sprint_river.vpcf"
    end
end

function modifier_72_bian_fish:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_72_bian_fish:OnDestroy()
    self:GetCaster():RemoveModifierByName("modifier_water_fade")
end