local Matrix = require("Math/Math")

--[TODO：在透视相机和正交相机间交换]
Camera = {
    fov = 60,
    near = 0.0001,
    far = 1000,
    position = Vector4(0, 0, -10, 1),
    up = Vector4(0, 1, 0),
    right = Vector4(1, 0, 0),
    front = Vector4(0, 0, 1),
    projectionMatrix = Matrix:new(4, "I"),
    viewMatrix = Matrix:new(4, "I")
}

setmetatable(Camera, Camera)

Camera.__index = Camera
Camera.__call = function(t, aspect)
    return Camera.new(aspect)
end

Camera.new = function(aspect)
    local inst = {}
    setmetatable(inst, Camera)
    inst.aspect = aspect
    inst.projectionMatrix = GetProjectionMatrix(inst.fov, inst.aspect, inst.near, inst.far)
    inst.viewMatrix = GetViewMatrix(inst.position, inst.front, inst.right, inst.up)
    return inst
end

--[[
观察矩阵
V = R*T

R = [ rx ,ry ,rz , 0
      ux ,uy ,uz , 0
      fx ,fy ,fz , 0
       0 , 0 , 0 , 1]

T = [  1 , 0 , 0 , -px
       0 , 1 , 0 , -py
       0 , 0 , 1 , -pz
       0 , 0 , 0 , 1]

V = [  rx ,ry ,rz , -r . p
       ux ,uy ,uz , -u . p
       -fx,-fy,-fz,  f . p
        0 , 0 , 0 , 1]

这里使用左右坐标系，f向量取负数
]]
function GetViewMatrix(pos, front, right, up)
    return Matrix {
        {right.x, right.y, right.z, Vector4.Dot(-right, pos)},
        {up.x, up.y, up.z, Vector4.Dot(-up, pos)},
        {-front.x, -front.y, -front.z, Vector4.Dot(front, pos)},
        {0, 0, 0, 1}
    }
end

--[[
    透视相机投影矩阵
    ProjectionMatrix
    P = [1 / (a * tan(fov/2))   , 0                 , 0                             , 0
        0                       , 1 / tan(fov/2)    , 0                             , 0
        0                       , 0                 , -(far + near) / (far - near)  , -2 * far * near / (far - near)
        0                       , 0                 , -1                            , 0]
]]
function GetProjectionMatrix(fov, aspect, near, far)
    return Matrix {
        {1 / (aspect * math.tan(fov * math.pi / 180 / 2)), 0, 0, 0},
        {0, 1 / math.tan(fov * math.pi / 180 / 2), 0, 0},
        {0, 0, -(far + near) / (far - near), -2 * far * near / (far - near)},
        {0, 0, -1, 0}
    }
end

--[[
Camera.GetProjectionMatrix = function(self, aspect)
    return Matrix {
        {1 / (aspect * math.tan(self.fov / 2)), 0, 0, 0},
        {0, 1 / math.tan(self.fov / 2), 0, 0},
        {0, 0, -(self.far + self.near) / (self.far - self.near), -2 * self.far * self.near / (self.far - self.near)},
        {0, 0, -1, 0}
    }
end
]]
