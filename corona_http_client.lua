module(..., package.seeall) 
local _u = require 'utils'

Client = {
  headers = {}
  , protocol = "http"
  , host = "localhost"
  , method = "get"
  , port = 80
}

function Client:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Client:addHeader(name, value)
  self.headers[name] = value
end

function Client:request(options)
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
      p(e.response, "生レス")
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
    p(url, "url")
    network.request(url, options.method, networkListener, params)
end
