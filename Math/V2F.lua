V2F = {
    worldPos = Vector4(),
    clipPos = Vector4(),
    color = Vector4(),
    texcoord = Vector4(),
    normal = Vector4()
}

setmetatable(V2F, V2F)

V2F.__index = V2F
V2F.__call = function()
    return V2F.new()
end

V2F.new = function()
    return setmetatable({}, V2F)
end

function V2F:NDC()
    self.clipPos = self.clipPos / self.clipPos.w
end
