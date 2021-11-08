Vertex = {
    position = Vector4(),
    texcoord = Vector4()
    --不使用顶点normal数据
    --normal = Vector4(0, 0, 1, 0)
}

setmetatable(Vertex, Vertex)

Vertex.__index = Vertex
Vertex.__call = function()
    return Vertex.new()
end

Vertex.new = function()
    return setmetatable({}, Vertex)
end
