local homeAirClick = {}
setmetatable(homeAirClick,{__index = _G})
setfenv(1,homeAirClick)


--收获 金
function onClick_harvest_Gold(configData , buildingData , serverData)
	local function onRecv(result, msgData)
		if(result==true)then
			g_musicManager.playEffect(g_data.sounds[5000032].sounds_path)
			local count = 0
			for k, v in pairs(msgData.PlayerBuild) do
				count = count + 1
				g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
				require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
				require("game.effectlayer.harvestEffect_Fly").play_Gold(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
			end
			if count > 1 then
				local function playDoubleSound()
					g_musicManager.playEffect(g_data.sounds[5000032].sounds_path)
				end
				g_autoCallback.addCocosList(playDoubleSound, 0.4)
			end
		end
	end
	local homeMapHelperMD = require("game.maplayer.homeMapHelper")
	local positionList = {[1] = serverData.position, }
	local buildList = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.gold)
	for k1, v1 in pairs(buildList) do
		local air = homeMapHelperMD.getAirs(v1.position)
		for k2, v2 in pairs(air) do
			if k2 == homeMapHelperMD.m_AirType.harvest and v2:isCanClick() then
				positionList[(#positionList) + 1] = v1.position
				v2:lua_playClickHide()
			end
		end
	end
	g_sgHttp.postData("build/gainResource",{position = positionList },onRecv,true)
end


--收获 食物
function onClick_harvest_Food(configData , buildingData , serverData)
	local function onRecv(result, msgData)
		if(result==true)then
			g_musicManager.playEffect(g_data.sounds[5000030].sounds_path)
			local count = 0
			for k, v in pairs(msgData.PlayerBuild) do
				count = count + 1
				g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
				require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
				require("game.effectlayer.harvestEffect_Fly").play_Food(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
			end
			if count > 1 then
				local function playDoubleSound()
					g_musicManager.playEffect(g_data.sounds[5000030].sounds_path)
				end
				g_autoCallback.addCocosList(playDoubleSound, 0.4)
			end
		end
	end
	local homeMapHelperMD = require("game.maplayer.homeMapHelper")
	local positionList = {[1] = serverData.position, }
	local buildList = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.food)
	for k1, v1 in pairs(buildList) do
		local air = homeMapHelperMD.getAirs(v1.position)
		for k2, v2 in pairs(air) do
			if k2 == homeMapHelperMD.m_AirType.harvest and v2:isCanClick() then
				positionList[(#positionList) + 1] = v1.position
				v2:lua_playClickHide()
			end
		end
	end
	g_sgHttp.postData("build/gainResource",{position = positionList },onRecv,true)
end


--收获 木头
function onClick_harvest_Wood(configData , buildingData , serverData)
	local function onRecv(result, msgData)
		if(result==true)then
			g_musicManager.playEffect(g_data.sounds[5000031].sounds_path)
			local count = 0
			for k, v in pairs(msgData.PlayerBuild) do
				count = count + 1
				g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
				require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
				require("game.effectlayer.harvestEffect_Fly").play_Wood(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
			end
			if count > 1 then
				local function playDoubleSound()
					g_musicManager.playEffect(g_data.sounds[5000031].sounds_path)
				end
				g_autoCallback.addCocosList(playDoubleSound, 0.4)
			end
		end
	end
	local homeMapHelperMD = require("game.maplayer.homeMapHelper")
	local positionList = {[1] = serverData.position, }
	local buildList = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.wood)
	for k1, v1 in pairs(buildList) do
		local air = homeMapHelperMD.getAirs(v1.position)
		for k2, v2 in pairs(air) do
			if k2 == homeMapHelperMD.m_AirType.harvest and v2:isCanClick() then
				positionList[(#positionList) + 1] = v1.position
				v2:lua_playClickHide()
			end
		end
	end
	g_sgHttp.postData("build/gainResource",{position = positionList },onRecv,true)
end


--收获 石头
function onClick_harvest_Stone(configData , buildingData , serverData)
	local function onRecv(result, msgData)
		if(result==true)then
			g_musicManager.playEffect(g_data.sounds[5000033].sounds_path)
			local count = 0
			for k, v in pairs(msgData.PlayerBuild) do
				count = count + 1
				g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
				require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
				require("game.effectlayer.harvestEffect_Fly").play_Stone(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
			end
			if count > 1 then
				local function playDoubleSound()
					g_musicManager.playEffect(g_data.sounds[5000033].sounds_path)
				end
				g_autoCallback.addCocosList(playDoubleSound, 0.4)
			end
		end
	end
	local homeMapHelperMD = require("game.maplayer.homeMapHelper")
	local positionList = {[1] = serverData.position, }
	local buildList = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.stone)
	for k1, v1 in pairs(buildList) do
		local air = homeMapHelperMD.getAirs(v1.position)
		for k2, v2 in pairs(air) do
			if k2 == homeMapHelperMD.m_AirType.harvest and v2:isCanClick() then
				positionList[(#positionList) + 1] = v1.position
				v2:lua_playClickHide()
			end
		end
	end
	g_sgHttp.postData("build/gainResource",{position = positionList },onRecv,true)
end


--收获 铁
function onClick_harvest_Iron(configData , buildingData , serverData)
	local function onRecv(result, msgData)
		if(result==true)then
			g_musicManager.playEffect(g_data.sounds[5000032].sounds_path)
			local count = 0
			for k, v in pairs(msgData.PlayerBuild) do
				count = count + 1
				g_PlayerBuildMode.updateSingleBuildData(v.buildInfo, v.buildInfo.position)
				require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(v.buildInfo, v.buildInfo.position)
				require("game.effectlayer.harvestEffect_Fly").play_Iron(v.buildInfo.position, v.getResource / math.max(1, v.buildInfo.resource_in))
				require("game.effectlayer.harvestEffect_Fly").playAirText(v.buildInfo.position, "+"..tostring(v.getResource))
			end
			if count > 1 then
				local function playDoubleSound()
					g_musicManager.playEffect(g_data.sounds[5000032].sounds_path)
				end
				g_autoCallback.addCocosList(playDoubleSound, 0.4)
			end
		end
	end
	local homeMapHelperMD = require("game.maplayer.homeMapHelper")
	local positionList = {[1] = serverData.position, }
	local buildList = g_PlayerBuildMode.FindBuild_Table_OriginID(g_PlayerBuildMode.m_BuildOriginType.iron)
	for k1, v1 in pairs(buildList) do
		local air = homeMapHelperMD.getAirs(v1.position)
		for k2, v2 in pairs(air) do
			if k2 == homeMapHelperMD.m_AirType.harvest and v2:isCanClick() then
				positionList[(#positionList) + 1] = v1.position
				v2:lua_playClickHide()
			end
		end
	end
	g_sgHttp.postData("build/gainResource",{position = positionList },onRecv,true)
end


--收获 战争工坊
function onClick_harvest_Workshop(configData , buildingData , serverData)
	g_musicManager.playEffect(g_data.sounds[5000029].sounds_path)
    g_sgHttp.postData("trap/finishProduce", {position = serverData.position}, nil,true)
end


--收获 步兵营
function onClick_harvest_Infantry(configData , buildingData , serverData)
    g_musicManager.playEffect(g_data.sounds[5000026].sounds_path)
	
    local function callback(result, msgData)
        if (result == true) then
            local homeMapArmyShow = require("game.maplayer.homeMapArmyShow")
            homeMapArmyShow.pushArmy(  g_ArmyUnitMode.m_SoldierOriginType.infantry )
        end
    end

    g_sgHttp.postData("soldier/finishRecruit", {position = serverData.position}, callback,true)

end


--收获 弓兵营
function onClick_harvest_Archers(configData , buildingData , serverData)
	g_musicManager.playEffect(g_data.sounds[5000026].sounds_path)
	
    local function callback(result, msgData)
        if (result == true) then
            local homeMapArmyShow = require("game.maplayer.homeMapArmyShow")
            homeMapArmyShow.pushArmy(  g_ArmyUnitMode.m_SoldierOriginType.archer )
        end
    end
    g_sgHttp.postData("soldier/finishRecruit", {position = serverData.position}, callback,true)
end


--收获 骑兵营
function onClick_harvest_Cavalry(configData , buildingData , serverData)
	g_musicManager.playEffect(g_data.sounds[5000027].sounds_path)
	
    local function callback(result, msgData)
        if (result == true) then
            local homeMapArmyShow = require("game.maplayer.homeMapArmyShow")
            homeMapArmyShow.pushArmy(  g_ArmyUnitMode.m_SoldierOriginType.cavalry )
        end
    end
    g_sgHttp.postData("soldier/finishRecruit", {position = serverData.position}, callback,true)
end


--收获 车兵营
function onClick_harvest_Car(configData , buildingData , serverData)
	g_musicManager.playEffect(g_data.sounds[5000028].sounds_path)
	
    local function callback(result, msgData)
        if (result == true) then
            local homeMapArmyShow = require("game.maplayer.homeMapArmyShow")
            homeMapArmyShow.pushArmy(  g_ArmyUnitMode.m_SoldierOriginType.vehicles )
        end
    end
    g_sgHttp.postData("soldier/finishRecruit", {position = serverData.position}, callback,true)
end


--收获 医院
function onClick_harvest_Hospital(configData , buildingData , serverData)
    local onResult = function(result,msgData)
        if result then
            dump(msgData)
            for key, var in pairs(msgData) do
                local soldierType = g_data.soldier[tonumber(var.soldier_id)].soldier_type
            	require("game.maplayer.homeMapArmyShow").pushArmy(soldierType)
            end
        end
    end
    g_sgHttp.postData("soldier/doCureInjuredSoldier", {}, onResult,true)
end


--建筑 请求帮助升级
function onClick_LevelUp_Help(configData , buildingData , serverData)
    g_PlayerHelpMode.SendHelpAction_Async(serverData.position)
end


--建筑 秒升级
function onClick_LevelUp_Free(configData , buildingData , serverData)
	g_musicManager.playEffect(g_data.sounds[5000036].sounds_path)
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
	local function onRecv(result, msgData)
		if result==true then
			levelUpSucceedCall()
			g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
			require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
		end
	end
	g_sgHttp.postData("build/accelerate",{position = serverData.position , type = 2}, onRecv, true)
end


--帮助所有人 屯所
function onClick_helpAll_ThePlace(configData , buildingData , serverData)
	--g_sceneManager.addNodeForUI(require("game.uilayer.tun.TunView").new())
	
    local function getResult()
        g_PlayerHelpMode.RequestSycData()
    end
    
    local mode = require("game.uilayer.tun.TunMode").new()
    mode:helpAll_Async(getResult)
    
    --g_PlayerHelpMode.HelpAll_Async()
end


--需要修理了 城墙
function onClick_repair_Rampart(configData , buildingData , serverData)
	g_sceneManager.addNodeForUI(require("game.uilayer.wall.WallView").new())
end


--着火了 城墙
function onClick_fire_Rampart(configData , buildingData , serverData)
	g_sceneManager.addNodeForUI(require("game.uilayer.wall.WallView").new())
end


--医院治疗 请求帮助
function onClick_help_Hospital(configData , buildingData , serverData)
	g_PlayerHelpMode.SendHelpAction_Async(serverData.position)
end


--研究科技 请求帮助
function onClick_help_Institute(configData , buildingData , serverData)
	g_PlayerHelpMode.SendHelpAction_Async(serverData.position)
end


--酒馆 可以招募
function onClick_recruit_Bar(configData , buildingData , serverData)
    
    --新手引导期间点击无效
    if g_guideManager.getLastShowStep() then
        return
    end

	--酒馆招募
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    --g_sceneManager.addNodeForUI(require("game.uilayer.recruit.GeneralRecruitLayer"):create(configData.id)) --酒馆招募入口
    g_sceneManager.addNodeForUI(require("game.uilayer.pub.PubLayer"):create()) --酒馆招安入口
end


--收获 磨坊
function onClick_harvest_Grindery(configData , buildingData , serverData)
    
    local startPos = nil
    local button = require("game.maplayer.homeMapLayer").getBuildButtonWithPlace(serverData.position)
    if button then
        local size = button:getContentSize()
        startPos = button:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
    end
	g_millData.RequestCollect_Async(startPos)
end


--官府 可佩戴装备
function onClick_canWear_MainCity(configData , buildingData , serverData)
	local flag, genId = g_GeneralMode.canEquipForGeneral() 
	if flag then 
		g_sceneManager.addNodeForUI(require("game.uilayer.office.OfficeLayer").new(genId))
	end 
end


--校场 空闲。。。。。
function onClick_sleep_Spectacular(configData , buildingData , serverData)
    --新手引导期间点击无效
    if g_guideManager.getLastShowStep() then
        return
    end
    
	g_sceneManager.addNodeForUI(require("game.uilayer.drill.DrillView").new(nil, g_ArmyMode.getCurArmy()))
end

--神龛 能用
function onClick_canUse_god(configData , buildingData , serverData)
    
    if g_guideManager.getLastShowStep() then
        return
    end
    
    local conditionBuildConfigId = tonumber(g_data.starting[96].data)
    local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(conditionBuildConfigId)
    if enoughCount > 0 then
        local GodGeneralEnhance = require("game.uilayer.godGeneral.GodGeneralEnhance"):create()
        g_sceneManager.addNodeForUI(GodGeneralEnhance)
    end

end


--观星台 免费
function onClick_free_stars(configData , buildingData , serverData)
	if g_guideManager.getLastShowStep() then
		return
	end

	local playerInfo = g_playerInfoData.GetData()

	local startingData = tonumber(g_data.starting[90].data)
	local tTemp = g_clock.getCurServerTime() - playerInfo.bowl_type1_last_time + 3
	if tTemp >= startingData then
		g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(1))
		return
	end

	startingData = tonumber(g_data.starting[92].data)
	tTemp = g_clock.getCurServerTime() - playerInfo.bowl_type2_last_time + 3
	if tTemp >= startingData then
		g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(2))
		return
	end

	local itemEquip = {51001,51002,51003,51004,51005,51006}
	local tag = true
	for i=1, #itemEquip do
		if g_BagMode.findItemNumberById(itemEquip[i]) == 0 then
			tag = false
			break
		end
	end

	if tag == true then
		g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(3))
		return
	end

	local tag = false
	if g_PlayerBuildMode.getMainCityBuilding_lv() >= tonumber(g_data.starting[106].data) then
      if playerInfo.sacrifice_free_flag == 1 then
         tag = true
      else
        local num = g_BagMode.findItemNumberById(52005)
        if num > 0 then
          tag = true
        end
      end
  end

  if tag == true then
  	g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(4))
	  return
  end

  local conditionBuildConfigId = tonumber(g_data.starting[95].data)
  local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(conditionBuildConfigId)
  if enoughCount > 0 then
    if g_BagMode.findItemNumberById(52001) > 0 then --免费占星券
      g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(1))
      return 
    end

    if g_BagMode.findItemNumberById(52002) > 0 then --免费天陨券
      g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(2))
      return
    end
  end 
end


--城墙上的少死兵BUFF
function onClick_wanqiangdouzhi_rampart(configData , buildingData , serverData)
	
	local ts = ""
	local t = g_BuffMode.getBuffEndTimeByBuffId(474) - g_clock.getCurServerTime()
	if(t > 0)then
		ts = g_gameTools.convertSecondToString(t)
	end	
	g_msgBox.show(g_tr("air_msgbox_wanqiangyizhi",{time = ts,}))
	
end


function onClick_wudou(configData, buildingData, serverData)
	require("game.uilayer.fightperipheral.FightPrepare").show()
end

function onClick_Bar(configData, buildingData, serverData)
	--新手引导期间点击无效
    if g_guideManager.getLastShowStep() then
        return
    end

	--酒馆招募
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    --g_sceneManager.addNodeForUI(require("game.uilayer.recruit.GeneralRecruitLayer"):create(configData.id)) --酒馆招募入口
    g_sceneManager.addNodeForUI(require("game.uilayer.pub.PubLayer"):create()) --酒馆招安入口
end

return homeAirClick