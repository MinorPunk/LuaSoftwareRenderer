Vector4 = {
    x = 0,
    y = 0,
    z = 0,
    w = 0
}

setmetatable(Vector4, Vector4)

Vector4.__index = Vector4
Vector4.__call = function(t, x, y, z, w)
    return Vector4.new(x, y, z, w)
end

Vector4.new = function(x, y, z, w)
    local v4 = setmetatable({}, Vector4)
    v4.x = x or 0
    v4.y = y or 0
    v4.z = z or 0
    v4.w = w or 0
    return v4
end

function Vector4:Set(x, y, z, w)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.w = w or 0
end

function Vector4.Lerp(from, to, factor)
    return (1 - factor) * from + factor * to
end

function Vector4.SqrMagnitude(self)
    return Vector4(self.x * self.x, self.y * self.y, self.z * self.z, self.w * self.w)
end

--[[
    只用于Vector3
]]
function Vector4.Cross(v1, v2)
    local x = v1.y * v2.z - v1.z * v2.y
    local y = v1.z * v2.x - v1.x * v2.z
    local z = v1.x * v2.y - v1.y * v2.x
    return Vector4(x, y, z, 0)
end

function Vector4.Dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z + v1.w * v2.w
end

Vector4.__tostring = function(self)
    return "[" .. self.x .. "|" .. self.y .. "|" .. self.z .. "|" .. self.w .. "]"
end

Vector4.__mul = function(self, d)
    if type(d) == "number" then
        return Vector4(self.x * d, self.y * d, self.z * d, self.w * d)
    end
end

Vector4.__div = function(self, d)
    return self * (1 / d)
end

Vector4.__add = function(self, other)
    return Vector4(self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w)
end

Vector4.__sub = function(self, other)
    return self + (-other)
end

Vector4.__unm = function(self)
    return Vector4(-self.x, -self.y, -self.z, -self.w)
end

Vector4.__eq = function(self, other)
    local temp = self - other
    local length = temp:SqrMagnitude()
    return length < 1e-10
end

Vector4.zero = function()
    return Vector4(0, 0, 0, 0)
end
