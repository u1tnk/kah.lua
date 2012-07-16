local M = _u.newObject{}


-- DBから情報を取得、その後画像を取得する必要があるため、
-- DBから取得後、loadChildrenメソッドがあれば実行、更にlazyLoadオブジェクトを取得した場合はqueueに突っ込み終了待ち…という処理です。
function M.runLazyLoads(lazyLoads, onComplete, onUpdate)
  local queue = _u.clone(lazyLoads)

  local function getFinishedCount()
    local count = 0
    for key, lazyLoad in pairs(queue) do
      if lazyLoad.done then
        count = count + 1
      end
    end
    return count
  end

  local function checkAllDone()
    return _u.size(queue) == getFinishedCount()
  end

  local results = {}

  local createLoadCallBack
  local ended = false
  function createLoadCallBack(lazyLoad)
    return function(result)
      if result then
        results[_u.getKeyByValue(queue, lazyLoad)] = result
      end
      if lazyLoad.loadChildren then
        local children = lazyLoad.loadChildren(result)
        for key, child in pairs(children) do
          if _u.isString(child) then
            local lazyDownload = _client:lazyDownload({path = child})
            lazyDownload.load(createLoadCallBack(lazyDownload))
            if _u.isNumber(key) then
              table.insert(queue, lazyDownload)
            else
              queue[key] = lazyDownload
            end
          else
            child.load(callBack)
            if _u.isNumber(key) then
              table.insert(queue, child)
            else
              queue[key] = child
            end
          end
        end
      end
      lazyLoad.done = true
      if onUpdate then
        onUpdate{allCount = _u.size(queue), finishedCount = getFinishedCount()}
      end
      if checkAllDone() and not ended then
        ended = true
        onComplete(results)
      end
    end
  end
  for key, lazyLoad in pairs(queue) do
    lazyLoad.load(createLoadCallBack(lazyLoad))
  end
end



return M

