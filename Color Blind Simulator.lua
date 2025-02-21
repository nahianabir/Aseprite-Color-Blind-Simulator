----------------------------------------------------------------
-- Color Blindness Simulator (Aseprite 1.3.10.1-compatible) --
-- only works for background layer--
----------------------------------------------------------------


local spr = app.activeSprite
if not spr then
  return app.alert("No active sprite found!")
end


local dlg = Dialog("Color Blindness Simulator")
dlg:combobox{
  id = "cbType",
  label = "Simulate:",
  options = {"Protanopia", "Deuteranopia", "Tritanopia"}
}
dlg:button{ id = "ok", text = "OK" }
dlg:show()

local data = dlg.data
if not data.ok then
  return -- user canceled
end

-- transformation matrices
local matrices = {
  Protanopia = {
    0.56667, 0.43333, 0.0,
    0.55833, 0.44167, 0.0,
    0.0,     0.24167, 0.75833
  },
  Deuteranopia = {
    0.625,   0.375,   0.0,
    0.70,    0.30,    0.0,
    0.0,     0.30,    0.70
  },
  Tritanopia = {
    0.95,    0.05,    0.0,
    0.0,     0.43333, 0.56667,
    0.0,     0.475,   0.525
  }
}

local matrix = matrices[data.cbType]
if not matrix then
  return app.alert("Invalid simulation type!")
end


local newSprite = Sprite(spr.width, spr.height, spr.colorMode)
newSprite.filename = spr.filename .. " (" .. data.cbType .. ").aseprite"


local layer = spr.layers[1]
local frameIndex = 1
local srcCel = layer:cel(frameIndex)
if not srcCel then
  return app.alert("No cel found in layer #1, frame #1.")
end


local srcImage = srcCel.image:clone()
local destImage = Image(srcImage.spec)

-- Shortcuts for pixelColor functions
local pc = app.pixelColor


for y = 0, srcImage.height - 1 do
  for x = 0, srcImage.width - 1 do
    local pixel = srcImage:getPixel(x, y)
    -- Extract RGBA from the pixel
    local r = pc.rgbaR(pixel)
    local g = pc.rgbaG(pixel)
    local b = pc.rgbaB(pixel)
    local a = pc.rgbaA(pixel)

    -- Transform with the color blindness matrix
    local newR = math.floor(math.min(255, math.max(0, r*matrix[1] + g*matrix[2] + b*matrix[3])))
    local newG = math.floor(math.min(255, math.max(0, r*matrix[4] + g*matrix[5] + b*matrix[6])))
    local newB = math.floor(math.min(255, math.max(0, r*matrix[7] + g*matrix[8] + b*matrix[9])))

    
    destImage:drawPixel(x, y, pc.rgba(newR, newG, newB, a))
  end
end


local newLayer = newSprite.layers[1]       -- The default layer
local newCel = newLayer:cel(frameIndex)    -- Cel #1 in that layer
newCel.image = destImage

-- Done!  
app.alert("Color Blindness Simulation complete!")
