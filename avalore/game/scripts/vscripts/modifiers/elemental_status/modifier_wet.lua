modifier_wet = class({})

function modifier_wet:IsHidden()
--     return false
    --return (self:GetAbility() == nil and self:GetStackCount() <= 0)
    return (self:GetStackCount() <= 0)
end
function modifier_wet:IsDebuff()        return true end
function modifier_wet:IsPurgable()      return false end
function modifier_wet:RemoveOnDeath()   return false end

-- function modifier_wet:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE -- allow stacking with self
-- end


function modifier_wet:GetTexture()
    return "elemental_status/wet"
end

function modifier_wet:OnCreated(kv)
    

    print("Created modifier_wet for " .. self:GetParent():GetUnitName())

    self.spell_stacks = 0 -- stacks coming from spells that hit the owner
    self.spell_stack_duration = 0
    self.natural_stacks = 0 -- basically just from being in the water
    self.natural_linger = 0
    --if kv.spell then 
    --if self:GetAbility() or self:GetCaster() then

    -- self.spells_stacks = 1
    -- self.spell_stack_duration = 3

    --end
    -- if self:GetAbility() and self:GetAbility():GetName() == "item_essence_of_water" then
    --     print("Came from Essence of Water")
    --     --self.override_linger = self:GetAbility():GetSpecialValueFor("douse_duration")
    --     self.spells_stacks = 1
    --     self.spell_stack_duration = self:GetAbility():GetSpecialValueFor("douse_duration")
    --     print("DUR = " .. tostring(self.spell_stack_duration))
    -- end

    --if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_wet:AddSpellDur(spell_stack, spell_dur)
    print("modifier_wet:AddSpellDur(spell_stack, spell_dur)")
    -- self.spell_stacks = self.spell_stacks + spell_stack
    -- self.spell_stack_duration = self.spell_stack_duration + spell_dur
    if spell_stack > self.spell_stacks then
        self.spell_stacks = spell_stack
    end

    if spell_dur > self.spell_stack_duration then
        self.spell_stack_duration = spell_dur
    end
end

-- if some spell douses a character, then add a stack
-- don't impact current timer
function modifier_wet:OnRefresh(kv)
    --if not IsServer() then return end

    if IsServer() then
        print("[SERVER] modifier_wet:OnRefresh(kv)")
    else
        print("[CLIENT] modifier_wet:OnRefresh(kv)")
    end

    if kv.spell_stacks and kv.spell_dur then
        self:AddSpellDur(kv.spell_stacks, kv.spell_dur)
    end

    -- self.spell_stacks = self.spell_stacks + 1
    -- if self.spell_stack_duration == 0 then
    --     self.spell_stack_duration = 3
    -- end
end

function modifier_wet:OnIntervalThink()
    --if not IsServer() then return end

    -- if standing in the river
    if self:GetParent():GetAbsOrigin().z <= 0.5 or self:GetParent():HasModifier("modifier_rainstorm_aura") then
        --print("in water")
        self.natural_stacks = 2
        self.natural_linger = 2
    -- elseif self.override_linger then
    --     self.natural_linger = self.override_linger
    --     self.override_linger = nil
    elseif self.natural_linger > 0 then
        self.natural_linger = self.natural_linger - 0.1
    else
        self.natural_stacks = 0
    end

    if self.spell_stacks > 0 then
        if self.spell_stack_duration > 0 then
            self.spell_stack_duration = self.spell_stack_duration - 0.1
            print("Spell Stack Dur => " .. tostring(self.spell_stack_duration))
        else
            self.spell_stacks = self.spell_stacks - 1
        end
    end

    --print("Setting Stack Count to: " .. tostring(self.natural_stacks + self.spell_stacks))
    self:SetStackCount(self.natural_stacks + self.spell_stacks)
    -- if self:GetStackCount() > 0 then
    --     print("We have stacks!")
    -- end

    -- if this is an ability then we need to destroy this if it expired
    -- if self:GetAbility() then
    --     if self.natural_stacks == 0 and self.spell_stacks == 0 and self.natural_linger == 0 and self.spell_stack_duration == 0 then
    --         self:Destroy()
    --     end
    -- end

    -- if unit is burning, then purge that
    if not IsServer() then return end
    local mod_burning = self:GetParent():FindModifierByName("modifier_conflagration")
    if mod_burning then
        self:GetParent():RemoveModifierByName("modifier_conflagration")
    end
end