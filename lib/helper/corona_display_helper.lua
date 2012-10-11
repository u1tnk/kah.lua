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
  _u.copyPropertiesIfExist(o, group, {"x", "y"})

  self:newCommon(group, o)

  local helper = self
  local inserts = self.inserts
  function group:inserts(targets)
    inserts(helper, self, targets)
  end
  function group:insertGroup(targets)
    self:inserts(targets)
  end

  return group
end

function M:newCommon(target, options)
  if options.parent then
    options.parent:insert(target)
  end

  _u.copyPropertiesIfExist(options, target, {"alpha", "xScale", "yScale", "rotation", "blendMode"})

  if options.originX or options.originY then
    target:setReferencePoint(self:resolveReferencePoint(options))
    target.x = options.x
    target.y = options.y
  end

  function target:show()
    target:setVisible(true)
  end

  function target:hide()
    target:setVisible(false)
  end

  function target:setScale(scale)
    target.xScale = scale
    target.yScale = scale
  end

  function target:setVisible(isVisible)
    local alpha = 0
    if isVisible then
      alpha = 1
    end
    target.alpha = alpha
  end

  return target
end

function M:insertGroup(group, children)
  self:inserts(group, children)
end
-- target(displayObject), x, y, reference(referencePoint)の配列を渡す
function M:inserts(group, children)
  for i, child in ipairs(children) do
    if child.target then
      group:insert(child.target)
      if child.reference then
        child.target:setReferencePoint(child.reference)
      end
      _u.copyPropertiesIfExist(child, child.target, {"x", "y"})
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

  _u.copyPropertiesIfExist(o, displayText, {"x", "y"})

  displayText:setTextColor(_u.color(o.color))

  self:newCommon(displayText, options)

  return displayText
end

-- originX,originYからdisplay.CenterRightReferencePoint等に変換
-- originX = CENTER,RIGHT,LEFT
-- originY = CENTER,BOTTOM,TOP
local REFERENCE_POINT_MAP = {
  CENTER = {
    LEFT   = display.CenterLeftReferencePoint,
    CENTER = display.CenterReferencePoint,
    RIGHT  = display.CenterRightReferencePoint,
  },
  TOP = {
    LEFT   = display.TopLeftReferencePoint,
    CENTER = display.TopCenterReferencePoint,
    RIGHT  = display.TopRightReferencePoint,
  },
  BOTTOM = {
    LEFT   = display.BottomLeftReferencePoint,
    CENTER = display.BottomCenterReferencePoint,
    RIGHT  = display.BottomRightReferencePoint,
  },
}

function M:resolveReferencePoint(options)
  local o = _u.setDefault(options, {
    originX = "CENTER", 
    originY = "CENTER", 
  }) 
  return REFERENCE_POINT_MAP[o.originY][o.originX]
end

function M:newRightAlignText(options)
  local text = self:newText(options)
  text:setReferencePoint(display.CenterRightReferencePoint)
  text.x = options.right
  return text
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

function M:newTextWithLineHeight(options)
  local defaults = {
    top = 0,
    left = 0,
    x = nil,
    y = nil,
    text = "",
    parent = nil,
    lineHeight = 0,
    align = "left"
  }
  local o = _u.setDefault(options, defaults) 

  local lines = {}
  for line in string.gmatch(o.text, "[^\n]+") do
    table.insert(lines, line)
  end

  local group = display.newGroup()
  local textTop = 0
  for _, line in ipairs(lines) do
    -- 一旦左寄せで作る
    local t = _helper:newText{
      parent = group,
      text = line,
      top = textTop,
      left = 0,
      color = o.color,
      font = o.font,
      size = o.size
    }
    textTop = textTop + t.height + o.lineHeight
  end

  -- align == "center" ならテキストを真ん中寄せにする
  -- align == "right" は未実装
  if o.align == "center" then
    local groupWidth = group.width
    for i = 1, group.numChildren do
      group[i].x = groupWidth / 2
    end
  end

  -- 位置設定
  if o.x then
    group.x = o.x - (group.width / 2)
  else
    group.x = o.left
  end
    
  if o.y then
    group.y = o.y - (group.height / 2)
  else
    group.y = o.top
  end

  self:newCommon(group, options)
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
    width = W,
    height = H,
    type = nil,
    fillColor = nil,
    strokeColor = nil,
    strokeWidth = nil,
  }
  local o = _u.setDefault(options, defaults) 
  assert(o.type, 'type is required')

  local target
  if o.type == "circle" then
    target = display.newCircle(o.x, o.y, o.radius); 
  elseif o.type == "roundedRect" then
    target = display.newRoundedRect(o.x, o.y, o.width, o.height, o.radius); 
  elseif o.type == "rect" then
    target = display.newRect(0, 0, o.width, o.height); 
    target.x, target.y = o.x, o.y
  end
  if o.fillColor then
    target:setFillColor(_u.color(o.fillColor))
  end
  if o.strokeColor then
    target:setStrokeColor(_u.color(o.strokeColor))
  end

  _u.copyPropertiesIfExist(o, target, {"strokeWidth"})

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

function M:toFront(object)
  if object and _u.size(object) > 0 then
    object:toFront()
  end
end

function M:layer(array)
  for key, value in pairs(array) do
    M:toFront(value)
  end
end

function M:setVisible(isVisible, targets)
  local alpha = 0
  if isVisible then
    alpha = 1
  end
  self:setPropertyMulti(targets, "alpha", alpha)
end

function M:show(targets)
  self:setVisible(true, targets)
end

function M:hide(targets)
  self:setVisible(false, targets)
end

-- 一括設定
function M:setPropertyMulti(targets, propertyName, value)
  if _u.isTable(propertyName) then
    local properties = propertyName
    for k, v in pairs(properties) do
      self:setPropertyMulti(targets, k, v)
    end
  else
    for _, v in ipairs(targets) do
      v[propertyName] = value
    end
  end
end

function M:newRotateListener(options)
  local defaults = {
    targets = nil,
    speed = 1, -- 小数点以下対応
    directionSign = 1, -- -1 to left rotate
  }
  local o = _u.setDefault(options, defaults) 

  return function()
    local rotation = o.targets[1].rotation + o.speed * o.directionSign
    if math.abs(rotation) >= 360 then
      rotation = 0
    end
    self:setPropertyMulti(o.targets, "rotation", rotation)
  end
end

function M:remove(target)
  if not target then
    return
  end
  if #target > 0 then
    local targets = target
    for _, v in ipairs(targets) do
      self:remove(v)
    end
  else
    display.remove(target)
  end
end

function M:newSinWaveListener(options)
  local o = _u.setDefault(options, {
    target = nil,
    width = 0,
    height = 0,
    speed = 1,
  })
  local count = 0
  local originX = o.target.x
  local originY = o.target.y
  return function()
    if count >= 360 then
      count = count - 360
    end
    count = count + o.speed
    o.target.x = originX + math.sin(math.rad(count)) * o.width
    o.target.y = originY + math.sin(math.rad(count)) * o.height
  end
end

function M:newSinBlinkListener(options)
  local o = _u.setDefault(options, {
    target = nil,
    speed = 1,
    maxAlpha = 1,
  })
  -- 最初はついていて欲しい
  local count = 90
  return function()
    if count >= 360 then
      count = count - 360
    end
    count = count + o.speed
    o.target.alpha = o.maxAlpha * math.abs(math.sin(math.rad(count)))
  end
end

function M:createImageSheet(options)
  local o = _u.setDefault(options, {
    path = nil,
    width = nil,
    height = nil,
    count = nil,
  })
  _u.propertyRequired(o, "path")
  _u.propertyRequired(o, "width")
  _u.propertyRequired(o, "height")
  _u.propertyRequired(o, "count")

  return graphics.newImageSheet(o.path, {
      width = o.width, 
      height = o.height, 
      numFrames = o.count, 
    }
  )
end

function M:newSprite(options)
  local o = _u.setDefault(options, {
    width = nil,
    height = nil,
    path = nil,
    start = 1,
    count = nil,
    time = 1000,
    loopCount = 0,
    loopDirection = 'forward',
    x = CX,
    y = CY,
    onComplete = nil,
    removeOnComplete = true,
    startImmediately = true,
  })

  _u.propertyRequired(o, "path")

  local imageSheet = self:createImageSheet(o)
  local sprite = display.newSprite(imageSheet, o)
  sprite.x, sprite.y = o.x, o.y

  self:newCommon(sprite, o)

  function sprite:setOnComplete(onComplete)
    o.onComplete = onComplete
  end

  sprite:addEventListener("sprite", function(e)
    if e.phase == 'ended' then
      if o.removeOnComplete then
        display.remove(sprite)
      end
      if o.onComplete then
        o.onComplete()
      end
    end
  end)
  if o.startImmediately then
    sprite:play()
  end
  return sprite
end

function M:newBlinkListener(options)
  local defaults = {
    targets = nil,
    interval = 6,
  }
  local o = _u.setDefault(options, defaults) 

  local function toggle()
    if o.target.alpha > 0 then
      o.target:hide()
    else
      o.target:show()
    end
  end
  -- 最初の一回は変わって欲しい
  local updateFrameCounter = o.interval
  return function()
    if updateFrameCounter >= o.interval then
      updateFrameCounter = 0
      toggle()
    else
      updateFrameCounter = updateFrameCounter + 1
    end
  end
end


return M
