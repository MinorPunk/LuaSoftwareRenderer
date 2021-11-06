require("Math/Math")
require("Renderer")
require("Shader")
require("Camera")
require("Renderable")

FPS = 0
Resolution = {x = 200, y = 200}
WindowSize = {x = 1600, y = 900}
local myRenderer = Renderer(-Resolution.x / 2, Resolution.y / 2, Resolution.x, Resolution.y)
local myCamera = Camera(WindowSize.x / WindowSize.y)
local myShader = Shader(myCamera)
local item = Renderable(myShader)

function love.load()
  item.vbo = {Vertex(), Vertex(), Vertex()}
  item.vbo[1].position = Vector4(0.5, 0.5)
  item.vbo[2].position = Vector4(2, 1)
  item.vbo[3].position = Vector4(3.5, 0.1)
  item.ebo = {1, 2, 3}

  love.window.setMode(WindowSize.x, WindowSize.y, {resizable = true})
  imageData = love.image.newImageData(Resolution.x, Resolution.y)
  image = love.graphics.newImage(imageData)
  image:setFilter("nearest")

  myRenderer:Render(1, imageData, item, Vector4(0.4, 0.7, 1, 1))
end

function love.update(dt)
  FPS = love.timer.getFPS()
  imageData = love.image.newImageData(Resolution.x, Resolution.y)
  myRenderer:Render(dt, imageData, item, Vector4(0.4, 0.7, 1, 1))
end

function love.draw()
  image:replacePixels(imageData)
  love.graphics.draw(image, 0, 0, 0, WindowSize.x / Resolution.x, WindowSize.y / Resolution.y)
  --love.graphics.draw(image, 0, 0)
  love.graphics.print("FPS: " .. FPS, WindowSize.x / 2, 0)
  love.graphics.print("Resolution: " .. Resolution.x .. "," .. Resolution.y, WindowSize.x * 0.8, 0)
end
