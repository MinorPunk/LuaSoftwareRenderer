local Matrix = require("Math/Math")

Shader = {
    modelMatrix = Matrix:new(4, "I"),
    camera = {}
}

setmetatable(Shader, Shader)

Shader.__index = Shader
Shader.__call = function(t, camera)
    return Shader.new(camera)
end

Shader.new = function(camera)
    local inst = {}
    setmetatable(inst, Shader)
    inst.camera = camera
    return inst
end

--[[
    objectPos -> ModelMatrix -> worldSpace
    worldPos -> ViewMatrix -> cameraSpace
    cameraPos -> ProjectionMatrix -> clipSpace
]]
Shader.VertexShader = function(self, vertex)
    v2f = V2F()
    clipPosMatrix =
        self.camera.projectionMatrix * self.camera.viewMatrix * self.modelMatrix * Math.V4ToMatrix(vertex.position)
    v2f.clipPos = Math.MatrixToV4(clipPosMatrix)
    v2f.texcoord = vertex.texcoord
    v2f.normal = vertex.normal
    return v2f
end

Shader.FragmentShader = function(self, v2f)
    return v2f.color
end
