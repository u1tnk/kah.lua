local _u = require '..utils'
local parent = require 'logger'
local M = parent:new()

function M:out(o, description)
  _u.p(o, description)
end

return M
