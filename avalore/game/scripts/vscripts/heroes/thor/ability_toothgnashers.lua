ability_toothgnashers = class({})

LinkLuaModifier("modifier_toothgnashers_counter", "heroes/thor/modifier_toothgnashers_counter.lua", LUA_MODIFIER_MOTION_NONE)

function ability_toothgnashers:OnSpellStart()
    if not IsServer then return end

    local caster = self:GetCaster()

    self.num_goats = 2
    self.goat_model = "models/items/hex/sheep_hex/sheep_hex_gold.vmdl"

    -- if we have the modifier, then check to see if we can add a stack
    if caster:HasModifier("modifier_toothgnashers_counter") then
        if caster:HasModifier("modifier_toothgnashers_counter"):GetStackCount() < self.num_goats then
            caster:FindModifierByName("modifier_toothgnashers_counter"):IncrementStackCount()
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
    end
end