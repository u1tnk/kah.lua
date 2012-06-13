local _u = require 'utils'
local http = require 'socket.http'
local ltn12 = require 'ltn12'


local parent = require 'object'
local M = parent:new{
  headers = {},
  protocol = "http",
  host = "localhost",
  method = "GET",
  port = nil, 
  path = "",
  body = nil,
  redirect = true,
  queryParams = nil,
}
local L = {}
function M.makeUrl(o)
  local url = {o.protocol, "://", o.host}
  if o.port then
    url[#url + 1] = ":"
    url[#url + 1] = o.port
  end
  url[#url + 1] = o.path
  if o.queryParams then
    url[#url + 1] = "?"
    url[#url + 1] = _u.makeQuery(o.queryParams)
  end
  return table.concat(url)
end

function M:addHeader(name, value)
  self.headers[name] = value
end

function M:setDefault(options, defaults)
  local defaults = {
    headers = self.headers,
    protocol = self.protocol,
    host = self.host,
    method = self.method,
    port = self.port, 
    path = self.path,
    body = self.body,
    redirect = self.redirect,
    queryParams = self.queryParams,
  }
  local o = _u.setDefault(options, defaults) 
  local headers = _u.setDefault(options.headers, self.headers) 
  o.headers = headers
  return o
end

function M:request(options)
  o = self:setDefault(options)

  local responseBuffer = {}

  local result, code, responseHeaders = http.request{
    url = M.makeUrl(o),
    method = o.method,
    headers = o.headers,
    rediret = o.redirect,
    source = ltn12.source.string(o.body),
    sink = ltn12.sink.table( responseBuffer ),
  }

  local responseBody = table.concat(responseBuffer)
  if not result or code ~= 200 then
    _u.p("request error")
    _u.p(code, "code")
    _u.p(headers, "headers")
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
