local GroundData = {}
setmetatable(GroundData,{__index = _G})
setfenv(1, GroundData)

local baseData = nil

local baseView = nil

function NotificationUpdateShow()
	if baseView ~=nil then
		baseView:show()
	end
end

function RequestSycData(callback)
	local function onRecv(result, msgData)
		if(result==true)then
			g_ArmyUnitMode.SetData(msgData.PlayerArmyUnit)
			g_ArmyMode.SetData(msgData.PlayerArmy)
			NotificationUpdateShow()
		else
			if baseView ~= nil then
				baseView:executeCallback()
			end
		end

		if callback ~= nil then
			callback(result, msgData)
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerArmy","PlayerArmyUnit"}},onRecv, true)	
end

function RequestSycGetArmyAndArmyUnitData(callback)
	local function onRecv(result, msgData)
		if callback  then
			callback(result, msgData)
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerArmy","PlayerArmyUnit"}},onRecv, true)
end

function RequestSycCrossData(callback)
	local function onRecv(result, msgData)
		g_busyTip.hide_1()
		if(result==true)then
			
			g_guildWarPlayerData.SetData(msgData.CrossPlayer)
			g_guildWarPlayerData.NotificationUpdateShow()
			
			g_crossSoldier.SetData(msgData.CrossPlayerSoldier)
			g_crossGeneral.SetData(msgData.CrossPlayerGeneral)
			g_crossArmy.SetData(msgData.CrossPlayerArmy)
			g_crossArmyUnit.SetData(msgData.CrossPlayerArmyUnit)
			g_crossGuild.SetData(msgData.CrossGuild)
			g_crossPlayerMasterskill.SetData(msgData.CrossPlayerMasterskill)

			NotificationUpdateShow()
		else
			if baseView ~= nil then
				baseView:executeCallback()
			end
		end

		if callback ~= nil then
			callback(result, msgData)
		end
	end

	g_busyTip.show_1()
	g_sgHttp.postData("data/index",{name = {"CrossPlayer","CrossPlayerSoldier", "CrossPlayerGeneral", "CrossPlayerArmy", "CrossPlayerArmyUnit","CrossGuild","CrossPlayerMasterskill"}},onRecv, true)	
end

function RequestSycCrossBattleData(callback)
	local function onRecv(result, msgData)
		g_busyTip.hide_1()
		if(result==true)then
			g_crossArmy.SetData(msgData.CrossPlayerArmy)
			g_crossArmyUnit.SetData(msgData.CrossPlayerArmyUnit)
			g_crossSoldier.SetData(msgData.CrossPlayerSoldier)
			NotificationUpdateShow()
		else
			if baseView ~= nil then
				baseView:executeCallback()
			end
		end

		if callback ~= nil then
			callback(result, msgData)
		end
	end

	g_busyTip.show_1()
	g_sgHttp.postData("data/index",{name = {"CrossPlayerArmy", "CrossPlayerArmyUnit","CrossPlayerSoldier"}},onRecv, true)	
end

function RequestSycCityBattleData(callback)
	local function onRecv(result, msgData)
		g_busyTip.hide_1()
		if(result==true)then
			
			g_cityBattlePlayerData.SetData(msgData.CityBattlePlayer)
			g_cityBattlePlayerData.NotificationUpdateShow()
			
			g_cityBattleSoldier.SetData(msgData.CityBattlePlayerSoldier)
			g_cityBattleGeneral.SetData(msgData.CityBattlePlayerGeneral)
			g_cityBattleArmy.SetData(msgData.CityBattlePlayerArmy)
			g_cityBattleArmyUnit.SetData(msgData.CityBattlePlayerArmyUnit)
			g_cityBattleCamp.SetData(msgData.CityBattleCamp)
			g_cityBattlePlayerMasterskill.SetData(msgData.CityBattlePlayerMasterskill)

			NotificationUpdateShow()
		else
			if baseView ~= nil then
				baseView:executeCallback()
			end
		end

		if callback ~= nil then
			callback(result, msgData)
		end
	end

	g_busyTip.show_1()
	g_sgHttp.postData("data/index",{name = {"CityBattlePlayer","CityBattlePlayerSoldier", "CityBattlePlayerGeneral", "CityBattlePlayerArmy", "CityBattlePlayerArmyUnit","CityBattleCamp","CityBattlePlayerMasterskill"}},onRecv, true)	
end

function RequestSycCityBattleBattleData(callback)
	local function onRecv(result, msgData)
		g_busyTip.hide_1()
		if(result==true)then
			g_cityBattleArmy.SetData(msgData.CityBattlePlayerArmy)
			g_cityBattleArmyUnit.SetData(msgData.CityBattlePlayerArmyUnit)
			g_cityBattleSoldier.SetData(msgData.CityBattlePlayerSoldier)
			NotificationUpdateShow()
		else
			if baseView ~= nil then
				baseView:executeCallback()
			end
		end

		if callback ~= nil then
			callback(result, msgData)
		end
	end

	g_busyTip.show_1()
	g_sgHttp.postData("data/index",{name = {"CityBattlePlayerArmy", "CityBattlePlayerArmyUnit","CityBattlePlayerSoldier"}},onRecv, true)	
end

function SetView(value)
	baseView = value
end

return GroundData