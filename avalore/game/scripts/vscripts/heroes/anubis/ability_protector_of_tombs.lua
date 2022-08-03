ability_protector_of_tombs = ability_protector_of_tombs or class({})

-- TALENTS
LinkLuaModifier("modifier_talent_great_pyramid",    		  "scripts/vscripts/heroes/anubis/modifier_talent_great_pyramid.lua", LUA_MODIFIER_MOTION_NONE)


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
    tombstone:StartGesture(ACT_DOTA_LOADOUT)
    tombstone:SetOwner(caster)
	tombstone:SetBaseMaxHealth(tombstone_health + self:GetCaster():FindTalentValue("talent_great_pyramid", "bonus_health")) 
	tombstone:SetMaxHealth(tombstone_health + self:GetCaster():FindTalentValue("talent_great_pyramid", "bonus_health"))
	tombstone:SetHealth(tombstone_health + self:GetCaster():FindTalentValue("talent_great_pyramid", "bonus_health"))
    tombstone:SetModelScale(tombstone:GetModelScale() + self:GetCaster():FindTalentValue("talent_great_pyramid", "bonus_model_size"))
    tombstone:GetAbilityByIndex(0):SetLevel(1)
    tombstone:GetAbilityByIndex(1):SetLevel(1)
    tombstone:AddNewModifier(self:GetCaster(), nil, "modifier_mummy", {duration = duration})

    if self:GetCaster():HasTalent("talent_great_pyramid") then
        print("Has Modifier")
        tombstone:AddNewModifier(tombstone, nil, "modifier_talent_great_pyramid", {duration = duration})
    end

    -- TODO: add aura modifier
    GridNav:DestroyTreesAroundPoint(target_point, trees_destroy_radius, true)
end