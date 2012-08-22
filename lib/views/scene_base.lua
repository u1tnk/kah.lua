local parent = require 'view_base'

local M = parent:new()

-- createの前ろに呼び出される非同期処理のベース実装
function M:before_create(params, next)
  next()
end

function M:after_create(params, next)
  next()
end

return M
