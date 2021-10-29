modifier_lightning_bolt = class({})

function modifier_lightning_bolt:IsHidden() return true end
function modifier_lightning_bolt:IsPurgable() return false end

function modifier_lightning_bolt:CheckState()
	return {
                [MODIFIER_STATE_NO_TEAM_MOVE_TO] 	= true,
                [MODIFIER_STATE_NO_TEAM_SELECT] 	= true,
                [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
                [MODIFIER_STATE_ATTACK_IMMUNE] 		= true,
                [MODIFIER_STATE_MAGIC_IMMUNE] 		= true,
                [MODIFIER_STATE_INVULNERABLE] 		= true,
                [MODIFIER_STATE_UNSELECTABLE] 		= true,
                [MODIFIER_STATE_NOT_ON_MINIMAP] 	= true,
                [MODIFIER_STATE_NO_HEALTH_BAR] 		= true,
                [MODIFIER_STATE_FLYING]             = true
            }
end

