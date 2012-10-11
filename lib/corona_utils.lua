require 'sqlite3'
local _tlf = require 'helper.corona_timeline_factory'

local parent = require 'utils'
local M = parent:new()
local L = {}

L.TEMP_DATABASE_NAME = "string_length_check_only"
-- lua基本だとバイト数しか取れないため、sqlite3を利用して文字列長を取得
function M.stringLength(s)
  local path = system.pathForFile( L.TEMP_DATABASE_NAME, system.DocumentsDirectory )
  local db =  sqlite3.open( path )
  local statement = db:prepare[[SELECT length(?) as l]]
  statement:bind(1, s)
  local result 
  for row in statement:nrows() do
    result = row.l
  end
  db:close()
  return result
end

function M.printMemoryStatus()

    collectgarbage()
    M.p(collectgarbage("count"), "Memory Usage")

    local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
    M.p(textMem, "textureMemoryUsed")
end

function M.newTl()
  return _tlf:newTl()
end

function M.enterFrame(listener)
 Runtime:addEventListener( "enterFrame", listener )
end

function M.removeFrame(listener)
 Runtime:removeEventListener( "enterFrame", listener )
end

-- ブロックリスナを設定する
function M.addBlockListener(obj)
  if obj then
    obj.isHitTestable = true 
    obj:addEventListener("tap", function() return true end)
    obj:addEventListener("touch", function() return true end)
  end
end

-- イベントリスナ生成用関数
-- 二度押し防止機能
-- キャプチャリング防止機能
function M.makeListener(fn)
  -- ２度押し用フラグ
  local actioning = false
  return function(...)
    -- actioning == true の場合はボタンを押しても反応しない
    if actioning then
      return true
    end
    actioning = true
    fn(..., function()
      actioning = false
    end)
    
    -- キャプチャリング防止
    return true
  end
end

return M
