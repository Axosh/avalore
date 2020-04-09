if Constants == nil then
    Constants = {}
end

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
OBJECTIVE_FLAG_MODEL_A      = "maps/reef_assets/props/teams/banner_radiant_reef.vmdl"

-- Red Flag ==> Morale (Dire)
OBJECTIVE_FLAG_SPAWNER_B    = "spawner_flag_b"
OBJECTIVE_FLAG_ITEM_B       = "item_avalore_flag_b"
OBJECTIVE_FLAG_MODEL_B      = "maps/journey_assets/props/teams/banner_journey_radiant.vmdl"

-- Yellow Flag ==> Agility
OBJECTIVE_FLAG_SPAWNER_C    = "spawner_flag_c"
OBJECTIVE_FLAG_ITEM_C       = "item_avalore_flag_c"
OBJECTIVE_FLAG_MODEL_C      = "maps/journey_assets/props/teams/banner_journey_dire_small.vmdl" 

-- Purple Flag ==> Arcane
OBJECTIVE_FLAG_SPAWNER_D    = "spawner_flag_d"
OBJECTIVE_FLAG_ITEM_D       = "item_avalore_flag_d"
OBJECTIVE_FLAG_MODEL_D      = "maps/reef_assets/props/teams/banner_dire_reef_small.vmdl" 

-- Blue Flag ==> Regrowth
OBJECTIVE_FLAG_SPAWNER_E    = "spawner_flag_e"
OBJECTIVE_FLAG_ITEM_E       = "item_avalore_flag_e"
OBJECTIVE_FLAG_MODEL_E      = "models/props_teams/bannerb_dire.vmdl" 

-- ==================================
-- SCORE RELATED
-- ==================================

SCORE_DIVIDEND_KILLS = 1 --ie. 1 kill = 1 point
SCORE_DIVIDEND_ASSISTS = 10
SCORE_DIVIDEND_LASTHITS = 100

SCORE_MULTIPLIER_T1 = 15
SCORE_MULTIPLIER_T2 = 15
SCORE_MULTIPLIER_T3 = 15
SCORE_MULTIPLIER_T4 = 15

SCORE_MULTIPLIER_RAX_MELEE = 15
SCORE_MULTIPLIER_RAX_RANGED = 15

SCORE_MULTIPLIER_WISP = 3

SCORE_MULTIPLIER_FLAG = 15


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


-- MESSAGE TYPES 
MSG_TYPE_NOTIFY = 0
MSG_TYPE_ERROR = 1