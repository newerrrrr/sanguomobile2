local InjuredSoldierData = {}
setmetatable(InjuredSoldierData,{__index = _G})
setfenv(1, InjuredSoldierData)

local baseData = nil
local updateViews = {}
function InjuredSoldierData.setData(data)
    baseData = data
end

function InjuredSoldierData.getData()
    if baseData == nil then
      InjuredSoldierData.requestData()
    end
    return baseData
end

function InjuredSoldierData.requestData()
    local ret = false
    local function onRecv(result, msgData)
      if result == true then
        InjuredSoldierData.setData(msgData.PlayerSoldierInjured)
        InjuredSoldierData.notificationUpdateShow()
        ret = true
      end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerSoldierInjured",}},onRecv)
    
    return ret
end

--异步请求
function InjuredSoldierData.requestDataAsync(callback)
    local function onRecv(result, msgData)
      if result == true then
        InjuredSoldierData.setData(msgData.PlayerSoldierInjured)
      end
      
       if callback then
            callback(result,msgData)
       end
    end
    
    g_sgHttp.postData("data/index",{name = {"PlayerSoldierInjured",}},onRecv,true)
end

function InjuredSoldierData.addUpdateView(layer)
    for key, view in pairs(updateViews) do
        if view == layer then
            return
        end
    end
    table.insert(updateViews,layer)
end

function InjuredSoldierData.removeUpdateView(layer)
    for key, view in pairs(updateViews) do
        if view == layer then
            table.remove(updateViews,key)
            break
        end
    end
end

function InjuredSoldierData.removeAllUpdateView()
    updateViews = {}
end

function InjuredSoldierData.notificationUpdateShow()
    for key, view in pairs(updateViews) do
      assert(view.updateView)
      view:updateView()
    end
end

return InjuredSoldierData
