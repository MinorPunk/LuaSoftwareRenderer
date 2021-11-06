local Matrix = require("Math/Math")

Shader = {
    modelMatrix = {},
    camera = {}
}

setmetatable(Shader, Shader)

Shader.__index = Shader
Shader.__call = function(t, camera, renderable)
    return Shader.new(camera)
end

Shader.new = function(camera, renderable)
    local inst = {}
    setmetatable(inst, Shader)
    inst.camera = camera
    inst.renderable = renderable
    return inst
end

Shader.VertexShader = function(self, vertex)
    v2f = V2F()
    --[[
        objectPos -> ModelMatrix -> worldSpace
        worldPos -> ViewMatrix -> cameraSpace
        cameraPos -> ProjectionMatrix -> clipSpace
    ]]
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
