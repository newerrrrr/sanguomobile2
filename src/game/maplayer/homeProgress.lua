local homeProgress = {}
setmetatable(homeProgress,{__index = _G})
setfenv(1,homeProgress)

--[[
步兵营地	兵名 + NUM
骑兵营地
弓兵营地
车兵营地
医疗士兵	治疗伤兵 + NUM
建造
研究所研究科技	科技名字
陷阱制造	陷阱名字 + NUM
--]]

local c_Icon_Image = {
	[g_PlayerBuildMode.m_BuildOriginType.infantry] = "homeImage_type_infantry.png",
	[g_PlayerBuildMode.m_BuildOriginType.archers] = "homeImage_type_archer.png",
	[g_PlayerBuildMode.m_BuildOriginType.cavalry] = "homeImage_type_cavalry.png",
	[g_PlayerBuildMode.m_BuildOriginType.car] = "homeImage_type_thrower.png",
	[g_PlayerBuildMode.m_BuildOriginType.workshop] = "homeImage_type_trap.png",
	[g_PlayerBuildMode.m_BuildOriginType.hospital] = "homeImage_type_cure.png",
	[g_PlayerBuildMode.m_BuildOriginType.institute] = "homeImage_type_science.png",
	[g_PlayerBuildMode.m_BuildOriginType.grindery] = "homeImage_type_mill.png",		--待修改
}

local c_Icon_LevelUp = "homeImage_type_build.png"


function create( var1 , var2 , var3 , var4 , var5 )
	local widget = cc.CSLoader:createNode("upgrade2.csb")
	widget:setAnchorPoint(cc.p(0.5, 1.0))
	
	local timeText = widget:getChildByName("Text_2")
	local loadingBar = widget:getChildByName("LoadingBar_1")
	local iconImage = widget:getChildByName("Image_tp")
	local descBack = widget:getChildByName("Image_3")
	local descLabel = widget:getChildByName("Text_3_0")
	
	local cacheData = {
		basic_position_node = nil,
		configData = nil,
		buildingData = nil,
		serverData = nil,
		grinderyInfo = nil,
		
		imageResName = nil,
		
		descText = nil,
	}
	
	
	local function update_progress_levelUp(serverData)
		local timeCur = g_clock.getCurServerTime()
		loadingBar:setPercent(math.clampf((timeCur - serverData.build_begin_time) / ((serverData.build_finish_time - serverData.build_begin_time) + 0.0001) * 100, 0, 100))
		local timeSub = serverData.build_finish_time - timeCur
		timeText:setString( timeSub > 0 and g_gameTools.convertSecondToString(timeSub) or g_gameTools.convertSecondToString(0) )
	end
	
	local function update_progress_working(serverData)
		local timeCur = g_clock.getCurServerTime()
		loadingBar:setPercent(math.clampf((timeCur - serverData.work_begin_time) / ((serverData.work_finish_time - serverData.work_begin_time) + 0.0001) * 100, 0, 100))
		local timeSub = serverData.work_finish_time - timeCur
		timeText:setString( timeSub > 0 and g_gameTools.convertSecondToString(timeSub) or g_gameTools.convertSecondToString(0) )
	end
	
	local function update_progress_grindery(grinderyInfo)
		local timeCur = g_clock.getCurServerTime()
		loadingBar:setPercent(math.clampf((timeCur - grinderyInfo.begin_time) / ((grinderyInfo.finish_time - grinderyInfo.begin_time) + 0.0001) * 100, 0, 100))
		local timeSub = grinderyInfo.finish_time - timeCur
		timeText:setString( timeSub > 0 and g_gameTools.convertSecondToString(timeSub) or g_gameTools.convertSecondToString(0) )
	end
	
	function widget:lua_update_serverData( basic_position_node , configData , buildingData , serverData , grinderyInfo)
		
		if cacheData.buildingData == nil or cacheData.buildingData.id ~= buildingData.id then
			--位置部分
			local position = require("game.maplayer.homeMapLayer").convertToProgressNodeSpace(basic_position_node:convertToWorldSpaceAR(cc.p(0.0, 0.0)))
			widget:setPosition(cc.p(position.x, position.y - (configData.build_type == g_PlayerBuildMode.m_BuildType.cityIn and 70.0 or 50.0)))
		end
		
		if serverData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.grindery then
			--磨坊
			if cacheData.grinderyInfo == nil then
				descBack:setVisible(true)
				descLabel:setVisible(true)
				update_progress_grindery(grinderyInfo)
			end
			local desc = "unknow"
			local itemConfig = g_data.item[grinderyInfo.item_id]
			if itemConfig then
				desc = g_tr(itemConfig.item_name)
			end
			if cacheData.descText == nil or cacheData.descText ~= desc then
				descLabel:setString(desc)
				cacheData.descText = desc --放入缓存
			end
			local imageResName = c_Icon_Image[configData.origin_build_id]
			if cacheData.imageResName == nil or cacheData.imageResName ~= imageResName then
				iconImage:loadTexture(imageResName, ccui.TextureResType.plistType)
				cacheData.imageResName = imageResName --放入缓存
			end
		else
			if serverData.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
				--升级部分
				if cacheData.serverData == nil or cacheData.serverData.status ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng then
					descBack:setVisible(false)
					descLabel:setVisible(false)
					update_progress_levelUp(serverData)
				end
				if cacheData.imageResName == nil or cacheData.imageResName ~= c_Icon_LevelUp then
					iconImage:loadTexture(c_Icon_LevelUp, ccui.TextureResType.plistType)
					cacheData.imageResName = c_Icon_LevelUp --放入缓存
				end
			elseif serverData.status == g_PlayerBuildMode.m_BuildStatus.working then
				--工作部分
				if cacheData.serverData == nil or cacheData.serverData.status ~= g_PlayerBuildMode.m_BuildStatus.working then
					descBack:setVisible(true)
					descLabel:setVisible(true)
					update_progress_working(serverData)
				end
				do --文字
					local desc = "unknow"
					if configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.infantry then
						local info = require("game.uilayer.militaryCamp.SoldierTraningLayer").getInfantryInfo()
						desc = info.name..tostring(info.num)
					elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.archers then
						local info = require("game.uilayer.militaryCamp.SoldierTraningLayer").getArcherInfo()
						desc = info.name..tostring(info.num)
					elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.cavalry then
						local info = require("game.uilayer.militaryCamp.SoldierTraningLayer").getCavalryInfo()
						desc = info.name..tostring(info.num)
					elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.car then
						local info = require("game.uilayer.militaryCamp.SoldierTraningLayer").getCatapultsInfo()
						desc = info.name..tostring(info.num)
					elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.workshop then
						local info = require("game.uilayer.militaryCamp.SoldierTraningLayer").getTrapInfo()
						desc = info.name..tostring(info.num)
					elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.hospital then
						local count = 0
						if serverData.work_content and serverData.work_content.soldier then
							for k , v in pairs(serverData.work_content.soldier) do
								count = count + v.num 
							end
						end
						desc = g_tr("hp_hospital_working")..tostring(count)
					elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.institute then
						desc = require("game.uilayer.science.Science"):instance():getLearningScience()
					end
					if cacheData.descText == nil or cacheData.descText ~= desc then
						descLabel:setString(desc)
						cacheData.descText = desc --放入缓存
					end
				end
				local imageResName = c_Icon_Image[configData.origin_build_id]
				if cacheData.imageResName == nil or cacheData.imageResName ~= imageResName then
					iconImage:loadTexture(imageResName, ccui.TextureResType.plistType)
					cacheData.imageResName = imageResName --放入缓存
				end
			end
		end
		
		--放入缓存
		cacheData.basic_position_node = basic_position_node
		cacheData.configData = configData
		cacheData.buildingData = buildingData
		cacheData.serverData = serverData
		cacheData.grinderyInfo = grinderyInfo
	end
	widget:lua_update_serverData(var1 , var2 , var3 , var4 , var5)
	
	
	local function update_progress(dt)
		if cacheData.configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.grindery then
			--磨坊
			update_progress_grindery(cacheData.grinderyInfo)
		else
			if cacheData.serverData.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
				--升级
				update_progress_levelUp(cacheData.serverData)
			elseif cacheData.serverData.status == g_PlayerBuildMode.m_BuildStatus.working then
				--工作
				update_progress_working(cacheData.serverData)
			end
		end
	end
	
	
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_progress, 1.0, false)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
        end
    end
    widget:registerScriptHandler(rootLayerEventHandler)
	
	
	return widget
end



return homeProgress