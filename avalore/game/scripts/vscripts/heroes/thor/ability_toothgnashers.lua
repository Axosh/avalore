ability_toothgnashers = class({})

LinkLuaModifier("modifier_toothgnashers_counter", "heroes/thor/modifier_toothgnashers_counter.lua", LUA_MODIFIER_MOTION_NONE)
-- TALENTS
LinkLuaModifier("modifier_talent_replenish", "heroes/thor/modifier_talent_replenish.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_replenish_counter", "heroes/thor/modifier_replenish_counter.lua", LUA_MODIFIER_MOTION_NONE)


function ability_toothgnashers:OnCreated()
    if self:GetCaster():HasTalent("talent_replenish") then
        self:SetupStacks()
    end
end

function ability_toothgnashers:GetAbilityTextureName()
    --print(tostring(self:GetCaster()))
    if self:GetCaster():HasTalent("talent_replenish") then
        --return ("thor/toothgnashers" .. tostring(self.replenish_stacks));
        return ("thor/toothgnashers" .. tostring(self:GetCaster():GetModifierStackCount("modifier_replenish_counter", nil)))
    else
        return "thor/toothgnashers"
    end
end

-- NOTE: OnSpellStart only fires on server-side
function ability_toothgnashers:OnSpellStart()
    --if not IsServer then return end

    local caster = self:GetCaster()

    self.num_goats = 2
    self.goat_model = "models/items/hex/sheep_hex/sheep_hex_gold.vmdl"

    if self.replenish_stacks then
        print("Replenish Stacks => " .. tostring(self.replenish_stacks))
    end

    -- if we have the modifier, then check to see if we can add a stack
    if caster:HasModifier("modifier_toothgnashers_counter") then
        if caster:FindModifierByName("modifier_toothgnashers_counter"):GetStackCount() < self.num_goats then
            caster:FindModifierByName("modifier_toothgnashers_counter"):IncrementStackCount()
            self:PlayEffects()

            if self:GetCaster():HasTalent("talent_replenish") and (self:GetCaster():GetModifierStackCount("modifier_replenish_counter", nil)) > 0 then
                self:EndCooldown()
                --self.replenish_stacks = self.replenish_stacks - 1
                self.replenish_counter:DecrementStackCount()
                self:MarkAbilityButtonDirty()
            end
        else
            -- couldn't cast - refund
            self:RefundManaCost()
            self:EndCooldown()
            return
        end
    else
        -- first cast - give him both goats
        local mod = caster:AddNewModifier(caster, self, "modifier_toothgnashers_counter", {})
        mod:IncrementStackCount()
        self:PlayEffects()
    end
end

function ability_toothgnashers:SetupStacks()
    if not IsServer() then return end
    self.replenish_stacks_max   = self:GetCaster():FindTalentValue("talent_replenish", "max_stacks")
    --self.replenish_stacks       = self:GetCaster():FindTalentValue("talent_replenish", "max_stacks")
    --self.replenish_counter      = self:GetCaster():FindModifierByName("modifier_replenish_counter")
    if IsServer() then
        self.replenish_counter      = self:GetCaster():FindModifierByName("modifier_replenish_counter")
        self.replenish_counter:SetStackCount(self.replenish_stacks_max)
        print("Set Counter to .. " ..  tostring(self.replenish_stacks_max))
    end
    self.replenish_timer        = 0 -- start counting up towards the ability's cooldown

    -- reset cooldown (server-side only function)
    if IsServer() then
        self:EndCooldown()
    end
    
    print ("CD => " .. tostring(self:GetCooldown(self:GetLevel())))
    --self:StartIntervalThink(1)
    --self:SetContextThink("ReplenishThinker", ReplenishThinker, 1)
    local think_interval = 1
    self:GetCaster():SetContextThink( DoUniqueString("ReplenishThinker"), function ( )
        -- while we're not maxed out on stacks, count up
        if self.replenish_counter:GetStackCount() < self.replenish_stacks_max then
            self.replenish_timer = self.replenish_timer + 1
            print("Replenish Timer = " .. tostring(self.replenish_timer))
        end

        -- if we've surpassed the cooldown timer, add a stack and reset the timer
        if self.replenish_timer > self:GetCooldown(self:GetLevel()) then
            --self.replenish_stacks = self.replenish_stacks + 1
            if IsServer() then
                self.replenish_counter:IncrementStackCount()
            end
            print("Replenish Stack Added")
            self.replenish_timer = 0
        end
        return think_interval
    end, think_interval)
end

--function ability_toothgnashers:OnIntervalThink()
-- function ReplenishThinker(self)

--     -- while we're not maxed out on stacks, count up
--     if self.replenish_stacks < self.replenish_stacks_max then
--         self.replenish_timer = self.replenish_timer + 1
--         print("Replenish Timer = " .. tostring(self.replenish_timer))
--     end

--     -- if we've surpassed the cooldown timer, add a stack and reset the timer
--     if self.replenish_timer > self:GetCooldown(self:GetLevel()) then
--         self.replenish_stacks = self.replenish_stacks + 1
--         print("Replenish Stack Added")
--         self.replenish_timer = 0
--     end

-- end

function ability_toothgnashers:PlayEffects()
    local sound_cast = "Hero_ShadowShaman.SheepHex.Target"

    EmitSoundOn( sound_cast, self:GetCaster() )
end

-- function ability_toothgnashers:GetAssociatedSecondaryAbilities()
--     return ""

function ability_toothgnashers:OnUpgrade()
   if not self.consume then
       self.consume = self:GetCaster():FindAbilityByName("ability_consume_goat")
   end

   self.consume:UpgradeAbility(true)
   --TODO: Refresh modifier bonus
end