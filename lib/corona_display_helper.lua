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

function M:newGroup(options)
  local defaults = {
    x = nil,
    y = nil,
    parent = nil,
  }
  local o = _u.setDefault(options, defaults) 
  local group = display.newGroup()
  if o.x then
    group.x = o.x
  end
  if o.y then
    group.y = o.y
  end

  self:newCommon(group, options)

  return group
end

function M:newCommon(target, options)
  local defaults = {
    parent = nil,
  }

  if options.parent then
    options.parent:insert(target)
  end

  return target

end

-- target(displayObject), x, y, reference(referencePoint)の配列を渡す
function M:insertGroup(group, children)
  for i, child in ipairs(children) do
    group:insert(child.target)
    if child.reference then
      child.target:setReferencePoint(child.reference)
    else
      -- groupで使うときはcenterが一番使いやすいので
      child.target:setReferencePoint(display.CenterReferencePoint)
    end
    if child.x then
      child.target.x = child.x
    end
    if child.y then
      child.target.y = child.y
    end
  end
end

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

  self:newCommon(displayText, options)

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

  local target = display.newRect(o.top, o.left, o.width, o.height)
  target:setFillColor(_u.color(o.fillColor))
  if o.strokeColor then
    target:setStrokeColor(_u.color(o.strokeColor))
  end

  _u.copyPropertyIfExist(o, target, "x")
  _u.copyPropertyIfExist(o, target, "y")
  _u.copyPropertyIfExist(o, target, "alpha")

  self:newCommon(target, options)

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

  self:newCommon(this, options)

  return this
end

function M:newImage(options)
  local defaults = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    path = nil,
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.path, 'path is required')

  local display = display.newImageRect(o.path, o.width, o.height ); 
  display.x = o.x
  display.y = o.y

  self:newCommon(display, options)

  return display
end

function M:newTextField(options)
  local defaults = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    path = nil,
  }

  local o = _u.setDefault(options, defaults) 

  local target = native.newTextField(o.x, o.y, o.width, o.height); 

  self:newCommon(target, options)

  return target
end


function M:newVector(options)
  local defaults = {
    x = 0,
    y = 0,
    type = nil,
    fillColor = nil,
    strokeColor = nil,
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.type, 'type is required')

  local target
  if o.type == "circle" then
    target = display.newCircle(o.x, o.y, o.radius); 
  elseif o.type == "roundedRect" then
    target = display.newRoundedRect(o.x, o.y, o.width, o.height, o.radius); 
  end
  if o.fillColor then
    target:setFillColor(_u.color(o.fillColor))
  end
  if o.strokeColor then
    target:setStrokeColor(_u.color(o.strokeColor))
  end

  self:newCommon(target, options)

  return target
end

function M:newCircle(options)
  local defaults = {
    radius = nil,
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.radius, 'radius is required')
  o.type = "circle"

  return self:newVector(o)
end

function M:newRoundedRect(options)
  local defaults = {
    radius = nil,
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.radius, 'radius is required')
  o.type = "roundedRect"

  return self:newVector(o)
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
    tapArea = 30,
    longTapTime = 500,
    onTap = function() end,
    onLongTap = function() end,
    masked = true,
    scrollable = true,
    parent = nil,
  }
  local o = _u.setDefault(options, defaults) 

  local group = display.newGroup()

  local xGridUnit = math.floor(o.width / o.columns)
  local yGridUnit = math.floor(o.height / o.rows)

  local lists = display.newGroup()
  group:insert(lists)

  local touchBlock = self:newRect{top = o.x, left = o.y, width = o.width, height = o.height, alpha = 0}
  touchBlock.isHitTestable = true
  group:insert(touchBlock)

  local longTapTimer

  for i, value in ipairs(o.elements) do
    value:setReferencePoint(display.CenterReferencePoint)
    local xPosition = (i - 1) % o.columns + 1
    local yPosition = math.floor((i - 1) / o.columns) + 1
    value.x = o.x + ((xPosition - 1) * xGridUnit) + (xGridUnit / 2)
    value.y = o.y + ((yPosition - 1) * yGridUnit) + (yGridUnit / 2)

    local touchListener = function(e)
      if e.phase == "began" then
        longTapTimer = timer.performWithDelay(o.longTapTime, function()
          o.onLongTap(value)
        end)
      else
        if longTapTimer then
          timer.cancel(longTapTimer)
        end
      end

      if e.phase == "ended" then
        if math.abs(e.xStart - e.x) < o.tapArea and math.abs(e.yStart - e.y) < o.tapArea  then
          o.onTap(value)
        end
      end
    end
    value:addEventListener("touch", touchListener)
    lists:insert(value)
  end

  if o.masked then
    local mask = graphics.newMask(self.imagesPath .. "/mask_square.png")
    group:setMask( mask )
    group.maskX = o.x + o.width / 2
    group.maskY = o.y + o.height / 2
    -- 本来は256だが、マスクの制限で内部に4px黒が入るので、広めにマスク
    group.maskScaleX = o.width / 225
    group.maskScaleY = o.height / 225
  end

  if o.scrollable and o.height < lists.height then
    local yStart = lists.y
    local yLast = lists.y
    local endedTimer
    -- 普通にfocusを使うとelementsにイベントが飛ばなくなるため自力focus
    local focus = false

    local function endedCallback(newY)
      focus = false
      local yBottom = o.height - lists.height
      if yBottom > newY  then
        transition.to(lists, {y = o.height - lists.height, time = 300, transition=easing.inQuad})
        yStart, yLast = yBottom, yBottom
      elseif newY > 0 then
        transition.to(lists, {y = 0, time = 300, transition=easing.inQuad})
        yStart, yLast = 0, 0
      else
        yStart = yLast
      end
    end

    touchBlock:addEventListener("touch", function(e)
      local yDiff = e.y - e.yStart
      local newY = yStart + yDiff

      if e.phase == "began" then
        focus = true
      end

      if not focus then
        return
      end

      if e.phase == "moved" then
          lists.y = newY
          yLast = newY
          if endedTimer then
            timer.cancel(endedTimer)
          end
          endedTimer = timer.performWithDelay(100, function()
            endedCallback(newY)
          end)
      end

      if e.phase == "ended" then
        if endedTimer then
          timer.cancel(endedTimer)
        end
        endedCallback(newY)
      end
    end)
  end

  self:newCommon(group, options)
  
  return group
end


return M
