--g_AllianceMode
local Alliance = {}
setmetatable(Alliance,{__index = _G})
setfenv(1,Alliance)


local updateViews = {}
local baseData = nil
local techData = nil
local allTechData = {}
local searchCondition = {}
local mainView = nil
local guildPlayers = {}
local applyedPlayers = {}
local requestNum = 0
local current_season_start_date = 0

--盟主颁奖
haveShowRewardSend = false
rewardCnt = 0

local function repaireAllAllianceBaseData(msgData)--guild/comboGuildMemberInfo接口专用
    local data = {}
    data.PlayerGuild = msgData.PlayerGuild or {}
    data.PlayerGuildRequest = msgData.PlayerGuildRequest or {}
    data.Guild = msgData.Guild or {id = 0}
    data.GuildBoard = msgData.GuildBoard or nil
    return data
end

local updateAllianceBaseData = function(msgData)
    --所有玩家
    if msgData.PlayerGuild then
        Alliance.setGuildPlayers(msgData.PlayerGuild)
    end
    
    --申请列表
    local requestMembers = msgData.PlayerGuildRequest
    if requestMembers then
        applyedPlayers = {}
        for key, member in pairs(requestMembers) do
            table.insert(applyedPlayers,member)
        end
        Alliance.setRequestNum(#applyedPlayers)
    end
    
    --联盟基础数据
    if msgData.Guild then
        Alliance.setBaseData(msgData.Guild)
    end    
    
    --留言板数据
    if msgData.GuildBoard then
        g_allianceCommentData.SetData(msgData.GuildBoard)
    end
end

function Alliance.setTechData(data)
    techData = data
   --[[
      "[
          {
              "id": 73,
              "science_type": 12,
              "science_level": 0,
              "science_exp": 0,
              "science_level_type": 1,
              "finish_time": 0,
              "status": 0
          },
          {
              "id": 74,
              "science_type": 13,
              "science_level": 0,
              "science_exp": 0,
              "science_level_type": 1,
              "finish_time": 0,
              "status": 0
          }
         ]"
  ]]
    
    for key, var in pairs(data) do
       Alliance.updateTechByServerData(var)
    end
end

--读取联盟科技信息列表
function Alliance.getTechData()
    if techData == nil then
       Alliance.reqTechData()
    end
    return techData
end

--请求联盟科技信息列表
function Alliance.reqTechData()
    local ret = false
    local function onRecv(result, msgData)
      if result == true then
        ret = true
        Alliance.setTechData(msgData.GuildScience)
      end
    end
    g_sgHttp.postData("data/index",{name = {"GuildScience",}},onRecv)
    return ret
end

function Alliance.reqTechDataAsync(callback)
    local function onRecv(result, msgData)
      if result == true then
        Alliance.setTechData(msgData.GuildScience)
      end
      if callback then
          callback(result, msgData)
      end
    end
    g_sgHttp.postData("data/index",{name = {"GuildScience",}},onRecv,true)
end

function Alliance.reqAllAllianceDataAsync(callback)
    
    local resultHandler = function(result, msgData)
      if result then
         local data = repaireAllAllianceBaseData(msgData)
         updateAllianceBaseData(data)
      end
      
      if callback then
         callback(result, msgData)
      end
    end
    g_sgHttp.postData("Guild/comboGuildMemberInfo",{},resultHandler,true)
   
end


function Alliance.getCampWarCurrentSeasonStatTime()
	return current_season_start_date
end


function Alliance.reqAllAllianceData()
    local ret = false
    local resultHandler = function(result, msgData)
      if result then
        ret = true
        Alliance.SetAllAllianceData(msgData)
      end
    end
    g_sgHttp.postData("Guild/comboGuildMemberInfo",{},resultHandler)
    return ret
end

function Alliance.SetAllAllianceData(msgData)
    local data = repaireAllAllianceBaseData(msgData)
    updateAllianceBaseData(data)
end

function Alliance.reqGuildPlayersAsync()
    if Alliance.getSelfHaveAlliance() then
        local resultHandler = function(result, msgData)
          if result then
            print("guild/viewAllMember success")
            updateAllianceBaseData(msgData)
          end
        end
        g_sgHttp.postData("guild/viewAllMember",{guild_id = Alliance.getBaseData().id},resultHandler,true)
    end
end

function Alliance.reqGuildPlayers()
    if Alliance.getSelfHaveAlliance() then
        local resultHandler = function(result, msgData)
          if result then
            print("guild/viewAllMember success")
            updateAllianceBaseData(msgData)
          end
        end
        g_sgHttp.postData("guild/viewAllMember",{guild_id = Alliance.getBaseData().id},resultHandler)
    end
    return true
end

function Alliance.setGuildPlayers(playerGuildData)
    if playerGuildData == nil then
        return
    end
    guildPlayers = {}
    for key, m in pairs(playerGuildData) do
      table.insert(guildPlayers,m)
    end
end

--获取联盟成员信息列表
function Alliance.getGuildPlayers()
    --{"100017":{"id":6,"player_id":100017,"guild_id":9,"rank":4,"create_time":1448092313,"update_time":1448092313,"Player":{"nick":"nick-561e4cb642267","is_online":0}}},"basic":[]}
    if #guildPlayers == 0 and Alliance.getSelfHaveAlliance()  then
        Alliance.reqGuildPlayers()
    end
    return guildPlayers
end

function Alliance.setRequestNum(num)
    requestNum = num
end

function Alliance.getRequestNum()
    return requestNum
end

function Alliance.isHaveApplyedMembers()
   local isHave = false
   local num = 0
   if Alliance.isAllianceManager() then
      if requestNum > 0  then
           isHave = true
           num = requestNum
      end
   end
   return isHave,num
end

function Alliance.clearAllApplyedMembers()
   Alliance.setRequestNum(0)
   applyedPlayers = {}
end

function Alliance.getApplyedMembers()
    return applyedPlayers
end

--    if not Alliance.isAllianceManager() then
--        return
--    end
    
--获取申请列表
function Alliance.reqApplyedMembersAsync(callback)
   
    local resultHandler = function(result, msgData)
      if result then
        print("guild/viewAllRequestMember success")
        updateAllianceBaseData(msgData)
      end
      
      if callback then
        callback(result, msgData)
      end
      
    end
    g_sgHttp.postData("guild/viewAllRequestMember",{guild_id = g_AllianceMode.getBaseData().id},resultHandler,true)
end
--解散联盟
function Alliance.reqDismissGuild()
    local ret = false
    local function onRecv(result, msgData)
      if result == true then
        ret = true
        g_AllianceMode.reqAllAllianceData()
        Alliance.notifyUpdateView()
        g_AllianceMode.updateWorldMap()
        haveShowRewardSend = false
        rewardCnt = 0
      end
    end
    g_sgHttp.postData("guild/dismissGuild",{},onRecv)
    return ret
end

function Alliance.updateWorldMap()
    require "game.maplayer.worldMapLayer_bigMap".forceRequestMapAllDataAndUpdateShow_Manual()
end

--更新AllianceTech 实例信息
function Alliance.updateTechByServerData(serverData)
    --[[
    {
          "id": 73,
          "science_type": 12,
          "science_level": 0,
          "science_exp": 0,
          "science_level_type": 1,
          "finish_time": 0,
          "status": 0
      }
    ]]
    local levelType  = serverData.science_level_type
    local scienceType = serverData.science_type
    local allianceTect = allTechData[levelType][scienceType]
    assert(allianceTect)
    allianceTect:updateExtraInfo(serverData)
end

--根据LevelType获取 AllianceTech 的实例列表
function Alliance.getTechDataByLevelType(type)
    local tables = {}
    local allTech = allTechData[type] or {}
    for key, var in pairs(allTech) do
      table.insert(tables,var)
    end
    
    table.sort(tables,function(a,b)
        return a:getConfig().id < b:getConfig().id
    end)
    
    return tables
end

--根据LevelType 和scienceType  获取 AllianceTech 的实例
function Alliance.getAllianceTech(levelType,scienceType)
    return allTechData[levelType][scienceType]
end

--根据和scienceType 获取 AllianceTech 的实例列表
function Alliance.getAllianceTechListByScienceType(scienceType)
    local list = {}
    for key, var in pairs(allTechData) do
    	if var[scienceType] then
    	   table.insert(list,var[scienceType])
    	end
    end
    return list
end

--获取所有
function Alliance.getAllAllianceTechs()
    local tables = {}
    for key, var in pairs(allTechData) do
    	for ikey, ivar in pairs(var) do
    		table.insert(tables,ivar)
    	end
    end
    return tables
end


--初始化联盟科技
function Alliance.initLocalTechData()
    for key, var in pairs(g_data.alliance_science) do
      if allTechData[var.level_type] == nil then
          allTechData[var.level_type] = {}
      end
      
      if allTechData[var.level_type][var.science_type] == nil then
          local AllianceTech = require("game.gamedata.AllianceTech") 
          allTechData[var.level_type][var.science_type] = AllianceTech.new(var.id)
      end
    end
end

--默认联盟搜索选项

--fix me
searchCondition.num = 0
searchCondition.condition_fuya_level = 0
searchCondition.max_num = 0
searchCondition.condition_player_power = 0
searchCondition.need_check = -1
--记录联盟搜索选项
function Alliance.getSearchCondition()
    return searchCondition
end

--获取联盟阶段名称
function Alliance.getRankNameByRank(rank)
    local rankName = Alliance.getBaseData().GuildRankName[rank]
     if rankName == nil or rankName == "" then
        rankName = g_tr("allianceRankName"..rank)
     end
     return rankName
end

--判断当前账号是否已经加入联盟
function Alliance.getSelfHaveAlliance()
    local selfHaveAlliance = false

    local data = Alliance.getBaseData()
    if data and data.id and data.id > 0 then
      selfHaveAlliance = true
    end
    return selfHaveAlliance
end

--是否是管理 （盟主和管理 r4 r5）
function Alliance.isAllianceManager()
    local result = false
    local selfInfo = Alliance.getSelfGuildPlayerInfo()
    if Alliance.getSelfHaveAlliance() and selfInfo and selfInfo.rank >= 4 then
        result = true
    end
    return result
end

--是否是盟主（r5）
function Alliance.isAllianceLeader()
    local result = false
    local selfInfo = Alliance.getSelfGuildPlayerInfo()
    if Alliance.getSelfHaveAlliance() and selfInfo and selfInfo.rank > 4 then
        result = true
    end
    return result
end

function Alliance.reqBaseDataAsync()
    local function onRecv(result, msgData)
      if result == true then
        --组合数据让格式在updateAllianceBaseData中通用
        local data = {}
        data.Guild = msgData
        updateAllianceBaseData(data)
        
        Alliance.notifyUpdateView()
      end
    end
    g_sgHttp.postData("guild/viewGuildInfo",{},onRecv,true)
end

function Alliance.reqBaseData()
    local ret = false
    local function onRecv(result, msgData)
      if result == true then
        ret = true

        --组合数据让格式在updateAllianceBaseData中通用
        local data = {}
        data.Guild = msgData
        updateAllianceBaseData(data)
      end
    end
    --g_sgHttp.postData("data/index",{name = {"PlayerGuild",}},onRecv)
    g_sgHttp.postData("guild/viewGuildInfo",{},onRecv)
    return ret
end

function Alliance.getGuildId()
    local data = Alliance.getBaseData()
    return data.id or 0
end

--读取联盟基本信息
function Alliance.getBaseData()
    if baseData == nil then
      Alliance.reqAllAllianceData()
    end
    return baseData
end

function Alliance.setBaseData(data)
    baseData = data
    local newSeasonTime = baseData.current_season_start_date
		if newSeasonTime then
			current_season_start_date = newSeasonTime
		end
end

function Alliance.getAllianceIconId(serverIconId)
    local currentIcon = serverIconId or Alliance.getBaseData().icon_id
    if currentIcon < g_Consts.AllianceIconDefaultId then
        currentIcon = g_Consts.AllianceIconDefaultId
    end 
    return currentIcon
end

function Alliance.getAllianceCampId()
	local campId = g_PlayerMode.GetData().camp_id
	if Alliance.getSelfHaveAlliance() then
		if Alliance.getBaseData() and Alliance.getBaseData().camp_id then
			campId = Alliance.getBaseData().camp_id
		end
	end
	return campId
end

--修改联盟信息
function Alliance.reqAlterGuild(data,callCack)
    local resultHandler = function(result, msgData)
        if result == true then
            Alliance.setBaseData(msgData)
            Alliance.notifyUpdateView()
        end
        callCack(result, msgData)
    end

    g_sgHttp.postData("guild/alterGuild",data,resultHandler)
end

--修改联盟阵营信息
function Alliance.reqChangeCamp(data,callCack)
    local resultHandler = function(result, msgData)
        if result == true then
            --Alliance.setBaseData(msgData)
            Alliance.notifyUpdateView()
        end
        callCack(result, msgData)
    end

    g_sgHttp.postData("guild/changeCamp",data,resultHandler)
end

function Alliance.addUpdateView(layer)
    for key, view in pairs(updateViews) do
        if view == layer then
            return
        end
    end
    table.insert(updateViews,layer)
end

function Alliance.removeUpdateView(layer)
    for key, view in pairs(updateViews) do
        if view == layer then
            table.remove(updateViews,key)
            break
        end
    end
end

function Alliance.removeAllUpdateView()
    updateViews = {}
end

function Alliance.notifyUpdateView()
    for key, view in pairs(updateViews) do
      assert(view.updateView)
      view:updateView()
    end
end

function Alliance.setMainView(allianceMainView)
    mainView = allianceMainView
end

function Alliance.getMainView()
    return mainView
end

--获取自己的联盟成员信息
function Alliance.getSelfGuildPlayerInfo()
    local myInfo = nil
    if Alliance.getSelfHaveAlliance() then
        local allMembers = Alliance.getGuildPlayers()
        for key, member in pairs(allMembers) do
          if member.player_id == g_PlayerMode.GetData().id then
             myInfo = member
             break
          end
        end
    end
    return myInfo
end

--获取盟主信息
function Alliance.getLeaderInfo()
    local leaderInfo = nil
    if Alliance.getSelfHaveAlliance() then
        local guildInfo = Alliance.getBaseData()
        local leaderPlayerId = 0 
        local guildGuildPlayers =  g_AllianceMode.getGuildPlayers()
        
        if guildInfo and guildInfo.leader_player_id and  guildInfo.id > 0  then
            leaderPlayerId = guildInfo.leader_player_id
        end

        print("leaderPlayerId",leaderPlayerId)

        if guildGuildPlayers and leaderPlayerId ~= 0 then
            for _, var in ipairs(guildGuildPlayers) do
                if var.player_id == leaderPlayerId then
                    leaderInfo = var
                    break
                end
            end
        end
    end

    return leaderInfo
end


Alliance.initLocalTechData()

return Alliance