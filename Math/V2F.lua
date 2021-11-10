V2F = {
    worldPos = Vector4.new(),
    clipPos = Vector4.new(),
    NDC = Vector4.new(),
    screenPos = Vector4.new(),
    color = Vector4.new(),
    texcoord = Vector4.new(),
    normal = Vector4.new()
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
    self.NDC = self.clipPos / self.clipPos.w
end
