ability_summon_storm = class({})

LinkLuaModifier("modifier_storm_cloud", "heroes/zeus/modifier_storm_cloud.lua", LUA_MODIFIER_MOTION_NONE)

function ability_summon_storm:GetAOERadius()
	return self:GetSpecialValueFor("cloud_radius")
end

function ability_summon_storm:OnSpellStart()
    if not IsServer() then return end

    self.target_point 			= self:GetCursorPosition()
    local caster 				= self:GetCaster()
    
    local cloud_bolt_interval 	= self:GetSpecialValueFor("cloud_bolt_interval")
    local cloud_duration 		= self:GetSpecialValueFor("cloud_duration")
    local cloud_radius 			= self:GetSpecialValueFor("cloud_radius")

    EmitSoundOnLocationWithCaster(self.target_point, "Hero_Zuus.Cloud.Cast", caster)
    
    --self.storm_unit = CreateUnitByName("npc_dota_zeus_cloud", Vector(self.target_point.x, self.target_point.y, 450), false, caster, nil, caster:GetTeam())
    self.storm_unit = CreateUnitByName("avalore_unit_storm_cloud", Vector(self.target_point.x, self.target_point.y, 450), false, caster, nil, caster:GetTeam())

    self.storm_unit:SetControllableByPlayer(caster:GetPlayerID(), true)
    self.storm_unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
    self.storm_unit:SetBaseMoveSpeed(400)
    self.storm_unit:SetModelScale(0.7)
    --self.storm_unit:AddNewModifier(self.storm_unit, self, "modifier_phased", {}) -- built-in dota2 modifier
    self.storm_unit:AddNewModifier(caster, self, "modifier_storm_cloud", {duration = cloud_duration, cloud_bolt_interval = cloud_bolt_interval, cloud_radius = cloud_radius})
    self.storm_unit:AddNewModifier(caster, nil, "modifier_kill", {duration = cloud_duration}) -- built-in dota2 modifier
end