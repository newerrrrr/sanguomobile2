local smallMenuClick = {}
setmetatable(smallMenuClick,{__index = _G})
setfenv(1,smallMenuClick)


function onClick(cellType , configData , buildingData , serverData)
	print("======================",cellType)
	local func = smallMenuClick[string.format("onClick_%s",tostring(cellType))]
	if(func and type(func)=="function")then
	func(configData , buildingData , serverData)
	else
	assert(false,"not found func id : "..tostring(cellType))
	end
end


--点击到集市
function onClick_Market(configData , buildingData , serverData)
	
	local needLv = tonumber(g_data.starting[56].data)
	if g_PlayerBuildMode.getMainCityBuilding_lv() >= needLv then
		require("game.uilayer.shop.ShopMarketLayer").show()
	else
		g_airBox.show(g_tr("openMarketCondition",{build_name = g_tr(10001),build_lv = needLv}))
	end
	
--	local startingId = g_data.starting[56].data
--	local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(tonumber(startingId))
--	if enoughCount > 0 then
--	 g_sceneManager.addNodeForUI(require("game.uilayer.shop.ShopMarketLayer"):create())
--	else
--	 local buildInfo = g_data.build[tonumber(startingId)]
--	 g_airBox.show(g_tr("openMarketCondition",{build_name = g_tr(buildInfo.build_name),build_lv = buildInfo.build_level}))
--	end
end


--点击到磨坊
function onClick_Grindery(configData , buildingData , serverData)
	g_sceneManager.addNodeForUI(require("game.uilayer.mill.MillLayer"):create())
end	

--点击到武斗
function onClick_Tournament(configData , buildingData , serverData)
	--g_airBox.show(g_tr("peripheral_comming_soon"))
	g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.TOURNAMENT)
end	

--点击到神龛
function onClick_God(configData , buildingData , serverData)
	local conditionBuildConfigId = tonumber(g_data.starting[96].data)
	local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(conditionBuildConfigId)
	if enoughCount > 0 then
	local step = g_guideManager.getLastShowStep()
	if step then
		 local config = step:getGuideInfo():getConfig()
		 local generalId = config.general_ids[1]
		 local GodGeneralEnhance = require("game.uilayer.godGeneral.GodGeneralEnhance"):create(generalId)
		 g_sceneManager.addNodeForUI(GodGeneralEnhance)
	else
		 local GodGeneralEnhance = require("game.uilayer.godGeneral.GodGeneralEnhance"):create()
		 g_sceneManager.addNodeForUI(GodGeneralEnhance)
	end
	 
	else
	local buildInfo = g_data.build[conditionBuildConfigId]
	if buildInfo then
		g_airBox.show(g_tr("openShenKanCondition",{build_name = g_tr(buildInfo.build_name),build_lv = buildInfo.build_level}))
	end
	end

end	

--点击到观星台
function onClick_Stars(configData , buildingData , serverData)

	local conditionBuildConfigId = tonumber(g_data.starting[95].data)
	local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(conditionBuildConfigId)
	if enoughCount > 0 then
	local idx = 1
	local step = g_guideManager.getLastShowStep()
	if step then
		idx = 2 --天陨
		local config = step:getGuideInfo():getConfig()
		--找出府衙等级
		local buildConfigId = config.build_ids
		for key, var in pairs(config.build_ids) do
		local buildConfig = g_data.build[var]
		if buildConfig.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.mainCity then
			if buildConfig.build_level >= tonumber(g_data.starting[106].data) then
			idx = 4 --祭天
			end
			break
		end
		end
	end
	g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(idx))
	else
	local buildInfo = g_data.build[conditionBuildConfigId]
	if buildInfo then
		g_airBox.show(g_tr("openGuanXingTaiCondition",{build_name = g_tr(buildInfo.build_name),build_lv = buildInfo.build_level}))
	end
	end
end	

function onClick_Activity(configData , buildingData , serverData)

	local list = require("game.uilayer.activity.ActivityMainLayer").getOpenListByActivityType(g_activityData.ActivityType.Operation)
	
	if #list  > 0 then
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		g_sceneManager.addNodeForUI(require("game.uilayer.activity.ActivityMainLayer").new(g_activityData.ActivityType.Operation))
	end
end


--函数编号对应的意思看配置表Build.xlsx中的Build_menu sheet
--参数为: 		 build配置	, building配置 , 本地缓存数据
--参数只能使用,不能修改,配置数据被改了就麻烦了


function onClick_101(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	g_sceneManager.addNodeForUI(require("game.uilayer.buildupgrade.BuildingInformationLayer"):create(configData.id,serverData))
end


function onClick_102(configData , buildingData , serverData)
	
	local function onLevelUp()
	local function onRecv(result, msgData)
		if(result==true)then
		    g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
		    require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
			--是否解锁新兵
			require("game.uilayer.militaryCamp.MilitaryCampData").saveUnlockSolider(msgData.build_id)
			--弹出快速加速道具界面
			local position = msgData.position
			local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Build)
			g_sceneManager.addNodeForUI(view)
		end
	end
	g_sgHttp.postData("build/lvUp",{ position = serverData.position },onRecv)
	end
	
	local function onFastDone()
		local function onRecv(result, msgData)
			if(result==true)then
				
				--升级成功特效
				local function levelUpSucceedCall()
					cc.Director:getInstance():setNextDeltaTimeZero(true)
					local function onEventCallFunc(armature , eventType , name)
						if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
							armature:removeFromParent()
						end
					end
					local armature , animation = g_gameTools.LoadCocosAni("anime/LingQuTiShiOne/LingQuTiShiOne.ExportJson", "LingQuTiShiOne", onEventCallFunc)
					require("game.maplayer.homeMapLayer").addAutoEffectTop(serverData.position, armature)
					animation:play("Animation1")
					--是否解锁新兵
					require("game.uilayer.militaryCamp.MilitaryCampData").saveUnlockSolider(msgData.build_id)
				end
				levelUpSucceedCall()
				
				g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
		require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
			end
		end
		g_sgHttp.postData("build/lvUp",{ position = serverData.position,useGem = 1 },onRecv)
	end
	
	local function onMoveCancle(build_id)
	local v = g_PlayerBuildMode.FindBuild_lv_less_ConfigID(build_id)
	if(v)then
		--require("game.maplayer.homeMapLayer").moveToCenterForGuide(v.position)
		require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(v.position)
	else
		local needBuild = g_PlayerBuildMode.FindBuildConfig_firstBuilding_ConfigID(build_id)
		local canBuildPlace = require("game.maplayer.homeMapLayer").getClearingWithBuildID(needBuild.id)
		if(canBuildPlace)then
		--require("game.maplayer.homeMapLayer").moveToCenterForGuide(canBuildPlace)
		require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(canBuildPlace)
		end
	end
	end
	
	--g_musicManager.playEffect(g_data.sounds[5000035].sounds_path)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function onCancle()
	
	end
	
	local params =	{}
	params.onStart = onLevelUp
	params.onFastDone = onFastDone
	params.onMoveCancle = onMoveCancle
	params.onCancle = onCancle
	
	g_sceneManager.addNodeForUI(require("game.uilayer.buildupgrade.BuildingUpgradeLayer"):create(configData.id,params,true,serverData))

end


function onClick_103(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	g_sceneManager.addNodeForUI(require("game.uilayer.garrison.BuildingGrarrisonLayer"):create(configData.id,serverData))
end


function onClick_104(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	--弹出快速加速道具界面
    local position = serverData.position
	local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Build,nil,true)
	g_sceneManager.addNodeForUI(view)
end


function onClick_105(configData , buildingData , serverData)
	--元宝加速
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local finishTime = serverData.build_finish_time
	local doSpeedUpHandler = function(costGem)
		local function onRecv(result, msgData)
		if(result==true)then
			--dump(msgData)
			--升级成功特效
			local function levelUpSucceedCall()
				cc.Director:getInstance():setNextDeltaTimeZero(true)
				local function onEventCallFunc(armature , eventType , name)
					if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
						armature:removeFromParent()
					end
				end
				local armature , animation = g_gameTools.LoadCocosAni("anime/LingQuTiShiOne/LingQuTiShiOne.ExportJson", "LingQuTiShiOne", onEventCallFunc)
				require("game.maplayer.homeMapLayer").addAutoEffectTop(serverData.position, armature)
				animation:play("Animation1")
			end
			levelUpSucceedCall()
				
			
			g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
		require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
		end
		end
		g_sgHttp.postData("build/accelerate",{position = serverData.position,type = 1},onRecv)
	end
	g_msgBox.showSpeedUp(finishTime, g_tr("speedUpBuildingCD"), nil, nil, doSpeedUpHandler)
end

--战争工坊(造陷阱)
function onClick_106(configData , buildingData , serverData)
	if serverData.status ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng then --战争工坊升级过程中不允许进入
	--保证数据完整性
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
		SoldierTraningLayer:createLayer(serverData.build_id)
	end
end

--士兵训练
function onClick_107(configData , buildingData , serverData)
	if serverData.status ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng then --兵营升级过程中不允许进入
	--保证数据完整性
		g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
		SoldierTraningLayer:createLayer(serverData.build_id)
	end
end


function onClick_108(configData , buildingData , serverData)
	--铁匠铺：进阶
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local SmithyData = require("game.uilayer.smithy.SmithyData")
	g_sceneManager.addNodeForUI(require("game.uilayer.smithy.SmithyBaseLayer").new(SmithyData.viewType.Advance)) 
end


function onClick_109(configData , buildingData , serverData)
	--铁匠铺：重铸
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local SmithyData = require("game.uilayer.smithy.SmithyData")
	g_sceneManager.addNodeForUI(require("game.uilayer.smithy.SmithyBaseLayer").new(SmithyData.viewType.Recast)) 	
end


function onClick_110(configData , buildingData , serverData)
	--研究所
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	g_sceneManager.addNodeForUI(require("game.uilayer.science.ScienceLayer").new()) 
end


function onClick_111(configData , buildingData , serverData)
	
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	if g_AllianceMode.getSelfHaveAlliance() == false then
		g_airBox.show(g_tr_original("battleHallNoAlliance"))
		return
	end
	g_sceneManager.addNodeForUI(require("game.uilayer.tun.TunView").new())
	
end


function onClick_112(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	if g_AllianceMode.getSelfHaveAlliance() == false then
		g_airBox.show(g_tr_original("battleHallNoAlliance"))
		return
	end
	g_sceneManager.addNodeForUI(require("game.uilayer.tun.ArmyHelpView").new())
end


function onClick_113(configData , buildingData , serverData)
	--书院--
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	g_sceneManager.addNodeForUI(require("game.uilayer.college.CollegeView").new())
end


function onClick_114(configData , buildingData , serverData)
	--酒馆招募
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	--g_sceneManager.addNodeForUI(require("game.uilayer.recruit.GeneralRecruitLayer"):create(configData.id)) --酒馆招募入口
	g_sceneManager.addNodeForUI(require("game.uilayer.pub.PubLayer"):create()) --酒馆招安入口
end


function onClick_115(configData , buildingData , serverData)
	--校场--
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	g_sceneManager.addNodeForUI(require("game.uilayer.drill.DrillView").new())
	--g_sceneManager.addNodeForUI(require("game.uilayer.guildwar.GuildWarInfoView").new())
end


function onClick_116(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	g_sceneManager.addNodeForUI(require("game.uilayer.hospital.HospitalLayer"):create(configData.id,serverData))
end


function onClick_117(configData , buildingData , serverData)
	--哨塔--
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	g_sceneManager.addNodeForUI(require("game.uilayer.tower.TowerView").new())
	--g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new())
end


function onClick_118(configData , buildingData , serverData)
	--官府
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	g_sceneManager.addNodeForUI(require("game.uilayer.office.OfficeLayer").new())
end


function onClick_119(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	g_sceneManager.addNodeForUI(require("game.uilayer.wall.WallView").new())
	--g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.MatchView").new())
end


function onClick_120(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function postIncreaseProduce()
	local function onRecv(result, msgData)
		if (result==true)then
		g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
		require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
		end
	end
	g_sgHttp.postData("build/increaseProduce",{position = serverData.position, useGem = 0},onRecv,true)
	end
	local tips_time = 6
	if tonumber(serverData.ex_addition_end_time) == 0 or tonumber(serverData.ex_addition_end_time) < g_clock.getCurServerTime() + 3600 * tips_time then
	postIncreaseProduce()
	else
	local function msgBoxCallBack(event)
		if event == 0 then
		postIncreaseProduce()
		end
	end
	g_msgBox.show(g_tr("smallMenu_tips_use", {time = tips_time}), nil, nil, msgBoxCallBack, 1)
	end
end


function onClick_121(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function postIncreaseProduce()
	local doHandler = function()
		local function onRecv(result, msgData)
		if (result==true)then
			g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
			require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
		end
		end
		g_sgHttp.postData("build/increaseProduce",{position = serverData.position,useGem = 1},onRecv,true)
	end
	
	local num = tonumber(g_data.starting[98].data)
	local text = g_tr("makeSureSpeedUpResource",{build_name = g_tr(configData.build_name),cnt = num})
	local cost = g_data.item[g_Consts.ResAddSpeedItemId[serverData.origin_build_id]].direct_price
	local buttonText = g_tr("resourceSpeedUpNow")
	local title = nil
	g_msgBox.showConsume(cost, text, title, buttonText,doHandler)
	end
	local tips_time = 6
	if tonumber(serverData.ex_addition_end_time) == 0 or tonumber(serverData.ex_addition_end_time) < g_clock.getCurServerTime() + 3600 * tips_time then
	postIncreaseProduce()
	else
	local function msgBoxCallBack(event)
		if event == 0 then
		postIncreaseProduce()
		end
	end
	g_msgBox.show(g_tr("smallMenu_tips_use", {time = tips_time}), nil, nil, msgBoxCallBack, 1)
	end
end


function onClick_122(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function onRecv(result, msgData)
	if(result==true)then
		g_musicManager.playEffect(g_data.sounds[5000032].sounds_path)
		for k, v in pairs(msgData.PlayerBuild) do
		g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
		require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
		require("game.effectlayer.harvestEffect_Fly").play_Gold(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
		require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
		end
	end
	end
	g_sgHttp.postData("build/gainResource",{position = {serverData.position, } },onRecv,true)
end


function onClick_123(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function onRecv(result, msgData)
	if(result==true)then
		g_musicManager.playEffect(g_data.sounds[5000030].sounds_path)
		for k, v in pairs(msgData.PlayerBuild) do
		g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
		require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
		require("game.effectlayer.harvestEffect_Fly").play_Food(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
		require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
		end
	end
	end
	g_sgHttp.postData("build/gainResource",{position = {serverData.position, } },onRecv,true)
end


function onClick_124(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function onRecv(result, msgData)
	if(result==true)then
		g_musicManager.playEffect(g_data.sounds[5000031].sounds_path)
		for k, v in pairs(msgData.PlayerBuild) do
		g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
		require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
		require("game.effectlayer.harvestEffect_Fly").play_Wood(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
		require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
		end
	end
	end
	g_sgHttp.postData("build/gainResource",{position = {serverData.position, } },onRecv,true)
end


function onClick_125(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function onRecv(result, msgData)
	if(result==true)then
		g_musicManager.playEffect(g_data.sounds[5000033].sounds_path)
		for k, v in pairs(msgData.PlayerBuild) do
		g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
		require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
		require("game.effectlayer.harvestEffect_Fly").play_Stone(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
		require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
		end
	end
	end
	g_sgHttp.postData("build/gainResource",{position = {serverData.position, } },onRecv,true)
end


function onClick_126(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function onRecv(result, msgData)
	if(result==true)then
		g_musicManager.playEffect(g_data.sounds[5000032].sounds_path)
		for k, v in pairs(msgData.PlayerBuild) do
		g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
		require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
		require("game.effectlayer.harvestEffect_Fly").play_Iron(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
		require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
		end
	end
	end
	g_sgHttp.postData("build/gainResource",{position = {serverData.position, } },onRecv,true)
end


function onClick_127(configData , buildingData , serverData)
	
end


function onClick_128(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	if g_AllianceMode.getSelfHaveAlliance() == false then
		g_airBox.show(g_tr_original("battleHallNoAlliance"))
		return
	end
	g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleHallView").new())
end

--步兵道具
function onClick_129(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	--[[
	local function formatData(serverNewData)
		serverNewData = serverNewData or serverData
		local tb = {
			bid = serverNewData.position,
			stime = serverNewData.work_begin_time or 0 ,
			ftime = serverNewData.work_finish_time,
			itype = g_Consts.UseItemType.Soldier,
		}

		return tb
	end

	local UsePropsLayer = require("game.uilayer.publicMode.UsePropsLayer")
	UsePropsLayer:createLayer(	formatData )]]
	local position = serverData.position
	local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Soldier,nil,true)
	g_sceneManager.addNodeForUI(view)
end

--兵营立即完成（外）
function onClick_130(configData , buildingData , serverData)
	local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
	SoldierTraningLayer:quickBuild(serverData,"soldier/accelerateRecruit")
end

--骑兵道具
function onClick_131(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	--[[local function formatData(serverNewData)
		serverNewData = serverNewData or serverData
		local tb = {
			bid = serverNewData.position,
			stime = serverNewData.work_begin_time or 0 ,
			ftime = serverNewData.work_finish_time,
			itype = g_Consts.UseItemType.Soldier,
		}

		return tb
	end

	local UsePropsLayer = require("game.uilayer.publicMode.UsePropsLayer")
	UsePropsLayer:createLayer(	formatData )]]
	local position = serverData.position
	local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Soldier,nil,true)
	g_sceneManager.addNodeForUI(view)
end


function onClick_132(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
	SoldierTraningLayer:quickBuild(serverData,"soldier/accelerateRecruit")
end

--弓兵道具
function onClick_133(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	--[[local function formatData(serverNewData)
		serverNewData = serverNewData or serverData
		local tb = {
			bid = serverNewData.position,
			stime = serverNewData.work_begin_time or 0 ,
			ftime = serverNewData.work_finish_time,
			itype = g_Consts.UseItemType.Soldier,
		}

		return tb
	end

	local UsePropsLayer = require("game.uilayer.publicMode.UsePropsLayer")
	UsePropsLayer:createLayer(	formatData )]]
	local position = serverData.position
	local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Soldier,nil,true)
	g_sceneManager.addNodeForUI(view)

	--local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
	--SoldierTraningLayer:quickBuild(serverData,"soldier/accelerateRecruit")
end


function onClick_134(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
	SoldierTraningLayer:quickBuild(serverData,"soldier/accelerateRecruit")
end

--车兵道具
function onClick_135(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	--[[local function formatData(serverNewData)
		serverNewData = serverNewData or serverData
		local tb = {
			bid = serverNewData.position,
			stime = serverNewData.work_begin_time or 0 ,
			ftime = serverNewData.work_finish_time,
			itype = g_Consts.UseItemType.Soldier,
		}

		return tb
	end

	local UsePropsLayer = require("game.uilayer.publicMode.UsePropsLayer")
	UsePropsLayer:createLayer(	formatData )]]
	local position = serverData.position
	local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Soldier,nil,true)
	g_sceneManager.addNodeForUI(view)
end


function onClick_136(configData , buildingData , serverData)
	local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
	SoldierTraningLayer:quickBuild(serverData,"soldier/accelerateRecruit")
end

--陷阱道具加速
function onClick_137(configData , buildingData , serverData)

	--[[local function formatData(serverNewData)
		serverNewData = serverNewData or serverData
		local tb = {
			bid = serverNewData.position,
			stime = serverNewData.work_begin_time or 0 ,
			ftime = serverNewData.work_finish_time,
			itype = g_Consts.UseItemType.Trap,
		}

		return tb
	end

	local UsePropsLayer = require("game.uilayer.publicMode.UsePropsLayer")
	UsePropsLayer:createLayer(	formatData )]]
	local position = serverData.position
	local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Trap,nil,true)
	g_sceneManager.addNodeForUI(view)

end

--陷阱立即完成（外）
function onClick_138(configData , buildingData , serverData)
	local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
	SoldierTraningLayer:quickBuild(serverData,"trap/accelerateProduce")
end

--科技道具加速
function onClick_139(configData , buildingData , serverData)
	--print("onClick_139")

	 --dump(serverData)
	 --[[dump(buildingData)
	 dump(configData)]]
	 g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	 --[[local function formatData( serverNewData )
		serverNewData = serverNewData or serverData
		local scienceData = g_data.science[tonumber(serverNewData.work_content)]
		local science_type_id = 0
		if scienceData then
			science_type_id = scienceData.science_type_id
		end

		--print("science_type_id",science_type_id)

		local tb = {
			bid = science_type_id,
			stime = serverNewData.work_begin_time or 0 ,
			ftime = serverNewData.work_finish_time,
			itype = g_Consts.UseItemType.Study,
		}

		return tb
	end

	local UsePropsLayer = require("game.uilayer.publicMode.UsePropsLayer")
	UsePropsLayer:createLayer(	formatData )]]
	local position = serverData.position
	local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Study,nil,true)
	g_sceneManager.addNodeForUI(view)
end

--研究所科技元宝加速
function onClick_140(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local finishTime = serverData.work_finish_time
	local doSpeedUpHandler = function(costGem)
		local function onRecv(result, msgData)
			if(result==true)then
			end
		end
		local scienceId = tonumber(serverData.work_content)

		g_sgHttp.postData("Science/accelerate", {scienceTypeId = g_data.science[scienceId].science_type_id, type=2}, onRecv)
	end
	g_msgBox.showSpeedUp(finishTime, g_tr("speedUpSciLearningCD"), nil, nil, doSpeedUpHandler)
end

--医疗加速
function onClick_141(configData , buildingData , serverData)
	--if serverData and serverData.status == g_PlayerBuildMode.m_BuildStatus.working then
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	--[[local function formatData( serverNewData )
		serverNewData = serverNewData or serverData
		local tb = {
			bid = serverNewData.id,
			stime = serverNewData.work_begin_time or 0 ,
			ftime = serverNewData.work_finish_time,
			itype = g_Consts.UseItemType.Health,
		}
		return tb
	end

	local UsePropsLayer = require("game.uilayer.publicMode.UsePropsLayer")
	UsePropsLayer:createLayer(	formatData )
	--end]]
	local position = serverData.position
	local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Health,nil,true)
	g_sceneManager.addNodeForUI(view)
end

--治疗伤病元宝加速
function onClick_142(configData , buildingData , serverData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local finishTime = serverData.work_finish_time
	local doSpeedUpHandler = function(costGem)
		local function onRecv(result, msgData)
			if(result==true)then
			--g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
		--require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
			end
		end
		g_sgHttp.postData("soldier/doCureInjuredSoldierWithGemOrItem",{},onRecv)
	end
	g_msgBox.showSpeedUp(finishTime, g_tr("speedUpCureSoilderCD"), nil, nil, doSpeedUpHandler)
end

function onClick_143(configData , buildingData , serverData)
	onClick_120(configData, buildingData, serverData)
end

function onClick_144(configData , buildingData , serverData)
	onClick_120(configData, buildingData, serverData)
end

function onClick_145(configData , buildingData , serverData)
	onClick_120(configData, buildingData, serverData)
end

function onClick_146(configData , buildingData , serverData)
	onClick_120(configData, buildingData, serverData)
end



return smallMenuClick