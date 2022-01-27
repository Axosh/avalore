ability_thunder_gods_strength = class({})

LinkLuaModifier("modifier_thunder_gods_strength_buff", "heroes/thor/modifier_thunder_gods_strength_buff.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_thunder_gods_strength_observer", "heroes/thor/modifier_thunder_gods_strength_observer.lua", LUA_MODIFIER_MOTION_NONE)


function ability_thunder_gods_strength:OnSpellStart()
    if not IsServer() then return end
    
    self:GetCaster():AddNewModifier(self:GetCaster(),
                                    self,
                                    "modifier_thunder_gods_strength_buff",
                                    {duration = self:GetSpecialValueFor("duration")}
                                    );

    -- if not self:GetCaster():HasModifier("modifier_thunder_gods_strength_observer") then
    --     self:GetCaster():AddNewModifier(self:GetCaster(),
    --                                 self,
    --                                 "modifier_thunder_gods_strength_observer",
    --                                 {}
    --                                 );
    -- end
end