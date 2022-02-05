if Constants == nil then
    Constants = {}
end

MELEE_ATTACK_RANGE = 150

--[[ 
    Definitions for a bunch of keys used throughout so the values
    can be controlled from one central location and updated (or 
    modified for debugging) with ease.
--]]


-- ==================================
-- ROUND START TIMES (IN SECONDS)
-- ==================================

Constants.TIME_ROUND_1_START = 0     --00 min
Constants.TIME_ROUND_2_START = 600   --10 min
Constants.TIME_ROUND_3_START = 1200  --20 min
Constants.TIME_ROUND_4_START = 1800  --30 min

-- ==================================
-- SPAWNER KEY NAMES
-- ==================================

Constants.KEY_RADIANT_TOP       = "Radiant_Top"
Constants.KEY_RADIANT_MIDA      = "Radiant_MidA"
Constants.KEY_RADIANT_MIDB      = "Radiant_MidB"
Constants.KEY_RADIANT_BOT       = "Radiant_Bot"
Constants.KEY_RADIANT_SHELFTOP  = "Radiant_ShelfTop"
Constants.KEY_RADIANT_SHELFBOT  = "Radiant_ShelfBot"

Constants.KEY_DIRE_TOP          = "Dire_Top"
Constants.KEY_DIRE_MIDA         = "Dire_MidA"
Constants.KEY_DIRE_MIDB         = "Dire_MidB"
Constants.KEY_DIRE_BOT          = "Dire_Bot"
Constants.KEY_DIRE_SHELFTOP     = "Dire_ShelfTop"
Constants.KEY_DIRE_SHELFBOT     = "Dire_ShelfBot"

-- used for locations, not spawning
-- Constants.KEY_RADIANT_MID       = "Radiant_Mid"
-- Constants.KEY_DIRE_MID          = "Dire_Mid"

--[[
    RADIANT BASE ENTITIES
    rax_ranged_radiant_mid
    rax_melee_radiant_mid

    rax_ranged_radiant_top
    rax_melee_radiant_top

    rax_ranged_radiant_bot
    rax_melee_radiant_bot

    ancient_radiant
    fountain_radiant

    RADIANT TOWER ENTITIES

    tower_radiant_top_1
    tower_radiant_top_2
    tower_radiant_top_3
    tower_radiant_top_4

    tower_radiant_bot_1
    tower_radiant_bot_2
    tower_radiant_bot_3
    tower_radiant_bot_4

    tower_radiant_mid_1
    tower_radiant_mid_2
    tower_radiant_mid_3
--]]

--[[
    DIRE BASE ENTITIES

    rax_ranged_dire_mid
    rax_melee_dire_mid

    rax_ranged_dire_bot
    rax_melee_dire_bot

    rax_ranged_dire_top
    rax_melee_dire_top

    ancient_dire
    fountain_dire

    DIRE TOWER ENTITIES

    tower_dire_top_2
    tower_dire_top_1
    tower_dire_top_3
    tower_dire_top_4

    tower_dire_bot_1
    tower_dire_bot_2
    tower_dire_bot_3
    tower_dire_bot_4

    tower_dire_mid_1
    tower_dire_mid_2
    tower_dire_mid_3
--]]

--[[
    OBJECTIVE ENTITIES
    radiant_outpost // radiant_outpost_trigger
]]


-- ==================================
-- MODELS
-- ==================================

---CONSTANTS.RADI_FLAG_BASE = 

-- ==================================
-- FLAGS
-- ==================================
-- NOTE: These are generic in case they need to change down the line
--       If these get updated, also do so in npc_items_custom.txt

OBJECTIVE_FLAG_PARTICLE_CAPTURE = "particles/customgames/capturepoints/cp_wood.vpcf"

-- Orange Flag ==> Morale (Radiant)
OBJECTIVE_FLAG_SPAWNER_A    = "spawner_flag_a"
OBJECTIVE_FLAG_ITEM_A       = "item_avalore_flag_a"
OBJECTIVE_FLAG_MODEL_A      = "models/flag_tintable.vmdl" --"models/props_teams/bannerb_dire.vmdl" --"maps/reef_assets/props/teams/banner_radiant_reef.vmdl"

-- Red Flag ==> Morale (Dire)
OBJECTIVE_FLAG_SPAWNER_B    = "spawner_flag_b"
OBJECTIVE_FLAG_ITEM_B       = "item_avalore_flag_b"
OBJECTIVE_FLAG_MODEL_B      = "models/flag_tintable.vmdl" --"models/props_teams/bannerb_dire.vmdl" --"maps/journey_assets/props/teams/banner_journey_radiant.vmdl"

-- Yellow Flag ==> Agility
OBJECTIVE_FLAG_SPAWNER_C    = "spawner_flag_c"
OBJECTIVE_FLAG_ITEM_C       = "item_avalore_flag_c"
OBJECTIVE_FLAG_MODEL_C      = "models/flag_tintable.vmdl" --"models/props_teams/bannerb_dire.vmdl" --"maps/journey_assets/props/teams/banner_journey_dire_small.vmdl"

-- Purple Flag ==> Arcane
OBJECTIVE_FLAG_SPAWNER_D    = "spawner_flag_d"
OBJECTIVE_FLAG_ITEM_D       = "item_avalore_flag_d"
OBJECTIVE_FLAG_MODEL_D      = "models/flag_tintable.vmdl" --"models/props_teams/bannerb_dire.vmdl" --"maps/reef_assets/props/teams/banner_dire_reef_small.vmdl"

-- Blue Flag ==> Regrowth
OBJECTIVE_FLAG_SPAWNER_E    = "spawner_flag_e"
OBJECTIVE_FLAG_ITEM_E       = "item_avalore_flag_e"
OBJECTIVE_FLAG_MODEL_E      = "models/flag_tintable.vmdl" --"models/props_teams/bannerb_dire.vmdl"

OBJECTIVE_FLAG_SPAWNERS = {OBJECTIVE_FLAG_SPAWNER_A, OBJECTIVE_FLAG_SPAWNER_B, OBJECTIVE_FLAG_SPAWNER_C, OBJECTIVE_FLAG_SPAWNER_D, OBJECTIVE_FLAG_SPAWNER_E}


-- ==================================
-- OTHER OBJECTIVES
-- ==================================

OBJECTIVE_RADI_BASE = "npc_dota_goodguys_fort"
OBJECTIVE_DIRE_BASE = "npc_dota_badguys_fort"

OBJECTIVE_GEM_ITEM          = "item_avalore_summoning_gem"

ROUND1_WISP_UNIT = "npc_avalore_quest_wisp"

ROUND3_BOSS_UNIT = "npc_avalore_gem_boss"
ROUND3_GEM_ACTIVATE_DIRE_SIDE = "trigger_dire_gem_activate" --radi bring theirs here
ROUND3_GEM_ACTIVATE_RADI_SIDE = "trigger_radi_gem_activate" --dire bring theirs here

ROUND4_TOWER_TRIGGERS = {}
ROUND4_TOWER_TRIGGERS.radi_a = "trigger_radi_round4_tower_a"
ROUND4_TOWER_TRIGGERS.radi_b = "trigger_radi_round4_tower_b"
ROUND4_TOWER_TRIGGERS.dire_a = "trigger_dire_round4_tower_a"
ROUND4_TOWER_TRIGGERS.dire_b = "trigger_dire_round4_tower_b"
ROUND4_TOWER_UNIT = "npc_avalore_building_round4_tower"

ROUND4_SPAWNER_BOSS = "spawner_map_center"
ROUND4_BOSS_UNIT = "npc_avalore_round4_boss"
ROUND4_MELEE_CREEPS = "npc_avalore_round4_melee_creep"

-- ==================================
-- SCORE RELATED
-- ==================================

SCORE_DIVIDEND_KILLS    = 1 --ie. 1 kill = 1 point
SCORE_DIVIDEND_ASSISTS  = 10
SCORE_DIVIDEND_LASTHITS = 100

SCORE_DIVIDEND_ROUND2 = 30 -- 30sec intervals = 1 point
SCORE_MULTIPLIER_ROUND2_OUTPOST = 15

SCORE_MULTIPLIER_T1 = 10
SCORE_MULTIPLIER_T2 = 10
SCORE_MULTIPLIER_T3 = 10
SCORE_MULTIPLIER_T4 = 10

SCORE_MULTIPLIER_RAX_MELEE  = 15
SCORE_MULTIPLIER_RAX_RANGED = 15

SCORE_MULTIPLIER_WISP = 3

SCORE_MULTIPLIER_FLAG = 15

SCORE_MULTIPLIER_BOSS_ROUND3 = 30

SCORE_MULTIPLIER_BOSS_ROUND4 = 50


-- ==================================
-- MODIFIERS
-- ==================================

-- this is to make it easy to find instances of them by searching the code
IDENTIFIER_FLAG_A = "a"
IDENTIFIER_FLAG_B = "b"
IDENTIFIER_FLAG_C = "c"
IDENTIFIER_FLAG_D = "d"
IDENTIFIER_FLAG_E = "e"

-- in: game/../resource/flash3/images
MODIFIER_FLAG_MORALE_TEXTURE = "morale_aura"

MODIFIER_FLAG_CARRY_NAME = "modifier_item_flag_carry"

MODIFIER_FLAG_MORALE_NAME   = "modifier_flag_morale"
MODIFIER_FLAG_AGILITY_NAME  = "modifier_flag_agility"
MODIFIER_FLAG_ARCANE_NAME   = "modifier_flag_arcane"
MODIFIER_FLAG_REGROWTH_NAME = "modifier_flag_regrowth"

MODIFIER_ROUND1_WISP_REGEN = "modifier_wisp_regen"


-- ==========================================
-- MESSAGING RELATED
-- ==========================================

MESSAGE_EVENT_BROADCAST = "broadcast_message"

-- MESSAGE TYPES
MSG_TYPE_NOTIFY = 0
MSG_TYPE_ERROR = 1
--MSG_TYPE_OBJECTIVE = 2 -- TODO: Implement nice coloring for this

-- ==========================================
-- ITEM SLOT
-- ==========================================

AVALORE_ITEM_SLOT_HEAD = 0
AVALORE_ITEM_SLOT_CHEST = 1
AVALORE_ITEM_SLOT_BACK = 2
AVALORE_ITEM_SLOT_HANDS = 3
AVALORE_ITEM_SLOT_FEET = 4
AVALORE_ITEM_SLOT_TRINKET = 5
-- Backpack
AVALORE_ITEM_SLOT_MISC = 30 -- this is used when we don't need to reference the exact slot
AVALORE_ITEM_SLOT_MISC1 = 6
AVALORE_ITEM_SLOT_MISC2 = 7
AVALORE_ITEM_SLOT_MISC3 = 8
-- Stash
AVALORE_ITEM_SLOT_STASH1 = 9
AVALORE_ITEM_SLOT_STASH2 = 10
AVALORE_ITEM_SLOT_STASH3 = 11
AVALORE_ITEM_SLOT_STASH4 = 12
AVALORE_ITEM_SLOT_STASH5 = 13
AVALORE_ITEM_SLOT_STASH6 = 14
-- Misc
AVALORE_ITEM_SLOT_TP = 15
AVALORE_ITEM_SLOT_NEUT = 16
-- TEMP
AVALORE_ITEM_SLOT_TEMP = 31