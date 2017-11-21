--g_activityData
local ActivityData = {}
setmetatable(ActivityData,{__index = _G})
setfenv(1, ActivityData)

local baseData = nil

local giftData = nil

local activityData = nil

local newbieActivityLoginData = nil

local newbieActivityChargeData = nil

local newbieActivityConsumeData = nil

local actServerView = nil

local crossBasicInfoData = nil

local inCrossBattle = false

local inActivityView = false

local crossArmyInfoData = nil

local panicData = nil

--活动类型,根activity表path_type字段对应
ActivityType = {
	All = -1, --全部
	Normal = 0, --普通活动
	Operation = 1, --运营活动
	openService = 2 --开服活动
}

--更新显示
function NotificationUpdateShow()
	require("game.uilayer.activity.ActivityMainLayer").updateActivityOpenList()
end


function NotificationEffect()
	ShowEffect()
end

function SetData(data)
	baseData = data
end

function SetGiftData(data)
	giftData = data
end

function GetGiftData()
	return giftData
end

function SetNewbieLogin(data)
	newbieActivityLoginData = data
end

function SetNewbieCharge(data)
	newbieActivityChargeData = data
end

function SetNewbieConsume(data)
	newbieActivityConsumeData = data
end

function GetNewbieLogin()
	return newbieActivityLoginData
end

function GetNewbieCharge()
	return newbieActivityChargeData
end

function GetNewbieConsume()
	return newbieActivityConsumeData
end

function SetActServerView(value)
	actServerView = value
end

function SetInActivity(value)
	inActivityView = value
end

function SetCrossBasicInfo(value)
	crossBasicInfoData = value
end

function SetCrossArmyInfoData(value)
	crossArmyInfoData = value
end

function SetPanicData(value)
	panicData = data
end

--同步请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.activityList)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("Activity/getActivity",{},onRecv)
	return ret
end

--异步请求数据
function RequestDataAsync(callback)
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.activityList)
			NotificationUpdateShow()
		end
		
		if callback then
			callback(result, msgData)
		end
	end
	g_sgHttp.postData("Activity/getActivity",{},onRecv,true)
end

function RequestGiftList()
	local ret = false
	local tbl = 
	{
		["channel"] = g_channelManager.GetPayWayList()[1],
	}

	local function onRecv(result, data)
		if result == true then
			ret = true
			SetGiftData(data)
		end
	end

	g_netCommand.send("order/getGiftList", tbl, onRecv, false)
	return ret
end

function RequestNewbieActivityLogin()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetNewbieLogin(msgData.PlayerNewbieActivityLogin)
			refresh = false
		end
	end
	
	g_sgHttp.postData("data/index",{name = {"PlayerNewbieActivityLogin"}}, onRecv)
	
	return ret 
end

function RequestCrossBasicInfo()
	local ret = false
	local function onRecv(result, msgData)
		if result == true then

			ret = true

			SetCrossBasicInfo(msgData)
		end
	end

	g_netCommand.send("cross/basicInfo", {}, onRecv)

	return ret
end

function RequestSycCrossBasicInfo()
	local function onRecv(result, msgData)
		if result == true then
			SetCrossBasicInfo(msgData)
		end
	end

	g_netCommand.send("cross/basicInfo", {}, onRecv, true)
end

function RequestNewbieActivityCharge()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetNewbieCharge(msgData.PlayerNewbieActivityCharge)
			refresh = false
		end
	end
	
	g_sgHttp.postData("data/index",{name = {"PlayerNewbieActivityCharge"}}, onRecv)
	
	return ret 
end

function RequestNewbieActivityChargeSyc()
	local function onRecv(result, msgData)
		if(result==true)then
			SetNewbieCharge(msgData.PlayerNewbieActivityCharge)
			refresh = false
		end
	end
	
	g_sgHttp.postData("data/index",{name = {"PlayerNewbieActivityCharge"}}, onRecv, true)
end

function RequestNewbieActivityConsume()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetNewbieConsume(msgData.PlayerNewbieActivityConsume)
			refresh = false
		end
	end
	
	g_sgHttp.postData("data/index",{name = {"PlayerNewbieActivityConsume"}}, onRecv)
	
	return ret 
end

function RequestCrossArmyInfo()
	local ret = false
	local function callback(result, data)
		if result == true then
			ret = true
			SetCrossArmyInfoData(data)
		end
	end

	g_netCommand.send("cross/crossArmyInfo", {}, callback)
end

function RequestPanicShow(fun)
	local function callback(result, data)
		if result == true then
			SetPanicData(data)

			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/panicShow", {}, callback, true)
end

function doPanic(id, fun)
	local tbl = 
	{
		["buyId"] = id,
	}

	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				dump(data)
				local result = g_tr("panicSuc")
				for i=1, #data.drop do
					local item = require("game.uilayer.common.DropItemView").new(data.drop[i].type,data.drop[i].id,data.drop[i].num)

					result = result..item:getName().."x"..data.drop[i].num

					if i < #data.drop	then
						result = result..","
					end
				end
				g_airBox.show(result)
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/doPanic", tbl, callback, true)
end

function GetCrossArmyInfo()
	if crossArmyInfoData == nil then
		RequestCrossArmyInfo()
	end
	return crossArmyInfoData.cross_army_info.army
end

function GetCrossBasicInfo()
	if crossBasicInfoData == nil then
		RequestCrossBasicInfo()
	end

	return crossBasicInfoData
end

function GetCrossState()
	local data = GetCrossBasicInfo()

	if data == nil then
		return false
	end

	--if data.current_guild_info and data.current_guild_info.round_status == 3 and data.current_guild_info.cross_joined_flag == 1 and data.current_guild_info.guild_status == 1 then
	if data.current_guild_info and data.current_guild_info.round_status >= 0 and data.current_guild_info.round_status < 4 then	
		return true
	end

	return false
end

function IsInBattle()
	local data = GetCrossBasicInfo()

	if data == nil then
		return false
	end

	if inCrossBattle == true then
		return false
	end

	if inActivityView == true then
		return false
	end

	if data.current_guild_info and data.current_guild_info.round_status == 3 and data.current_guild_info.cross_joined_flag == 1 and data.current_guild_info.guild_status == 1 then
		inCrossBattle = true
		return true
	end

	return false
end


function ShowBanner()
	local data = GetData()

	if data == nil then
		return g_Consts.BannerType.noActivity
	end

	local result = g_Consts.BannerType.money

	if g_saveCache.banner_save == 0 then
		g_saveCache.banner_save = 1

		--限时比赛
		local data = require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").GetCustomMatchInfo()
		if data.status ~= 0 then
			result = g_Consts.BannerType.kill
			return result
		end

		local MissionMode = require("game.uilayer.activity.allianceMission.AllianceMissionMode")
		local isOpen, missionType = MissionMode:hasMissionOpen()
		if isOpen == true then
			result = g_Consts.BannerType.mission
			return result
		end
	end

	for i=1, #data do
		if data[i].activity_id == 1017 or data[i].activity_id == 1018 or data[i].activity_id == 1019 or data[i].activity_id	== 1022 
			or data[i].activity_id == 1020 or data[i].activity_id == 1023 or data[i].activity_id == 1026 or data[i].activity_id == 1027 
			then
			result = g_Consts.BannerType.activity
			break
		end
	end

	return result
end

function ShowNewbieIcon()
	local player = g_PlayerMode.GetData()

	if g_Account.getCurrentAreaInfo().id >= tonumber(g_data.starting[102].data) and (g_clock.getCurServerTime() - player.create_time) <= tonumber(g_data.starting[101].data)*24*3600 then
		return true
	end

	return false
end

function GetData()
	if baseData == nil then
		RequestData()
	end

	return baseData
end

function InitData()
	activityData = {}
	for key, value in pairs(g_data.activity_commodity) do
		if value.open_time ~= 0 then
			if value.open_time > g_clock.getCurServerTime() then
				activityData[key] = false
			else
				activityData[key] = true
			end
		end
	end
end

--是否需要重新刷新数据
function RefreshData()
	local tag = false
	for key, value in pairs(g_data.activity_commodity) do
		if activityData[key] == false and value.open_time <= g_clock.getCurServerTime() then
			activityData[key] = true
			tag = true
		end
	end

	if tag == true then
		RequestData()
	end
	
	return tag
end

function UpdateServerView()
	if actServerView ~= nil then
		actServerView:update()
	end
end

function UpdateServerViewTip()
	if actServerView ~= nil then
		--actServerView:updateShowTip()
	end
end

function ShowEffect()
	local playerInfo = g_playerInfoData.GetData()
	local loginInfo = g_activityData.GetNewbieLogin()
	local player = g_PlayerMode.GetData()

	local mainSurfacePlayer = require("game.uilayer.mainSurface.mainSurfacePlayer")

	--进入游戏为1级的情况下，可能为空
	if loginInfo == nil then
		return
	end

	local tag = false
	for i=1,#playerInfo.newbie_login do
		if loginInfo.flag[i] == nil then
			tag = true
			break
		end
	end

	if tag == true then
		mainSurfacePlayer.showNewbieEffect(true)
		return
	end

	local chargeInfo = g_activityData.GetNewbieCharge()

	if chargeInfo == nil then
		return
	end

	if (#chargeInfo) > 0 then
		local dataList = {}
		local time = math.ceil((g_clock.getCurServerTime() - player.create_time)/3600/24)

		for i=1,#g_data.act_newbie_recharge do
			if time >= g_data.act_newbie_recharge[i].open_date and time <= g_data.act_newbie_recharge[i].close_date then
				table.insert(dataList, g_data.act_newbie_recharge[i])
			end
		end

		if (#dataList) > 0 then
			for i=1,#chargeInfo do
				local t = false
				if chargeInfo[i].period == dataList[1].period then
					if #chargeInfo[i].flag <= 0 then
						break
					end

					for j=1, #dataList do
						local tag = false
						for k=1, #chargeInfo[i].flag do
							if tonumber(chargeInfo[i].flag[k]) == dataList[j].recharge_price then
								tag = true
								break
							end
						end

						if tag == false then
							mainSurfacePlayer.showNewbieEffect(true)
							t = true
							return
						end
					end
				end

				if t == true then
					break
				end
			end
		end
	end

	local costInfo = g_activityData.GetNewbieConsume()

	if costInfo == nil then
		return
	end

	if(#costInfo) > 0 then
		local dataList = {}
		local time = math.ceil((g_clock.getCurServerTime() - player.create_time)/3600/24)

		local period = 0
		for i=1,#g_data.act_newbie_cost do
			if time >= g_data.act_newbie_cost[i].open_date and time <= g_data.act_newbie_cost[i].close_date then
				table.insert(dataList, g_data.act_newbie_cost[i])
				period = g_data.act_newbie_cost[i].period
			end
		end

		if #dataList > 0 then
			
			local curData = nil
			local gem = 0

			for i=1, #costInfo do
				local tag = false
				if costInfo[i].period == period then
					gem = costInfo[i].gem
					for j=1, #dataList do
						if costInfo[i].flag[j..""] then
							tag = true
							gem = gem - dataList[j].cost_price
						else
							tag = false
							curData = dataList[j]
							break
						end
					end

					if tag == false then
						if curData.cost_price <= gem then
							mainSurfacePlayer.showNewbieEffect(true)
							return
						end
						break
					end
				end
			end
		end
	end

	mainSurfacePlayer.showNewbieEffect(false)
end

return ActivityData