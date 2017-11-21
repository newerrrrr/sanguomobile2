local battleManager = class("battleManager")
local setLayerView = require("game.uilayer.battleSet.battleSettingView")

--data 所需的数据 多个就塞多个在里面 比如
--data.mapConfigData,data.buildServerData

--采集
function battleManager.gotoCollect(data,_costType)
    local function gotoCollection(ArmyID,PlaySound,isUseMove)
		local function onRecv(result, msgData)
            g_busyTip.hide_1()
			if(result==true)then
				require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                if PlaySound then
                    PlaySound()
                end
			end
		end
        g_busyTip.show_1()
		g_sgHttp.postData("map/gotoCollection",{ x = data.buildServerData.x , y = data.buildServerData.y , armyId = ArmyID,useMove = isUseMove },onRecv,true)
	end
    
    local costType = _costType or g_Consts.FightCostPowerType.CostCollect
    setLayerView:setUsePowerType(costType)
    setLayerView:createLayer(gotoCollection,{ x = data.buildServerData.x , y = data.buildServerData.y },g_Consts.FightType.Collect)
end

--建造联盟建筑
function battleManager.gotoBuildGuild(data)
    local function gotoGuildBuild(ArmyID,PlaySound,isUseMove)
        --选择军团建造联盟建筑
        local function onRecv(result, msgData)
            g_busyTip.hide_1()
            if(result==true)then
                require("game.maplayer.worldMapLayer_bigMap").requestMapAllData_Manual()
                if PlaySound then
                    PlaySound()
                end
            end
        end
        g_busyTip.show_1()
        g_sgHttp.postData("Guild/gotoGuildBuild",{ x = data.buildServerData.x , y = data.buildServerData.y , army_id = ArmyID , useMove = isUseMove},onRecv,true)
    end
    setLayerView:setUsePowerType(g_Consts.FightCostPowerType.CostFree)
    setLayerView:createLayer(gotoGuildBuild,{ x = data.buildServerData.x , y = data.buildServerData.y},g_Consts.FightType.Expedition)

end

--攻击城池
function battleManager.gotoAttack(data)
    local function sendBattle()
        local function gotoAttackCity(ArmyID,PlaySound,isUseMove)
            local function onRecv(result, msgData)
                g_busyTip.hide_1()
			    if(result==true)then
				    require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                    if PlaySound then
                        PlaySound()
                    end
			    end
		    end
            g_busyTip.show_1()
		    g_sgHttp.postData("map/gotoAttackCity",{ x = data.buildServerData.x , y = data.buildServerData.y , armyId = ArmyID, useMove = isUseMove },onRecv,true)
	    end
        setLayerView:setUsePowerType(g_Consts.FightCostPowerType.CostCastle)
        setLayerView:createLayer(gotoAttackCity,{ x = data.buildServerData.x , y = data.buildServerData.y },g_Consts.FightType.Expedition)
    end

    battleManager.battleHasAvoidMsgShow(sendBattle)
end

--集结宣战
function battleManager.gotoGather(data)
    
    --是否加入联盟
    if not g_AllianceMode.getSelfHaveAlliance() then
        g_airBox.show(g_tr("battleHallNoAlliance"),3)
        return
    end

    --判断是否建造战争大厅
    if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.battleHall) == nil then
        g_airBox.show(g_tr("MapJJError"),3)
        return
    end

    local function sendBattle()
        local muster_time_type
        local function gotoCollection(ArmyID,PlaySound)
            local function onRecv(result, msgData)
                g_busyTip.hide_1()
			    if(result==true)then
                    --完成集结
				    require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                    if PlaySound then
                        PlaySound()
                    end
			    end
		    end
            g_busyTip.show_1()
            g_sgHttp.postData("map/startGather",{ x = data.buildServerData.x , y = data.buildServerData.y , armyId = ArmyID,time = muster_time_type },onRecv,true)
        end
    
        --选择时间TYPE
        local BattleCollectTimeView = require("game.uilayer.battleHall.BattleCollectTimeView")
        local view = BattleCollectTimeView:create(
            function (timeType)
                muster_time_type = timeType
                --选择队伍
                local isJijie = true
                setLayerView:setUsePowerType(g_Consts.FightCostPowerType.CostCastle)
                setLayerView:createLayer(gotoCollection,{x = data.buildServerData.x , y = data.buildServerData.y},g_Consts.FightType.Expedition,isJijie)
            end)
        g_sceneManager.addNodeForUI( view )
    end
    battleManager.battleHasAvoidMsgShow(sendBattle)
end

--士兵增援
function battleManager.gotoSendArmy(data)
    local function sendBattle()
        local function callback(ArmyID,PlaySound,isUseMove)
            local function onRecv(result, msgData)
                g_busyTip.hide_1()
                if(result==true)then
                    require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                    if PlaySound then
                        PlaySound()
                    end
                end
            end
            g_busyTip.show_1()
            g_sgHttp.postData("player_help/sendArmy",{ to_player_id = data.playerData.id, army_id = ArmyID, useMove = isUseMove},onRecv,true)
        end
        setLayerView:setUsePowerType(g_Consts.FightCostPowerType.CostAid)
        setLayerView:createLayer(callback,{x = data.buildServerData.x , y = data.buildServerData.y},g_Consts.FightType.Expedition)
    end

    battleManager.battleHasAvoidMsgShow(sendBattle)
end

local _requireBigMap = function()
	local bigMap = require("game.maplayer.worldMapLayer_bigMap")
	local changeMapScene = require("game.maplayer.changeMapScene")
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
			bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
			bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
	end
	return bigMap
end

function battleManager.gotoBackStayQueue(buildId,queueType,callback)
	local BigMap = _requireBigMap()
	local onRecv = function(result, msgData)
		g_busyTip.hide_1()
		BigMap.requestMapAllData_Manual()
		if callback then
			callback(result, msgData)
		end
	end

	local queueSD = BigMap.getSelfQueueDoing_bigTileIndex_queueType(buildId, queueType)
	if queueSD then
		local changeMapScene = require("game.maplayer.changeMapScene")
		local mapStatus = changeMapScene.getCurrentMapStatus()
		
		g_busyTip.show_1()
		if mapStatus == changeMapScene.m_MapEnum.guildwar then
			g_sgHttp.postData("cross/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
		elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
			g_sgHttp.postData("City_Battle/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
		else
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
		end
	end
end



--召回
function battleManager.gotoBackQueue(data)
	
	local changeMapScene = require("game.maplayer.changeMapScene")
	local mapStatus = changeMapScene.getCurrentMapStatus()
	
  local doBackQueue = function() --召回部队
    local function onRecv(result, msgData)
      g_busyTip.hide_1()
      if(result==true)then
      	_requireBigMap().requestMapAllData_Manual()
      end
    end
  
    if data.queueServerData then
      g_busyTip.show_1()
      if mapStatus == changeMapScene.m_MapEnum.guildwar then
      	g_sgHttp.postData("cross/callbackMoveQueue",{ queueId = data.queueServerData.id },onRecv,true)
      elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
      	g_sgHttp.postData("City_Battle/callbackMoveQueue",{ queueId = data.queueServerData.id },onRecv,true)
      else
      	g_sgHttp.postData("map/callbackMoveQueue",{ queueId = data.queueServerData.id },onRecv,true)
      end
      
    end
  end

  local shopId = 2001 --商店id

	if mapStatus ~= changeMapScene.m_MapEnum.guildwar and  mapStatus ~= changeMapScene.m_MapEnum.citybtattle then --联盟战没有集结
	
	  local QueueHelperMD = require "game.maplayer.worldMapLayer_queueHelper"
	  if QueueHelperMD.isGatherGotoType(data.queueServerData) then --是否属于集结部队
	      shopId = 2002 --商店id
	  end
	  
  end
  
  local shopItemData = g_playerShop.GetShopItemDataByShopId(shopId) 
  local configId = shopItemData:getItemConfigId()
  
  local isItemEnough = false
  
  local bagData = g_BagMode.FindItemByID(configId)
  if bagData and bagData.num > 0 then 
      isItemEnough = true
  end
  
  if not isItemEnough then
    local buyItemHandler = function()
        local function onResult(result, msgData)
          g_busyTip.hide_1()
          if result == true then
              doBackQueue()
          end
        end
        g_busyTip.show_1()
        g_sgHttp.postData("Player/shopBuy",{shopId = shopId,itemNum = 1},onResult,true)
    end
    
    
    local itemInfo = g_data.item[configId]
--    local costId = g_data.shop[shopId].cost_id
--    local costGroup = g_gameTools.getCostsByCostId(costId)
    local itemNotEnoughTipStr = g_tr("queue_back_buy_tips",{item_name = g_tr_original(itemInfo.item_name),price = shopItemData:getPrice()})
    g_msgBox.show(itemNotEnoughTipStr,nil,nil,
        function ( eventType )
            --确定
            if eventType == 0 then 
                buyItemHandler()
            end
        end , 1)
  else
      doBackQueue()
  end
  
	
end

--攻击王城营寨
function battleManager.gotoBattleTown(data)
    local function sendBattle()
        local function gotoGuildBuild(ArmyID,PlaySound,isUseMove)
		    local function onRecv(result, msgData)
                g_busyTip.hide_1()
			    if(result==true)then
				    require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                    if PlaySound then
                        PlaySound()
                    end
			    end
		    end
            g_busyTip.show_1()
            g_sgHttp.postData("map/gotoTown",{ x = data.buildServerData.x , y = data.buildServerData.y , armyId = ArmyID,useMove = isUseMove },onRecv,true)
        end
        --出征界面
        setLayerView:setUsePowerType(g_Consts.FightCostPowerType.CostCastle)
        setLayerView:createLayer(gotoGuildBuild,{ x = data.buildServerData.x , y = data.buildServerData.y },g_Consts.FightType.Expedition)
    end

    battleManager.battleHasAvoidMsgShow(sendBattle)
end

--查看王城营寨
function battleManager.showTown(data)
     if data.buildServerData then
        if data.guildData then
            local myGuild = g_AllianceMode.getBaseData().id
            if data.guildData.id == myGuild then
                local function onRecv(result,msgData)
                    g_busyTip.hide_1()
                    if true == result then
                        --dump(data)
                        g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingGarrisonLayer"):create(data.buildServerData,msgData.kingTownArmy))
                    end
                end
                g_busyTip.show_1()
                g_sgHttp.postData("king/getTownArmy",{ x = data.buildServerData.x , y = data.buildServerData.y },onRecv,true)
            end
        else
            g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingGarrisonLayer"):create(data.buildServerData))
        end
    end
end

function battleManager.gotoGarrison(data)
    local function sendBattle()
        local function gotoGuildBuild(ArmyID,PlaySound,isUseMove)
		    local function onRecv(result, msgData)
                g_busyTip.hide_1()
			    if(result==true)then
				    require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                    if PlaySound then
                        PlaySound()
                    end
			    end
		    end
            g_busyTip.show_1()
            g_sgHttp.postData("map/gotoTown",{ x = data.buildServerData.x , y = data.buildServerData.y , armyId = ArmyID,useMove = isUseMove },onRecv,true)
        end
        --出征界面
        --local setLayer = require("game.uilayer.battleSet.battleSettingView")
        setLayerView:setUsePowerType(g_Consts.FightCostPowerType.CostAid)
        setLayerView:createLayer(gotoGuildBuild,{ x = data.buildServerData.x , y = data.buildServerData.y },g_Consts.FightType.Expedition)
    end

    battleManager.battleHasAvoidMsgShow(sendBattle)
end

--联盟战攻击
function battleManager.gotoAttack2GuildWar(data)
    
    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()
    if mapStatus == changeMapScene.m_MapEnum.guildwar then
    
	    local guildWarStatus = g_guildWarBattleInfoData.getRealStatus()
	    print("guildWarStatus",guildWarStatus)
	    if guildWarStatus ~= g_guildWarBattleInfoData.StatusType.STATUS_ATTACK
	    and guildWarStatus ~= g_guildWarBattleInfoData.StatusType.STATUS_DEFEND
	    then
	        g_airBox.show(g_tr("guild_war_no_battle"))
	        return 
	    end
	
	
	    local function gotoAttackCity(ArmyID,PlaySound,isUseMove)
	      local function onRecv(result, msgData)
	        g_busyTip.hide_1()
					if( true == result )then
						require "game.mapguildwar.worldMapLayer_bigMap".requestMapAllData_Manual()
				            if PlaySound then
				                PlaySound()
				            end
					end
				end
	    	g_busyTip.show_1()
				g_sgHttp.postData("cross/gogogo",{ x = data.buildServerData.x , y = data.buildServerData.y , armyId = ArmyID, useMove = isUseMove },onRecv,true)
			end
	    --setLayerView:setUsePowerType(g_Consts.FightCostPowerType.CostCastle)
	
	    local view = require("game.uilayer.battleSet.gwBattleSettingView")
	    view:createLayer(gotoAttackCity,{ x = data.buildServerData.x , y = data.buildServerData.y },g_Consts.FightType.Expedition)
	  elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
	  	local guildWarStatus = g_cityBattleInfoData.getRealStatus()
	    print("cityBattle Status",guildWarStatus)
	    if guildWarStatus ~= g_cityBattleInfoData.StatusType.STATUS_SEIGE
	    and guildWarStatus ~= g_cityBattleInfoData.StatusType.STATUS_MELEE
	    then
	        g_airBox.show(g_tr("guild_war_no_battle"))
	        return 
	    end
	
	
	    local function gotoAttackCity(ArmyID,PlaySound,isUseMove)
	      local function onRecv(result, msgData)
	        g_busyTip.hide_1()
					if( true == result )then
						require "game.mapcitybattle.worldMapLayer_bigMap".requestMapAllData_Manual()
				            if PlaySound then
				                PlaySound()
				            end
					end
				end
	    	g_busyTip.show_1()
				g_sgHttp.postData("City_Battle/gogogo",{ x = data.buildServerData.x , y = data.buildServerData.y , armyId = ArmyID, useMove = isUseMove },onRecv,true)
			end
	    --setLayerView:setUsePowerType(g_Consts.FightCostPowerType.CostCastle)
	
	    local view = require("game.uilayer.battleSet.cwBattleSettingView")
	    view:createLayer(gotoAttackCity,{ x = data.buildServerData.x , y = data.buildServerData.y },g_Consts.FightType.Expedition)
		end
end



--加速筐
function battleManager.speedDialog(data)

    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()
    --TYPE_NPCBATTLE_GOTO
    --TYPE_COLLECT_GOTO
    --TYPE_CITYBATTLE_GOTO
    --TYPE_CITYBATTLE_RETURN
    --TYPE_NPCBATTLE_RETURN
    --TYPE_COLLECT_RETURN

    if mapStatus == changeMapScene.m_MapEnum.guildwar then
        
        if data.queueServerData then
            local icon,num,shopId = require("game.uilayer.mainSurface.mainSurfaceQueueWorld").getGuildWarSpeedCost()

            local  function acce()
                local function onRecv(result,msgData)
                    if true == result then
                        require("game.uilayer.mainSurface.mainSurfaceQueueWorld").updateQueueCostIcons()
                        require "game.mapguildwar.worldMapLayer_bigMap".requestMapAllData_Manual()
                    end
                end
                g_sgHttp.postData("cross/acceQueue",{ queueId = data.queueServerData.id },onRecv)
            end 
            
            if shopId == 0 then
                acce()
            else
                local mode = require("game.uilayer.publicMode.UseActions").new()
                if mode:shopBuy(shopId,1) then
                    acce()
                end
            end
        end

        --local UseBuffItemLayer = require("game.uilayer.publicMode.UseBuffItemLayer")
		--UseBuffItemLayer:createLayer(1,data.queueServerData)
        return
    elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
        
        if data.queueServerData then
            local icon,num,shopId = require("game.uilayer.mainSurface.mainSurfaceQueueWorld").getGuildWarSpeedCost()

            local  function acce()
                local function onRecv(result,msgData)
                    if true == result then
                        require("game.uilayer.mainSurface.mainSurfaceQueueWorld").updateQueueCostIcons()
                        require "game.mapcitybattle.worldMapLayer_bigMap".requestMapAllData_Manual()
                    end
                end
                g_sgHttp.postData("City_Battle/acceQueue",{ queueId = data.queueServerData.id },onRecv)
            end 
            
            if shopId == 0 then
                acce()
            else
                local mode = require("game.uilayer.publicMode.UseActions").new()
                if mode:shopBuy(shopId,1) then
                    acce()
                end
            end
        end

        --local UseBuffItemLayer = require("game.uilayer.publicMode.UseBuffItemLayer")
		--UseBuffItemLayer:createLayer(1,data.queueServerData)
        return
    end


		local helper = require "game.maplayer.worldMapLayer_queueHelper"
    --单人攻击城池，单人攻击野怪，单人采集,侦查与其所对应的返回操作
    if
    data.queueServerData.type == helper.QueueTypes.TYPE_NPCBATTLE_GOTO or 
    data.queueServerData.type == helper.QueueTypes.TYPE_NPCBATTLE_RETURN or 
    data.queueServerData.type == helper.QueueTypes.TYPE_CITYBATTLE_GOTO or 
    data.queueServerData.type == helper.QueueTypes.TYPE_CITYBATTLE_RETURN or 
    data.queueServerData.type == helper.QueueTypes.TYPE_COLLECT_GOTO or 
    data.queueServerData.type == helper.QueueTypes.TYPE_COLLECT_RETURN or
    data.queueServerData.type == helper.QueueTypes.TYPE_DETECT_GOTO or 
    data.queueServerData.type == helper.QueueTypes.TYPE_DETECT_RETURN 
    then
        local UseOnlyPowerLayer = require("game.uilayer.publicMode.UseOnlyPowerLayer"):create(data.queueServerData)
        g_sceneManager.addNodeForUI(UseOnlyPowerLayer)
    else
        local UseBuffItemLayer = require("game.uilayer.publicMode.UseBuffItemLayer")
		UseBuffItemLayer:createLayer(1,data.queueServerData)
    end

end


function battleManager.battleHasAvoidMsgShow(callback)
    --判断是否有保护
	if g_PlayerMode.hasAvoid() then
        g_msgBox.show( g_tr("battleMissAegis"),nil,2,
        function ( eventType )
            --确定
            if eventType == 0 then 
                if callback then
                    callback()
                end
            end
        end , 1)
    else
        if callback then
            callback()
        end
    end
end


return battleManager