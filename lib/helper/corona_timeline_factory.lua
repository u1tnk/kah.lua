local parent = require '..object'
local _u = require '..utils'
local M = parent:new()

-- イベント系
-- to
-- from
-- delay
-- parallel
-- eachParallel
-- call
-- subTl
-- 起動系
-- run
-- times
-- loop (非推奨、できればtransition系ではなくenterFrameで実行した方が良い)
-- pause
-- resume
-- 通信エラーなどで処理中断したいときは
-- nextを呼ばずにonErrorを呼ぶ。
-- 残りのイベントはnewTlで生成したインスタンスがGCされるなら問題無いはず
function M:newTl(options)
  local tl = {}
  local index
  local queue = {}
  local loop = false
  local times = 0

  local defaults = {
    showIndicator = false,
    onComplete = nil,
    onError = nil,
  }
  local o = _u.setDefault(options, defaults) 

  local next
  next = function()
    index = index + 1
    if index <= #queue then
      queue[index]()
    elseif loop then
      index = 0
      next()
    elseif times > 0 then
      index = 0
      times = times - 1
      next()
    else
      if o.showIndicator then
        native.setActivityIndicator(false)
      end
      queue = {}
      if o.onComplete then
        o.onComplete()
      end
    end
  end

  tl.addQueue = function(o)
    table.insert(queue, o)
  end

  local function assertTarget(target)
    assert(target, "getParams function or target object is required")
  end
    
  -- 上書きされる前提
  -- cancelメソッドが設定される前にcancelが呼び出されても問題無いようにする
  tl.cancel = function() next = function() end end

  tl.eachSerial = function(arr, fn)
    table.insert(queue, function()
      -- arrが関数の時はその呼出結果を引数とする
      if _u.isFunction(arr) then
        arr, fn = arr()
      end

      if _u.isNotEmpty(arr) then
        local n
        local index = 1
        local count = #arr
        n = function()
          index = index + 1
          if count < index then
            next()
            return 
          end
          fn(index, arr[index], n, o.onError)
        end
        fn(index, arr[index], n, o.onError)
      else
        next()
      end
    end)
    return tl
  end

  tl.eachParallel = function(arr, fn) 
    table.insert(queue, function()
      -- arrが関数の時はその呼出結果を引数とする
      if _u.isFunction(arr) then
        arr, fn = arr()
      end

      if _u.isNotEmpty(arr) then
        local n
        local count = #arr
        n = function()
          count = count -1
          if count == 0 then
            count = #arr
            next()
          end
        end
        for i, v in ipairs(arr) do
          fn(i, v, n, o.onError)
        end
      else
        next()
      end
    end)
    return tl
  end

  tl.subTl = function(t)
    if not t then
      return tl
    end
    return tl.parallel({t})
  end

  tl.parallel = function(tls)
    table.insert(queue, function()
      if _u.isFunction(tls) then
        tls = tls()
      end
      local n
      local count = #tls
      n = function()
        count = count - 1
        if count == 0 then
          -- reset count for loop
          count = #tls
          next()
        end
      end
      for i, v in ipairs(tls) do
        v.run(n)
      end
      tl.cancel = function()
        for i, v in ipairs(tls) do
          v.cancel()
        end
      end
    end)

    return tl
  end

  tl.to = function(target, params)
    assertTarget(target)
    table.insert(queue, function()
      if _u.isFunction(target) then
        target, params = target()
      end
      params.onComplete = next
      local id = transition.to(target, params)
      tl.cancel = function()
        transition.cancel(id)
      end
    end)

    return tl
  end

  tl.from = function(target, params)
    assertTarget(target)
    table.insert(queue, function()
      if _u.isFunction(target) then
        target, params = target()
      end
      params.onComplete = next
      local id = transition.from(target, params)
      tl.cancel = function()
        transition.cancel(id)
      end
    end)

    return tl
  end

  tl.delay = function(delay) 
    table.insert(queue, function()
      local id = timer.performWithDelay(delay, next)
      tl.cancel = function()
        timer.cancel(id)
      end
    end)

    return tl
  end

  tl.call = function(fn)
    table.insert(queue, function()
      fn(o.onError)
      next()
    end)

    return tl
  end

  tl.callMethod = function(obj, method)
    table.insert(queue, function()
      local fn = _u.bind(obj, method)
      fn(o.onError)
      next()
    end)

    return tl
  end

  tl.async = function(fn)
    table.insert(queue, function()
      fn(next, o.onError)
      tl.cancel = function()
        next = function() end
      end
    end)

    return tl
  end

  tl.asyncMethod = function(obj, method)
    table.insert(queue, function()
      local fn = _u.bind(obj, method)
      fn(next, o.onError)
      tl.cancel = function()
        next = function() end
      end
    end)

    return tl
  end

  tl.run = function(options)
    if _u.isFunction(options) then
      o.onComplete = options
    else 
      o = _u.setDefault(options, o) 
    end

    if o.showIndicator then
      native.setActivityIndicator(true)
    end
    index = 0
    next()
  end

  -- TODO パラメータで設定するようにしたほうがよさげ
  tl.loop = function() 
    loop = true
    tl.run()
    return tl
  end

  -- TODO パラメータで設定するようにしたほうがよさげ
  tl.times = function(count)
    times = count
    tl.run()
    return tl
  end

  tl.pause = function()
    table.insert(queue, function() end)
    return tl
  end

  tl.resume = function(onComplete)
    if onComplete then
      if o.onComplete then
        print("WARNING: already set onComplete!")
      end
      o.onComplete = onComplete
    end
    next()
  end

  tl.fadeOut = function(target, options)
    local o = _u.setDefault(options, {
      time = 500,
      removeOnComplete = true,
      alpha = 0,
    })
    tl
      .to(target, o)
      .call(function()
        if o.removeOnComplete then
          display.remove(target)
        end
      end)
    return tl
  end

  tl.fadeIn = function(target, options)
    local o = _u.setDefault(options, {
      time = 500,
      alpha = 1,
    })
    tl
      .to(target, o)
    return tl
  end

  tl.crossFade = function(from, to, options)
    local o = _u.setDefault(options, {
      time = 500,
      removeOnComplete = true,
      outAlpha = 0,
      inAlpha = 1,
    })
    tl
      .parallel{
        self:newTl().fadeOut(from, {
          time = o.time,
          removeOnComplete = o.removeOnComplete,
          alpha = o.outAlpha,
        }),
        self:newTl().fadeIn(to, {
          time = o.time,
          alpha = o.inAlpha,
        }),
      }
    return tl
  end

  return tl
end

return M
