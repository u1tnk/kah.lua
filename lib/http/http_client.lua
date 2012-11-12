local _u = require '..utils'
local http = require 'socket.http'
local ltn12 = require 'ltn12'

local parent = require '..object'
local M = parent:new{
  headers = {},
  protocol = "http",
  host = "localhost",
  method = "GET",
  port = nil,
  path = "",
  body = nil,
  redirect = true,
  params = nil
}

function M:serviceRootUrl()
  return _u.makeUrl(self)
end

function M:addHeader(name, value)
  self.headers[name] = value
end

function M:setDefault(options)
  local defaults = {
    headers = self.headers,
    protocol = self.protocol,
    host = self.host,
    method = self.method,
    port = self.port,
    path = self.path,
    body = self.body,
    redirect = self.redirect,
    params = self.params,
  }
  local o = _u.setDefault(options, defaults)

  if o.body then
    o.headers['content-length'] = string.len(o.body)
    o.source = ltn12.source.string(o.body)
  end

  return o
end

function M:request(options)
  local o = self:setDefault(options)

  local responseBuffer = {}

  local requestUrl = _u.makeUrl(o)
  local result, code, responseHeaders = http.request{
    url = requestUrl,
    method = o.method,
    headers = o.headers,
    rediret = o.redirect,
    source = o.source,
    sink = ltn12.sink.table( responseBuffer )
  }

  local responseBody = table.concat(responseBuffer)
  if not result or code ~= 200 then
    _u.p("request error")
    _u.p(code, "code")
    _u.p(responseHeaders, "headers")
    _u.p(responseBody, "responseBody")
    return nil
  end

  return {
    code=code,
    body=responseBody,
    headers=responseHeaders,
  }
end
return M
