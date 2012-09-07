local LOGGER = require '..logger.logger'

local M = _u.newObject()

M.DEVELOPMENT = 1
M.STAGING = 2
M.PRODUCTION = 4
-- set parameter
M.environment = M.DEVELOPMENT -- or M.STAGING, M.PRODUCTION

-- simulatro or device
M.target = "simulator"

-- host name and port
M.host = "localhost"
M.port = "8080"

function M:rootUrl()
  _u.makeUrl{host = self.host, port = self.port}
end

-- debug,info,warning,error
M.logLevel = LOGGER.DEBUG
M.standAlone = true

function M:isProduction()
  return self.environment ==  M.PRODUCTION
end

function M:isStaging()
  return self.environment ==  M.STAGING
end

function M:isDevelopment()
  return self.environment ==  M.DEVELOPMENT
end

return M


