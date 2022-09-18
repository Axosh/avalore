item_fairy_dust = class({})

LinkLuaModifier( "modifier_avalore_flying", "modifiers/modifier_avalore_flying.lua", LUA_MODIFIER_MOTION_NONE )

function item_fairy_dust:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_avalore_flying", {duration = self:GetSpecialValueFor("flying_time")})
end


-- function SkyWalk(ability)

-- end