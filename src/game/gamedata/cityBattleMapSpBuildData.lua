--g_cityBattleMapSpBuildData
local cityBattleMapSpBuildData = {}
setmetatable(cityBattleMapSpBuildData,{__index = _G})
setfenv(1,cityBattleMapSpBuildData)

local m_spBuildMapData = {}
local m_spBuildPlayerData = {}
local m_localSpBuildData = {}


function setSpBuildData(data)
	if data == nil then
		return
	end
	
	local mapType = g_cityBattleInfoData.GetCurrentMapType()
	m_spBuildMapData = {}
	--dump(m_localSpBuildData)
	for key, var in pairs(data.Map) do
		if m_spBuildMapData[mapType] == nil then
			m_spBuildMapData[mapType] = {}
		end
		if m_localSpBuildData[mapType][var.x.."_"..var.y] then --只缓存特殊建筑
			m_spBuildMapData[mapType][var.x.."_"..var.y] = var
		end
	end
	
	m_spBuildPlayerData = data.Player
	
end

function getSpBuildPlayerDatas()
	return m_spBuildPlayerData
end

function getSpBuildMapDatas(mapType)
	if mapType == nil then
		mapType = g_cityBattleInfoData.GetCurrentMapType()
	end
	return m_spBuildMapData[mapType]
end

function getSpBuildDataBy_xy(x,y,mapType)
	if mapType == nil then
		mapType = g_cityBattleInfoData.GetCurrentMapType()
	end
	
	return m_spBuildMapData[mapType][x.."_"..y]
end

function getLocalSpBuildDataBy_xy(x,y,mapType)
	if mapType == nil then
		mapType = g_cityBattleInfoData.GetCurrentMapType()
	end

	local localSpBuildData = nil
	if m_localSpBuildData[mapType] then
		localSpBuildData = m_localSpBuildData[mapType][x.."_"..y]
	end
	return localSpBuildData
end

local _initconfig = function()
	for key, var in pairs(g_data.city_battle_map_config) do
		if var.city_battle_map_element_id > 0 then
			local localSpBuildData =  clone(var)
			localSpBuildData.build_display = {} --用于存放自定义数据
			if m_localSpBuildData[var.part] == nil then
				m_localSpBuildData[var.part] = {}
			end
			m_localSpBuildData[var.part][var.x.."_"..var.y] = localSpBuildData
		end
	end
end

_initconfig()

return cityBattleMapSpBuildData