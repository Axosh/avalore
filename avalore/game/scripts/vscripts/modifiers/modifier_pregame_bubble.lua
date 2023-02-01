modifier_pregame_bubble = class({})

function modifier_pregame_bubble:IsHidden() return true end
function modifier_pregame_bubble:IsDebugg() return true end
function modifier_pregame_bubble:IsPurgeable() return false end

function modifier_pregame_bubble:OnCreated(kv)
    if not IsServer() then return end
    self.radius = 1000
end

function modifier_pregame_bubble:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end