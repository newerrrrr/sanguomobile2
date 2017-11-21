

local AllianceMissionMode = class("AllianceMissionMode")

local missionTypeEnum = {
    alliance_devote = 1, --联盟捐献
    treasure_fight  = 2, --和氏璧
    yellow_turbans  = 3, --黄巾起义 
    judian_fight    = 4, --据点战 
  }

local missionStateEnum = {
    waitToOpen = 1, --未开启
    opening    = 2, --进行中
    closed     = 3, --已结束
  }

function AllianceMissionMode:ctor()

end

-- 获取当前开启的活动(每次在线请求),如果没有,则返回即将开启的活动
function AllianceMissionMode:getValidMission(needReq)

  local function checkValid()
    local _type, val 

    local curTime = g_clock.getCurServerTime()
    local allData = g_allianceMissionData.GetData()
    if allData then             
      for k, v in pairs(allData) do 
        if curTime >= v.activityStartTime and curTime < v.activityEndTime then
          _type = tonumber(k)
          val = v 
          break 
        end 

        if nil == _type then 
          _type = tonumber(k)
          val = v 
        elseif v.activityStartTime < val.activityStartTime then 
          _type = tonumber(k)
          val = v           
        end 
      end 
    end 

    return _type, val 
  end 

  if needReq then 
    g_allianceMissionData.RequestData()
  end 

  return checkValid() 
end 

--获取指定任务类型最新数据
function AllianceMissionMode:getMissionData(missionType)
  g_allianceMissionData.RequestData()
  local allData = g_allianceMissionData.GetData()
  if allData then
    return allData[""..missionType]
  end 
end 

function AllianceMissionMode:getTimeString(missionType)
  local str = ""
  local function formatTimes(time) 
    local tmp = ""
    if time < 0 then 
    elseif time >= 3600*24 then 
      tmp = math.ceil(time/3600*24) .. g_tr("day")
    elseif time >= 3600 then 
      tmp = math.ceil(time/3600) .. g_tr("hour")
    elseif time >= 60 then 
      tmp = math.ceil(time/60) .. g_tr("minute")
    else 
      tmp = math.ceil(time/60) .. g_tr("second")
    end 

    return tmp 
  end 

  local allData = g_allianceMissionData.GetData()
  if allData then 
    local data = allData[""..missionType] --数据以活动类型(string)做下标
    if data then 
      local curTime = g_clock.getCurServerTime()
      if curTime < data.activityStartTime then --即将开启
        str = g_tr("openInTime", {time = formatTimes(data.activityStartTime - curTime)})

      elseif curTime >= data.activityEndTime then --已结束,敬请期待
        str = g_tr("waitingForOpen")
      end 
    end 
  end 

  return str 
end 

--联盟任务积分奖励
function AllianceMissionMode:getMissionPointDrop(missionType)
  local tbl = {}
  for k, v in pairs(g_data.alliance_match) do 
    for i, _type in pairs(v.match_type) do 
      if _type == missionType then 
        for j, id in pairs(v.drop_id) do 
          table.insert(tbl, g_data.alliance_match_point_drop[id])
        end 
      end 
    end 
  end 

  return tbl 
end 

--联盟任务排名奖励 
function AllianceMissionMode:getMissionRankDrop(missionType) 
  local tbl = {} 
  for k, v in pairs(g_data.alliance_match) do 
    for i, _type in pairs(v.match_type) do 
      if _type == missionType then 
        for j, id in pairs(v.rank_drop_id) do 
          table.insert(tbl, g_data.alliance_match_point_drop[id])
        end 
      end 
    end 
  end 

  return tbl 
end 

--返回活动状态
function AllianceMissionMode:getMissionState(dataItem)
  local state = missionStateEnum.closed

  if dataItem then 
    local curTime = g_clock.getCurServerTime()

    if curTime < dataItem.activityStartTime then --未开启
      state = missionStateEnum.waitToOpen
    elseif curTime >= dataItem.activityEndTime then --已结束
      state = missionStateEnum.closed
    else 
      state = missionStateEnum.opening
    end 
  end 

  return state  
end 

local function isActOpen() 
  local flag = false 

  local curTime = g_clock.getCurServerTime()
  local data = require("game.uilayer.activity.ActivityMainLayer").getServerOpenInfoByActivityId(1003)
  if data then 
    if curTime >= data.start_time and curTime < data.end_time then 
      flag = true 
    end 
  end 

  return flag 
end 

local function isMissonValid(missionType)
  --外部联盟任务活动总开关判断
  if not isActOpen() then 
    return false 
  end 

  --内部联盟任务和氏璧开关判断
  local curTime = g_clock.getCurServerTime()
  local allData = g_allianceMissionData.GetData()
  if allData then 
    local itemData = allData[""..missionType] 
    if itemData then             
      if curTime >= itemData.activityStartTime and curTime < itemData.activityEndTime then
        return true 
      end 
    end 
  end   

  return false 
end 

--氏璧活动是否进行中
function AllianceMissionMode:isTreasureFightValid()
  return isMissonValid(missionTypeEnum.treasure_fight)
end 

--据点战是否进行中
function AllianceMissionMode:isJuDianFightValid()
  return isMissonValid(missionTypeEnum.judian_fight)
end 

--黄巾起义是否进行中
function AllianceMissionMode:isYellowTurbansValid()
  return isMissonValid(missionTypeEnum.yellow_turbans)
end 

function AllianceMissionMode:getMissionTypeEnum()
  return missionTypeEnum 
end 

function AllianceMissionMode:getMissionStateEnum()
  return missionStateEnum 
end 

function AllianceMissionMode:hasNewMission()
  local isNew = false
  if isActOpen() then 
    local _type, itemData = self:getValidMission(false)
    if itemData then 
      if self:getMissionState(itemData) == missionStateEnum.opening then 
        local activityCacheTag = require("game.uilayer.activity.ActivityMainLayer").getActivityCacheTag(1003)
        -- print("hasNewMission, type=", g_saveCache[activityCacheTag])
        if g_saveCache[activityCacheTag] ~= _type then
          isNew = true
        end
      end 
    end  
  end 

  return isNew 
end 

function AllianceMissionMode:saveValidCacheType(_type)
  local activityCacheTag = require("game.uilayer.activity.ActivityMainLayer").getActivityCacheTag(1003)
  if g_saveCache[activityCacheTag] ~= _type then
    g_saveCache[activityCacheTag] = _type
  end 
end 

function AllianceMissionMode:hasMissionOpen()
  local open = false
  local _type 
  if isActOpen() then 
    open = true 
    _type, _ = self:getValidMission(false)
  end 

  return open, _type 
end 

return AllianceMissionMode

