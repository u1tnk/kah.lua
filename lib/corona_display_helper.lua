local _u = require 'utils'

local parent = require 'object'
local M = parent:new{
  defaultFont = native.systemFont,
  defaultFontSize = 24,
  -- kahlua以下に置いて symbolic link経由で読み込ませようとしたがpackageしてくれない
  imagesPath = 'static/images/kahlua',
}
local L = {}


local W = display.contentWidth
local H = display.contentHeight
local CX = display.contentCenterX
local CY = display.contentCenterY

function M:newText(options)
  local defaults = {
    x = 0,
    y = 0,
    color = "FFF",
    font = self.defaultFont,
    size = self.defaultFontSize,
    text = "",
    width = 0,
    height = 0,
    parent = nil,
  }
  local o = _u.setDefault(options, defaults) 
  local displayText
  if o.width > 0 and o.height > 0 then
    displayText = display.newText(o.text, o.x, o.y, o.width, o.height, o.font, o.size )
  else
    displayText = display.newText(o.text, o.x, o.y, o.font, o.size )
  end
  displayText:setTextColor(_u.color(o.color))

  if o.parent then
    o.parent:insert(displayText)
  end

  return displayText
end

function M:newRect(options)
  local defaults = {
    parent = nil,
    x = nil,
    y = nil,
    top = 0,
    left = 0,
    width = nil,
    height = nil,
    fillColor = "000",
    strokeColor = nil,
    alpha = nil,
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.width, "width is required")
  assert(o.height, "height is required")

  p(o, "ooooo")
  local target = display.newRect(o.top, o.left, o.width, o.height)
  target:setFillColor(_u.color(o.fillColor))
  if o.strokeColor then
    target:setStrokeColor(_u.color(o.strokeColor))
  end

  _u.copyPropertyIfExist(o, target, "x")
  _u.copyPropertyIfExist(o, target, "y")
  _u.copyPropertyIfExist(o, target, "alpha")

  if o.parent then
    o.parent:insert(displayText)
  end

  return target
end


function M:newBorderText(options)
  local defaults = {
    text = "",
    x = 0,
    y = 0,
    color = "FFF",
    border_color = "000",
    border_width = 1,
  }
  local o = _u.setDefault(options, defaults) 
  
  local this = display.newGroup()

  local size = o.size
  local color = o.color
  local border_color = o.border_color
  local left = x - o.border_width
  local right = x + o.border_width
  local top = y - o.border_width
  local bottom = y + o.border_width

  local borderText1 = newText(text,  left, y, {font=font, size=size} )
  borderText1:setTextColor(_u.color(border_color))

  local borderText2 = newText(text,  left, top, {font=font, size=size} )
  borderText2:setTextColor(_u.color(border_color))

  local borderText3 = newText(text, x, top, {font=font, size=size} )
  borderText3:setTextColor(_u.color(border_color))

  local borderText4 = newText(text, right, top, {font=font, size=size} )
  borderText4:setTextColor(_u.color(border_color))

  local borderText5 = newText(text, right, y, {font=font, size=size} )
  borderText5:setTextColor(_u.color(border_color))

  local borderText6 = newText(text, right, bottom, {font=font, size=size} )
  borderText6:setTextColor(_u.color(border_color))

  local borderText7 = newText(text, x, bottom, {font=font, size=size} )
  borderText7:setTextColor(_u.color(border_color))

  local borderText8 = newText(text, left, bottom, {font=font, size=size} )
  borderText8:setTextColor(_u.color(border_color))

  local mainText = newText(text, x, y, {font=font, size=size} )
  mainText:setTextColor(_u.color(color))

  this:insert(borderText1)
  this:insert(borderText2)
  this:insert(borderText3)
  this:insert(borderText4)
  this:insert(borderText5)
  this:insert(borderText6)
  this:insert(borderText7)
  this:insert(borderText8)
  this:insert(mainText)

  this.x = x
  this.y = y

  return this
end

function M:newImage(options)
  local defaults = {
    x = CX,
    y = CY,
    width = 0,
    height = 0,
    path = nil
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.path, 'path is nil')

  local display = display.newImageRect( o.path, o.width, o.height ); 
  display.x = o.x
  display.y = o.y

  return display
end

function M.toFront(object)
  if object and _u.size(object) > 0 then
    object:toFront()
  end
end

function M.alignFront(array)
  for key, value in pairs(array) do
    M.toFront(value)
  end
end


function M.alignFront(array)
  for key, value in pairs(array) do
    M.toFront(value)
  end
end

function M:newGridList(options)
  local defaults = {
    x = 0,
    y = 0,
    width = W,
    height = H,
    columns = 3,
    rows = 3, -- これは表示上なのでこれ以上のデータも配置される
    elements = elements,
  }
  local o = _u.setDefault(options, defaults) 

  local group = display.newGroup()
  group.x = o.x
  group.y = o.y

  local xGridUnit = math.floor(o.width / o.columns)
  local yGridUnit = math.floor(o.height / o.rows)

  local lists = display.newGroup()
  group:insert(lists)

  local touchBlock = self:newRect{width = o.width, height = o.height,  alpha = 0}
  touchBlock.isHitTestable = true
  touchBlock.isHitTestMasked = true
  group:insert(touchBlock)

  for i, value in ipairs(o.elements) do
    value:setReferencePoint(display.CenterReferencePoint)
    local xPosition = (i - 1) % o.columns + 1
    local yPosition = math.floor((i - 1) / o.columns) + 1
    value.x = ((xPosition - 1) * xGridUnit) + (xGridUnit / 2)
    value.y = ((yPosition - 1) * yGridUnit) + (yGridUnit / 2)
    lists:insert(value)
  end

  local mask = graphics.newMask(self.imagesPath .. "/mask_square.png")
  group:setMask( mask )
  group.maskX = o.width / 2
  group.maskY = o.height / 2
  group.maskScaleX = o.width / 256
  group.maskScaleY = o.height / 256
  group.isHitTestable = true
  group.isHitTestMasked = true

  local isFocus = false
  local yStart = lists.y
  local yLast = lists.y


      p(lists.height)
      p(lists.height)
  touchBlock:addEventListener("touch", function(e)
    if "began" == e.phase then
      display.getCurrentStage():setFocus(touchBlock)
      isFocus = true
    end

    if not isFocus  then
      return false
    end

    local yDiff = e.y - e.yStart
    local newY = yStart + yDiff

    if e.phase == "moved" then
      if o.height - lists.height < newY and newY < 0 then
        lists.y = newY
        yLast = newY
      end
    end
    if e.phase == "ended" then
      display.getCurrentStage():setFocus(nil)
      isFocus = false
      yStart = yLast
    end
  end)
  
  return group
end


return M
