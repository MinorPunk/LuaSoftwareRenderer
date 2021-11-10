local Matrix = require("Math/Math")

Shader = {
    modelMatrix = Matrix:new(4, "I"),
    texture = {},
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
Shader.VertexShader = function(self, vertexPos, texcoord)
    v2f = V2F.new()
    worldMatrix = self.modelMatrix * Math.V4ToMatrix(vertexPos)
    v2f.worldPos = Math.MatrixToV4(worldMatrix)
    clipPosMatrix = self.camera.projectionMatrix * self.camera.viewMatrix * worldMatrix
    v2f.clipPos = Math.MatrixToV4(clipPosMatrix)
    v2f.texcoord = texcoord
    return v2f
end

Shader.FragmentShader = function(self, v2f)
    width, height = self.texture:getWidth() - 1, self.texture:getHeight() - 1
    return self.texture:getPixel(width * v2f.texcoord.x, height * v2f.texcoord.y)
end
