local _u = require '..utils'

local parent = require 'http_client'
local M = parent:new{
  onComplete = function() _u.p("request success") end,
  onError = function() _u.p("request success") end,
}

-- ローディング中の数を初期化する
function M:resetLoadCount()
  self.loadCount = 0
  self.completeLoadCount = 0
end

-- ローディング中の数を増やす
function M:incrementLoadCount()
  self.loadCount = self.loadCount + 1
end

-- 終了したローディングの数を増やす
function M:incrementCompleteLoadCount()
  self.completeLoadCount = self.completeLoadCount + 1
end

function M:asyncRequest(options)
  local this = self
  local o = self:setDefault(_u.setDefault(options, self))
  this:incrementLoadCount()

  local networkListener
  networkListener = function(e)
    this:incrementCompleteLoadCount()

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
  local this = self
  this:incrementLoadCount()
  local o = M:setDefault(_u.setDefault(options, self))

  local function networkListener(e)
    this:incrementCompleteLoadCount()
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

  local baseDirectory 
  if o.baseDirectory then
    baseDirectory = o.baseDirectory
  else
    baseDirectory = system.TemporaryDirectory
  end

  print("save path is ", o.savePath)

  network.download(
    _u.makeUrl(o),
    "GET",
    networkListener,
    params,
    o.savePath,
    baseDirectory
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
