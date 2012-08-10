local parent = require 'view_base'

local M = parent:new()

-- createの前に呼び出される非同期処理のベース実装
function M:async(params, next)
  next()
end

return M
