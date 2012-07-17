local _u = require '..corona_utils'
local _helper = require '..helper.corona_display_helper'

local M = _u.newObject{}

-- appはrequire後にセットする 
local _app = nil

function M.setApp(app)
  _app = app
  _u = _app.u
  _helper = _app.helper
end

M.requireBasePath = "views."

-- createするたびに新しいgroupが必要なため
function M:newScene()
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

sceneStage = display.newGroup()
function M.getSceneStage()
  return sceneStage
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

local currentScene 
function M.go(name, options)
  assert(_app, "app is required, please call setApp")
  local defaults = {
    effect = M.DEFAULT_EFFECT,
    params = {},
  }
  local o = _u.setDefault(options, defaults)
  -- 遷移する際にCleanUpしないとParticle Candy呼び出し時にエラーになる
  -- TODO 使うページのexitでやって欲しい
  Particles.CleanUp()

  _u.printMemoryStatus()
  p(name, "goto scene!")
  if currentScene then
    _u.callMethodIfExist(currentScene, "exit")
  end

  local nextScene = _app:requireView(name):newScene()
  M.getSceneStage():insert(nextScene.group)


  local function afterLoad(loaded)
    _u.callMethodIfExist(nextScene, "create", o.params or {}, loaded)

    native.setActivityIndicator(false)
    -- TODO 遷移エフェクト
    o.effect:run(currentScene, nextScene, function()
      if currentScene then
        _u.callMethodIfExist(currentScene, "destroy")
        display.remove(currentScene.group)
      end
      _u.callMethodIfExist(nextScene, "enter", o.params or {}, loaded)
      currentScene = nextScene
      nextScene = nil
    end)

  end
  local lazyLoads 
  if nextScene.load then
    lazyLoads = nextScene:load(o.params)
  end

  if _u.isNotEmpty(lazyLoads) then
    native.setActivityIndicator(true)
    _model.runLazyLoads(lazyLoads, afterLoad)
  else
    afterLoad()
  end
  
end
    

return M

