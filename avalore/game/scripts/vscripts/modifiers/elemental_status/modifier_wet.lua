modifier_wet = class({})

function modifier_wet:IsHidden()
    return self:GetStackCount() == 0
end
function modifier_wet:IsDebuff()        return true end
function modifier_wet:IsPurgable()      return false end
function modifier_wet:RemoveOnDeath()   return false end

function modifier_wet:GetTexture()
    return "elemental_status/wet"
end

function modifier_wet:OnCreated(kv)
    if not IsServer() then return end

    self.spell_stacks = 0 -- stacks coming from spells that hit the owner
    self.spell_stack_duration = 0
    self.natural_stacks = 0 -- basically just from being in the water
    self.natural_linger = 0
    self:StartIntervalThink(0.1)
end

-- if some spell douses a character, then add a stack
-- don't impact current timer
function modifier_wet:OnRefresh(kv)
    if not IsServer() then return end

    self.spell_stacks = self.spell_stacks + 1
    if self.spell_stack_duration == 0 then
        self.spell_stack_duration = 3
    end
end

function modifier_wet:OnIntervalThink()
    if not IsServer() then return end

    -- if standing in the river
    if self:GetParent():GetAbsOrigin().z <=0.5 then
        self.natural_stacks = 2
        self.natural_linger = 2
    elseif self.natural_linger > 0 then
        self.natural_linger = self.natural_linger - 0.1
    else
        self.natural_stacks = 0
    end
    if self.spell_stacks > 0 then
        if self.spell_stack_duration > 0 then
            self.spell_stack_duration = self.spell_stack_duration - 0.1
        else
            self.spell_stacks = self.spell_stacks - 1
        end
    end

    self:SetStackCount(self.natural_stacks + self.spell_stacks)

    -- if unit is burning, then purge that
    local mod_burning = self:GetParent():FindModifierByName("modifier_conflagration")
    if mod_burning then
        self:GetParent():RemoveModifierByName("modifier_conflagration")
    end
end