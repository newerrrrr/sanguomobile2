--g_guildWarBattleInfoData
local guildWarBattleInfoData = {}
setmetatable(guildWarBattleInfoData,{__index = _G})
setfenv(1,guildWarBattleInfoData)

StatusType = {
    STATUS_READY 	= 0,
    STATUS_ATTACK_READY = 1,
    STATUS_ATTACK = 2,
    STATUS_ATTACK_CLAC = 3,
    STATUS_DEFEND_READY = 4,
    STATUS_DEFEND = 5,
    STATUS_DEFEND_CLAC = 6,
    STATUS_FINISH = 7,
}

local baseData = nil
local topPlayerData = nil
function NotificationUpdateShow()
	require("game.mapguildwar.worldMapLayer_uiLayer").checkAndShowResult()
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
	g_sgHttp.postData("Cross/battleInfo",{},onRecv)
	return ret
end

--玩家初始状态是否属于攻击方
function IsOriginalAttacker()
	local battleInfo = GetData()
	local guildWarPlayerData = g_guildWarPlayerData.GetData()
	--local playerId = tonumber(guildWarPlayerData.player_id)
	local guildId = tonumber(guildWarPlayerData.guild_id)
	return guildId == tonumber(battleInfo.guild_1_id)
end

--判断玩家当前是否属于攻击方
function IsAttacker()
	local isAttacker = false
	local battleInfo = GetData()
	if battleInfo == nil then
			return isAttacker
	end
	
	local guildWarPlayerData = g_guildWarPlayerData.GetData()
	local playerId = tonumber(guildWarPlayerData.player_id)
	local guildId = tonumber(guildWarPlayerData.guild_id)
	
	assert(guildId == tonumber(battleInfo.guild_1_id) or guildId == tonumber(battleInfo.guild_2_id))
	
	local battleStatus = battleInfo.status
--				STATUS_READY 	= 0,
--		    STATUS_ATTACK_READY = 1,
--		    STATUS_ATTACK = 2,
--		    STATUS_ATTACK_CLAC = 3,
--		    STATUS_DEFEND_READY = 4,
--		    STATUS_DEFEND = 5,
--		    STATUS_DEFEND_CLAC = 6,
--		    STATUS_FINISH = 7,
	if battleStatus == StatusType.STATUS_READY 
	or battleStatus == StatusType.STATUS_ATTACK_READY 
	or battleStatus == StatusType.STATUS_ATTACK 
	or battleStatus == StatusType.STATUS_ATTACK_CLAC 
	then
		if guildId == tonumber(battleInfo.guild_1_id) then
  		isAttacker = true
  	end
	else
		if guildId == tonumber(battleInfo.guild_2_id) then
			isAttacker = true
		end
	end 

--	if battleInfo.change_time and type(battleInfo.change_time) == "number" then
--    if g_clock.getCurServerTime() > battleInfo.change_time then
--    	if guildId == tonumber(battleInfo.guild_2_id) then
--    		isAttacker = true
--    	end
--    end
--	else
--		if guildId == tonumber(battleInfo.guild_1_id) then
--  		isAttacker = true
--  	end
--	end
	
	return isAttacker
end

--获取默认出生点区域
function GetCurrentDefaultArea()
	if IsAttacker() then
		local battleInfo = GetData()
		local attackList = {}
		for key, var in pairs(battleInfo.attack_area) do
			table.insert(attackList,tonumber(var))
		end
		table.sort(attackList,function(a,b)
			return a < b
		end)
		return attackList[1]
	else
		return 3
	end 
end

--获取当前开放的区的列表
function GetCurrentArea()
	local areaList = {}
	
	local battleInfo = GetData()
	
	if IsAttacker() then
		local attackList = {}
		for key, var in pairs(battleInfo.attack_area) do
			attackList[tonumber(var)] = var
		end
		areaList = attackList
	else
		areaList = {1,2,3,4,5}
	end
	
	return areaList
end

--该区域的投石车是否属于己方
function IsSelfOccupationArea(areaId)
	local isSelfArea = false
	
	assert(areaId ~= nil)

	local attackList = {}
	local battleInfo = GetData()
	for key, var in pairs(battleInfo.attack_area) do
		attackList[tonumber(var)] = var
	end
	
	if IsAttacker() then
		if attackList[tonumber(areaId)] then
			isSelfArea = true
		end
	else
		if attackList[tonumber(areaId)] == nil then
			isSelfArea = true
		end
	end 
	
	return isSelfArea
end

function getRealStatus()
	local currentTime = g_clock.getCurServerTime()
	local battleStatus = GetData().status
--				STATUS_READY 	= 0,
--		    STATUS_ATTACK_READY = 1,
--		    STATUS_ATTACK = 2,
--		    STATUS_ATTACK_CLAC = 3,
--		    STATUS_DEFEND_READY = 4,
--		    STATUS_DEFEND = 5,
--		    STATUS_DEFEND_CLAC = 6,
--		    STATUS_FINISH = 7,
	local realStatus = battleStatus

	if battleStatus == StatusType.STATUS_ATTACK_READY 
	or battleStatus == StatusType.STATUS_ATTACK then
		if currentTime <= GetData().real_start_time then
			realStatus = StatusType.STATUS_ATTACK_READY
		else
			realStatus = StatusType.STATUS_ATTACK
		end
	elseif battleStatus == StatusType.STATUS_DEFEND_READY
	or battleStatus == StatusType.STATUS_DEFEND then
		if currentTime <= GetData().change_time then
			realStatus = StatusType.STATUS_DEFEND_READY
		else
			realStatus = StatusType.STATUS_DEFEND
		end
	end 
	
	return realStatus
end

return guildWarBattleInfoData