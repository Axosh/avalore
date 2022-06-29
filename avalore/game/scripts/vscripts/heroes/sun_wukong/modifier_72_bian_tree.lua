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
    -- initialize with random tree
    local rand = RandomInt(0, 5)
    self.tree_model = random_tree_table[rand]
    -- see if we can find a better option nearby to clone
    -- local nearby_trees = GridNav:GetAllTreesAroundPoint(self:GetParent():GetAbsOrigin(), 600, false)
    -- -- local nearby_trees = FindUnitsInRadius( self:GetParent():GetTeamNumber(), 
    -- --                                         self:GetParent():GetAbsOrigin(), 
    -- --                                         nil, 
    -- --                                         600, --search range
    -- --                                         0, --DOTA_UNIT_TARGET_TEAM_BOTH, 
    -- --                                         DOTA_UNIT_TARGET_ALL + DOTA_UNIT_TARGET_TREE + DOTA_UNIT_TARGET_CUSTOM, --DOTA_UNIT_TARGET_TREE, 
    -- --                                         DOTA_UNIT_TARGET_FLAG_NONE,
    -- --                                         FIND_CLOSEST,
    -- --                                         false)
    -- if #nearby_trees > 0 then
    --     for _, tree in pairs(nearby_trees) do
    --         local tree_entid = GetEntityIndexForTreeId(tree:GetEntityIndex())
    --         print("Tree ID => " .. tostring(tree_entid))
    --         print("Tree EntID => " .. tostring(tree:GetEntityIndex()))
    --         --self.tree_model = tree:GetModelName()
    --         --print("Found Tree Model => " .. tree:GetModelName())
    --         --print("Tree => " .. tostring(tree:GetTeam()))
    --         --PrintTable(EntIndexToHScript(tree:GetEntityIndex()))
    --         --print("Found Tree Model => " .. EntIndexToHScript(tree:GetEntityIndex()):GetModelName())
    --         print("Found Tree Model => " .. EntIndexToHScript(tree_entid):GetModelName())
    --         --break
    --     end
    -- end

    if IsOnRadiantSide(self:GetParent():GetAbsOrigin().x, self:GetParent():GetAbsOrigin().y) then
        self.tree_model = "models/props_tree/tree_pinestatic_02.vmdl"
    else
        self.tree_model = "models/props_tree/dire_tree004b_sfm.vmdl"
    end

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