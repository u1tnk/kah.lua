--[[
- 
-- Tir(https://github.com/zedshaw/Tir)のutil.lua
-- License: http://tir.mongrel2.org/wiki/license.html
-- BSD License
--
-- Underscore.lua(https://github.com/mirven/underscore.lua)
-- MIT License
--
-- 等から引用、改変している
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


-- import form http://bsharpe.com/code/coronasdk-how-to-know-if-a-file-exists
function M.fileExists(fileName, base)
  assert(fileName, "fileName is missing")
  local base = base or system.ResourceDirectory
  local filePath = system.pathForFile( fileName, base )
  local exists = false
 
  if (filePath) then -- file may exist. won't know until you open it
    local fileHandle = io.open( filePath, "r" )
    if (fileHandle) then -- nil if no file found
      exists = true
      io.close(fileHandle)
    end
  end
 
  return(exists)
end

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
  local result = M.clone(array)
  local length = #array
  for i, v in ipairs(result) do
    local a = math.random(1, i)
    result[i], result[a] = result[a], result[i]
    if i == length then
      return result
    end
  end
end


function M.randomPosition(x, y, width, height)
  newX = x + math.random(-width, width)
  newY = y + math.random(-height, height)
  return newX, newY
end

-- 部分配列を返す、sizeと違い配列のみが対象
function M.subArray(array, startIndex, endIndex)
  if not endIndex then
    endIndex = #array
  end
  local result = {}
  for i, v in ipairs(array) do
    if startIndex <= i and i <= endIndex then
      table.insert(result, v)
    end
  end
  return result
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
  if not params then
    return default or {}
  end
  if not default then
    return params
  end
  for k, v in pairs(default) do
    if params[k] == nil then
      params[k] = v
    end
  end
  return params
end
-- alias
M.include = M.setDefault

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
  if item then
    table.insert(array, item)
  end
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
M.add = M.push

function M.each(array, fn)
  local results = {}
  for index, value in ipairs(array) do
    local result = fn(index, value)
    if result ~= nil then
      table.insert(results, result)
    end
  end
  
  return results
end

function M.every(array, fn)
  for index, value in ipairs(array) do
    local result = fn(index, value)
    if result == false or result == nil then
      return false
    end
  end

  return true
end

function M.any(array, fn)
  for index, value in ipairs(array) do
    local result = fn(index, value)
    if result  then
      return true
    end
  end

  return false
end

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

function M.extract(key, array)
  local result = {}
  for i, v in ipairs(array) do
   table.insert(result, v[key]) 
  end
  return result
end

-- 配列の中で指定したプロパティの値が一番大きいオブジェクトを返す
function M.maxOfProperty(array, prop)
  local max = nil
  for _, v in ipairs(array) do
    if max == nil then
      max = v
    elseif max[prop] < v[prop] then
      max = v
    end
  end
  return max
end

-- 配列の中で指定したプロパティの値が一番小さいオブジェクトを返す
function M.minOfProperty(array, prop)
  local min = nil
  for _, v in ipairs(array) do
    if min == nil then
      min = v
    elseif max[prop] > v[prop] then
      min = v
    end
  end
  return min
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

-- tableならそのまま、その他なら1要素のtableを作る
function M.toTable(elements)
  if M.isTable(elements) then
    return elements
  else
    return {elements}
  end
end

function M.removeProperties(target, property)
  for _, p in ipairs(M.toTable(property)) do
    target[p] = nil
  end
  return target
end

function M.copyProperties(from, to, property)
  for _, p in ipairs(M.toTable(property)) do
    to[p] = from[p]
  end
  return to
end

function M.copyPropertiesIfExist(from, to, property)
  for _, p in ipairs(M.toTable(property)) do
    if from[p] then
      to[p] = from[p]
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
    params = nil,
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
  -- TODO POST、PUTの時はURLにパラメータを含めないにする
  if o.params then
    url[#url + 1] = "?"
    url[#url + 1] = _u.makeQuery(o.params)
  end
  return table.concat(url)
end

function M.getKeyByValue(table, value)
  for k, v in pairs(table) do
    if v == value then
      return k
    end
  end
end

-- 指定したfunction名があれば呼ぶ o.foo(...)
function M.callIfExist(o, functionName, ...)
  if o[functionName] then
    return o[functionName](...)
  end
end

-- 指定したfunction名があれば呼ぶ o:foo(...)
function M.callMethodIfExist(o, functionName, ...)
  if not o then
    return
  end
  if o[functionName] then
    return o[functionName](o, ...)
  end
end

-- javascript の bind 関数と同様の処理を行う
function M.bind(object, method, ...)
  local args1 = {...}
  return function(...)
    local args2 = {...}
    local args = _u.arrayConcat(args1, args2)
    return method(object, unpack(args))
  end
end

-- カリー化を行う
-- 例
-- function hoge(x, y) return x + y end
-- 上記の関数に対してcurried = _u.curry(hoge, 10)とし
-- curried(20)とすると30が返ってくる
function M.curry(method, ...)
  local args1 = {...}
  return function(...)
    local args2 = {...}
    local args = _u.arrayConcat(args1, args2)
    return method(unpack(args))
  end
end

-- 配列同士の連結を行う
function M.arrayConcat(table1, table2)
  local concatedArray = {}
  if table1 ~= nil then
    for _, value in ipairs(table1) do
      table.insert(concatedArray, value)
    end
  end
  if table2 ~= nil then
    for _, value in ipairs(table2) do
      table.insert(concatedArray, value)
    end
  end
  return concatedArray
end

-- http://symfoware.blog68.fc2.com/blog-entry-455.html を元に実装
function M.split(str, delim)
  if string.find(str, delim) == nil then
      return { str }
  end

  local result = {}
  local pat = "(.-)" .. delim .. "()"
  local lastPos
  for part, pos in string.gfind(str, pat) do
      table.insert(result, part)
      lastPos = pos
  end
  table.insert(result, string.sub(str, lastPos))
  return result
end


function M.camelize(str)
  local parts = M.split(str, "_")
  local temp = {}
  for i, v in ipairs(parts) do
    if i == 1 then
      temp[i] = v
    else
      temp[i] = string.sub(v, 1, 1):upper() .. string.sub(v, 2)
    end
  end
  return table.concat(temp)
end

function M.camelizeKeys(t)
  local result = {}
  for key, value in pairs(t) do

    local camelizedKey
    if M.isNumber(key) then
      camelizedKey = key
    else
      camelizedKey = M.camelize(key)
    end

    if M.isTable(value) then
      result[camelizedKey] = M.camelizeKeys(value)
    else
      result[camelizedKey] = value
    end

  end
  return result
end

function M.existsValue(t, e)
  for k, v in pairs(t) do
    if v == e then
      return true
    end
  end
  return false
end

function M.propertyRequired(o, name)
  assert(o[name], name .. ' is required')
end

-- nilを0に変換する
-- 数値以外を渡すとerror
function M.safetyNumber(v)
  if not v then
    return 0
  elseif M.isNumber(tonumber(v)) then
    return tonumber(v)
  else
    assert(false, 'safetyNumberは数値かnilのみ受け付けます')
  end
end

function M.positionToRotation(ax, ay, bx, by)
  return math.deg(math.atan2(ay - by, ax - bx))
end

-- 現在時刻を取得する(単位: 秒)
function M.getCurrentTime()
  return os.time(os.date('*t'))
end

return M
