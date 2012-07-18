local _u = require '..corona_utils'
local _helper = require '..helper.corona_display_helper'

local M = _u.newObject{}


-- createするたびに新しいgroupが必要なため
function M:newView()
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

function M:addChild(child)
  if not self.childrenParts then
    self.childrenParts = {}
  end
  if not self.children then
    self.children = {}
  end
  table.insert(self.childrenParts, child:newView())
end

function M:create()
end
function M:enter()
end
function M:exit()
end
function M:destroy()
end
    

return M

