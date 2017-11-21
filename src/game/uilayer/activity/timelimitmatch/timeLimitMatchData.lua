local timeLimitMatchData = {}
setmetatable(timeLimitMatchData,{__index = _G})
setfenv(1,timeLimitMatchData)

local baseData = nil
local baseView = nil

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

function SetData(data)
    baseData = data
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
    g_sgHttp.postData("limit_match/showLimitMatch",{},onRecv)
    return ret
end

function RequestDataAsync(callback)
    local function onRecv(result, msgData)
        if(result==true)then
            SetData(msgData)
            NotificationUpdateShow()
        end
        if callback then
            callback(result, msgData)
        end
    end
    g_sgHttp.postData("limit_match/showLimitMatch",{},onRecv,true)
end

function GetData()
    if(baseData == nil)then
        RequestData()
    end
    return baseData
end

function GetCustomMatchInfo()
    
    local matchData = GetData()
    
    local matchInfo = {}
    matchInfo.match_id = 0
    matchInfo.match_type = 0
    matchInfo.status = 0
    matchInfo.close_time = 0
    matchInfo.open_time = 0
    
    if matchData and matchData.config_match and matchData.config_match.id then
         matchInfo.status = 1
         
         --[[
           "today_match": {
            "id": 176,
            "time_limit_match_config_id": 12,
            "time_limit_match_id":1,
            "match_type": 2,
            "match_date_start": 1461081600,
            "match_date_end": 1461168000,
            "award_status": 0
            },
        ]]
        
         matchInfo.match_id = matchData.today_match.time_limit_match_id
         matchInfo.match_type = matchData.today_match.match_type
         matchInfo.open_time = matchData.today_match.match_date_start
         matchInfo.close_time = matchData.today_match.match_date_end
    end
    
    return matchInfo
    
end

function isNew()
   local isNew = false
   local matchInfo = GetCustomMatchInfo()
   if matchInfo.status == 0 then --未开启
    
   else
       local activityCacheTag = require("game.uilayer.activity.ActivityMainLayer").getActivityCacheTag(1002)
       if g_saveCache[activityCacheTag] ~= matchInfo.match_type then
            isNew = true
       end
   end
   return isNew
end

return timeLimitMatchData