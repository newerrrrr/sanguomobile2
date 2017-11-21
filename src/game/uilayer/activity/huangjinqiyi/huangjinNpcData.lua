local huangjinNpcData = {}
setmetatable(huangjinNpcData,{__index = _G})
setfenv(1,huangjinNpcData)

local baseData = nil

--更新显示
function NotificationUpdateShow()
    
end

function SetData(data)
    baseData = data
end

--异步请求数据
function RequestDataAsync()
    local function onRecv(result, msgData)
        if(result==true)then
            SetData(msgData)
            NotificationUpdateShow()
        end
    end
    g_sgHttp.postData("Map/getHjNpc",{},onRecv,true)
end


--请求数据
function RequestData()
    local ret = false
    local function onRecv(result, msgData)
        if(result==true)then
            ret = true
            SetData(msgData)
            NotificationUpdateShow()
        end
    end
    g_sgHttp.postData("Map/getHjNpc",{},onRecv)
    return ret
end

function GetData()
    if(baseData == nil)then
        RequestData()
    end
    return baseData
end

return huangjinNpcData