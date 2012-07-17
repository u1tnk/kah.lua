local _u = require 'utils'

local parent = require 'http_client'
local M = parent:new{
  onComplete = function() _u.p("request success") end,
  onError = function() _u.p("request success") end,
}

function M:asyncRequest(options)
  local o = self:setDefault(_u.setDefault(options, self))

  local networkListener
  networkListener = function(e)

    if e.status ~= 200 then
      _u.p(e, "request error")
      o.onError()
    else
      o.onComplete(e.response)
    end
  end
  local params = {}
  params.headers = o.headers
  params.body = o.body

  network.request(_u.makeUrl(o), options.method, networkListener, params)
end

function M:asyncDownload(options)
  local o = M:setDefault(_u.setDefault(options, self))

  local function networkListener(e)
    if e.status ~= 200 then
      _u.p(e, "download error")
      o.onError()
    else
      o.onComplete(e.response)
    end
  end
  local params = {}
  params.headers = o.headers
  params.body = o.body

  network.download(
    _u.makeUrl(o),
    "GET",
    networkListener,
    params,
    o.savePath,
    system.TemporaryDirectory 
  )
end

function M:lazyRequest(requestParams)
  local o = {}
  o.key = requestParams.key
  function o.load(onComplete) 
    requestParams.onComplete = onComplete
    self:asyncRequest(requestParams)
  end
  return o
end

function M:lazyDownload(requestParams)
  local o = {}
  function o.load(onComplete) 
    requestParams.onComplete = onComplete
    self:asyncDownload(requestParams)
  end
  return o
end


function M:lazyMock(requestParams)
  local o = {}
  o.key = requestParams.key
  function o.load(onComplete) 
    onComplete(requestParams.result)
  end
  return o
end

return M
