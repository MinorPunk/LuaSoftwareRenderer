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
    --print(inst.viewportMatrix)
    return inst
end

--渲染流程
Renderer.Render = function(self, dt, imageData, renderable, color)
    lastTime = love.timer.getTime()
    for i = 1, #renderable.ebo, 3 do
        --read triangle 取三角形
        local v2fs = {}
        for j = i, i + 2 do
            local v2f = {}
            index = renderable.ebo[j]
            --vertex shader
            v2f = renderable.material.shader:VertexShader(renderable.vbo[index])
            --NDC
            v2f:NDC()
            --视口变换
            viewportTransform(self.viewportMatrix, v2f)
            table.insert(v2fs, v2f)
        end

        --draw triangle 画三角形
        DrawTriangle(v2fs, imageData, color)
    end
end

function DrawTriangle(v2fs, imageData, color)
    width = imageData:getWidth() - 1
    height = imageData:getHeight() - 1
    bboxMin = Vector4(width, height)
    bboxMax = Vector4()
    for i = 1, 3 do
        bboxMin.x = math.max(0, math.min(bboxMin.x, v2fs[i].clipPos.x))
        bboxMin.y = math.max(0, math.min(bboxMin.y, v2fs[i].clipPos.y))
        bboxMax.x = math.min(width, math.max(bboxMax.x, v2fs[i].clipPos.x))
        bboxMax.y = math.min(height, math.max(bboxMax.y, v2fs[i].clipPos.y))
    end

    a01 = v2fs[1].clipPos.y - v2fs[2].clipPos.y
    b01 = v2fs[2].clipPos.x - v2fs[1].clipPos.x
    a12 = v2fs[2].clipPos.y - v2fs[3].clipPos.y
    b12 = v2fs[3].clipPos.x - v2fs[2].clipPos.x
    a20 = v2fs[3].clipPos.y - v2fs[1].clipPos.y
    b20 = v2fs[1].clipPos.x - v2fs[3].clipPos.x

    bboxMin.x = math.floor(bboxMin.x)
    bboxMin.y = math.floor(bboxMin.y)
    bboxMax.x = math.floor(bboxMax.x)
    bboxMax.y = math.floor(bboxMax.y)

    p = Vector4(bboxMin.x, bboxMin.y)
    w0_row = Orient2d(v2fs[2], v2fs[3], p)
    w1_row = Orient2d(v2fs[3], v2fs[1], p)
    w2_row = Orient2d(v2fs[1], v2fs[2], p)

    --Rasterize
    for y = bboxMin.y, bboxMax.y do
        w0 = w0_row + 60
        w1 = w1_row + 60
        w2 = w2_row + 60

        for x = bboxMin.x, bboxMax.x do
            if w0 >= 0 and w1 >= 0 and w2 >= 0 then
                imageData:setPixel(x, y, color.x, color.y, color.z, color.w)
            end

            w0 = w0 + a12
            w1 = w1 + a20
            w2 = w2 + a01
        end

        w0_row = w0_row + b12
        w1_row = w1_row + b20
        w2_row = w2_row + b01
    end
end

function Orient2d(a, b, p)
    return (b.clipPos.x - a.clipPos.x) * (p.y - a.clipPos.y) - (b.clipPos.y - a.clipPos.y) * (p.x - a.clipPos.x)
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
