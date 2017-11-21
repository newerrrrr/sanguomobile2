--g_millData
local millData = {}
setmetatable(millData,{__index = _G})
setfenv(1,millData)

local baseData = nil
local view = nil
local requesting = false
--status 0排队中1完成2正在生产
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

--收集
function RequestCollect_Async(startPos)

    local function onRecv(result, msgData)
        if(result==true)then
            --"items":[30501,30601]}
            local items = msgData.items
            
            --把重复的id数量相加
            local newData = {}
            do
                for key, itemId in pairs(items) do
                	if newData[itemId] == nil then
                	   newData[itemId] = 0
                	end
                	newData[itemId] = newData[itemId] + 1
                end
            end
            
            --组织dropGroups
            local dropGroups = {}
            do
                for itemId, cnt in pairs(newData) do
                    local dropG = {}
                	dropG[1] = g_Consts.DropType.Props
                	dropG[2] = itemId
                	dropG[3] = cnt
                	table.insert(dropGroups,dropG)
                end
            end
            
            --显示掉落
            require("game.uilayer.common.dropFlyEffect").show(dropGroups,startPos)
        end
    end
    g_sgHttp.postData("mill/gain",{},onRecv,true)
end

--请求数据
function RequestData()
    local ret = false
    local function onRecv(result, msgData)
        if(result==true)then
            ret = true
            SetData(msgData.PlayerMill)
            NotificationUpdateShow()
        end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerMill",}},onRecv)
    return ret
end

--异步请求数据
function RequestData_Async()
    if requesting then
        return
    end
    
    requesting = true
    local function onRecv(result, msgData)
         requesting = false
        if(result==true)then
            SetData(msgData.PlayerMill)
            NotificationUpdateShow()
        end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerMill",}},onRecv,true)
end

function SetData(data)
    baseData = data
end

--得到基本信息,只可使用不可修改
function GetData()
    if baseData == nil then
        RequestData()
    end
    return baseData
end

function isHaveCollectionRes()
    local ret = false
    local playerMillItems = GetData().item_ids
    --{"item_id":30101,"second":1500,"status":2}     --status 0排队中1完成2正在生产
    for key, var in ipairs(playerMillItems) do
        if var.status == 1 then
            ret = true
            break
        end
    end
    return ret
end

function getWorkingInfo()
    local playerMillItems = GetData().item_ids
    --{"item_id":30101,"second":1500,"status":2}     --status 0排队中1完成2正在生产
    local workingInfo = nil
    for key, var in ipairs(playerMillItems) do
        if var.status == 2 then
            var.begin_time = GetData().begin_time
            var.finish_time = GetData().begin_time + var.second
            workingInfo = var
            break
        end
    end
    
    --时间到的时候更新数据
    if workingInfo and g_clock.getCurServerTime() > workingInfo.finish_time then
       RequestData_Async()
    end
    
    return workingInfo
end

return millData