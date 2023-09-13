LinkLuaModifier( "modifier_urban_legend_revive",  "units/urban_legends/modifier_urban_legend.lua",        LUA_MODIFIER_MOTION_NONE )

modifier_urban_legend = class({})

function modifier_urban_legend:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_urban_legend:OnTakeDamage(kv)

	if IsServer() then
		local target = self:GetParent()

		if target == kv.unit then
            -- if this is gonna kill us
			if (target:GetHealth() - kv.damage) <= 0 then
				target:AddNewModifier(target, nil, "modifier_urban_legend_revive", {duration = 15.0})
            end
		end
	end

end

-- ==============================================
-- Invuln/Regen
-- ==============================================
modifier_urban_legend_revive = class({})

function modifier_urban_legend_revive:DeclareFunctions()
    return { 
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, 
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, 
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
			MODIFIER_STATE_UNSELECTABLE,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MIN_HEALTH
    }
end

function modifier_urban_legend_revive:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
	}
end


function modifier_urban_legend_revive:OnCreated(kv)
    if not IsServer() then return end
    self.particle = "particles/generic_gameplay/generic_stunned.vpcf"
	self.bonus_health_regen = (self:GetParent():GetMaxHealth() / kv.duration)
end

function modifier_urban_legend_revive:GetAbsoluteNoDamageMagical( params )
	return 0
end

function modifier_urban_legend_revive:GetAbsoluteNoDamagePhysical( params )
	return 0
end

function modifier_urban_legend_revive:GetAbsoluteNoDamagePure( params )
	return 0
end

function modifier_urban_legend_revive:GetMinHealth()
	return 1
end

function modifier_urban_legend_revive:GetModifierConstantHealthRegen()
	return self.bonus_health_regen
end

function modifier_urban_legend_revive:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_urban_legend_revive:GetEffectName()
	return self.particle
end

function modifier_urban_legend_revive:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end