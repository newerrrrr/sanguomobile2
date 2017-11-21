--g_cityBattleInfoData
local cityBattleInfoData = {}
setmetatable(cityBattleInfoData,{__index = _G})
setfenv(1,cityBattleInfoData)

StatusType = {
    STATUS_READY 	= 0,
    STATUS_ATTACK_READY = 1,
    STATUS_ATTACK = 2,
    STATUS_ATTACK_CLAC = 3,
    STATUS_DEFEND_READY = 4,
    STATUS_DEFEND = 5,
    STATUS_DEFEND_CLAC = 6,
    STATUS_FINISH = 7,
    
    STATUS_DEFAULT = 0,
    STATUS_READY_SEIGE = 1,
    STATUS_SEIGE = 2,
    STATUS_CLAC_SEIGE = 3,
		STATUS_READY_MELEE = 4,
    STATUS_MELEE = 5,
    STATUS_CLAC_MELEE = 6,
    STATUS_FINISH = 7,
    
}

local baseData = nil
local topPlayerData = nil
function NotificationUpdateShow()
	require("game.mapcitybattle.worldMapLayer_uiLayer").checkAndShowResult()
end


function SetTopPlayerData(data)
	topPlayerData = data
end

function GetTopPlayerData()
	if topPlayerData == nil then
		RequestData()
	end
	return topPlayerData
end

function SetData(data)
	baseData = data
end

--[battleInfo] => Array (13) (
--  [id] => Numeric string (3) "383"
--  [round_id] => Numeric string (1) "2"
--  [guild_1_id] => Numeric string (7) "1000001"
--  [guild_2_id] => Numeric string (7) "1000074"
--  [map_type] => Numeric string (1) "1"
--  [start_time] => Integer (1487246400)
--  [change_time] => Integer (-62170013143)
--  [attack_area] => Array (1) (
--    [0] => Numeric string (1) "1"
--  )
--  [status] => Numeric string (1) "2"
--  [guild_1_total_score] => Numeric string (4) "1070"
--  [guild_2_total_score] => Numeric string (1) "0"
--  [create_time] => String (19) "2017-02-16 10:12:26"
--  [update_time] => String (19) "2017-02-16 10:12:26"
--)
--得到基本信息,只可使用不可修改
function GetData()
	if baseData == nil then
		RequestData()
	end
	return baseData
end

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.battleInfo)
			SetTopPlayerData(msgData.topPlayer)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("City_Battle/battleInfo",{},onRecv)
	return ret
end

--请求数据
function RequestDataAsync(callback)
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.battleInfo)
			SetTopPlayerData(msgData.topPlayer)
			NotificationUpdateShow()
		end
		if callback then
			callback(result, msgData)
		end
	end
	g_sgHttp.postData("City_Battle/battleInfo",{},onRecv,true)
end

--玩家初始状态是否属于攻击方
--function IsOriginalAttacker()
--	local battleInfo = GetData()
--	local guildWarPlayerData = g_cityBattlePlayerData.GetData()
--	--local playerId = tonumber(guildWarPlayerData.player_id)
--	local guildId = tonumber(guildWarPlayerData.guild_id)
--	return guildId == tonumber(battleInfo.guild_1_id)
--end

--是否有城内战资格
function CanEnterMeleeRound()
	local canEnter = false
	if not IsDoorMap() then
		local battleInfo = GetData()
		local guildWarPlayerData = g_cityBattlePlayerData.GetData()
		if guildWarPlayerData.camp_id == battleInfo.attack_camp or guildWarPlayerData.camp_id == battleInfo.defend_camp then
			canEnter = true
		end
	end
	return canEnter
end

--判断玩家当前是否属于攻击方
function IsAttacker()
	local isAttacker = false
	local battleInfo = GetData()
--	if battleInfo == nil then
--			return isAttacker
--	end
	
	--[[
	  	[id] => Integer (9)
      [round_id] => Integer (3)
      [city_id] => Integer (2001)
      [map_type] => Integer (1)
      [camp_id] => Integer (0)
      [start_time] => Integer (1500508800)
      [real_start_time] => Integer (1500519480)
      [melee_time] => Integer (0)
      [melee_end_time] => Integer (0)
      [attack_camp] => Integer (0)
      [defend_camp] => Integer (0)
      [attack_score] => Integer (0)
      [defend_score] => Integer (0)
      [score_time] => Integer (0)
      [status] => Integer (1)
      [win_camp] => Integer (0)
      [sign_num_wei] => Integer (11)
      [sign_num_shu] => Integer (0)
      [sign_num_wu] => Integer (11)
      [door1] => Integer (0)
      [door2] => Integer (0)
      [door3] => Integer (0)
      [first_blood_1] => Integer (0)
      [first_blood_2] => Integer (0)
      [camp_1_kill] => Integer (0)
      [camp_2_kill] => Integer (0)
      [camp_3_kill] => Integer (0)
      [door_battle_time] => Integer (0)
      [create_time] => Integer (1500517090)
      [update_time] => Integer (1500519300)
      ]]
      
	if battleInfo.status <= StatusType.STATUS_CLAC_SEIGE then --城门战
		if tonumber(battleInfo.camp_id) == 0 then
			isAttacker = true
		else
			local guildWarPlayerData = g_cityBattlePlayerData.GetData()
			isAttacker = not (tonumber(battleInfo.camp_id) == tonumber(guildWarPlayerData.camp_id))
		end
	else --城内战
		local guildWarPlayerData = g_cityBattlePlayerData.GetData()
		--assert(guildWarPlayerData.camp_id == battleInfo.attack_camp or guildWarPlayerData.camp_id == battleInfo.defend_camp)
		if guildWarPlayerData.camp_id == battleInfo.attack_camp then
			isAttacker = true
		else
			isAttacker = false
		end
	end
	
	return isAttacker
	
	
end

function GetCurrentMapType()
	--local battleInfo = GetData()
	local mapType = 1
	local status = getRealStatus()
	if status <= StatusType.STATUS_CLAC_SEIGE then
		mapType = 1
	else
		mapType = 2
	end
	return mapType
end

function IsDoorMap()
	return GetCurrentMapType() == 1
end

--获取默认出生点区域
function GetCurrentDefaultArea()
	if IsAttacker() then
		local guildWarPlayerData = g_cityBattlePlayerData.GetData()
		return guildWarPlayerData.camp_id
	else
		return 4
	end 
end

--获取当前开放的区的列表
function GetCurrentArea()
	local areaList = {}
	
	local battleInfo = GetData()
	
	if IsDoorMap() then
		if IsAttacker() then
			local guildWarPlayerData = g_cityBattlePlayerData.GetData()
			local attackList = {guildWarPlayerData.camp_id}
		else
			areaList = {1,2,3,4}
		end
	else
		areaList = {1,2,3,4,5}
	end
	return areaList
end

--该区域的投石车是否属于己方
function IsSelfOccupationArea(areaId)
	local isSelfArea = true --城战的投石车双方都可以占领
--	
--	assert(areaId ~= nil)
--
--	local attackList = {}
--	local battleInfo = GetData()
--	for key, var in pairs(battleInfo.attack_area) do
--		attackList[tonumber(var)] = var
--	end
--	
--	if IsAttacker() then
--		if attackList[tonumber(areaId)] then
--			isSelfArea = true
--		end
--	else
--		if attackList[tonumber(areaId)] == nil then
--			isSelfArea = true
--		end
--	end 

	if IsDoorMap() then
		isSelfArea = not IsAttacker()
	else
		isSelfArea = true
	end
	
	return isSelfArea
end

function getRealStatus()
	local currentTime = g_clock.getCurServerTime()
	local battleStatus = GetData().status
--    
--    STATUS_DEFAULT = 0,
--    STATUS_READY_SEIGE = 1,
--    STATUS_SEIGE = 2,
--    STATUS_CLAC_SEIGE = 3,
--		STATUS_READY_MELEE = 4,
--    STATUS_MELEE = 5,
--    STATUS_CLAC_MELEE = 6,
--    STATUS_FINISH = 7,
	local realStatus = battleStatus

	if battleStatus == StatusType.STATUS_READY_SEIGE 
	or battleStatus == StatusType.STATUS_SEIGE then
		if currentTime <= GetData().real_start_time then
			realStatus = StatusType.STATUS_READY_SEIGE
		else
			realStatus = StatusType.STATUS_SEIGE
		end
	elseif battleStatus == StatusType.STATUS_READY_MELEE
	or battleStatus == StatusType.STATUS_MELEE then
		if currentTime <= GetData().melee_time then
			realStatus = StatusType.STATUS_READY_MELEE
		else
			realStatus = StatusType.STATUS_MELEE
		end
	end 
	
	return realStatus
end

return cityBattleInfoData