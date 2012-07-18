local _u = require '..corona_utils'

local M = _u.newObject{}

-- appはrequire後にセットする 
local _app = nil
local _helper = nil

function M:setApp(app)
  _app = app
  if _app.helper then
    _helper = _app.helper
  end
end

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
  -- 遷移する際にCleanUpしないとParticle Candy呼び出し時にエラーになる
  -- TODO 使うページのexitでやって欲しい
  Particles.CleanUp()

  _u.printMemoryStatus()
  p(name, "goto scene!")

  local nextScene = _app:requireScene(name):newView()
  self:getSceneStage():insert(nextScene.group)


  local function afterLoad(loaded)
    native.setActivityIndicator(false)

    nextScene:create(o.params or {}, loaded)
    if M.currentScene then
      _u.callMethodIfExist(M.currentScene, "exit")
    end

    local nextLayout
    if not M.currentLayout or M.currentScene.layout ~= nextScene.layout then
      if M.currentLayout then
        M.currentLayout:exit()
      end
      nextLayout = _app:requireLayout(nextScene.layout or 'default'):newView()
      nextLayout:create()
      nextLayout:layer(self:getSceneStage())

      -- layoutも同じエフェクト
      o.effect:run(M.currentLayout, nextLayout, function()
        if M.currentLayout then
          M.currentLayout.destroy()
          display.remove(M.currentLayout.group)
        end
        M.currentLayout = nextLayout
        nextLayout = nil
      end)
    end

    -- TODO 遷移エフェクト
    o.effect:run(M.currentScene, nextScene, function()
      if M.currentScene then
        M.currentScene:destroy()
        display.remove(M.currentScene.group)
      end
      nextScene:enter(o.params or {}, loaded)
      M.currentScene = nextScene
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

