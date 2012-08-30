local parent = require 'view_base'

local M = parent:new()

function M:afterCreate(params, next)
  next()
end

function M:getName()
  return string.gsub(self.name, 'views.scene.', '')
end

return M
