local exchangeMode = class("exchangeMode")

function exchangeMode:instance()
    
    if nil == exchangeMode._instance then 
        exchangeMode._instance = exchangeMode.new()
    end

    return exchangeMode 
end


--兑换活动的数据
function exchangeMode:getExchangeData()
    local data = nil
    local function callback(res,msgData)
        if true == res then
            data = msgData.activity
        end
    end
    g_sgHttp.postData("activity/exchangeShow",{},callback)

    return data
end

--兑换
function exchangeMode:exchange(exchangeId)
    if exchangeId == nil then print("exchangeId is nil") return end
    local result = false
    local function callback(res,msgData)
        if true == res then
            result = true
            --dump(msgData)
        end
    end
    g_sgHttp.postData("activity/doExchange",{ exchangeId = exchangeId },callback)
    return result
end


return exchangeMode



