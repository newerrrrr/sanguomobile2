local playerGrownFundData = {}
setmetatable(playerGrownFundData,{__index = _G})
setfenv(1,playerGrownFundData)

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

function isFinished()
    local isFinished = false
    local data = GetData()
    if data then
        local getedNumAwards = data.num_reward
        local getedLvAwards = data.level_reward
        local maxNumAward = 8
        local maxLvAward = table.nums(g_data.growth_level_reward)
        isFinished = (table.nums(getedNumAwards) == maxNumAward) and (table.nums(getedLvAwards) == maxLvAward)
    end
    return isFinished
end

--请求数据
function RequestData()
    local ret = false
    local function onRecv(result, msgData)
        if(result==true)then
            ret = true
            SetData(msgData.PlayerGrowth)
            NotificationUpdateShow()
        end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerGrowth",}},onRecv)
    return ret
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

--检查府衙等级奖励是否已经领取
function checkIsGetedLvAward(id)
    local isGeted = false
    
    local data = GetData()
    if data then
        local getedLvAwards = data.level_reward
        
        for key, var in pairs(getedLvAwards) do
            if tonumber(var) == id then
               isGeted = true 
               break
            end
        end
    end
    return isGeted
end

--检查基金人数是否已经领取
function checkIsGetedNumAward(id)
    local isGeted = false
    local data = GetData()
    if data then
        local getedNumAwards = data.num_reward
        
        for key, var in pairs(getedNumAwards) do
            if tonumber(var) == id then
               isGeted = true 
               break
            end
        end
    end
    return isGeted
end

--检查是否已经购买成长基金
function checkIsBuy()
    local isBuy = false
    local data = GetData()
    if data then
        if data.buy == 1 then
            isBuy = true
        end
    end
    return isBuy
end

--检查是否有可领取的奖励
function checkIsHaveAward(id)
    local haveAward = false
    
    local data = GetData()
    if data then
        local currentNum = data.total_num
        for i = 1, 8 do
            local number = g_data.growth_number_reward[i].number
            local rewardInfo = g_data.growth_number_reward[i]
            local isGeted = checkIsGetedNumAward(rewardInfo.id)
    
            local getAwardEnabled = (data.buy ~= 0) and (currentNum >= rewardInfo.number) and (isGeted == false)
            if getAwardEnabled then
                haveAward = true 
                break
            end
        end
        
        if not haveAward then
            local allLength = table.nums(g_data.growth_level_reward)
            --府衙等级
            local mainCityLevel = g_PlayerBuildMode.getMainCityBuilding_lv()
            for key, var in ipairs(g_data.growth_level_reward) do
                local isGeted = checkIsGetedLvAward(var.id)
                haveAward = (mainCityLevel >= var.level) and not isGeted
                if haveAward then
                    break
                end
            end
        end
    end
    
    return haveAward
end

return  playerGrownFundData