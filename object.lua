--[[
-- 継承するオブジェクト全般の親
--]]
local M = {}

function M:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

return M
