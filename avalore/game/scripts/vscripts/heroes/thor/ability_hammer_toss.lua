ability_hammer_toss = class({})

function ability_hammer_toss:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_grounded.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_burning_trail.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_trail.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf", context )
end

function ability_hammer_toss:OnSpellStart()
	local caster 	= self:GetCaster()
	local target 	= self:GetVectorTargetPosition()
	local radius 	= self:GetSpecialValueFor( "projectile_radius" )
	local speed 	= self:GetSpecialValueFor( "projectile_speed" )
	local distance 	= self:GetSpecialValueFor( "range" )
end