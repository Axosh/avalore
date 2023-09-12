modifier_urban_legend = class({})

function modifier_urban_legend:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_urban_legend:OnTakeDamage(kv)

	if IsServer() then
		local target = self:GetParent()

		if target == kv.unit then
            -- if this is gonna kill us
			if target:GetHealth() - kv.damage <= 0 then
                
            end
		end
	end

end