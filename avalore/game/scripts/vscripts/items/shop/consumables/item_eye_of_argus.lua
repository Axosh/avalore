item_eye_of_argus = class({})

LinkLuaModifier( "modifier_generic_custom_indicator", "scripts/vscripts/modifiers/modifier_generic_custom_indicator", LUA_MODIFIER_MOTION_NONE )

function item_eye_of_argus:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET
end



function item_eye_of_argus:CastFilterResultLocation(vLoc)
    if IsClient() then
        if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( vLoc )
		end
	end

	return UF_SUCCESS
end


-- Reference Code: https://github.com/SteamDatabase/GameTracking-Dota2/blob/master/game/dota_addons/winter2022/scripts/vscripts/modifiers/gameplay/modifier_building_candy_bucket.lua#L280
function item_eye_of_argus:CreateCustomIndicator()
    local particle = "particles/ui_mouseactions/range_finder_generic_ward_aoe.vpcf"
    local radius = self:GetSpecialValueFor("vision_range")
    self.effect_indicator = ParticleManager:CreateParticle( particle, PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl( self.effect_indicator, 0, self:GetCaster():GetAbsOrigin() )
    --ParticleManager:SetParticleControl( self.effect_indicator, 1, Vector( radius, radius, radius ) )
    --ParticleManager:SetParticleControl( self.effect_indicator, 2, Vector( radius, radius, radius ) )
    ParticleManager:SetParticleControl( self.effect_indicator, 1, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl( self.effect_indicator, 2, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl( self.effect_indicator, 3, Vector( radius, radius, radius ))
    ParticleManager:SetParticleControl( self.effect_indicator, 6, Vector( 250, 0, 60 ) );
    ParticleManager:SetParticleControl( self.effect_indicator, 10, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl( self.effect_indicator, 11, Vector( radius, radius, radius ))

end

function item_eye_of_argus:UpdateCustomIndicator( loc )
	-- update particle position
	ParticleManager:SetParticleControl( self.effect_indicator, 0, loc )
    ParticleManager:SetParticleControl( self.effect_indicator, 1, loc )
    ParticleManager:SetParticleControl( self.effect_indicator, 2, loc )
    ParticleManager:SetParticleControl( self.effect_indicator, 10, loc )
end

function item_eye_of_argus:DestroyCustomIndicator()
	-- destroy particle
	ParticleManager:DestroyParticle( self.effect_indicator, false )
	ParticleManager:ReleaseParticleIndex( self.effect_indicator )
end

function item_eye_of_argus:GetIntrinsicModifierName()
	return "modifier_generic_custom_indicator"
end

function item_eye_of_argus:OnSpellStart()
    local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorPosition()
    local cast_sound = "DOTA_Item.ObserverWard.Activate"

    -- Ability specials
	local lifetime = ability:GetSpecialValueFor("lifetime")

    -- model
    --local ward = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wards/skywrath_sentinel/skywrath_sentinel.vmdl"})
    local ward = CreateUnitByName("npc_avalore_eye_of_argus", target, false, nil, nil, caster:GetTeam())
    local wearable = "models/items/death_prophet/ti9_cache_dp_peacock_priest_skirt/ti9_cache_dp_peacock_priest_skirt.vmdl"
    local cosmetic = CreateUnitByName("wearable_dummy", ward:GetAbsOrigin(), false, nil, nil, ward:GetTeam())
    cosmetic:SetOriginalModel(wearable)
    cosmetic:SetModel(wearable)
    cosmetic:AddNewModifier(nil, nil, "modifier_wearable", {})
    cosmetic:SetParent(unit, nil)
    cosmetic:SetOwner(unit)
    --cosmetic:FollowEntity(unit, true)
    cosmetic:SetForwardVector(Vector(0, -1, 0))

    ward:AddNewModifier(caster, nil, "modifier_item_observer_ward", {duration = lifetime})

    -- Emit sound
	EmitSoundOn(cast_sound, ward)

end