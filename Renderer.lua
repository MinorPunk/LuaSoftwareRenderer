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

local faceNormalCache = {}
local v2fs = {true, true, true}
local r, g, b, a = 1, 1, 1, 1

--渲染流程
Renderer.Render = function(self, dt, imageData, renderable)
    self.zBuffer = {}
    lastTime = love.timer.getTime()
    local obj = renderable.obj
    for i = 1, #renderable.obj.f do
        --read triangle 取三角形
        local f = renderable.obj.f[i]
        for j = 1, 3 do
            local v = f[j]
            vIndex = v.v
            tIndex = v.vt
            --vertex shader
            local v2f = renderable.material.shader:VertexShader(obj.v[vIndex], obj.vt[tIndex])
            --NDC
            v2f:NDC()
            v2fs[j] = v2f
        end

        --culling
        culling, faceNormalCache = FaceCulling(v2fs)
        if not culling then
            for j = 1, 3 do
                --视口变换
                viewportTransform(self.viewportMatrix, v2fs[j])
            end

            --draw triangle 画三角形
            Rasterization(self, v2fs, imageData, faceNormalCache, renderable)
        end
    end
end

--NDC之后剔除面，此时观察方向为(0,0,1)
function FaceCulling(v2fs)
    normal = Vector4.Cross(v2fs[3].worldPos - v2fs[2].worldPos, v2fs[1].worldPos - v2fs[2].worldPos)
    normal = normal:Normal()

    --屏幕剔除
    outOfScreen = {false, false, false}
    for i = 1, 3 do
        if v2fs[i].NDC.x < -1 or v2fs[i].NDC.x > 1 or v2fs[i].NDC.y < -1 or v2fs[i].NDC.y > 1 then
            outOfScreen[i] = true
        end
    end
    if outOfScreen[1] and outOfScreen[2] and outOfScreen[3] then
        return true, nil
    end

    if Vector4.Dot(normal, Vector4(0, 0, 1)) > 0.2 then
        return true, nil
    end

    return false, normal
end

function Rasterization(self, v2fs, imageData, faceNormal, renderable)
    local baryCache = {Vector4.new(), Vector4.new()}
    local pCahce = Vector4.new()
    local width = imageData:getWidth() - 1
    local height = imageData:getHeight() - 1
    local bboxMin = Vector4.new(width, height)
    local bboxMax = Vector4.new()

    local w1, w2, w3 = 1 / v2fs[1].clipPos.w, 1 / v2fs[2].clipPos.w, 1 / v2fs[3].clipPos.w
    local tex1, tex2, tex3 = v2fs[1].texcoord * w1, v2fs[2].texcoord * w2, v2fs[3].texcoord * w3

    --计算光照
    intensity = math.min(1, math.max(0.12, -Vector4.Dot(faceNormal, self.lightDir)))

    for i = 1, 3 do
        bboxMin.x = math.max(0, math.min(bboxMin.x, v2fs[i].screenPos.x))
        bboxMin.y = math.max(0, math.min(bboxMin.y, v2fs[i].screenPos.y))
        bboxMax.x = math.min(width, math.max(bboxMax.x, v2fs[i].screenPos.x))
        bboxMax.y = math.min(height, math.max(bboxMax.y, v2fs[i].screenPos.y))
    end

    bboxMin.x = math.floor(bboxMin.x)
    bboxMin.y = math.floor(bboxMin.y)
    bboxMax.x = math.floor(bboxMax.x)
    bboxMax.y = math.floor(bboxMax.y)

    pCahce.x = bboxMin.x
    pCahce.y = bboxMin.y
    --print("w0_row:" .. w0_row .. "w1_row:" .. w1_row .. "w2_row:" .. w2_row)

    --Rasterize
    tempV2f = V2F.new()
    for y = bboxMin.y, bboxMax.y do
        for x = bboxMin.x, bboxMax.x do
            pCahce.x = x
            pCahce.y = y
            cx, cy, cz = Barycentric(baryCache, v2fs[1].screenPos, v2fs[2].screenPos, v2fs[3].screenPos, pCahce)
            if cx >= 0 and cy >= 0 and cz >= 0 then
                zb = self.zBuffer[x + (y - 1) * width]

                zc = cx * v2fs[1].clipPos.z + cy * v2fs[2].clipPos.z + cz * v2fs[3].clipPos.z
                if zb == nil or zb > zc then
                    self.zBuffer[x + (y - 1) * width] = zc
                    r, g, b, a = 1, 1, 1, 1

                    if renderable.material.texture ~= false then
                        w = w1 * cx + w2 * cy + w3 * cz
                        tempV2f.texcoord = tex1 * cx + tex2 * cy + tex3 * cz
                        tempV2f.texcoord = tempV2f.texcoord / w
                        r, g, b, a = renderable.material.shader:FragmentShader(tempV2f)
                    end

                    --r, g, b, a = 1, 1, 1, 1
                    imageData:setPixel(x, y, intensity * r, intensity * g, intensity * b, a)
                end
            end
        end
    end
end

function Barycentric(baryCache, a, b, c, p)
    baryCache[2].x = c.y - a.y
    baryCache[2].y = b.y - a.y
    baryCache[2].z = a.y - p.y
    baryCache[1].x = c.x - a.x
    baryCache[1].y = b.x - a.x
    baryCache[1].z = a.x - p.x

    bx, by, bz = Vector4.RawCross(baryCache[2], baryCache[1])
    if bz > 0.01 or bz < -0.01 then
        return 1 - (bx + by) / bz, by / bz, bx / bz
    end
    return -1, 1, 1
end

--视口转换
function viewportTransform(viewportMatrix, v2f)
    v2f.screenPos = Math.MatrixToV4(viewportMatrix * Math.V4ToMatrix(v2f.NDC))
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
