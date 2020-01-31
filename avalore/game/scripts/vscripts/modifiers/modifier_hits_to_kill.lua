modifier_hits_to_kill = class({})


--Set which functions we're overriding
function modifier_hits_to_kill:DeclareFunctions()
    return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, 
    		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, 
    		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
    		MODIFIER_PROPERTY_DISABLE_HEALING, 
    		MODIFIER_EVENT_ON_ATTACK_LANDED,
    		DOTA_ABILITY_BEHAVIOR_HIDDEN}
end

function modifier_hits_to_kill:GetAbsoluteNoDamageMagical( params )
	return 1
end

function modifier_hits_to_kill:GetAbsoluteNoDamagePhysical( params )
	return 1
end

function modifier_hits_to_kill:GetAbsoluteNoDamagePure( params )
	return 1
end

function modifier_hits_to_kill:GetDisableHealing()
    return 1
end

function modifier_hits_to_kill:OnAttackLanded(params)
	--print('Attack landed')
    if params.target == self:GetParent() then
        params.target:SetHealth(params.target:GetHealth() - 1)
    end
end

function modifier_hits_to_kill:IsHidden()
	return true
end