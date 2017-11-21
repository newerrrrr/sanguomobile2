--g_guildWarMapSpBuildData
local guildWarMapSpBuildData = {}
setmetatable(guildWarMapSpBuildData,{__index = _G})
setfenv(1,guildWarMapSpBuildData)

local m_spBuildMapData = {}
local m_spBuildPlayerData = {}
local m_localSpBuildData = {}


function setSpBuildData(data)
	if data == nil then
		return
	end
	
	m_spBuildMapData = {}
	for key, var in pairs(data.Map) do
		if m_localSpBuildData[var.x.."_"..var.y] then --只缓存特殊建筑
			m_spBuildMapData[var.x.."_"..var.y] = var
		end
	end
	
	m_spBuildPlayerData = data.Player
	
end

function getSpBuildPlayerDatas()
	return m_spBuildPlayerData
end

function getSpBuildMapDatas()
	return m_spBuildMapData
end

function getSpBuildDataBy_xy(x,y)
	return m_spBuildMapData[x.."_"..y]
end

function getLocalSpBuildDataBy_xy(x,y)
	return m_localSpBuildData[x.."_"..y]
end

local _initconfig = function()
	for key, var in pairs(g_data.cross_map_config) do
		if var.cross_map_element_id > 0 then
			local localSpBuildData =  clone(var)
			localSpBuildData.build_display = {} --用于存放自定义数据
			m_localSpBuildData[var.x.."_"..var.y] = localSpBuildData
		end
	end
end

_initconfig()

return guildWarMapSpBuildData