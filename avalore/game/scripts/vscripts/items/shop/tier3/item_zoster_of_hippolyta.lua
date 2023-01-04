item_zoster_of_hippolyta = class({})

LinkLuaModifier( "modifier_item_zoster_of_hippolyta", "items/shop/tier3/item_zoster_of_hippolyta.lua", LUA_MODIFIER_MOTION_NONE )

function item_zoster_of_hippolyta:GetIntrinsicModifierName()
    return "modifier_item_solar_crown"
end

function item_zoster_of_hippolyta:GetBehavior() 
    return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
end

function item_zoster_of_hippolyta:OnSpellStart()

end