item_midas_touch = class({})

LinkLuaModifier( "modifier_item_midas_touch", "items/shop/tier2/item_midas_touch.lua", LUA_MODIFIER_MOTION_NONE )

function item_midas_touch:GetIntrinsicModifierName()
    return "modifier_item_midas_touch"
end