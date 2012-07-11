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
-- _u = require 'utils'
]]--

local parent = require 'object'
local M = parent:new()


function M:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local DEFAULT_PRINT_MAX_LENGTH = 100
M.printMaxLength = DEFAULT_PRINT_MAX_LENGTH
function M.tablePrint(tt, indent, done)
  local done = done or {}
  local indent = indent or 0
  local space = string.rep(" ", indent)

  if M.isTable(tt) then
    local sb = {}

    for key, value in pairs(tt) do
      table.insert(sb, space) -- indent it

      if M.isTable(value) and not done [value] then
        done [value] = true
        if M.isNumber(key) then
          table.insert(sb, " = {\n");
        else
          table.insert(sb, key .. " = {\n");
        end
        table.insert(sb, M.tablePrint(value, indent + 2, done))
        table.insert(sb, space) -- indent it
        table.insert(sb, "}\n");
      elseif M.isNumber(key) then
        table.insert(sb, string.format("\"%s\" ", tostring(value)))
      else
        local printValue = tostring(value)
        local cutLength = #printValue
        if printValue and #printValue > M.printMaxLength then
          printValue = printValue:sub(1, M.printMaxLength) .. "..."
        end
        table.insert(sb, string.format(
            "\"%s\" = \"%s\"\n", tostring(key), tostring(printValue)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function M.toString(data)
  if data == nil then
    return tostring(nil)
  elseif M.isTable(data) then
    return M.tablePrint(data)
  elseif M.isString(data) then
    return data
  else
    return tostring(data)
  end
end

function M.dump(data, name)
    print(M.toString({name or "*", data}))
end
M.p = M.dump

-- Helper function that loads a file into ram.
function M.loadFile(path)
  local intmp = io.open(path, 'r')
  if not intmp then
    return nil
  end
  local content = intmp:read('*a')
  intmp:close()

  return content
end

function M.writeFile(path, str)
  local out = io.open(path, "w")
  out:write(str)
  out:close()
end

function M.update(target, source, keys)
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
function M.clone(source, keys)
  local target = {}
  M.update(target, source, keys)
  return target
end

copy = clone


-- Simplistic HTML escaping.
function M.htmlEscape(s)
  if s == nil then return '' end

  local esc, i = s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
  return esc
end


-- Simplistic URL decoding that can handle + space encoding too.
function M.urlDecode(data)
  return data:gsub("%+", ' '):gsub('%%(%x%x)', function (s)
    return string.char(tonumber(s, 16))
  end)
end

-- Simplistic URL encoding
function M.urlEncode(data)
  return data:gsub("\n","\r\n"):gsub("([^%w%-%-%.])", 
    function (c) return ("%%%02X"):format(string.byte(c)) 
  end)
end

-- Basic URL parsing that handles simple key=value&key=value setups
-- and decodes both key and value.
function M.urlParse(data, sep)
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
function M.loadLines(source, firstline, lastline)
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

function M.sample(array)
  return array[math.random(1, #array)]
end

function M.shuffle(array)
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


function M.randomPosition(x, y, width, height)
  newX = x + math.random(-width, width)
  newY = y + math.random(-height, height)
  return newX, newY
end

function calculateAlignLeft(group, obj)
  return (-1 * group.width / 2) + (obj.width / 2)
end

-- crawlspaceLibから
function M.color(h, format)
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

function M.setDefault(params, default)
local result = M.clone(default)
  if not params then
    return result
  end
  for k, v in pairs(params) do
    result[k] = v
  end
  return result
end
extend = setDefault

function M.size(table)
  local i = 0
  for k, v in pairs(table) do
    i = i + 1
  end
  return i
end

function M.equal(o1, o2)
  if o1 == nil and o2 == nil then
    return true
  end

  if o1 == nil or o2 == nil then
    return false
  end

  if type(o1) ~= type(o2) then
    return false
  end

  if M.isTable(o1) then

    if M.size(o1) ~= M.size(o2) then
      return false
    end

    for key, value in pairs(o1) do
      if M.isTable(value) then
        if not M.equal(value, o2[key]) then
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

function M.checkPercent(percent)
  return math.random(1, 100) <= percent
end


--[[
-- underscore.luaから
-- https://github.com/mirven/underscore.lua
--]]--

function M.push(array, item)
	table.insert(array, item)
	return array
end

function M.pop(array)
	return table.remove(array)
end

function M.shift(array)
	return table.remove(array, 1)
end

function M.unshift(array, item)
	table.insert(array, 1, item)
	return array
end

-- ここまで

function M.sum(array)
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

function M.extract(array, key)
  local result = {}
  for i, v in ipairs(array) do
   table.insert(result, v[key]) 
  end
  return result
end

-- make query string for url
function M.makeQuery(params)
  if params == nil or M.size(params) == 0 then
    return ""
  end
  local _ = {}
  for key, value in pairs(params) do
    _[#_ + 1] = key .. "=" .. M.urlEncode(tostring(value))
  end
  return table.concat(_, "&")
end

-- sql escape for sqlite3
function M.sqlEscape(s)
  if s == nil then return '' end

  local esc, i = s:gsub("'", "''")
  return esc
end

function M.newObject(o)
  return parent:new(o)
end


function M.isNotEmpty(o)
  return not M.isEmpty(o)
end

function M.isEmpty(o)
  if not o then
    -- false and nil
    return true
  end
  if M.isTable(o) then
    return M.size(o) == 0
  elseif M.isString(o)  then
    return o == ""
  elseif M.isNumber(o) then
    return o == 0
  else 
    return true
  end
end

function M.copyPropertyIfExist(from, to, property)
  local properties 
  if M.isTable(property) then
    properties = property
  else
    properties = {}
    table.insert(properties, property)
  end

  for i, p in ipairs(properties) do
    local value = from[p]
    if value then
      to[p] = value
    end
  end

  return to
end

function M.isFunction(o)
  return type(o) == "function"
end

function M.isString(o)
  return type(o) == "string"
end

function M.isNumber(o)
  return type(o) == "number"
end

function M.isTable(o)
  return type(o) == "table"
end


function M.makeUrl(options)
  local defaults =  {
    protocol = "http",
    host = "localhost",
    port = 80,
    path = "",
    queryParams = nil,
  }
  local o = M.setDefault(options, defaults)
  local url = {o.protocol, "://", o.host}
  if o.port and
    not ( o.protocol == "http" and o.port == 80) 
    then
    url[#url + 1] = ":"
    url[#url + 1] = o.port
  end
  url[#url + 1] = o.path
  if o.queryParams then
    url[#url + 1] = "?"
    url[#url + 1] = _u.makeQuery(o.queryParams)
  end
  return table.concat(url)
end

return M
