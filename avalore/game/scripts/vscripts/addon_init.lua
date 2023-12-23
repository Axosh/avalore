-- load in stuff for client-side
require("references")
require("constants")
--require( "spawners" )

if IsClient() then	-- Load clientside utility lib
	require("client_extension")

	-- as of like August or September 2023, a bunch of these need to be laoded for client side
	-- now too

	-- ==========================================================
	-- From: addon_game_mode.lua
	-- ==========================================================
	LinkLuaModifier( "modifier_avalore_not_auto_attackable", "scripts/vscripts/modifiers/modifier_avalore_not_auto_attackable.lua", LUA_MODIFIER_MOTION_NONE )

	LinkLuaModifier( "modifier_unselectable", MODIFIER_UNSELECTABLE, LUA_MODIFIER_MOTION_NONE )
	-- LinkLuaModifier( "modifier_capturable", MODIFIER_CAPTURABLE, LUA_MODIFIER_MOTION_NONE )
	-- LinkLuaModifier( "modifier_invuln_tower_based", MODIFIER_INVULN_TOWER_BASED, LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_wearable", "scripts/vscripts/modifiers/modifier_wearable", LUA_MODIFIER_MOTION_NONE )
	-- LinkLuaModifier( "modifier_knockback", "scripts/vscripts/modifiers/modifier_knockback.lua", LUA_MODIFIER_MOTION_BOTH )

	-- ==========================================================
	-- From: events.lua
	-- ==========================================================
	LinkLuaModifier( "modifier_inventory_manager", "scripts/vscripts/modifiers/modifier_inventory_manager", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_pregame_bubble", "scripts/vscripts/modifiers/modifier_pregame_bubble.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( MODIFIER_ROUND1_WISP_REGEN, REF_MODIFIER_ROUND1_WISP_REGEN, LUA_MODIFIER_MOTION_NONE )

	-- LinkLuaModifier( "modifier_avalore_obs_ward", "scripts/vscripts/modifiers/modifier_avalore_obs_ward", LUA_MODIFIER_MOTION_NONE )
	-- LinkLuaModifier( "modifier_avalore_sent_ward", "scripts/vscripts/modifiers/modifier_avalore_sent_ward", LUA_MODIFIER_MOTION_NONE )
	-- LinkLuaModifier( "modifier_avalore_merc_building", "scripts/vscripts/modifiers/modifier_avalore_merc_building", LUA_MODIFIER_MOTION_NONE )

	-- Faction Stuff
	LinkLuaModifier("modifier_faction_forest",     "modifiers/faction/modifier_faction_forest.lua",       LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_water",      "modifiers/faction/modifier_faction_water.lua",        LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_olympians",  "modifiers/faction/modifier_faction_olympians.lua",    LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_storm",  	   "modifiers/faction/modifier_faction_storm.lua",    LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_creator",    "modifiers/faction/modifier_faction_creator.lua",    LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_mesoamerican",    "modifiers/faction/modifier_faction_mesoamerican.lua",    LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_psychopomp",    "modifiers/faction/modifier_faction_psychopomp.lua",    LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_psychopomp_helper",    "modifiers/faction/modifier_faction_psychopomp.lua",    LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_sharpshooter",    "modifiers/faction/modifier_faction_sharpshooter.lua",    LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_demigod",    "modifiers/faction/modifier_faction_demigod.lua",    LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_faction_middle_kingdom",    "modifiers/faction/modifier_faction_middle_kingdom.lua",    LUA_MODIFIER_MOTION_NONE)

	-- Talents that can be activated later
	-- LinkLuaModifier("modifier_talent_static_field", "heroes/zeus/modifier_talent_static_field.lua",                    LUA_MODIFIER_MOTION_NONE)
	-- LinkLuaModifier("modifier_synergy", 			"scripts/vscripts/heroes/gilgamesh/modifier_synergy.lua",          LUA_MODIFIER_MOTION_NONE)
	-- LinkLuaModifier("modifier_talent_endurance",    "scripts/vscripts/heroes/gilgamesh/modifier_talent_endurance.lua", LUA_MODIFIER_MOTION_NONE)
	-- LinkLuaModifier("modifier_talent_fortify",      "scripts/vscripts/heroes/gilgamesh/modifier_talent_fortify.lua",   LUA_MODIFIER_MOTION_NONE)

	-- Inventory Debug
	--LinkLuaModifier( "modifier_wearable", "scripts/vscripts/modifiers/modifier_wearable", LUA_MODIFIER_MOTION_NONE )

	-- Elemental
	LinkLuaModifier( "modifier_wet", "scripts/vscripts/modifiers/elemental_status/modifier_wet.lua", LUA_MODIFIER_MOTION_NONE )

	-- From: quests
	LinkLuaModifier( "modifier_quest_wisp", "scripts/vscripts/modifiers/modifier_quest_wisp.lua", LUA_MODIFIER_MOTION_NONE )

	--Spawners:Init()
end
