local _u = require 'utils'
local M = _u:newObject()
M.DEBUG = "debug"
M.D = M.DEBUG
M.INFO = "info"
M.I = M.INFO
M.WARN = "warn"
M.W = M.WARN
M.ERROR = "error"
M.E = M.ERROR

M.DEFAULT_LEVEL = M.DEBUG

M.level = M.DEFAULT_LEVEL

local LEVEL_VALUE = {
  debug = 1,
  info = 2,
  warning = 3,
  error = 4,
}

function M:isOutput(level)
  return LEVEL_VALUE[self.level] <= LEVEL_VALUE[level]
end

function M:baseOutput(level, o, description)
  if self:isOutput(level) then
    self:out(o, description)
  end
end

function M:debug(o, description)
  self:baseOutput(M.DEBUG, o, description)
end
M.d = M.debug

function M:info(o, description)
  self:baseOutput(M.INFO, o, description)
end
M.i = M.info

function M:warning(o, description)
  self:baseOutput(M.WARNING, o, description)
end
M.w = M.warning

function M:error(o, description)
  self:baseOutput(M.ERROR, o, description)
end
M.e = M.error

function M:out()
  print("base logger out")
end

return M
