local parent = require 'object'
local _u = require 'utils'
local M = parent:new()

-- to
-- from
-- delay
-- parallel
-- call
-- loop
-- times
-- run
function M:newTl()
  local tl = {}
  local index
  local queue = {}
  local loop = false
  local times = 0
  local onComplete

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
      queue = {}
      if onComplete then
        onComplete()
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

  tl.eachParallel = function(arr, fn) 
    table.insert(queue, function()
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
        fn(i, v, n)
      end
    end)
    
    return tl
  end

  tl.parallel = function(getTimelines)
    table.insert(queue, function()
      local tls = getTimelines()
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
      fn(next)
      tl.cancel = function()
        next = function() end
      end
    end)

    return tl
  end

  tl.run = function(_onComplete)
    index = 0
    onComplete = _onComplete
    next()
  end

  tl.loop = function() 
    loop = true
    
    return tl
  end

  tl.times = function(count)
    times = count

    return tl
  end

  return tl
end

return M
