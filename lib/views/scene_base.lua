local parent = require 'view_base'

local M = parent:new()

-- createの前ろに呼び出される非同期処理のベース実装
function M:beforeCreate(params, next)
  -- beforeCreateはnext falseを呼ぶと次の処理を行わない
  next(true)
end

function M:afterCreate(params, next)
  next()
end

function M:getName()
  return string.gsub(self.name, 'views.scene.', '')
end

return M
