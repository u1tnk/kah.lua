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

function M:parentMethod(methodName)
  return getmetatable(self).__index[methodName]
end

function M:callParentMethod(methodName, ...)
  return self:parentMethod(methodName)(self, ...)
end

return M
