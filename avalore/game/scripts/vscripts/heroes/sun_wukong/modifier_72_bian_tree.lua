modifier_72_bian_tree = class({})

function modifier_72_bian_tree:IsHidden() return false end
function modifier_72_bian_tree:IsPurgable() return false end
function modifier_72_bian_tree:IsDebuff() return false end
function modifier_72_bian_tree:RemoveOnDeath() return true end

local random_tree_table =   {
                                [0] = "maps/jungle_assets/trees/kapok/export/kapok_001.vmdl", -- pink tree
                                [1] = "models/heroes/hoodwink/hoodwink_tree_model.vmdl", --hoodwink tree
                                [2] = "models/props_garden/tree_garden001.vmdl", --derp tree
                                [3] = "models/props_tree/dire_tree006.vmdl", -- dire tree
                                [4] = "models/props_tree/frostivus_tree.vmdl", -- christmas tree
                                [5] = "models/props_tree/newbloom_tree.vmdl", -- new bloom tree
                            }

function modifier_72_bian_tree:GetTexture()
    return "sun_wukong/tree_form"
end

function modifier_72_bian_tree:OnCreated(kv)
    --self.speed_change = self:GetAbility():GetSpecialValueFor("speed_fish_rel")

    self.bonus_speed = self:GetCaster():FindTalentValue("talent_animal_agility", "bonus_speed") --kv.bonus_speed
    if not IsServer() then return end
    --self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_water_fade", {})
    local rand = RandomInt(0, 5)
    self.tree_model = random_tree_table[rand]

    if self:GetCaster():HasTalent("talent_camouflage") then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_forest_fade", {})
    end
    self:GetParent():GetAbilityByName("ability_ruyi_jingu_bang"):SetHidden(true)
end

function modifier_72_bian_tree:DeclareFunctions()
	return  {   MODIFIER_PROPERTY_MODEL_CHANGE,
                MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
            }
end

function modifier_72_bian_tree:CheckState()
	return {    [MODIFIER_STATE_DISARMED] = true,
                [MODIFIER_STATE_MUTED] = true,
                [MODIFIER_STATE_NOT_ON_MINIMAP] = true, --for testing
                [MODIFIER_STATE_NO_HEALTH_BAR] = true
                --[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true --for real
            }
end



function modifier_72_bian_tree:GetModifierMoveSpeedOverride()
    return 150 + self.bonus_speed
end


function modifier_72_bian_tree:GetModifierModelChange()
    return self.tree_model
end

function modifier_72_bian_tree:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_72_bian_tree:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():RemoveModifierByName("modifier_forest_fade")
    self:GetParent():GetAbilityByName("ability_ruyi_jingu_bang"):SetHidden(false)
end