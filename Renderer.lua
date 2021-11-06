local Matrix = require("Math/Math")

Renderer = {
    viewportMatrix = {}
}

setmetatable(Renderer, Renderer)
Renderer.__index = Renderer
Renderer.__call = function(t, ox, oy, sw, sh)
    return Renderer.new(ox, oy, sw, sh)
end

Renderer.new = function(ox, oy, sw, sh)
    local inst = {}
    setmetatable(inst, Renderer)
    inst.viewportMatrix =
        Matrix {
        {sw / 2, 0, 0, ox + sw / 2},
        {0, -sh / 2, 0, oy + sh / 2},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }
    print(inst.viewportMatrix)
    return inst
end

--渲染流程
Renderer.Render = function(self, dt, imageData, renderable, color)
    --取三角形
    for i = 1, #renderable.ebo, 3 do
        local v2fs = {}
        for j = i, i + 2 do
            local v2f = {}
            index = renderable.ebo[j]
            --vertex shader
            v2f = renderable.shader:VertexShader(renderable.vbo[index])
            --print("shader", v2f.clipPos)
            --NDC
            v2f:NDC()
            --print("NDC", v2f.clipPos)
            --视口变换
            viewportTransform(self.viewportMatrix, v2f)
            --print("viewport", v2f.clipPos)
            table.insert(v2fs, v2f)
        end
        --画三角形
        DrawTriangle(self, v2fs, imageData, color)
    end
end

--[[
    光栅化
]]
function DrawTriangle(self, v2fs, imageData, color)
    bboxMin = Vector4(imageData:getWidth() - 1, imageData:getHeight() - 1)
    bboxMax = Vector4()
    clamp = Vector4(imageData:getWidth() - 1, imageData:getHeight() - 1)
    for i = 1, 3 do
        bboxMin.x = math.max(0, math.min(bboxMin.x, v2fs[i].clipPos.x))
        bboxMin.y = math.max(0, math.min(bboxMin.y, v2fs[i].clipPos.y))
        bboxMax.x = math.min(clamp.x, math.max(bboxMax.x, v2fs[i].clipPos.x))
        bboxMax.y = math.min(clamp.y, math.max(bboxMax.y, v2fs[i].clipPos.y))
    end

    --print(bboxMin, bboxMax)

    p = Vector4(bboxMin.x, bboxMin.y)
    for x = bboxMin.x, bboxMax.x do
        for y = bboxMin.y, bboxMax.y do
            bcScreen = self.BarayCentric(v2fs, Vector4(x, y))
            if bcScreen.x >= 0 and bcScreen.y >= 0 and bcScreen.z >= 0 then
                --print("drawPixel", x, y)
                imageData:setPixel(x, y, color.x, color.y, color.z, color.w)
            end
        end
    end
end

Renderer.BarayCentric = function(v2fs, p)
    cross =
        Vector4.Cross(
        Vector4(
            v2fs[3].clipPos.x - v2fs[1].clipPos.x,
            v2fs[2].clipPos.x - v2fs[1].clipPos.x,
            v2fs[1].clipPos.x - p.x,
            0
        ),
        Vector4(
            v2fs[3].clipPos.y - v2fs[1].clipPos.y,
            v2fs[2].clipPos.y - v2fs[1].clipPos.y,
            v2fs[1].clipPos.y - p.y,
            0
        )
    )

    if (math.abs(cross.z) < 0) then
        return Vector4(-1, 1, 1)
    end
    return Vector4(1 - (cross.x + cross.y) / cross.z, cross.y / cross.z, cross.x / cross.z)
end

--视口转换
function viewportTransform(viewportMatrix, v2f)
    v2f.clipPos = Math.MatrixToV4(viewportMatrix * Math.V4ToMatrix(v2f.clipPos))
end

--[[
  Vp = [ w/2 ,   0  ,  0  , ox+w/2 ,
	      0  ,  h/2 ,  0  , oy+h/2 ,
          0  ,   0  ,  1  ,   0    ,
          0  ,   0  ,  0  ,   1   ]

在love中坐标原点在左上角
所以使用Vp = [ w/2 , 0  , 0  , ox + w/2
               0  ,-h/2, 0  , oy + h/2
               0  , 0  , 1  , 0 
               0  , 0  , 0  , 1    ]
]]
function GetViewportMatrix(ox, oy, sw, sh)
    return Matrix {
        {sw / 2, 0, 0, ox + sw / 2},
        {0, -sh / 2, 0, oy + sh / 2},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }
end
