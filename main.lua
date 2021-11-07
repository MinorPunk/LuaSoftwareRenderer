require("Math/Math")
require("Renderer")
require("Shader")
require("Camera")
require("Renderable")
require("Material")

FPS = 0
Resolution = {x = 1600, y = 900}
WindowSize = {x = 1600, y = 900}
local myRenderer = Renderer(0, 0, Resolution.x, Resolution.y)
local myCamera = Camera(WindowSize.x / WindowSize.y)
local myShader = Shader(myCamera)
local myMaterial = Material(myShader)
local cat = Renderable(myMaterial)

local rotate = 0

function love.load()
  cat:LoadObj("chair_01.obj")
  cat:SetPosition(0, -0.5, 0)
  cat:SetScale(6, 6, 6)

  love.window.setMode(WindowSize.x, WindowSize.y, {resizable = true})
  imageData = love.image.newImageData(Resolution.x, Resolution.y)
  image = love.graphics.newImage(imageData)
  image:setFilter("nearest")

  myRenderer:Render(1, imageData, cat, Vector4(0.4, 0.7, 1, 1))
end

function love.update(dt)
  FPS = love.timer.getFPS()

  rotate = rotate + dt / 3
  cat:SetRotation(0, rotate, 0)
  --imageData = love.image.newImageData(Resolution.x, Resolution.y)

  imageData:mapPixel(
    function()
      return 0, 0, 0, 0
    end
  )

  myRenderer:Render(dt, imageData, cat, Vector4(0.4, 0.7, 1, 1))

  --[[
  for x = 0, Resolution.x - 1 do
    for y = 0, Resolution.y - 1 do
      imageData:setPixel(x, y, x / 255, y / 255, (x + y) / 255, 1)
    end
  end
  ]]
end

function love.draw()
  image:replacePixels(imageData)
  love.graphics.draw(image, 0, 0, 0, WindowSize.x / Resolution.x, WindowSize.y / Resolution.y)
  --love.graphics.draw(image, 0, 0)
  --love.graphics.points(points)
  love.graphics.print("FPS: " .. FPS, WindowSize.x / 2, 0)
  love.graphics.print("Resolution: " .. Resolution.x .. "," .. Resolution.y, WindowSize.x * 0.8, 0)
end
