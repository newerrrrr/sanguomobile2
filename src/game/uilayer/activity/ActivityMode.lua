--region ActivityMode.lua
--Author : luqingqing
--Date   : 2016/3/29
--此文件由[BabeLua]插件自动生成

local ActivityMode = class("ActivityMode")

local baseView = nil

local wheelView = nil

function ActivityMode:ctor()

end

function ActivityMode:PlayerSignAward(fun)
	local function onRecv(result, msgData)
		
		local playerSignAward = nil
	
		if(result==true)then
			playerSignAward = msgData.PlayerSignAward
		end
		
		if fun then
			fun(playerSignAward)
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerSignAward",}},onRecv, true)
end

function ActivityMode:doGetSignAward(fun)
	local function callback(result, data)
		if result == true then
			g_actSign.RequestSycData()
		end
		
		if fun ~= nil then
			fun(result)
		end
	end

	g_netCommand.send("award/doGetSignAward", {}, callback, true)
end

function ActivityMode:getNowShowData()
	local limitData = g_limitRewardData:GetData()
	if limitData == nil then
		return nil 
	end

	local data = nil
	for key, var in ipairs(limitData) do
		if var.status == 0 then
			data = var
			break
		end
	end

	return data
end

function ActivityMode:getGiftList(channel, fun)
	local tbl = 
	{
		["channel"] = channel,
	}

	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("order/getGiftList", tbl, callback, false)
end

--请求数据
function ActivityMode:getTargetInfo(fun)
	if fun ~= nil then
		g_actSevenDayTarget.RequestSycData()
		fun(g_actSevenDayTarget.GetData())
	end
end

function ActivityMode:getTargetReward(current_id, fun)
	local tbl = 
	{
		["current_id"] = current_id,
	}

	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("target/getTargetAward", tbl, callback, false)
end

function ActivityMode:getLongCardAward(fun)
	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(1)
			end
		end
	end

	g_netCommand.send("player_info/getLongCardAward", {}, callback, false)
end

function ActivityMode:getMonthCardAward(fun)
	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(2)
			end
		end
	end

	g_netCommand.send("player_info/getMonthCardAward", {}, callback, false)
end

function ActivityMode:charge(fun)
	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/charge", {}, callback, false)
end

function ActivityMode:chargeReward(gem, fun)
	local tbl = 
	{
		["gem"] = gem,
	}

	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/chargeReward", tbl, callback, false)
end

function ActivityMode:loginCharge(fun)
	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/login", {}, callback, false)
end

function ActivityMode:loginReward(days, fun)
	local tbl = 
	{
		["days"] = days,
	}

	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/loginReward", tbl, callback, false)
end

function ActivityMode:npcDrop(fun)
	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/npcDrop", {}, callback, false)
end

function ActivityMode:consume(fun)
	local function callback(result, data)
		if result == true then
			if baseView ~= nil and fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/consume", {}, callback, true)
end

function ActivityMode:consumeReward(gem, fun)
	local tbl = 
	{
		["gem"] = gem,
	}

	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/consumeReward", tbl, callback, false)
end

function ActivityMode:wheel(fun)
	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/wheel", {}, callback)
end

function ActivityMode:wheelPlay(num, fun)
	local tbl = 
	{
		["num"] = num,
	}

	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		else
			if fun ~= nil then
				fun(nil)
			end
		end
	end

	g_netCommand.send("activity/wheelPlay", tbl, callback)
end

function ActivityMode:wheelReward(counter, fun)
	local tbl = 
	{
		["counter"] = counter,
	}
	local function callback(result, data)
		if result == true then
			g_airBox.show(g_tr("actFetchSuc"))
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/wheelReward", tbl, callback)
end

function ActivityMode:newbieLoginReward(days, fun)
	local tbl = 
	{
		["days"] = days,
	}
	local function callback(result, data)
		if result == true then
			g_airBox.show(g_tr("actFetchSuc"))
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/newbieLoginReward", tbl, callback)
end

function ActivityMode:newbieChargeReward(id, fun)
	local tbl = 
	{
		["id"] = id,
	}
	
	local function callback(result, data)
		if result == true then
			g_airBox.show(g_tr("actFetchSuc"))
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/newbieChargeReward", tbl, callback)
end

function ActivityMode:newbieConsumeReward(id, fun)
	local tbl = 
	{
		["id"] = id,
	}

	local function callback(result, data)
		if result == true then
			g_airBox.show(g_tr("actFetchSuc"))
			if fun ~= nil then
				fun(data)
			end
		end
	end

	g_netCommand.send("activity/newbieConsumeReward", tbl, callback)
end


--跨服战/城战 请求军团武将信息
function ActivityMode:reqArmyInfoByType(battleType, fun)

	local function callback(result, data)
		g_busyTip.hide_1()
		if result == true then
			if fun ~= nil then
				fun(data)
			end
		end
	end
	
	local host = battleType == 0 and "cross/crossArmyInfo" or "city_battle/setGeneral/" 
	g_netCommand.send(host, {}, callback, true)

	g_busyTip.show_1()
end 

--更换武将 battleType:0 跨服战 1:城战
function ActivityMode:changeArmyGeneral(battleType, general_ids, idx, fun)
	local tbl = 
	{
		["army"] = 
		{
			["index"] = idx,
			["general_ids"] = general_ids,
		}
	}

	local function callback(result, data)
		g_busyTip.hide_1()
		if result == true then
			if fun ~= nil then
				g_airBox.show(g_tr("selGneralSuc"))
				fun(data)
			end
		end
	end

	g_busyTip.show_1()

	local host = battleType == 0 and "cross/crossArmyInfo" or "city_battle/setGeneral/" 
	g_netCommand.send(host, tbl, callback) 
end

--更换城战技能 battleType:0 跨服战 1:城战
function ActivityMode:changeBattleSkill(battleType, skill, fun)
	local tbl = 
	{
		["skill"] = skill
	}

	local function callback(result, data)
		if result == true then
			if fun ~= nil then
				g_airBox.show(g_tr("selSkillSuc"))
				fun(data)
			end
		end
	end

	local host = battleType == 0 and "cross/crossArmyInfo" or "city_battle/setGeneral/" 
	g_netCommand.send(host, tbl, callback)
end


function ActivityMode:SetView(value)
	baseView = value
end

function ActivityMode:setWheelView(value)
	wheelView = value
end

return ActivityMode

--endregion
