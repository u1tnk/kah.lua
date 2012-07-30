local LOGGER = require '..logger.logger'

local M = _u.newObject()

-- set parameter

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
  return self.name ==  LOGGER.PRODUCTION
end


return M


