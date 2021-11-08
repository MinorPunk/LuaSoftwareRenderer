local Matrix = require("Math/Math")

Renderer = {
    viewportMatrix = {},
    lightDir = Vector4(-1, -1, 1),
    zBuffer = {}
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
    inst.lightDir = inst.lightDir:Normal()
    --print(inst.viewportMatrix)
    return inst
end

--渲染流程
Renderer.Render = function(self, dt, imageData, renderable, color)
    self.zBuffer = {}
    lastTime = love.timer.getTime()
    for i = 1, #renderable.ebo, 3 do
        --read triangle 取三角形
        local v2fs = {}
        faceNormal = {}
        for j = i, i + 2 do
            local v2f = {}
            index = renderable.ebo[j]
            --vertex shader
            v2f = renderable.material.shader:VertexShader(renderable.vbo[index])
            --NDC
            v2f:NDC()
            table.insert(v2fs, v2f)
        end

        --culling
        culling, faceNormal = FaceCulling(v2fs)

        if not culling then
            for j = 1, 3 do
                --视口变换
                viewportTransform(self.viewportMatrix, v2fs[j])
            end

            --draw triangle 画三角形
            Rasterization(self, v2fs, imageData, faceNormal, renderable)
        end
    end
end

--NDC之后剔除面，此时观察方向为(0,0,1)
function FaceCulling(v2fs)
    normal = Vector4.Cross(v2fs[2].worldPos - v2fs[1].worldPos, v2fs[3].worldPos - v2fs[1].worldPos)
    normal = normal:Normal()

    --屏幕剔除
    outOfScreen = {false, false, false}
    for i = 1, 3 do
        if v2fs[i].clipPos.x < -1 or v2fs[i].clipPos.x > 1 or v2fs[i].clipPos.y < -1 or v2fs[i].clipPos.y > 1 then
            outOfScreen[i] = true
        end
    end
    if outOfScreen[1] and outOfScreen[2] and outOfScreen[3] then
        return true, nil
    end

    --暂时留0.2，不然可以观察到垂直面明显的剔除过程
    if Vector4.Dot(normal, Vector4(0, 0, 1)) > 0.2 then
        return true, nil
    end

    return false, normal
end

function Rasterization(self, v2fs, imageData, faceNormal, renderable)
    width = imageData:getWidth() - 1
    height = imageData:getHeight() - 1
    bboxMin = Vector4(width, height)
    bboxMax = Vector4()
    texcoordMinX, texcoordMinY, texcoordMaxX, texcoordMaxY = 0, 0, 0, 0
    texcoordStepX, texcoordStepY = 0, 0

    --计算光照
    intensity = math.min(1, math.max(0.12, -Vector4.Dot(faceNormal, self.lightDir)))

    for i = 1, 3 do
        bboxMin.x = math.max(0, math.min(bboxMin.x, v2fs[i].clipPos.x))
        bboxMin.y = math.max(0, math.min(bboxMin.y, v2fs[i].clipPos.y))
        bboxMax.x = math.min(width, math.max(bboxMax.x, v2fs[i].clipPos.x))
        bboxMax.y = math.min(height, math.max(bboxMax.y, v2fs[i].clipPos.y))

        texcoordMinX = math.min(texcoordMinX, v2fs[i].texcoord.x)
        texcoordMinY = math.min(texcoordMinY, v2fs[i].texcoord.y)
        texcoordMaxX = math.max(texcoordMaxX, v2fs[i].texcoord.x)
        texcoordMaxY = math.max(texcoordMaxY, v2fs[i].texcoord.y)
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

    texcoordStepX = (texcoordMaxX - texcoordMinX) / (bboxMax.x - bboxMin.x)
    texcoordStepY = (texcoordMaxY - texcoordMinY) / (bboxMax.y - bboxMin.y)

    p = Vector4(bboxMin.x, bboxMin.y)
    w0_row = Orient2d(v2fs[2], v2fs[3], p)
    w1_row = Orient2d(v2fs[3], v2fs[1], p)
    w2_row = Orient2d(v2fs[1], v2fs[2], p)
    --print("w0_row:" .. w0_row .. "w1_row:" .. w1_row .. "w2_row:" .. w2_row)

    --Rasterize
    tempV2f = V2F()
    for y = bboxMin.y, bboxMax.y do
        w0 = w0_row
        w1 = w1_row
        w2 = w2_row

        for x = bboxMin.x, bboxMax.x do
            if w0 >= 0 and w1 >= 0 and w2 >= 0 then
                zb = self.zBuffer[x + (y - 1) * width]
                wSum = w0 + w1 + w2
                w0n = w0 / wSum
                w1n = w1 / wSum
                w2n = w2 / wSum

                zc = w0n * v2fs[1].clipPos.z + w1n * v2fs[2].clipPos.z + w2n * v2fs[3].clipPos.z
                if zb == nil or zb > zc then
                    self.zBuffer[x + (y - 1) * width] = zc
                    tempV2f.texcoord = v2fs[1].texcoord * w0n + v2fs[2].texcoord * w1n + v2fs[3].texcoord * w2n
                    --tempV2f.texcoord.x = texcoordMinX + (x - bboxMin.x) * texcoordStepX
                    --tempV2f.texcoord.y = texcoordMinY + (y - bboxMin.y) * texcoordStepY
                    --print("texcoord:", tempV2f.texcoord)
                    r, g, b, a = renderable.material.shader:FragmentShader(tempV2f)
                    -- r, g, b, a = 1, 1, 1, 1
                    imageData:setPixel(x, y, intensity * r, intensity * g, intensity * b, a)
                end
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
