local homeMapHelper = {}
setmetatable(homeMapHelper,{__index = _G})
setfenv(1,homeMapHelper)

local HomeAirMD = require "game.maplayer.homeAir"

--特效
local c_tag_resources_speed_up_t = 10011011
local c_tag_resources_speed_up_b = 10011012
local c_tag_levelUping = 10011013
local c_tag_workFinish = 10011014
local c_tag_hospital_work_and_have = 10011015
local c_tag_sleep = 10011016
local c_tag_bar_can_get = 10011017
local c_tag_grindery_build = 10011018

--添加气泡1
--气泡
local c_tag_air_harvest = 10019916			--收获气泡
local c_tag_air_levelUp_help = 10019917		--升级请求帮助气泡
local c_tag_air_levelUp_free = 10019918		--升级秒掉气泡
local c_tag_air_helpAll = 10019919			--帮助所有人气泡
local c_tag_air_fire = 10019920				--城墙着火气泡
local c_tag_air_repair = 10019921			--城墙需要维修气泡
local c_tag_air_help_hospital = 10019922	--请求帮助治疗气泡
local c_tag_air_help_institute = 10019923	--请求帮助研究气泡
local c_tag_air_recruit_bar = 10019924		--可以招募气泡
local c_tag_air_canWear_mainCity = 10019925	--可以穿戴气泡
local c_tag_air_sleep_spectacular = 10019926--校场空闲气泡
local c_tag_air_canUse_god = 10019927		--神龛能用
local c_tag_air_free_stars = 10019928		--观星台免费
local c_tag_air_wanqiangdouzhi = 10019929	--顽强斗志
local c_tag_air_wudou = 10019930            --武斗气泡
local c_tag_air_pub_new = 10019931          --酒馆新气泡

--添加气泡2
m_AirType = {
	harvest = tostring(c_tag_air_harvest),
	levelUp_help = tostring(c_tag_air_levelUp_help),
	levelUp_free = tostring(c_tag_air_levelUp_free),
	helpAll = tostring(c_tag_air_helpAll),
	fire = tostring(c_tag_air_fire),
	repair = tostring(c_tag_air_repair),
	hospital = tostring(c_tag_air_help_hospital),
	institute = tostring(c_tag_air_help_institute),
	bar = tostring(c_tag_air_recruit_bar),
	mainCity = tostring(c_tag_air_canWear_mainCity),
	spectacular = tostring(c_tag_air_sleep_spectacular),
	canUse_god = tostring(c_tag_air_canUse_god),
	free_stars = tostring(c_tag_air_free_stars),
	wanqiangdouzhi = tostring(c_tag_air_wanqiangdouzhi),
	wudou = tostring(c_tag_air_wudou),
	pubNew = tostring(c_tag_air_pub_new),
}


local c_tag_animation_wait_action = 10021501


--加入或显示特效
local function _addOrEnablePlayAnimation(tag , parent , exportJsonFileName , projectName , animationName , scale, firstWaitTime, offset)
	local originArmature  = parent:getChildByTag(tag)
	if originArmature then
		originArmature:stopActionByTag(c_tag_animation_wait_action)
		originArmature:setVisible(true)
	else
		local armature , animation = g_gameTools.LoadCocosAni(exportJsonFileName, projectName)
		armature:setTag(tag)
		parent:addChild(armature,0,tag)
		armature:setScale(scale)
		if offset then
			armature:setPosition(offset)
		end
		if firstWaitTime then
			armature:setVisible(false)
			local function onPlay()
				armature:setVisible(true)
				animation:play(animationName)
			end
			local action = cc.Sequence:create(cc.DelayTime:create(firstWaitTime), cc.CallFunc:create(onPlay))
			action:setTag(c_tag_animation_wait_action)
			armature:runAction(action)
		else
			animation:play(animationName)
		end
	end
end

--加入或显示特效 磨坊专用
local function _addOrEnablePlayAnimation_Grindery(tag , parent , exportJsonFileName , projectName , animationName , scale, firstWaitTime, grinderyInfo)
	local originArmature  = parent:getChildByTag(tag)
	if originArmature then
		originArmature:stopActionByTag(c_tag_animation_wait_action)
		originArmature:setVisible(true)
		if originArmature.lua_show_item_id ~= grinderyInfo.item_id then
			originArmature.lua_show_item_id = grinderyInfo.item_id
			local itemConfig = g_data.item[grinderyInfo.item_id]
			if itemConfig then
				local iconBone = originArmature:getBone("Layer2")
				if iconBone then
					local node = cc.Node:create()
					node:setAnchorPoint(cc.p(0.5, 0.5))
					node:addChild(cc.Sprite:create(g_data.sprite[itemConfig.res_icon].path))
					iconBone:addDisplay(node, 0)
				end
			end
		end
	else
		local armature , animation = g_gameTools.LoadCocosAni(exportJsonFileName, projectName)
		armature.lua_show_item_id = grinderyInfo.item_id
		local itemConfig = g_data.item[grinderyInfo.item_id]
		if itemConfig then
			local iconBone = armature:getBone("Layer2")
			if iconBone then
				local node = cc.Node:create()
				node:setAnchorPoint(cc.p(0.5, 0.5))
				node:addChild(cc.Sprite:create(g_data.sprite[itemConfig.res_icon].path))
				iconBone:addDisplay(node, 0)
			end
		end
		armature:setTag(tag)
		parent:addChild(armature,0,tag)
		armature:setScale(scale)
		if firstWaitTime then
			armature:setVisible(false)
			local function onPlay()
				armature:setVisible(true)
				animation:play(animationName)
			end
			local action = cc.Sequence:create(cc.DelayTime:create(firstWaitTime), cc.CallFunc:create(onPlay))
			action:setTag(c_tag_animation_wait_action)
			armature:runAction(action)
		else
			animation:play(animationName)
		end
	end
end

--删除特效
local function _removeAnimation(tag , parent)
	parent:removeChildByTag(tag)
end

--加入或显示气泡
local function _addOrEnableAir(tag , parent , createFunc)
	local originAir  = parent:getChildByTag(tag)
	if originAir then
		originAir:setVisible(true)
	else
		local air = createFunc()
		parent:addChild(air,0,tag)
	end
end

--删除气泡
local function _removeAir(tag , parent)
	parent:removeChildByTag(tag)
end

--加入或显示进度
local function _addOrEnableProgress(basic_position_node , configData , buildingData , serverData , grinderyInfo)
	require("game.maplayer.homeMapLayer").addOrEnableProgress(basic_position_node , configData , buildingData , serverData , grinderyInfo)
end

--删除进度
local function _removeProgress(buildingData)
	require("game.maplayer.homeMapLayer").removeProgress_BuildingData(buildingData)
end

--计算能否收获
local function canHarvest(serverData, currentTime)
	local l = g_PlayerMode.GetData().level
	local t = 180
	if l > 14 then
		t = 600
	elseif l > 6 then
		t = 300
	end
	return ( (currentTime - serverData.resource_start_time) > t and (currentTime - serverData.resource_start_time) * serverData.resource_in / 3600 > 1 )
end

--根据本地数据更新显示状态(比如气泡是否该显示了,特效是否该显示了)
function updateShowForLocalData(configData , buildingData , serverData)
	
	local homeMap = require("game.maplayer.homeMapLayer")
	
	local strPlace = tostring(buildingData.id)
	
	local buildButton = homeMap.getBuildButtonWithPlace(strPlace)
	local MapNormalizationPanle = homeMap.getMapNormalizationPanel()
	if buildButton == nil or MapNormalizationPanle == nil then
		return
	end
	
	local curTime = g_clock.getCurServerTime()
	
	local effect_Top = MapNormalizationPanle:getChildByName(strPlace.."_Effect")
	local effect_Bottom = buildButton:getChildByName("Effect_1")
	local effect_Air = MapNormalizationPanle:getChildByName(strPlace.."_top_efc")
	
	local buildStatus = tonumber(serverData.status)
	
	local scaleVar = tonumber(configData.build_zoom)
	
	do--通用特效
		if buildStatus == g_PlayerBuildMode.m_BuildStatus.default then
			--正常
			
			--删除升级特效
			_removeAnimation(c_tag_levelUping, effect_Top)
			
			--删除请求帮助气泡
			_removeAir(c_tag_air_levelUp_help, effect_Air)
			
			--删除秒掉升级气泡
			_removeAir(c_tag_air_levelUp_free, effect_Air)
			
			--删除进度
			_removeProgress(buildingData)
			
		elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
			--升级中
			
			--加入升级特效
			
			if configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.rampart then
				_addOrEnablePlayAnimation(c_tag_levelUping, effect_Top, "anime/anime_build2/anime_build2.ExportJson", "anime_build2", "jianzhushengji", scaleVar, nil, cc.p(buildingData.lvup_build_effect[1], buildingData.lvup_build_effect[2]))
			elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.mainCity then
				_addOrEnablePlayAnimation(c_tag_levelUping, effect_Top, "anime/anime_build/anime_build.ExportJson", "anime_build", "jianzhushengji", scaleVar, nil, cc.p(buildingData.lvup_build_effect[1], buildingData.lvup_build_effect[2]))
			else
				_addOrEnablePlayAnimation(c_tag_levelUping, effect_Top, "anime/anime_build/anime_build.ExportJson", "anime_build", "jianzhushengji2", scaleVar, nil, cc.p(buildingData.lvup_build_effect[1], buildingData.lvup_build_effect[2]))
			end
			
			--秒掉气泡
			if g_PlayerBuildMode.CheckFreeBuildEnd_ID(serverData.id) then
				_addOrEnableAir(c_tag_air_levelUp_free, effect_Air, HomeAirMD.create_levelUp_Free)
				
				--删除请求帮助气泡
				_removeAir(c_tag_air_levelUp_help, effect_Air)
			else
				_removeAir(c_tag_air_levelUp_free, effect_Air)
				
				--不能秒掉的情况下才出现 请求帮助气泡
				if serverData.need_help == g_PlayerBuildMode.m_BuildNeedHelpType.levelUp and g_AllianceMode.getSelfHaveAlliance() then
					_addOrEnableAir(c_tag_air_levelUp_help, effect_Air, HomeAirMD.create_levelUp_Help)
				else
					_removeAir(c_tag_air_levelUp_help, effect_Air)
				end
				
			end
			
			--加入进度
			_addOrEnableProgress(effect_Top, configData, buildingData, serverData)
			
		elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.working then
			--工作中
			
			--删除升级特效
			_removeAnimation(c_tag_levelUping, effect_Top)
			
			--删除请求帮助气泡
			_removeAir(c_tag_air_levelUp_help, effect_Air)
			
			--删除秒掉升级气泡
			_removeAir(c_tag_air_levelUp_free, effect_Air)
			
		end
	end
	
	
	if configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.gold then
		
		if tonumber(serverData.ex_addition_end_time) > curTime then
			--资源建筑提速时
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_t, effect_Top, "anime/ZiYuanJianZhuJiaSuQiPaoNewParticle/ZiYuanJianZhuJiaSuQiPaoNewParticle.ExportJson", "ZiYuanJianZhuJiaSuQiPaoNewParticle", "Animation1" ,scaleVar)
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_b, effect_Bottom, "anime/ZiYuanJianZhuJiaSuDi/ZiYuanJianZhuJiaSuDi.ExportJson", "ZiYuanJianZhuJiaSuDi", "Animation1" ,scaleVar)
		else
			--资源建筑没有提速时
			_removeAnimation(c_tag_resources_speed_up_t, effect_Top)
			_removeAnimation(c_tag_resources_speed_up_b, effect_Bottom)
		end
		
		if buildStatus == g_PlayerBuildMode.m_BuildStatus.default 
			and canHarvest(serverData, curTime)
				then
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Gold)
		else
			_removeAir(c_tag_air_harvest, effect_Air)
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.wood then
		
		if tonumber(serverData.ex_addition_end_time) > curTime then
			--资源建筑提速时
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_t, effect_Top, "anime/ZiYuanJianZhuJiaSuQiPaoNewParticle/ZiYuanJianZhuJiaSuQiPaoNewParticle.ExportJson", "ZiYuanJianZhuJiaSuQiPaoNewParticle", "Animation1" ,scaleVar)
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_b, effect_Bottom, "anime/ZiYuanJianZhuJiaSuDi/ZiYuanJianZhuJiaSuDi.ExportJson", "ZiYuanJianZhuJiaSuDi", "Animation1" ,scaleVar)
		else
			--资源建筑没有提速时
			_removeAnimation(c_tag_resources_speed_up_t, effect_Top)
			_removeAnimation(c_tag_resources_speed_up_b, effect_Bottom)
		end
		
		if buildStatus == g_PlayerBuildMode.m_BuildStatus.default 
			and canHarvest(serverData, curTime)
				then
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Wood)
		else
			_removeAir(c_tag_air_harvest, effect_Air)
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.food then
		
		if tonumber(serverData.ex_addition_end_time) > curTime then
			--资源建筑提速时
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_t, effect_Top, "anime/ZiYuanJianZhuJiaSuQiPaoNewParticle/ZiYuanJianZhuJiaSuQiPaoNewParticle.ExportJson", "ZiYuanJianZhuJiaSuQiPaoNewParticle", "Animation1" ,scaleVar)
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_b, effect_Bottom, "anime/ZiYuanJianZhuJiaSuDi/ZiYuanJianZhuJiaSuDi.ExportJson", "ZiYuanJianZhuJiaSuDi", "Animation1" ,scaleVar)
		else
			--资源建筑没有提速时
			_removeAnimation(c_tag_resources_speed_up_t, effect_Top)
			_removeAnimation(c_tag_resources_speed_up_b, effect_Bottom)
		end
		
		if buildStatus == g_PlayerBuildMode.m_BuildStatus.default 
			and canHarvest(serverData, curTime)
				then
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Food)
		else
			_removeAir(c_tag_air_harvest, effect_Air)
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.stone then
		
		if tonumber(serverData.ex_addition_end_time) > curTime then
			--资源建筑提速时
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_t, effect_Top, "anime/ZiYuanJianZhuJiaSuQiPaoNewParticle/ZiYuanJianZhuJiaSuQiPaoNewParticle.ExportJson", "ZiYuanJianZhuJiaSuQiPaoNewParticle", "Animation1" ,scaleVar)
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_b, effect_Bottom, "anime/ZiYuanJianZhuJiaSuDi/ZiYuanJianZhuJiaSuDi.ExportJson", "ZiYuanJianZhuJiaSuDi", "Animation1" ,scaleVar)
		else
			--资源建筑没有提速时
			_removeAnimation(c_tag_resources_speed_up_t, effect_Top)
			_removeAnimation(c_tag_resources_speed_up_b, effect_Bottom)
		end
		
		if buildStatus == g_PlayerBuildMode.m_BuildStatus.default 
			and canHarvest(serverData, curTime)
				then
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Stone)
		else
			_removeAir(c_tag_air_harvest, effect_Air)
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.iron then
		
		if tonumber(serverData.ex_addition_end_time) > curTime then
			--资源建筑提速时
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_t, effect_Top, "anime/ZiYuanJianZhuJiaSuQiPaoNewParticle/ZiYuanJianZhuJiaSuQiPaoNewParticle.ExportJson", "ZiYuanJianZhuJiaSuQiPaoNewParticle", "Animation1" ,scaleVar)
			_addOrEnablePlayAnimation(c_tag_resources_speed_up_b, effect_Bottom, "anime/ZiYuanJianZhuJiaSuDi/ZiYuanJianZhuJiaSuDi.ExportJson", "ZiYuanJianZhuJiaSuDi", "Animation1" ,scaleVar)
		else
			--资源建筑没有提速时
			_removeAnimation(c_tag_resources_speed_up_t, effect_Top)
			_removeAnimation(c_tag_resources_speed_up_b, effect_Bottom)
		end
		
		if buildStatus == g_PlayerBuildMode.m_BuildStatus.default 
			and canHarvest(serverData, curTime)
				then
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Iron)
		else
			_removeAir(c_tag_air_harvest, effect_Air)
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.workshop then
		
		if g_PlayerBuildMode.FindBuildIsWorkFinish_ID(serverData.id) then
			--可回收
			_addOrEnablePlayAnimation(c_tag_workFinish, effect_Top, "anime/JianZhuHuiShou/JianZhuHuiShou.ExportJson", "JianZhuHuiShou", "Animation1" ,scaleVar)
			
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Workshop)
			
			_removeProgress(buildingData)
			
			_removeAnimation(c_tag_sleep, effect_Top)
		else
			_removeAnimation(c_tag_workFinish, effect_Top)
			
			_removeAir(c_tag_air_harvest, effect_Air)
			
			if buildStatus == g_PlayerBuildMode.m_BuildStatus.working then
				--工作中
				if tonumber(serverData.work_finish_time) > curTime then
					--加入进度
					_addOrEnableProgress(effect_Top, configData, buildingData, serverData)
				end
				_removeAnimation(c_tag_sleep, effect_Top)
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.default then
				--正常状态
				_addOrEnablePlayAnimation(c_tag_sleep, effect_Top, "anime/Effect_JianZhuKongXian/Effect_JianZhuKongXian.ExportJson", "Effect_JianZhuKongXian", "Animation1" , scaleVar, math.random())
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
				--升级状态
				_removeAnimation(c_tag_sleep, effect_Top)
			end
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.infantry then
		
		if g_PlayerBuildMode.FindBuildIsWorkFinish_ID(serverData.id) then
			--可回收
			_addOrEnablePlayAnimation(c_tag_workFinish, effect_Top, "anime/JianZhuHuiShou/JianZhuHuiShou.ExportJson", "JianZhuHuiShou", "Animation1" ,scaleVar)
			
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Infantry)
			
			_removeProgress(buildingData)
			
			_removeAnimation(c_tag_sleep, effect_Top)
		else
			_removeAnimation(c_tag_workFinish, effect_Top)
			
			_removeAir(c_tag_air_harvest, effect_Air)
			
			if buildStatus == g_PlayerBuildMode.m_BuildStatus.working then
				--工作中
				if tonumber(serverData.work_finish_time) > curTime then
					--加入进度
					_addOrEnableProgress(effect_Top, configData, buildingData, serverData)
				end
				_removeAnimation(c_tag_sleep, effect_Top)
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.default then
				--正常状态
				_addOrEnablePlayAnimation(c_tag_sleep, effect_Top, "anime/Effect_JianZhuKongXian/Effect_JianZhuKongXian.ExportJson", "Effect_JianZhuKongXian", "Animation1" , scaleVar, math.random())
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
				--升级状态
				_removeAnimation(c_tag_sleep, effect_Top)
			end
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.archers then
		
		if g_PlayerBuildMode.FindBuildIsWorkFinish_ID(serverData.id) then
			--可回收
			_addOrEnablePlayAnimation(c_tag_workFinish, effect_Top, "anime/JianZhuHuiShou/JianZhuHuiShou.ExportJson", "JianZhuHuiShou", "Animation1" ,scaleVar)
			
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Archers)
		
			_removeProgress(buildingData)
			
			_removeAnimation(c_tag_sleep, effect_Top)
		else
			_removeAnimation(c_tag_workFinish, effect_Top)
			
			_removeAir(c_tag_air_harvest, effect_Air)
			
			if buildStatus == g_PlayerBuildMode.m_BuildStatus.working then
				--工作中
				if tonumber(serverData.work_finish_time) > curTime then
					--加入进度
					_addOrEnableProgress(effect_Top, configData, buildingData, serverData)
				end
				_removeAnimation(c_tag_sleep, effect_Top)
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.default then
				--正常状态
				_addOrEnablePlayAnimation(c_tag_sleep, effect_Top, "anime/Effect_JianZhuKongXian/Effect_JianZhuKongXian.ExportJson", "Effect_JianZhuKongXian", "Animation1" , scaleVar, math.random())
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
				--升级状态
				_removeAnimation(c_tag_sleep, effect_Top)
			end
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.cavalry then
		
		if g_PlayerBuildMode.FindBuildIsWorkFinish_ID(serverData.id) then
			--可回收
			_addOrEnablePlayAnimation(c_tag_workFinish, effect_Top, "anime/JianZhuHuiShou/JianZhuHuiShou.ExportJson", "JianZhuHuiShou", "Animation1" ,scaleVar)
		
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Cavalry)
			
			_removeProgress(buildingData)
			
			_removeAnimation(c_tag_sleep, effect_Top)
		else
			_removeAnimation(c_tag_workFinish, effect_Top)
			
			_removeAir(c_tag_air_harvest, effect_Air)
			
			if buildStatus == g_PlayerBuildMode.m_BuildStatus.working then
				--工作中
				if tonumber(serverData.work_finish_time) > curTime then
					--加入进度
					_addOrEnableProgress(effect_Top, configData, buildingData, serverData)
				end
				_removeAnimation(c_tag_sleep, effect_Top)
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.default then
				--正常状态
				_addOrEnablePlayAnimation(c_tag_sleep, effect_Top, "anime/Effect_JianZhuKongXian/Effect_JianZhuKongXian.ExportJson", "Effect_JianZhuKongXian", "Animation1" , scaleVar, math.random())
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
				--升级状态
				_removeAnimation(c_tag_sleep, effect_Top)
			end
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.car then
		
		if g_PlayerBuildMode.FindBuildIsWorkFinish_ID(serverData.id) then
			--可回收
			_addOrEnablePlayAnimation(c_tag_workFinish, effect_Top, "anime/JianZhuHuiShou/JianZhuHuiShou.ExportJson", "JianZhuHuiShou", "Animation1" ,scaleVar)
		
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Car)
			
			_removeProgress(buildingData)
			
			_removeAnimation(c_tag_sleep, effect_Top)
		else
			_removeAnimation(c_tag_workFinish, effect_Top)
			
			_removeAir(c_tag_air_harvest, effect_Air)
			
			if buildStatus == g_PlayerBuildMode.m_BuildStatus.working then
				--工作中
				if tonumber(serverData.work_finish_time) > curTime then
					--加入进度
					_addOrEnableProgress(effect_Top, configData, buildingData, serverData)
				end
				_removeAnimation(c_tag_sleep, effect_Top)
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.default then
				--正常状态
				_addOrEnablePlayAnimation(c_tag_sleep, effect_Top, "anime/Effect_JianZhuKongXian/Effect_JianZhuKongXian.ExportJson", "Effect_JianZhuKongXian", "Animation1" , scaleVar, math.random())
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
				--升级状态
				_removeAnimation(c_tag_sleep, effect_Top)
			end
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.hospital then
		
		--医馆
		if g_PlayerBuildMode.FindBuildIsWorkFinish_ID(serverData.id) then
			--可回收
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Hospital)
			
			_removeProgress(buildingData)
		else
			_removeAir(c_tag_air_harvest, effect_Air)
			
			if buildStatus == g_PlayerBuildMode.m_BuildStatus.working then
				--工作中
				if tonumber(serverData.work_finish_time) > curTime then
					--加入进度
					_addOrEnableProgress(effect_Top, configData, buildingData, serverData)
				end
			end
		end
		
		--请求帮助治疗的气泡
		if buildStatus ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng then
			if serverData.need_help == g_PlayerBuildMode.m_BuildNeedHelpType.treatment and g_AllianceMode.getSelfHaveAlliance() then
				_addOrEnableAir(c_tag_air_help_hospital, effect_Air, HomeAirMD.create_help_Hospital)
			else
				_removeAir(c_tag_air_help_hospital, effect_Air)
			end
		else
			_removeAir(c_tag_air_help_hospital, effect_Air)
		end
		
		--特效
		if buildStatus == g_PlayerBuildMode.m_BuildStatus.working or (buildStatus ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng and table.total(g_PlayerSoldierInjuredMode.getData()) > 0) then
			--有兵在里面,或者在医疗
			_addOrEnablePlayAnimation(c_tag_hospital_work_and_have, effect_Top, "anime/YiGuanXunHuanParticle/YiGuanXunHuanParticle.ExportJson", "YiGuanXunHuanParticle", "Animation1" ,scaleVar)
		else
			_removeAnimation(c_tag_hospital_work_and_have, effect_Top)
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.rampart then
		
		local playerData = g_PlayerMode.GetData()
		
		if curTime < playerData.fire_end_time then
			--燃烧
			
			if effect_Air:getChildByTag(c_tag_air_levelUp_help) == nil
				and effect_Air:getChildByTag(c_tag_air_levelUp_free) == nil 
				then
				--没有升级相关的气泡才出现着火气泡
				_addOrEnableAir(c_tag_air_fire, effect_Air, HomeAirMD.create_fire_Rampart)
			else
				_removeAir(c_tag_air_fire, effect_Air)
			end
			
		else
			_removeAir(c_tag_air_fire, effect_Air)
			
			--没有燃烧才出现 修理气泡
			if g_wallData.showPop() then
				
				if effect_Air:getChildByTag(c_tag_air_levelUp_help) == nil
					and effect_Air:getChildByTag(c_tag_air_levelUp_free) == nil 
					then
					--没有升级相关的气泡才出现修理气泡
					_addOrEnableAir(c_tag_air_repair, effect_Air, HomeAirMD.create_repair_Rampart)
				else
					_removeAir(c_tag_air_repair, effect_Air)
				end
				
			else
				_removeAir(c_tag_air_repair, effect_Air)
			end
			
		end
		
		if g_BuffMode.IsBuffWorkingByBuffId(474) then
			_addOrEnableAir(c_tag_air_wanqiangdouzhi, effect_Air, HomeAirMD.create_wanqiangdouzhi_Rampart)
		else
			_removeAir(c_tag_air_wanqiangdouzhi, effect_Air)
		end
	
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.thePlace then
		
		--帮助所有人
		if buildStatus ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng and g_PlayerHelpMode.canHelp() then
			_addOrEnableAir(c_tag_air_helpAll, effect_Air, HomeAirMD.create_helpAll_ThePlace)
		else
			_removeAir(c_tag_air_helpAll, effect_Air)
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.institute then
	
		if buildStatus == g_PlayerBuildMode.m_BuildStatus.working then
			--工作中
			if tonumber(serverData.work_finish_time) > curTime then
				--加入进度
				_addOrEnableProgress(effect_Top, configData, buildingData, serverData)
			end
			_removeAnimation(c_tag_sleep, effect_Top)
		else
			if buildStatus ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng then
				_removeProgress(buildingData)
			end
			
			if buildStatus == g_PlayerBuildMode.m_BuildStatus.default then
				--正常状态
				_addOrEnablePlayAnimation(c_tag_sleep, effect_Top, "anime/Effect_JianZhuKongXian/Effect_JianZhuKongXian.ExportJson", "Effect_JianZhuKongXian", "Animation1" , scaleVar, math.random())
			elseif buildStatus == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
				--升级状态
				_removeAnimation(c_tag_sleep, effect_Top)
			end
			
		end
		
		--请求帮助研究的气泡
		if buildStatus ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng then
			if serverData.need_help == g_PlayerBuildMode.m_BuildNeedHelpType.research and g_AllianceMode.getSelfHaveAlliance() then
				_addOrEnableAir(c_tag_air_help_institute, effect_Air, HomeAirMD.create_help_Institute)
			else
				_removeAir(c_tag_air_help_institute, effect_Air)
			end
		else
			_removeAir(c_tag_air_help_institute, effect_Air)
		end
	
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.bar then
		
		if buildStatus == g_PlayerBuildMode.m_BuildStatus.default then

			if g_PlayerPubMode.isHaveGeneralToRecuite() then
				_addOrEnableAir(c_tag_air_recruit_bar, effect_Air, HomeAirMD.create_help_Bar)
				_addOrEnablePlayAnimation(c_tag_bar_can_get, effect_Top, "anime/Effect_JiuGuangJianZhuZhaoHuanXunHuan/Effect_JiuGuangJianZhuZhaoHuanXunHuan.ExportJson", "Effect_JiuGuangJianZhuZhaoHuanXunHuan", "Animation1" , scaleVar, nil)
				return
			else
				_removeAir(c_tag_air_recruit_bar, effect_Air)
				_removeAnimation(c_tag_bar_can_get, effect_Top)
			end

			if g_PlayerPubMode.isHaveStarReward() then
				_addOrEnableAir(c_tag_air_pub_new, effect_Air, HomeAirMD.create_star_reward_Bar)
				return
			else
				_removeAir(c_tag_air_pub_new, effect_Air)
			end
			
		else
			_removeAir(c_tag_air_recruit_bar, effect_Air)
			_removeAnimation(c_tag_bar_can_get, effect_Top)
			_removeAir(c_tag_air_pub_new, effect_Air)
		end
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.grindery then	
		if g_millData.isHaveCollectionRes() then
			_addOrEnableAir(c_tag_air_harvest, effect_Air, HomeAirMD.create_harvest_Grindery)
		else
			_removeAir(c_tag_air_harvest, effect_Air)
		end
		local grinderyInfo = g_millData.getWorkingInfo()
		if grinderyInfo then
			_addOrEnablePlayAnimation_Grindery(c_tag_grindery_build, effect_Top, "anime/QiZhenGeJianZaoZhong/QiZhenGeJianZaoZhong.ExportJson", "QiZhenGeJianZaoZhong", "Animation1" , scaleVar, nil, grinderyInfo)
			_addOrEnableProgress(effect_Top, configData, buildingData, serverData, grinderyInfo)
		else
			_removeAnimation(c_tag_grindery_build, effect_Top)
			_removeProgress(buildingData)
		end
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.mainCity then
		if effect_Air:getChildByTag(c_tag_air_levelUp_help) == nil and effect_Air:getChildByTag(c_tag_air_levelUp_free) == nil and g_GeneralMode.canEquipForGeneral() then
			_addOrEnableAir(c_tag_air_canWear_mainCity, effect_Air, HomeAirMD.create_canWear_MainCity)
		else
			_removeAir(c_tag_air_canWear_mainCity, effect_Air)
		end
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.spectacular then
		if effect_Air:getChildByTag(c_tag_air_levelUp_help) == nil and effect_Air:getChildByTag(c_tag_air_levelUp_free) == nil and (g_ArmyUnitMode.ShowPop() or g_ArmyMode.ShowPop()) then
			_addOrEnableAir(c_tag_air_sleep_spectacular, effect_Air, HomeAirMD.create_sleep_Spectacular)
		else
			_removeAir(c_tag_air_sleep_spectacular, effect_Air)
		end
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.god then
		if require("game.uilayer.godGeneral.GodGeneralMode"):instance():isShowBubble() then
			_addOrEnableAir(c_tag_air_canUse_god, effect_Air, HomeAirMD.create_canUse_god)
		else
			_removeAir(c_tag_air_canUse_god, effect_Air)
		end
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.stars then
		if g_corData.ShowPop() then
			_addOrEnableAir(c_tag_air_free_stars, effect_Air, HomeAirMD.create_free_stars)
		else
			_removeAir(c_tag_air_free_stars, effect_Air)
		end
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.stars then
		
	elseif configData.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.tournament then
		if g_expeditionData.IsHaveDailyRankReward() or g_expeditionData.IsHaveDailyTimesReward() then
			_addOrEnableAir(c_tag_air_wudou, effect_Air, HomeAirMD.create_wudou)
		else
			_removeAir(c_tag_air_wudou, effect_Air)
		end
	end
	
end

--添加气泡3
--得到气泡组
function getAirs(place)
	local ret = {}
	local MapNormalizationPanle = require("game.maplayer.homeMapLayer").getMapNormalizationPanel()
	if MapNormalizationPanle then
		local effect_Top = MapNormalizationPanle:getChildByName(tostring(place).."_top_efc")
		ret[m_AirType.harvest] = effect_Top:getChildByTag(c_tag_air_harvest)
		ret[m_AirType.levelUp_help] = effect_Top:getChildByTag(c_tag_air_levelUp_help)
		ret[m_AirType.levelUp_free] = effect_Top:getChildByTag(c_tag_air_levelUp_free)
		ret[m_AirType.helpAll] = effect_Top:getChildByTag(c_tag_air_helpAll)
		ret[m_AirType.fire] = effect_Top:getChildByTag(c_tag_air_fire)
		ret[m_AirType.repair] = effect_Top:getChildByTag(c_tag_air_repair)
		ret[m_AirType.hospital] = effect_Top:getChildByTag(c_tag_air_help_hospital)
		ret[m_AirType.institute] = effect_Top:getChildByTag(c_tag_air_help_institute)
		ret[m_AirType.bar] = effect_Top:getChildByTag(c_tag_air_recruit_bar)
		ret[m_AirType.mainCity] = effect_Top:getChildByTag(c_tag_air_canWear_mainCity)
		ret[m_AirType.spectacular] = effect_Top:getChildByTag(c_tag_air_sleep_spectacular)
		ret[m_AirType.canUse_god] = effect_Top:getChildByTag(c_tag_air_canUse_god)
		ret[m_AirType.free_stars] = effect_Top:getChildByTag(c_tag_air_free_stars)
		ret[m_AirType.wanqiangdouzhi] = effect_Top:getChildByTag(c_tag_air_wanqiangdouzhi)
		ret[m_AirType.wudou] = effect_Top:getChildByTag(c_tag_air_wudou)
		ret[m_AirType.pubNew] = effect_Top:getChildByTag(c_tag_air_pub_new)
	end
	return ret
end






return homeMapHelper