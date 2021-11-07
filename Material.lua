Material = {
    color = {},
    texture = {},
    shader = {}
}

setmetatable(Material, Material)
Material.__index = Material
Material.__call = function(t, shader)
    return Material.new(shader)
end

Material.new = function(shader)
    local inst = {}
    setmetatable(inst, Material)
    inst.shader = shader
    return inst
end
