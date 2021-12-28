modifier_72_bian_boar = class({})

function modifier_72_bian_boar:IsAura() return true end
function modifier_72_bian_boar:IsHidden() return false end
function modifier_72_bian_boar:IsPurgable() return false end

function modifier_72_bian_boar:GetTexture()
    return "sun_wukong/boar_form"
end


function modifier_72_bian_boar:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MODEL_CHANGE,
                MODIFIER_PROPERTY_HEALTH_BONUS
            }
end

function modifier_72_bian_boar:GetModifierModelChange()
	return "models/items/beastmaster/boar/ti9_cache_beastmaster_king_of_beasts_boar/ti9_cache_beastmaster_king_of_beasts_boar.vmdl"
end

function modifier_72_bian_boar:GetModifierExtraHealthBonus()
    return 400 --temp for testing
end