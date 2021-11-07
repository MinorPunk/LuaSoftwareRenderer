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

function V2F.Lerp(from, to, factor)
    local v2f = V2F()
    v2f.worldPos = Vector4.Lerp(from.worldPos, to.worldPos, factor)
    v2f.clipPos = Vector4.Lerp(from.clipPos, to.clipPos, factor)
    v2f.color = Vector4.Lerp(from.color, to.color, factor)
    v2f.texcoord = Vector4.Lerp(from.texcoord, to.texcoord, factor)
    v2f.normal = Vector4.Lerp(from.normal, to.normal, factor)
    return v2f
end

function V2F:NDC()
    self.clipPos = self.clipPos / self.clipPos.w
end
