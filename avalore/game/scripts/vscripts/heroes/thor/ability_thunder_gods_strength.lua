ability_thunder_gods_strength = class({})

LinkLuaModifier("modifier_thunder_gods_strength_buff", "heroes/thor/modifier_thunder_gods_strength_buff.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_thunder_gods_strength_observer", "heroes/thor/modifier_thunder_gods_strength_observer.lua", LUA_MODIFIER_MOTION_NONE)

-- Talents
LinkLuaModifier("modifier_talent_brute_strength", "heroes/thor/modifier_talent_brute_strength.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_toughness", "heroes/thor/modifier_talent_toughness.lua", LUA_MODIFIER_MOTION_NONE)


function ability_thunder_gods_strength:OnSpellStart()
    EmitSoundOn( "Hero_Dawnbreaker.Solar_Guardian.BlastOff", self:GetCaster() )
    if not IsServer() then return end
    
    self:GetCaster():AddNewModifier(self:GetCaster(),
                                    self,
                                    "modifier_thunder_gods_strength_buff",
                                    {duration = self:GetSpecialValueFor("duration")}
                                    );

    local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( nFXIndex )

    --EmitSoundOn( "Hero_Sven.GodsStrength", self:GetCaster() )

    -- if not self:GetCaster():HasModifier("modifier_thunder_gods_strength_observer") then
    --     self:GetCaster():AddNewModifier(self:GetCaster(),
    --                                 self,
    --                                 "modifier_thunder_gods_strength_observer",
    --                                 {}
    --                                 );
    -- end
end