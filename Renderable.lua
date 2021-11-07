local Matrix = require("Math/Math")
local loader = require("loader")

Renderable = {
    modelMatrix = Matrix:new(4, "I"),
    axRotateMatrix = Matrix:new(4, "I"),
    ayRotateMatrix = Matrix:new(4, "I"),
    azRotateMatrix = Matrix:new(4, "I"),
    scaleMatrix = Matrix:new(4, "I"),
    translateMatrix = Matrix:new(4, "I"),
    material = {},
    vbo = {},
    ebo = {}
}

setmetatable(Renderable, Renderable)

Renderable.__index = Renderable
Renderable.__call = function(t, material)
    return Renderable.new(material)
end

Renderable.new = function(material)
    local inst = {}
    setmetatable(inst, Renderable)
    inst.material = material
    return inst
end

Renderable.LoadObj = function(self, path)
    self.vbo, self.ebo = loader.load(path)
end

function UpdateModelMatrix(self)
    self.modelMatrix =
        self.axRotateMatrix * self.ayRotateMatrix * self.azRotateMatrix * self.scaleMatrix * self.translateMatrix
    self.material.shader.modelMatrix = self.modelMatrix
end

Renderable.SetScale = function(self, ax, ay, az)
    self.scaleMatrix =
        Matrix {
        {ax or 1, 0, 0, 0},
        {0, ay or 1, 0, 0},
        {0, 0, az or 1, 0},
        {0, 0, 0, 1}
    }
    UpdateModelMatrix(self)
end

Renderable.SetPosition = function(self, ax, ay, az)
    self.translateMatrix =
        Matrix {
        {1, 0, 0, ax or 0},
        {0, 1, 0, ay or 0},
        {0, 0, 1, az or 0},
        {0, 0, 0, 1}
    }
    UpdateModelMatrix(self)
end

Renderable.SetRotation = function(self, ax, ay, az)
    if ax then
        self.axRotateMatrix =
            Matrix {
            {1, 0, 0, 0},
            {0, math.cos(ax), -math.sin(ax), 0},
            {0, math.sin(ax), math.cos(ax), 0},
            {0, 0, 0, 1}
        }
    else
        self.axRotateMatrix = Matrix.new(4, "I")
    end

    if ay then
        self.ayRotateMatrix =
            Matrix {
            {math.cos(ay), 0, math.sin(ay), 0},
            {0, 1, 0, 0},
            {-math.sin(ay), 0, math.cos(ay), 0},
            {0, 0, 0, 1}
        }
    else
        self.ayRotateMatrix = Matrix.new(4, "I")
    end

    if az then
        self.azRotateMatrix =
            Matrix {
            {math.cos(az), -math.sin(az), 0, 0},
            {math.sin(az), math.cos(az), 0, 0},
            {0, 0, 1, 0},
            {0, 0, 0, 1}
        }
    else
        self.ayRotateMatrix = Matrix.new(4, "I")
    end

    UpdateModelMatrix(self)
end
