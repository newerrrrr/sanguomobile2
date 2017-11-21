--g_expeditionData
local expeditionData = {}
setmetatable(expeditionData,{__index = _G})
setfenv(1,expeditionData)

local baseData = nil
local baseView = nil
local lastScoreUpdateTime = 0
isHaveNewReport = false
local isRegistedPkRecive = false

function getRankByScore(score)
    local rank = 1
    if score == 0 then
        return rank
    end
    
    for key, rankConfig in pairs(g_data.duel_rank) do
        if score >= rankConfig.min_point and score <= rankConfig.max_point then
            rank = rankConfig.id
            break
        end
    end
    return rank
end

--更新显示
function NotificationUpdateShow()
    if baseView then
        baseView:updateView()
    end
end

function SetView(view)
    baseView = view
end

function GetView()
    return baseView
end

--请求数据
function RequestData()
    if not checkIsDataRequestEnable() then
        return false
    end
    
    local ret = false
    local function onRecv(result, msgData)
        if(result==true)then
            ret = true
            SetData(msgData.PkPlayerInfo)
            NotificationUpdateShow()
        end
    end
    --g_sgHttp.postData("pk/getPkPlayerInfo",{},onRecv)
    g_sgHttp.postData("data/index",{name = {"PkPlayerInfo",}},onRecv)
    return ret
end

--请求数据
function checkIsDataRequestEnable()
    local isEnabled = false
    local conditionBuildConfigId = tonumber(g_data.starting[97].data)
    local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(conditionBuildConfigId)
    if enoughCount > 0 then
        isEnabled = true
    end
    return isEnabled
end

--请求数据
function RequestDataAsync(callback)
    if not checkIsDataRequestEnable() then
        if callback then
            if g_logicDebug == true then
                g_airBox.show("请求pk数据等级条件不足")
            end
            callback(false, nil)
        end
        return
    end
    
    local function onRecv(result, msgData)
        if(result==true)then
            SetData(msgData.PkPlayerInfo)
            NotificationUpdateShow()
        end
        if callback then
            callback(result, msgData)
        end
    end
    --g_sgHttp.postData("pk/getPkPlayerInfo",{},onRecv,true)
    g_sgHttp.postData("data/index",{name = {"PkPlayerInfo",}},onRecv,true)
end

--段位升级动画完成
function RequestAnimPlayedAsync(callback)
    local function onRecv(result, msgData)
        if callback then
            callback(result, msgData)
        end
    end
    g_sgHttp.postData("pk/syncDuelRankId",{},onRecv,true)
end

function SetData(data)
    baseData = data
end

function GetData()
    if(baseData == nil)then
        RequestData()
    end
    
    if not isRegistedPkRecive then
        g_gameCommon.addEventHandler(g_Consts.CustomEvent.PkRecive, function(_,data)
            isHaveNewReport = true
            g_expeditionData.RequestDataAsync()
        end)
        
        isRegistedPkRecive = true
    end
    
    return baseData
end

--是否有每日次数奖励
function IsHaveDailyTimesReward()
    if not checkIsDataRequestEnable() then
        return false
    end

    local exditionData = GetData()
    
    if exditionData == nil then
        return false
    end
    
    local todayMatchTimes = exditionData.current_day_match_times
    local currentDayGainId = exditionData.current_day_gain_id
    local haveReward = false
    do
        for key, var in pairs(g_data.duel_times_bonus) do
            if key > currentDayGainId then
                haveReward = todayMatchTimes >= var.times
                if haveReward then
                    break
                end
            end
        end
    end
    return haveReward
end

--当前段位每日奖励
function IsHaveDailyRankReward()
    if not checkIsDataRequestEnable() then
        return false
    end

    local exditionData = GetData()
    
    if exditionData == nil then
        return false
    end
    
    local haveReward = false
    do
        local dailyScore = exditionData.daily_score
        local gainDailyAwardTime = exditionData.gain_daily_award_date
        local awardExecTime = exditionData.award_exec_date
        
        if exditionData.daily_award_status == 1 then
            haveReward = false
        else
            haveReward = true
            if awardExecTime == 0 then --没有结算过
                haveReward = false
            end
        end
    end
    return haveReward
end

return expeditionData