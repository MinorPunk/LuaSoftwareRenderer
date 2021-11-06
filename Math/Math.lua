require("Math/Vector4")
local Matrix = require("Math/matrix")
require("Math/V2F")
require("Math/Vertex")

Math = {}

--[[
    V3转化成Matrix, w = 1
]]
Math.V4ToMatrix = function(v4)
    return Matrix {{v4.x}, {v4.y}, {v4.z}, {1}}
end

Math.MatrixToV4 = function(matrix)
    return Vector4(matrix[1][1], matrix[2][1], matrix[3][1], matrix[4][1])
end

return Matrix
