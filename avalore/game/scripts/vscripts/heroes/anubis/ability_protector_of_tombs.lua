ability_protector_of_tombs = ability_protector_of_tombs or class({})

function ability_protector_of_tombs:OnSpellStart()
    local caster = self:GetCaster()
	local ability = self
	local target_point = ability:GetCursorPosition()

    -- Spawn Tomb
    local cast_sound = "Hero_Undying.Tombstone"
    local tombstone_health      = ability:GetSpecialValueFor("tombstone_health")
	local duration              = ability:GetSpecialValueFor("duration")
	local trees_destroy_radius  = ability:GetSpecialValueFor("trees_destroy_radius")

    EmitSoundOnLocationWithCaster(target_point, cast_sound, caster)

    local tombstone = CreateUnitByName("npc_avalore_tomb", target_point, true, caster, caster, caster:GetTeamNumber())
    tombstone:SetOwner(caster)
	tombstone:SetBaseMaxHealth(tombstone_health)
	tombstone:SetMaxHealth(tombstone_health)
	tombstone:SetHealth(tombstone_health)

    -- TODO: add aura modifier
    GridNav:DestroyTreesAroundPoint(target_point, trees_destroy_radius, true)
end