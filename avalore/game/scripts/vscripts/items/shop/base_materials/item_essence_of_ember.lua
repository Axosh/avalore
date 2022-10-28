item_essence_of_ember = class({})

LinkLuaModifier( "modifier_item_essence_of_ember", "items/shop/base_materials/item_essence_of_ember.lua", LUA_MODIFIER_MOTION_NONE )

function item_essence_of_ember:GetIntrinsicModifierName()
    return "modifier_item_essence_of_ember"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_essence_of_ember = modifier_item_essence_of_ember or class({})