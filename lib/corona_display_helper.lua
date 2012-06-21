local _u = require 'utils'

local parent = require 'object'
local M = parent:new{
  defaultFont = native.systemFont,
  defaultFontSize = 24,
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
  }
  local o = _u.setDefault(options, defaults) 
  local displayText
  if o.width > 0 and o.height > 0 then
    displayText = display.newText(o.text, o.x, o.y, o.width, o.height, o.font, o.size )
  else
    displayText = display.newText(o.text, o.x, o.y, o.font, o.size )
  end
  displayText:setTextColor(_u.color(o.color))

  return displayText
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
  assert(o.path)

  local display = display.newImageRect( o.path, o.width, o.height ); 
  display.x = o.x
  display.y = o.y

  return display
end



return M
