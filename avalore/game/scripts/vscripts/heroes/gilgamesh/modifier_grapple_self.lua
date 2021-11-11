modifier_grapple_self = class({})

function modifier_grapple_self:IsHidden()		return true end
function modifier_grapple_self:IsPurgable()		return false end
function modifier_grapple_self:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

-- function modifier_grapple_self:DeclareFunctions()
-- 	return {
--                 MODIFIER_EVENT_ON_ABILITY_EXECUTED,
--                 MODIFIER_EVENT_ON_ORDER
--             }
-- end

