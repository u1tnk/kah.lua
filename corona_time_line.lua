module(..., package.seeall)
local _u = require 'utils'

--[[
-- 非同期のアニメーション系をまとめる。
-- 現状effect.lua,transition.toに対応してるがtransition.fromあたりは簡単に対応できるので
-- 必要になったらやる
-- TODO : 汎用化したのでeffectへの依存を取る。methodのところで文字列じゃなくてfunctionを受け取ってonCompleteをtable内変数で渡すようにしてやれば良いか
-- sample
    local _tl = require 'corona_time_line'
    _tl.new()
    :add({type="effect", method="growLight"}, {x=_CX, y=_CY})
    :add({type="transition.to", target=my.menu1}, {y=100, time=1000})
    :add({type="effect", method="growLight"}, {x=_CX, y=_CY})
    :add({type="transition.to", target=my.menu2}, {y=300, time=1000})
    :run();
--]]--
function new()
  local obj = {}

  obj.queue = {}
  obj.add = function(self, basics, params)
    assert(self, "require self")
    assert(basics, "require basics")
    if not params then
      params = {}
    end
    _u.push(self.queue, {basics=basics, params=params})
    return self
  end


  obj.run = function(self, onComplete)
    local nextRun = function()
      if #self.queue == 0 then
        if onComplete then
          onComplete()
        end
        return
      end
      self:run(onComplete)
    end

    local e = _u.shift(self.queue)
    local basics = e.basics
    local params = e.params
    params.onComplete = nextRun
    if basics.type == "effect" then
      effect[basics.method](params)
    elseif basics.type == "transition.to" then
      transition.to(basics.target, params)
    end
    return self
  end
  return obj
end
