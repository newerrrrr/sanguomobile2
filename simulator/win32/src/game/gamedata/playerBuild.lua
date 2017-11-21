local playerBuildMode = {}
setmetatable(playerBuildMode,{__index = _G})
setfenv(1,playerBuildMode)


m_BuildOriginType = {
	mainCity      = 1,		--官府
	rampart       = 2,		--城墙
	workshop      = 3,		--战争工坊
	infantry      = 4,		--步兵营
	archers       = 5,		--弓兵营
	cavalry       = 6,		--骑兵营
	car           = 7,		--车兵营
	cache         = 8,		--仓库
	smithy        = 9,		--铁匠铺
	institute     = 10,		--研究所
	thePlace      = 11,		--屯所
	tower         = 12,		--哨塔
	--book        = 13,		--书院
	bar           = 14,		--酒馆
	gold          = 16,		--金矿
	wood          = 21,		--伐木场
	food          = 26,		--农田
	stone         = 31,		--石料场
	iron          = 36,		--铁矿场
	spectacular   = 41,		--校场
	hospital      = 42,		--医院
	battleHall    = 43, 	--战争大厅
	mercenaryCamp = 44, 	--雇佣兵营地
	market        = 45, 	--集市
	grindery      = 46, 	--磨坊
	tournament    = 47, 	--武斗
	god      	  = 48, 	--神龛
	stars      	  = 49, 	--观星台
	activity      = 50,     --活动入口
}

m_BuildStatus = { --只能在100以内,100以上是特特殊的 "101额外道具加成时"
	default = 1,
	levelUpIng = 2,
	working = 3,
}

m_BuildType = {
	cityIn = 1,		--城内建筑
	cityOut = 2,	--城外建筑
}

m_BuildNeedHelpType = {
	levelUp = 1,	--升级
	treatment = 2,	--医疗
	research = 3,	--研究科技
}


local baseData = nil


--更新显示
function NotificationUpdateShow()
	require("game.maplayer.homeMapLayer").updateWithAutoMsg()
	if not g_guideManager.getLastShowStep() then
		g_guideManager.execute()
	end
end


function SetData(data)
	baseData = data
end


--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerBuild)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerBuild",}},onRecv)
	return ret
end


--请求数据 异步
function RequestData_Async()
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.PlayerBuild)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerBuild",}},onRecv,true)
end



--更新某一个位置的建筑数据,可能是添加,升级,删除
--删除的时候data为nil或者是无元素的table
function updateSingleBuildData(data, place)
	if baseData then
		if data and data.id then
			baseData[tostring(data.id)] = data
		else
			local p = tonumber(place)
			for k , v in pairs(baseData) do
				if tonumber(v.position)== p then
					baseData[k] = nil
					break
				end
			end
		end
		g_BuffMode.RequestGeneralBuffAsync(place)
		if not g_guideManager.getLastShowStep() then
			g_guideManager.execute()
		end
	end
end








--public

--得到建筑信息,只可使用不可修改
function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end


--根据 配置ID 找到第一个匹配的建筑数据
function FindBuild_ConfigID(configID)
	local data = GetData()
	local s = tostring(configID)
	for key , var in pairs(data) do
		if(var.build_id == s)then
			return var
		end
	end
	return nil
end


--根据 数据ID 找到建筑数据
function FindBuild_ID(id)
	local data = GetData()
	return data[tostring(id)]
end


--根据 位置ID 找到建筑数据
function FindBuild_Place(place)
	local data = GetData()
	local s = tonumber(place)
	for key , var in pairs(data) do
		if(tonumber(var.position) == s)then
			return var
		end
	end
	return nil
end


--根据 配置ID 找到与之原形ID匹配的第一个建筑数据
function FindBuild_origin_ConfigID(configID)
	local data = GetData()
	local configData = g_data.build[tonumber(configID)]
	if(configData)then
		for key , var in pairs(data) do
			local config = g_data.build[tonumber(var.build_id)]
			if(config.origin_build_id == configData.origin_build_id)then
				return var
			end
		end
	end
	return nil
end


--根据建筑配置ID查询与之建筑原型ID匹配并且等级>=的建筑的总数量
function FindBuildCount_lv_more_ConfigID(configID)
	local data = GetData()
	local configData = g_data.build[tonumber(configID)]
	local ret = 0
	if(configData)then
		for key , var in pairs(data) do
			local config = g_data.build[tonumber(var.build_id)]
			if(config.origin_build_id == configData.origin_build_id and config.build_level >= configData.build_level)then
				ret = ret + 1
			end
		end
	end
	return ret
end


--根据建筑配置ID查询与之建筑原型ID匹配并且等级<建筑数据的所有建筑中等级最高的一个,没有返回nil
function FindBuild_lv_less_ConfigID(configID)
	local data = GetData()
	local configData = g_data.build[tonumber(configID)]
	if(configData)then
		local builds = {}
		for key , var in pairs(data) do
			local config = g_data.build[tonumber(var.build_id)]
			if(config.origin_build_id == configData.origin_build_id and config.build_level < configData.build_level)then
				builds[(#builds) + 1] = {v = var , l = config.build_level}
			end
		end
		if #builds > 0 then
			table.sort(builds,function (a, b)
				return a.l > b.l
			end)
			return builds[1].v
		end
	end
	return nil
end


--根据 原形ID 找到第一个匹配的建筑数据
function FindBuild_OriginID(originID)
	local data = GetData()
	local s = tonumber(originID)
	for key , var in pairs(data) do
		if(tonumber(var.origin_build_id) == s)then
			return var
		end
	end
	return nil
end


--根据 原形ID 找到匹配的建筑数据中等级最高的一个
function FindBuild_high_OriginID(originID)
	local data = GetData()
	local builds = {}
	local s = tonumber(originID)
	for key , var in pairs(data) do
		local config = g_data.build[tonumber(var.build_id)]
		if config.origin_build_id == s then
			builds[(#builds) + 1] = {v = var , l = config.build_level}
		end
	end
	if #builds > 0 then
		table.sort(builds,function (a, b)
			return a.l > b.l
		end)
		return builds[1].v
	end
	return nil
end


--根据 原形ID 找到匹配的建筑数据中等级最低的一个
function FindBuild_low_OriginID(originID)
	local data = GetData()
	local builds = {}
	local s = tonumber(originID)
	for key , var in pairs(data) do
		local config = g_data.build[tonumber(var.build_id)]
		if config.origin_build_id == s then
			builds[(#builds) + 1] = {v = var , l = config.build_level}
		end
	end
	if #builds > 0 then
		table.sort(builds,function (a, b)
			return a.l < b.l
		end)
		return builds[1].v
	end
	return nil
end


--根据 原形ID 找到匹配的建筑数据列表
function FindBuild_Table_OriginID(originID)
	local data = GetData()
	local builds = {}
	local s = tonumber(originID)
	for key , var in pairs(data) do
		local config = g_data.build[tonumber(var.build_id)]
		if config.origin_build_id == s then
			builds[(#builds) + 1] = var
		end
	end
	return builds
end


--得到自己主城(官府)的等级
function getMainCityBuilding_lv()
	local data = GetData()
	for key , var in pairs(data) do
		local config = g_data.build[tonumber(var.build_id)]
		if(config.origin_build_id == m_BuildOriginType.mainCity)then
			return config.build_level
		end
	end
	return 0
end


--根据建筑配置ID查询与之建筑原型ID匹配并且为首次建造的配置数据
--注意：这个是用配置ID进行条件匹配查找配置数据,全过程和服务器数据无关
function FindBuildConfig_firstBuilding_ConfigID(configID)
	local configData = g_data.build[tonumber(configID)]
	if(configData)then
		if(configData.build_lv_sign == 1)then
			return configData
		end
		for key , var in pairs(g_data.build) do
			if(var.origin_build_id == configData.origin_build_id and var.build_lv_sign == 1)then
				return var
			end
		end
	end
	return nil
end


--根据建筑配置ID查询与之建筑原型ID匹配并且等级为1的配置数据
--注意：这个是用配置ID进行条件匹配查找配置数据,全过程和服务器数据无关
function FindBuildConfig_lv_1_ConfigID(configID)
	local configData = g_data.build[tonumber(configID)]
	if(configData)then
		if(configData.build_level == 1)then
			return configData
		end
		for key , var in pairs(g_data.build) do
			if(var.origin_build_id == configData.origin_build_id and var.build_level == 1)then
				return var
			end
		end
	end
	return nil
end


--根据建筑配置ID查询与之建筑原型ID匹配并且等级+1的配置数据
--注意：这个是用配置ID进行条件匹配查找配置数据,全过程和服务器数据无关
function FindBuildConfig_lv_Next_ConfigID(configID)
	local configData = g_data.build[tonumber(configID)]
	if(configData)then
		for key , var in pairs(g_data.build) do
			if(var.origin_build_id == configData.origin_build_id and var.build_level == configData.build_level + 1)then
				return var
			end
		end
	end
	return nil
end


--根据原形ID查询与之建筑原型ID匹配并且为首次建造的配置数据
--注意：这个是用原形ID进行条件匹配查找配置数据,全过程和服务器数据无关
function FindBuildConfig_firstBuilding_OriginID(originID)
	local s = tonumber(originID)
	for k , v in pairs(g_data.build) do
		if v.origin_build_id == s and v.build_lv_sign == 1 then
			return v
		end
	end
	return nil
end


--查找在免费队列的建筑
function FindBuild_InFree()
	local data = GetData()
	for k,v in pairs(data) do
		if (tonumber(v.status) == 2) and (tonumber(v.queue_index) == 1)then
			return v
		end
	end
	return nil
end


--查找在收费队列的建筑
function FindBuild_InCharge()
	local data = GetData()
	for k,v in pairs(data) do
		if (tonumber(v.status) == 2) and (tonumber(v.queue_index) == 2)then
			return v
		end
	end
	return nil
end


--根据 数据ID 查询对应建筑是否工作处于完成状态
function FindBuildIsWorkFinish_ID(id)
	local data = GetData()
	local v = data[tostring(id)]
	if v and v.status == m_BuildStatus.working and v.work_finish_time < g_clock.getCurServerTime() then
		return true
	else
		return false
	end
end


--根据 数据ID 查询这个正在升级的建筑是否可以免费秒掉了
function CheckFreeBuildEnd_ID(id)
	local data = GetData()
	local v = data[tostring(id)]
	--VIP完成后这里改为读VIP
	if v and v.status == m_BuildStatus.levelUpIng and (v.build_finish_time - g_clock.getCurServerTime() < g_PlayerMode.getReduceBuildTime()) then
		return true
	else
		return false
	end
end


--查询医馆是否可以请求别人帮助
function CheckHospitalNeedHelp()
	local d = FindBuild_OriginID(m_BuildOriginType.hospital)
	if d then
		return ( (d.need_help == m_BuildNeedHelpType.treatment and g_AllianceMode.getSelfHaveAlliance()) and true or false )
	end
	return false
end


--查询研究所是否可以请求别人帮助
function CheckInstituteNeedHelp()
	local d = FindBuild_OriginID(m_BuildOriginType.institute)
	if d then
		return ( (d.need_help == m_BuildNeedHelpType.research and g_AllianceMode.getSelfHaveAlliance()) and true or false )
	end
	return false
end


return playerBuildMode