modifier_quest_wisp = class({})


--Set which functions we're overriding
function modifier_quest_wisp:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_MAX,
            --MODIFIER_PROPERTY_MOVESPEED_LIMIT,
            --MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, 
    		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, 
    		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
    		MODIFIER_PROPERTY_DISABLE_HEALING, 
    		MODIFIER_EVENT_ON_ATTACK_LANDED,
    		DOTA_ABILITY_BEHAVIOR_HIDDEN}
end

function modifier_quest_wisp:GetAbsoluteNoDamageMagical( params )
	return 1
end

function modifier_quest_wisp:GetAbsoluteNoDamagePhysical( params )
	return 1
end

function modifier_quest_wisp:GetAbsoluteNoDamagePure( params )
	return 1
end

function modifier_quest_wisp:GetDisableHealing()
    return 1
end

function modifier_quest_wisp:OnAttackLanded(params)
	--print('Attack landed')
    if params.target == self:GetParent() then
        params.target:SetHealth(params.target:GetHealth() - 1)
    end
end

function modifier_quest_wisp:IsHidden()
	return true
end

--function modifier_quest_wisp:GetModifierMoveSpeed_Absolute()
    --return 700
--end

function modifier_quest_wisp:GetModifierMoveSpeed_Max()
    return 5000
end

--function modifier_quest_wisp:GetModifierMoveSpeed_Limit(params)
--    return 1000
--end