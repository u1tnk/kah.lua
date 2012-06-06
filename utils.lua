--[[
-- 
-- Tir(https://github.com/zedshaw/Tir)のutil.lua
-- License: http://tir.mongrel2.org/wiki/license.html
-- BSD License
--
-- Underscore.lua(https://github.com/mirven/underscore.lua)
-- MIT License
--
-- 等から引用、付加している
-- 改変、付加している
--
-- Example.
-- _ = require 'utils.lua'
]]--

module(..., package.seeall)
require 'json'

function tablePrint(tt, indent, done)
  local done = done or {}
  local indent = indent or 0
  local space = string.rep(" ", indent)

  if type(tt) == "table" then
    local sb = {}

    for key, value in pairs(tt) do
      table.insert(sb, space) -- indent it

      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, tablePrint(value, indent + 2, done))
        table.insert(sb, space) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\" ", tostring(value)))
      else
        table.insert(sb, string.format(
            "s = \"%s\"\n", tostring(key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function toString(data)
  if "nil" == type(data) then
    return tostring(nil)
  elseif "table" == type(data) then
    return tablePrint(data)
  elseif  "string" == type(data) then
    return data
  else
    return tostring(data)
  end
end

function dump(data, name)
    print(toString({name or "*", data}))
end
p = dump

-- Helper function that loads a file into ram.
function loadFile(path)
  local intmp = io.open(path, 'r')
  if not intmp then
    return nil
  end
  local content = intmp:read('*a')
  intmp:close()

  return content
end
function writeFile(path, str)
  local out = io.open(path, "w")
  out:write(str)
  out:close()
end

function update(target, source, keys)
  if keys then 
    for _, key in ipairs(keys) do
      target[key] = source[key]
    end
  else
    for k,v in pairs(source) do
      target[k] = v
    end
  end
end


-- useful for tables and params and stuff
function clone(source, keys)
  local target = {}
  update(target, source, keys)
  return target
end

copy = clone


-- Simplistic HTML escaping.
function htmlEscape(s)
  if s == nil then return '' end

  local esc, i = s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
  return esc
end

-- Simplistic URL decoding that can handle + space encoding too.
function urlDecode(data)
  return data:gsub("%+", ' '):gsub('%%(%x%x)', function (s)
    return string.char(tonumber(s, 16))
  end)
end

-- Simplistic URL encoding
function urlEncode(data)
  return data:gsub("\n","\r\n"):gsub("([^%w%-%-%.])", 
    function (c) return ("%%%02X"):format(string.byte(c)) 
  end)
end

-- Basic URL parsing that handles simple key=value&key=value setups
-- and decodes both key and value.
function urlParse(data, sep)
  local result = {}
  sep = sep or '&'
  data = data .. sep

  for piece in data:gmatch("(.-)" .. sep) do
    local k,v = piece:match("%s*(.-)%s*=(.*)")

    if k then
      result[urlDecode(k)] = urlDecode(v)
    else
      result[#result + 1] = urlDecode(piece)
    end
  end

  return result
end


-- Loads a source file, but converts it with line numbering only showing
-- from firstline to lastline.
function loadLines(source, firstline, lastline)
  local f = io.open(source)
  local lines = {}
  local i = 0

  -- TODO: this seems kind of dumb, probably a better way to do this
  for line in f:lines() do
    i = i + 1

    if i >= firstline and i <= lastline then
      lines[#lines+1] = ("%0.4d: %s"):format(i, line)
    end
  end

  return table.concat(lines,'\n')
end

sample = function(array)
  return array[math.random(1, #array)]
end

shuffle = function(array)
  math.randomseed(os.time())
  local result = utils.clone(array)
  local length = #array
  for i, v in ipairs(result) do
    if i == length then
      return result
    end
    local a = math.random(1, i + 1)
    result[i], result[a] = result[a], result[i]
  end
end


randomPosition = function(x, y, width, height)
  newX = x + math.random(-width, width)
  newY = y + math.random(-height, height)
  return newX, newY
end

calculateAlignLeft = function(group, obj)
  return (-1 * group.width / 2) + (obj.width / 2)
end

-- crawlspaceLibから
color = function(h, format)
  assert(h, "require color")
  local r,g,b,a
  local hex = string.lower(string.gsub(h,"#",""))
  if hex:len() >= 6 then
    r = tonumber(hex:sub(1, 2), 16)
    g = tonumber(hex:sub(3, 4), 16)
    b = tonumber(hex:sub(5, 6), 16)
    a = tonumber(hex:sub(7, 8), 16)
  elseif hex:len() == 3 then
    r = tonumber(hex:sub(1, 1) .. hex:sub(1, 1), 16)
    g = tonumber(hex:sub(2, 2) .. hex:sub(2, 2), 16)
    b = tonumber(hex:sub(3, 3) .. hex:sub(3, 3), 16)
    a = 255
  end
  if format == "table" then
    return {r,g,b,a or 255}
  else
    return r,g,b,a or 255
  end
end

setDefault = function(params, default)
local result = clone(default)
  if not params then
    return result
  end
  for k, v in pairs(params) do
    result[k] = v
  end
  return result
end
extend = setDefault

function size(table)
  local i = 0
  for k, v in pairs(table) do
    i = i + 1
  end
  return i
end

function equal(o1, o2)
  if o1 == nil and o2 == nil then
    return true
  end

  if o1 == nil or o2 == nil then
    return false
  end

  if type(o1) ~= type(o2) then
    return false
  end

  if type(o1) == "table" then

    if size(o1) ~= size(o2) then
      return false
    end

    for key, value in pairs(o1) do
      if type(value) == "table" then
        if not equal(value, o2[key]) then
          return false
        end
      else
        if value ~= o2[key] then
          return false
        end
      end
    end

  else
    return o1 == o2
  end
  return true
end

function checkPercent(percent)
  return math.random(1, 100) <= percent
end


--[[
-- underscore.luaから
-- https://github.com/mirven/underscore.lua
--]]--

function push(array, item)
	table.insert(array, item)
	return array
end

function pop(array)
	return table.remove(array)
end

function shift(array)
	return table.remove(array, 1)
end

function unshift(array, item)
	table.insert(array, 1, item)
	return array
end

-- ここまで

function sum(array)
  local result
  for i, v in ipairs(array) do
    if result then
      result = result + v
    else
      result = v
    end
  end
  return result
end

function extract(array, key)
  local result = {}
  for i, v in ipairs(array) do
   table.insert(result, v[key]) 
  end
  return result
end

