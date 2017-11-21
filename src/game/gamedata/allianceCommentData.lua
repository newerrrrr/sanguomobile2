--g_allianceCommentData
local allianceCommentData = {}
setmetatable(allianceCommentData,{__index = _G})
setfenv(1,allianceCommentData)

local baseData = nil
local view = nil
function NotificationUpdateShow()
    if view then
        view:updateView()
    end
end

function SetView(layer)
    view = layer
end

function GetView()
    return view
end

function RequestData()
  local ret = false

  local function onRecv(result, msgData)
    if result then
      ret = true
      SetData(msgData)
    end
  end

  g_sgHttp.postData("guild/showBoard", {}, onRecv)
  return ret
end

function SetData(data)
  baseData = clone(data)
  for key, var in pairs(baseData) do
  	if var.player_id == 0 then
  	    var.content = g_tr("allianceCommentDefaultContent")
  	    var.title = g_tr("allianceCommentDefaultTitle")
  	    break
  	end 
  end
end

function GetData() 
  if baseData == nil then 
    RequestData() 
  end 

  return baseData
end

function haveNew()
    local data = GetData()
    local haveNew = false
    if data then
        for key, var in pairs(data) do
            if isVaildData(var) then
                if g_clock.getCurServerTime() - var.update_time < 360 * 24 then
                    haveNew = true
                    break
                end
            end
        end
    end
    return haveNew
end

function isVaildData(data)
    local isVaild = false
    if data then
        if data.title ~= "" and data.content ~= "" then
            isVaild = true
        end
    end
    return isVaild
end

function changeComment(orderId,title,content,update_time)
  local ret = false
  local function onRecv(result, msgData)
    if result then
        ret = true
    end
  end
  g_sgHttp.postData("guild/changeBoard", {orderId = orderId,title = title,text = content,updateTime = update_time}, onRecv)
  return ret
end

function swapComment(pos1,pos2,updateTime1,updateTime2)
  assert(pos1 and pos1 ~= pos2)
  local function onRecv(result, msgData)
    if result then
      --dump(msgData)
      --SetData(msgData)
    end
  end
  g_sgHttp.postData("guild/swapBoard", {orderId1 = pos1,orderId2 = pos2,updateTime1 = updateTime1,updateTime2 = updateTime2}, onRecv)
end

function getCommentDataByOrderId(orderId)
    local data = {order_id = orderId,content = "",title = "",update_time = 0}
    local serverData = GetData()
    if serverData then
        for key, var in pairs(serverData) do
            if tonumber(var.order_id) == orderId then
                data = var
                break
            end
        end
    end
    return data
end

function getAnIdleOrderId()
    local idleId = nil

    local serverData = GetData()
    --[{"id":1,"guild_id":88,"order_id":1,"content":"dddd","update_time":1467097369},{"id":4,"guild_id":88,"order_id":1,"content":"bbbbb","update_time":1467097163},{"id":2,"guild_id":88,"order_id":5,"content":"5555","update_time":1467097392},{"id":3,"guild_id":88,"order_id":6,"content":"hello word 1","update_time":1467096984}]
    
    local haveOrderId = function(id)
        local haveId = false
        if serverData then
            for key, var in pairs(serverData) do
                if tonumber(var.order_id) == id and var.content ~= "" and var.title ~= "" then
                    haveId = true
                    break
                end
            end
        end
        return haveId
    end
    
    for i = 1, 8 do
        if not haveOrderId(i) then
           idleId = i
           break
        end
    end
    
    return idleId
end

return allianceCommentData
