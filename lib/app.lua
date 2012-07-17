local M = _u.newObject{
  sharedObjects = {},
  envPath = 'config.env',
  modelsRootPath = 'models.',
  modelsMockRootPath = 'models.mock.',
  viewsRootPath = 'views.',
}

function M:require(key)
  -- 常に絶対パス
  -- 上書きしたrequire.luaでキャッシュしているので何もしない
  return require("..." .. key)
end

M.env = M:require(M.envPath)
M.settings = M:require('lib.settings')

function M:requireModel(key)
  if self.env.standAlone then
    return self:require(M.modelsMockRootPath .. key)
  else
    return self:require(M.modelsRootPath .. key)
  end
end

function M:requireView(key)
  return self:require(M.viewsRootPath .. key)
end

function M:requireCommonView(key)
  return self:require(M.viewsRootPath .. 'common.' .. key)
end

function M:shared(key, value)
  if value then
    self.sharedObjects[key] = value
  end
  return self.sharedObjects[key]
end

function M:createSharedAccesor(attributes)
  for i, attribute in ipairs(attributes) do
    self[attribute] = function(self, value)
      return self:shared(attribute, value)
    end
  end
end

function M:initialize()
end

function M:getLogger()
  local logger = require 'kahlua.print_logger'
  logger.level = self.env.log_level
  return logger
end


return M
