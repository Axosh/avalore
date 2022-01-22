ability_consume_goat = class({})

LinkLuaModifier("modifier_consume_goat", "heroes/thor/modifier_consume_goat.lua", LUA_MODIFIER_MOTION_NONE)

function ability_consume_goat:OnSpellStart()
    local caster = self:GetCaster()

    if not IsServer() then return end
    local goat_count = caster:FindModifierByName("modifier_toothgnashers_counter")

    if goat_count:GetStackCount() > 0 then
        self.modifier = caster:AddNewModifier(caster, self, "modifier_consume_goat", {duration = self:GetChannelTime()})
        goat_count:DecrementStackCount()
    else
        self:EndCooldown()
    end
end

function ability_consume_goat:OnChannelFinish(bInstrrupted)
    if self.modifier then
        self.modifier:Destroy()
        self.modifier = nil
    end
end