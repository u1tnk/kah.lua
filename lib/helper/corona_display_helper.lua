local _u = require '..utils'

local parent = require '..object'
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

M.W = W
M.H = H
M.CX = CX
M.CY = CY

function M:newGroup(options)
  local defaults = {
    x = nil,
    y = nil,
    parent = nil,
  }
  local o = _u.setDefault(options, defaults) 
  local group = display.newGroup()
  _u.copyPropertyIfExist(o, group, {"x", "y"})

  self:newCommon(group, o)

  local helper = self
  local insertGroup = self.insertGroup
  function group:insertGroup(targets)
    insertGroup(helper, self, targets)
  end

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
    if child.target then
      group:insert(child.target)
      if child.reference then
        child.target:setReferencePoint(child.reference)
      else
        -- groupで使うときはcenterが一番使いやすいので
        child.target:setReferencePoint(display.CenterReferencePoint)
      end
      _u.copyPropertyIfExist(child, child.target, {"x", "y"})
    else 
      group:insert(child)
    end
  end
end

function M:newText(options)
  local defaults = {
    top = 0,
    left = 0,
    x = nil,
    y = nil,
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
    displayText = display.newText(o.text, o.left, o.top, o.width, o.height, o.font, o.size )
  else
    displayText = display.newText(o.text, o.left, o.top, o.font, o.size )
  end

  _u.copyPropertyIfExist(o, displayText, {"x", "y"})

  displayText:setTextColor(_u.color(o.color))

  self:newCommon(displayText, options)

  return displayText
end

function M:newBorderText(options)
  -- TODO borderText.text = 'hoge' で書き替わるようにする
  local defaults = {
    text = "",
    x = 0,
    y = 0,
    color = "FFF",
    border_color = "000",
    border_width = 1,
  }
  local o = _u.setDefault(options, defaults) 
  
  local group = _helper:newGroup()

  local size = o.size
  local color = o.color
  local border_color = o.border_color
  local left = o.x - o.border_width
  local right = o.x + o.border_width
  local top = o.y - o.border_width
  local bottom = o.y + o.border_width
  local text = o.text

  local function newShadowText(shadowOptions)
    local shadowText = self:newText(shadowOptions)
    shadowText:setTextColor(_u.color(border_color))
    return shadowText
  end

  local tempOptions = _u.clone(o)
  tempOptions.x = left
  local shadowText1 = newShadowText(tempOptions)

  tempOptions.y = top
  local shadowText2 = newShadowText(tempOptions)

  tempOptions.x = o.x
  local shadowText3 = newShadowText(tempOptions)

  tempOptions.x = right
  local shadowText4 = newShadowText(tempOptions)

  tempOptions.y = o.y
  local shadowText5 = newShadowText(tempOptions)

  tempOptions.y = bottom
  local shadowText6 = newShadowText(tempOptions)

  tempOptions.x = o.x
  local shadowText7 = newShadowText(tempOptions)

  tempOptions.x = left
  local shadowText8 = newShadowText(tempOptions)

  local mainText = self:newText(o)
  mainText:setTextColor(_u.color(color))

  group:insert(shadowText1)
  group:insert(shadowText2)
  group:insert(shadowText3)
  group:insert(shadowText4)
  group:insert(shadowText5)
  group:insert(shadowText6)
  group:insert(shadowText7)
  group:insert(shadowText8)
  group:insert(mainText)

  group.x = o.x
  group.y = o.y

  self:newCommon(group, options)

  return group
end

function M:newImage(options)
  local defaults = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    path = nil,
    baseDirectory = system.ResourceDirectory
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.path, 'path is required')

  local target = display.newImageRect(o.path, o.baseDirectory, o.width, o.height ); 
  target.x = o.x
  target.y = o.y

  self:newCommon(target, options)

  return target
end

function M:newImageBySheet(options)
  local defaults = {
    sheet = nil,
    index = nil,
    x = 0,
    y = 0,
    width = 0,
    height = 0,
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.sheet, 'sheet is required')
  assert(o.index, 'frame index is required')

  local target = display.newImageRect(o.sheet, o.index, o.width, o.height); 
  target.x, target.y = o.x, o.y

  self:newCommon(target, options)

  return target
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
    strokeWidth = nil,
    alpha = nil
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.type, 'type is required')

  local target
  if o.type == "circle" then
    target = display.newCircle(o.x, o.y, o.radius); 
  elseif o.type == "roundedRect" then
    target = display.newRoundedRect(o.x, o.y, o.width, o.height, o.radius); 
  elseif o.type == "rect" then
    target = display.newRect(o.x, o.y, o.width, o.height); 
  end
  if o.fillColor then
    target:setFillColor(_u.color(o.fillColor))
  end
  if o.strokeColor then
    target:setStrokeColor(_u.color(o.strokeColor))
  end

  _u.copyPropertyIfExist(o, target, {"alpha", "strokeWidth"})

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

function M:newRect(options)
  options.type = "rect"
  return self:newVector(options)
end



function M.toFront(object)
  if object and _u.size(object) > 0 then
    object:toFront()
  end
end

function M.layer(array)
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
    elements = nil,
    tapArea = 30,
    longTapTime = 500,
    onTap = function() end,
    onLongTap = function() end,
    masked = true,
    scrollable = true,
    parent = nil,
  }
  local o = _u.setDefault(options, defaults) 
  assert(_u.isNotEmpty(o.elements), 'elements is required')

  local group = display.newGroup()

  local xGridUnit = math.floor(o.width / o.columns)
  local yGridUnit = math.floor(o.height / o.rows)

  local lists = display.newGroup()
  group:insert(lists)

  local touchBlock = self:newRect{top = o.x, left = o.y, width = o.width, height = o.height, alpha = 0}
  -- 透明でも判定がある
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
  local overRange = o.height < lists.height

  if o.masked and overRange then
    local mask = graphics.newMask(self.imagesPath .. "/mask_square.png")
    group:setMask( mask )
    group.maskX = o.x + o.width / 2
    group.maskY = o.y + o.height / 2
    -- 本来は256だが、マスクの制限で内部に4px黒が入るので、広めにマスク
    group.maskScaleX = o.width / 225
    group.maskScaleY = o.height / 225
  end

  if o.scrollable and overRange  then
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
