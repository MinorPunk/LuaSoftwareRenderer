local Matrix = require("Math/Math")

Renderable = {
    modelMatrix = Matrix:new(4, "I"),
    axRotateMatrix = Matrix:new(4, "I"),
    ayRotateMatrix = Matrix:new(4, "I"),
    azRotateMatrix = Matrix:new(4, "I"),
    texture = {},
    shader = {},
    vbo = {},
    ebo = {}
}

setmetatable(Renderable, Renderable)

Renderable.__index = Renderable
Renderable.__call = function(t, shader)
    return Renderable.new(shader)
end

Renderable.new = function(shader)
    local inst = {}
    setmetatable(inst, Renderable)
    inst.shader = shader
    inst.shader.modelMatrix = Matrix:new(4, "I")
    return inst
end

Renderable.SetRotation = function(ax, ay, az)
    if ax then
        axRotateMatrix =
            Matrix {
            {1, 0, 0, 0},
            {0, math.cos(ax), -math.sin(ay), 0},
            {0, math.sin(ax), math.cos(ax), 0},
            {0, 0, 0, 1}
        }
    else
        axRotateMatrix = Matrix.new(4, "I")
    end

    if ay then
        ayRotateMatrix =
            Matrix {
            {math.cos(ay), 0, math.sin(ay), 0},
            {0, 1, 0, 0},
            {-math.sin(ay), 0, math.cos(ay), 0},
            {0, 0, 0, 1}
        }
    else
        ayRotateMatrix = Matrix.new(4, "I")
    end

    if az then
        azRotateMatrix =
            Matrix {
            {math.cos(az), -math.sin(az), 0, 0},
            {math.sin(az), math.cos(az), 0, 0},
            {0, 0, 1, 0},
            {0, 0, 0, 1}
        }
    else
        ayRotateMatrix = Matrix.new(4, "I")
    end

    modelMatrix = axRotateMatrix * ayRotateMatrix * azRotateMatrix
end
