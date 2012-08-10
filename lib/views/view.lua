local _u = require '..corona_utils'
local L = {}

local M = _u.newObject{}

local _app = nil
local _helper = nil

M.requireBasePath = "views."

M.sceneStage = display.newGroup()
function M:getSceneStage()
  return self.sceneStage
end

M.DEFAULT_EFFECT_TIME = 500

M.EFFECT_CROSS_FADE = _u.newObject()
M.EFFECT_CROSS_FADE.time = M.DEFAULT_EFFECT_TIME
function M.EFFECT_CROSS_FADE:run(currentScene, nextScene, onComplete)
  _helper.newTl().parallel(function() 
    local tls =  {}
    if currentScene then
      table.insert(tls, _helper.newTl().to(currentScene.group, {alpha = 0, time = self.time}))
    end
    table.insert(tls, _helper.newTl().from(nextScene.group, {alpha = 0, time = self.time}))
    return tls
  end)
  .call(function() onComplete() end)
  .run()
end
M.DEFAULT_EFFECT = M.EFFECT_CROSS_FADE

M.currentLayout = nil
M.currentScene = nil
function M:go(name, options)
  assert(_app, "app is required, please call setApp")
  local defaults = {
    effect = M.DEFAULT_EFFECT,
    params = {},
  }
  local o = _u.setDefault(options, defaults)

  _u.printMemoryStatus()
  p(name, "goto scene!")

  local nextScene = _app:requireScene(name):newView()
  self:getSceneStage():insert(nextScene.group)


  local function afterLoad(loaded)

    L.execChildren(nextScene, "create", o.params or {}, loaded)
    nextScene:create(o.params or {}, loaded)
    if self.currentScene then
      self.currentScene:exit()
      L.execChildren(self.currentScene, "exit")
    end

    local nextLayout
    if not self.currentLayout or self.currentScene.layout ~= nextScene.layout then
      if self.currentLayout then
        self.currentLayout:exit()
        L.execChildren(self.currentLayout, "exit")
      end
      nextLayout = _app:requireLayout(nextScene.layout or 'default'):newView()
      L.execChildren(nextLayout, "create")
      nextLayout:create()
      nextLayout:layer(self:getSceneStage())

      -- layoutも同じエフェクト
      o.effect:run(self.currentLayout, nextLayout, function()
        if self.currentLayout then
          self.currentLayout.destroy()
          L.execChildren(self.currentLayout, "destroy")
          display.remove(self.currentLayout.group)
        end
        self.currentLayout = nextLayout
      end)
    end

    -- TODO 遷移エフェクト
    o.effect:run(self.currentScene, nextScene, function()
      if self.currentScene then
        self.currentScene:destroy()
        L.execChildren(self.currentScene, "destroy")
        display.remove(self.currentScene.group)
      end
      L.execChildren(nextScene, "enter", o.params or {}, loaded)
      nextScene:enter(o.params or {}, loaded)
      self.currentScene = nextScene
    end)
  end

  -- シーンに定義されたasyncメソッドを呼び出す
  _u.newTl({showIndicator = true})
  .call(function(next)
      nextScene:async(o.params, next)
    end)
  .run(afterLoad)
  
end

function L.execChildren(o, method, ...)
  if not o.childrenParts then
    return
  end
  for key, childParts in pairs(o.childrenParts) do 
    L.execChildren(childParts, method, ...)
    -- TODO newViewするのはcreateのみ
    local child = childParts:newView()
    child[method](child, ...)
    if method == 'create' then 
      o.children[child.name] = child
      o.group:insert(child.group)
    end
  end
end

function M:newParts(partsName, options)
  local parts = _app:requireParts(partsName)
  return parts:newParts(_helper:newGroup(), options)
end

-- appに依存してるので直接モジュールを返さない
return function(app)
  _app = app
  if _app.helper then
    _helper = _app.helper
  end
  return M
end

