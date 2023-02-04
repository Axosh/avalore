LinkLuaModifier("modifier_replenish_counter", "heroes/thor/modifier_replenish_counter.lua", LUA_MODIFIER_MOTION_NONE)

-- tracking modifier for the talent
modifier_talent_replenish = class({})

function modifier_talent_replenish:IsHidden() 		return true  end
function modifier_talent_replenish:IsPurgable() 	return false end
function modifier_talent_replenish:RemoveOnDeath() 	return false end

function modifier_talent_replenish:OnCreated()
    local ability = self:GetCaster():FindAbilityByName("ability_toothgnashers")
    if IsServer() then
        local mod = self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_replenish_counter", {})
        mod:SetStackCount(self:GetCaster():FindTalentValue("talent_replenish", "max_stacks"))
        print("Stack Count => " .. tostring(mod:GetStackCount()))
    end
    -- if not self:GetCaster():HasModifier("modifier_replenish_counter") then
        
    -- end
    if ability then
        --print("Caster? " .. self:GetCaster():GetName())
        -- if self:GetCaster() then
        --     self:GetCaster():AddNewModifier(nil, nil, "modifier_replenish_counter", {})
        -- end
        ability:SetupStacks()
    end
end