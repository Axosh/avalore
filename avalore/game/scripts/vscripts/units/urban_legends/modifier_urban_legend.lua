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

            end
		end
	end

end

-- ==============================================
-- Invuln/Regen
-- ==============================================
modifier_urban_legend_revive = class({})

modifier_urban_legend_revive:DeclareFunctions()
    return { 
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, 
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, 
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
            MODIFIER_PROPERTY_DISABLE_HEALING, 
            MODIFIER_EVENT_ON_ATTACK_LANDED,
    }