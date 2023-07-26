require("constants")

AvaloreInventory = {}
AvaloreInventory.__index = AvaloreInventory

function AvaloreInventory.Create()
    local obj = {}
    setmetatable(obj, AvaloreInventory)
    return obj
end