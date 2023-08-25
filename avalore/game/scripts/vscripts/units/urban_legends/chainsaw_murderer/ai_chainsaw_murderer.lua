require("references")
require(REQ_AI_SHARED)

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then
        return
    end

    thisEntity.isCarrying = false
end