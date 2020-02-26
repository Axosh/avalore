--[[
    Utility functions for helping debug.
--]]

function DebugVector( vector )
    local result = "(" .. tostring(vector.X) .. ", " .. tostring(vector.Y) .. ", " .. tostring(vector.Z) .. ")"
    return result
end
