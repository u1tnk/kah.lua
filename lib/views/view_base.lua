local _u = require '..corona_utils'
local _helper = require '..helper.corona_display_helper'

local M = _u.newObject{}


-- createするたびに新しいgroupが必要なため
-- TODO ここの返り値をgroup自体にしてみよう。
function M:newView()
  local m = self:new()
  m.name = self.name
  m.group = _helper:newGroup()

  function m:insert(o)
    self.group:insert(o)
  end

  function m:insertGroup(targets)
    p('warn deprected! please use inserts')
    self:inserts(targets)
  end
  function m:inserts(targets)
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

-- 生成、エフェクト前
function M:create()
end
-- 生成、エフェクト後
function M:afterCreate()
end
-- 消去、エフェクト前
function M:exit()
end
-- 消去、エフェクト後
function M:destroy()
end

return M

