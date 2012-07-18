local _u = require '....corona_utils'

local M = _u.newObject()

-- createするたびに新しいgroupが必要なため
function M:newLayout()
  local m = self:new()
  m.name = self.name
  m.group = _helper:newGroup()

  function m:insert(o)
    self.group:insert(o)
  end

  function m:insertGroup(targets)
    _helper:insertGroup(self.group, targets)
  end

  return m
end

function M:create() 
end 

function M:layer(sceneGroup) 
end

function M:exit() 
end 

function M:destroy() 
end 

return M
