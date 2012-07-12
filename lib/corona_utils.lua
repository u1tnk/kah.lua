require 'sqlite3'

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

return M
