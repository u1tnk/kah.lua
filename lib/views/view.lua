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
  _u.newTl().parallel(function() 
    local tls =  {}
    if currentScene then
      table.insert(tls, _u.newTl().to(currentScene.group, {alpha = 0, time = self.time}))
    end
    table.insert(tls, _u.newTl().from(nextScene.group, {alpha = 0, time = self.time}))
    return tls
  end)
  .run(onComplete)
end

M.RIGHT_TO_LEFT = _u.newObject()
function M.RIGHT_TO_LEFT:run(currentScene, nextScene, onComplete)
  local time = 150
  if currentScene then
    nextScene.group.x = 1440
    _u.newTl()
    .to(currentScene.group, {x = -960, time = time})
    .delay(200)
    .to(nextScene.group, {x = 0, time = time})
    .run(onComplete)
  else
    _u.newTl()
    .from(nextScene.group, {x = 640, time = time})
    .run(onComplete)
  end
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

  self:disableTouch()

  _u.printMemoryStatus()
  p(name, "goto scene!")

  local nextScene = _app:requireScene(name):newView()
  self:getSceneStage():insert(nextScene.group)

  local function onBeforeCreateFinish(isSuccess)
    if not isSuccess then
      self:enableTouch()
      return
    end
    L.execChildren(nextScene, "create", o.params or {})
    nextScene:create(o.params or {})
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

      -- layoutと同じ時間で同じエフェクトすれば同じ時間に終わるはず…というイマイチな処理
      o.effect:run(self.currentLayout, nextLayout, function()
        if self.currentLayout then
          self.currentLayout.destroy()
          L.execChildren(self.currentLayout, "destroy")
          display.remove(self.currentLayout.group)
        end
        self.currentLayout = nextLayout
      end)
    end

    o.effect:run(self.currentScene, nextScene, function()
      if self.currentScene then
        self.currentScene:destroy()
        L.execChildren(self.currentScene, "destroy")
        display.remove(self.currentScene.group)
      end
      L.execChildren(nextScene, "afterCreate", o.params or {})
      self.currentScene = nextScene
      nextScene:afterCreate(o.params or {}, function() self:enableTouch() end)
    end)
  end

  nextScene:beforeCreate(o.params, onBeforeCreateFinish)
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

function M:disableTouch()
  if not self.touchGuard then
    self.touchGuard = _helper:newRect{x = CX, y = CY, width = W, height = H}
    self.touchGuard.isVisible = false
    self.touchGuard.isHitTestable = true
    self.touchGuard:addEventListener("tap", function() 
      return true;
    end)
    self.touchGuard:addEventListener("touch", function() 
      return true;
    end)
  end
end

function M:enableTouch()
  if self.touchGuard then
    display.remove(self.touchGuard)
    self.touchGuard = nil
  end
end


-- appに依存してるので直接モジュールを返さない
return function(app)
  _app = app
  if _app.helper then
    _helper = _app.helper
  end
  return M
end
