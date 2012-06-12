local _u = require 'utils'


local parent = require 'object'
local M = parent:new{
  headers = {},
  protocol = "http",
  host = "localhost",
  method = "get",
  port = 80, 
}
local L = {}

function M:addHeader(name, value)
  self.headers[name] = value
end

function M:request(options)
    local defaults = {
      headers = self.headers
      , method = self.method
      , host = self.host
      , port = self.port
      , protocol = self.protocol
      , path = ""
      , body = nil
      , queryParams = nil
      , onComplete = function() end
      , onError = function() end
    }
    o = _u.setDefault(options, defaults) 
    local headers = _u.setDefault(options.headers, defaults.headers) 
    o.headers = headers

    local function networkListener(e)
      if e.isError then
        o.onError()
      else
        o.onComplete(e.response)
      end
    end
    local params = {}
    params.headers = o.headers
    params.body = o.body
    local url = o.protocol .. "://" .. o.host .. ":" .. o.port .. o.path
    if queryParams then
      url = url .. "?"  .. _u.makeQuery(queryParams)
    end
    network.request(url, options.method, networkListener, params)
end

return M
