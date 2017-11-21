local ShopMarketData = {}
setmetatable(ShopMarketData,{__index = _G})
setfenv(1, ShopMarketData)

local baseData = nil
local viewToUpdate = nil
local lastSetDataTime = 0
--更新显示
function NotificationUpdateShow()
    if viewToUpdate then
        viewToUpdate:updateView()
    end
end

function setView(view)
    viewToUpdate = view
end

function getView()
    return viewToUpdate
end

function SetData(data)
    lastSetDataTime = g_clock.getCurServerTime()
    baseData = data
end

--请求数据
function RequestData()
    local ret = false
    local function onRecv(result, msgData)
        if(result==true)then
            ret = true
            SetData(msgData.PlayerMarket)
            NotificationUpdateShow()
        end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerMarket"}},onRecv)
    return ret
end

function GetData()
    if baseData == nil or not g_clock.isSameDay(g_clock.getCurServerTime(),lastSetDataTime) then
        RequestData()
    end

    return baseData
end

return ShopMarketData