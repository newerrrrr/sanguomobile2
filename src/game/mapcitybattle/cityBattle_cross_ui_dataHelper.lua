--g_cityBattle_cross_ui_dataHelper
local cityBattle_cross_ui_dataHelper = {}
setmetatable(cityBattle_cross_ui_dataHelper,{__index = _G})
setfenv(1,cityBattle_cross_ui_dataHelper)

local changeMapScene = require("game.maplayer.changeMapScene")
function requirePlayer()
	local data = nil
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		data = g_guildWarPlayerData
	else
		data = g_cityBattlePlayerData
	end
	return data
end

function requireBattleInfo()
	local data = nil
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		data = g_guildWarBattleInfoData
	else
		data = g_cityBattleInfoData
	end
	return data
end

function requireCrossGuildOrCityBattleCamp()
	local data = nil
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		data = g_crossGuild
	else
		data = g_cityBattleCamp
	end
	return data
end

function requireGeneral()
	local data = nil
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		data = g_crossGeneral
	else
		data = g_cityBattleGeneral
	end
	return data
end

function requireMasterSkill()
	local data = nil
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		data = g_crossPlayerMasterskill
	else
		data = g_cityBattlePlayerMasterskill
	end
	return data
end

function requireSoldier()
	local data = nil
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		data = g_crossSoldier
	else
		data = g_cityBattleSoldier
	end
	return data
end

function requireArmy()
	local data = nil
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		data = g_crossArmy
	else
		data = g_cityBattleArmy
	end
	return data
end

function requireArmyUnit()
	local data = nil
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		data = g_crossArmyUnit
	else
		data = g_cityBattleArmyUnit
	end
	return data
end

function requireMapSpBuildData()
	local data = nil
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		data = g_guildWarMapSpBuildData
	else
		data = g_cityBattleMapSpBuildData
	end
	return data
end



return cityBattle_cross_ui_dataHelper