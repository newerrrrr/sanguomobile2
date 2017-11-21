local AllianceManorInfoLayer = class("AllianceManorInfoLayer",function()
    return cc.Layer:create()
end)

local QueueHelperMD = require ("game.maplayer.worldMapLayer_queueHelper")
local function isHaveSelfQueueDoing(buildServerData,queueType)
    local self_player_id = g_PlayerMode.GetData().id
    local bigMap = require("game.maplayer.worldMapLayer_bigMap")
    local currentQueueDatas = bigMap.getCurrentQueueDatas()
    for k , v in pairs(currentQueueDatas.Queue) do
        assert(v.to_map_id ~= 0, "error : to_map_id == 0 ")
        if buildServerData.id == v.to_map_id and v.player_id == self_player_id and v.type == queueType then
            return v
        end
    end
    return nil
end

local baseNode = nil
local allianceManorHelper = require("game.uilayer.alliance.manor.AllianceManorHelper")

function AllianceManorInfoLayer:ctor(mapBuildId,serverData)
    local node = g_gameTools.LoadCocosUI("alliance_building_defense.csb",5)
    self:addChild(node)
    baseNode = node:getChildByName("scale_node")
    
    dump(serverData)

     --关闭本页
    local btnClose = baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent(true)
        end
    end)
    
    local buildInfoNode = baseNode:getChildByName("bg_building_info")
    for i=1, 3 do
    	buildInfoNode:getChildByName("text_property_name"..i):setString("")
    	buildInfoNode:getChildByName("text_property_value"..i):setString("")
    end
    
    local mapBuildInfo = g_data.map_element[mapBuildId]
    assert(mapBuildInfo,"cannot found mapBuildId:"..mapBuildId)
    buildInfoNode:getChildByName("text_name"):setString(g_tr(mapBuildInfo.name))
    buildInfoNode:getChildByName("text_name_0"):setString("")
    baseNode:getChildByName("Text_1"):setString(g_tr(mapBuildInfo.name))
    baseNode:getChildByName("text_2"):setString(g_tr(mapBuildInfo.name))
    baseNode:getChildByName("pic_building"):loadTexture(g_resManager.getResPath(mapBuildInfo.alliance_img))
    
    
    local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
    
    local dismissHandler = function()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local function doDelete()
            local resultHandler = function(result, msgData)
              if result then
                  print("dismiss success")
                  self:removeFromParent()
                  require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
              end
            end
            g_sgHttp.postData("guild/dismissSingleGuildBuild",{x = serverData.x,y = serverData.y},resultHandler)
        end
        g_msgBox.show(g_tr("allianceBuildDestroyTip"),nil,3,function(event)
            if event == 0 then
                doDelete()
            end
        end,1)
                
    end
    
    local btnDismiss = baseNode:getChildByName("btn_save")
    btnDismiss:getChildByName("Text"):setString(g_tr("allianceBuildDestroy")) --拆除
    btnDismiss:addClickEventListener(dismissHandler)
    btnDismiss:setEnabled(myInfo and myInfo.rank >= 4)
    
    local currentBuildPlayerCnt = 0
    local players = {}
    local resultHandler = function(result, msgData)
      if result then
          print("viewGuildBuildDetail success")
          dump(msgData)
          players = msgData
          currentBuildPlayerCnt = #msgData
      end
    end
    g_sgHttp.postData("guild/viewGuildBuildDetail",{x = serverData.x,y = serverData.y},resultHandler)
    
    local selfHaveJoined = false
    for key, var in pairs(players) do
    	if var.player_id == g_PlayerMode.GetData().id then
    	   selfHaveJoined = true
    	   break
    	end
    end
    
    local maxSize = mapBuildInfo.max_construction
    
    buildInfoNode:getChildByName("text_tips"):setTextColor(g_Consts.ColorType.Red)
    
    local listView = baseNode:getChildByName("ListView_1")
    
    if mapBuildInfo.alliance_type == 1 then --联盟堡垒
        --建筑防御值
        buildInfoNode:getChildByName("text_property_name1"):setString(g_tr("maxDefenseValue"))--建筑防御值
        local defenseValue = mapBuildInfo.starting_num
        -- 重置为服务器数据 当前防御值
        defenseValue = serverData.durability
        
        buildInfoNode:getChildByName("text_property_value1")
        :setString(string.formatnumberthousands(defenseValue).."/"..string.formatnumberthousands(serverData.max_durability))
        
        
        --驻防部队数
        local isDefing = false --建筑是否是驻守状态
        local statusStr = g_tr("allianceBuildUnJoined")
        local playerActionName = ""
        local addTip = ""
        if serverData.status == require("game.maplayer.worldMapLayer_helper").m_MapBuildStatus.build then
            playerActionName = g_tr("allianceBuildConstructionNum")
            statusStr = g_tr("allianceBuildConstructing")
            if selfHaveJoined == false then
                statusStr = g_tr("allianceBuildCanConstruct")
            end
            maxSize = mapBuildInfo.max_construction
            addTip = g_tr("allianceBuildConstructJoinNow")
        else
            if serverData.durability < serverData.max_durability then
                playerActionName = g_tr("allianceBuildRepaireNum")
                statusStr = g_tr("allianceBuildRepairing")
                 if selfHaveJoined == false then
                    statusStr = g_tr("allianceBuildCanRepaire")
                end
                maxSize = mapBuildInfo.max_construction
                addTip = g_tr("allianceBuildRepaireJoinNow")
            else
                playerActionName = g_tr("garrisonTroops")--驻防部队数
                statusStr = g_tr("allianceBuildGarrisoning")
                if selfHaveJoined == false then
                    statusStr = g_tr("allianceBuildUnJoined")
                end
                maxSize = mapBuildInfo.max_stationed
                addTip = g_tr("allianceBuildGarrisonJoinNow")
                isDefing = true
            end
        end
        
        buildInfoNode:getChildByName("text_property_name3"):setString(playerActionName)
        buildInfoNode:getChildByName("text_tips"):setString(statusStr)
        
        --重置为服务器数据 当前驻防数量
        local garrisonValue = currentBuildPlayerCnt
        buildInfoNode:getChildByName("text_property_value3")
        :setString(string.formatnumberthousands(garrisonValue).."/"..string.formatnumberthousands(mapBuildInfo.max_stationed))
        
        if #players > 0 then
            local listItem = cc.CSLoader:createNode("alliance_building_defense_list_1.csb")
            --listSize = listItem:getChildByName("scale_node"):getContentSize()
            for key, var in ipairs(players) do
            	local item = listItem:clone()
            	self:updateBuildOrGarrisonListItem(item,var,isDefing)
            	listView:pushBackCustomItem(item)
            end
        end
        
        local remainSize = maxSize - #players
        if remainSize > 0 then
            local listItem = cc.CSLoader:createNode("alliance_building_defense_list_4.csb")
            listItem:getChildByName("army_item"):getChildByName("text_tips"):setString(addTip)
            for i = 1, remainSize do
                local item = listItem:clone()
            	listView:pushBackCustomItem(item)
            	item:setTouchEnabled(true)
            	item:addClickEventListener(function(sender)
            	   local buildServerData = serverData
            	   self:onClick_107(buildServerData)
            	   --require("game.maplayer.worldMapLayer_smallMenuClick").onClick_107(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
            	end)
            end
        end
        
    elseif mapBuildInfo.alliance_type == 2 then --联盟箭塔
        --建筑防御值
        buildInfoNode:getChildByName("text_property_name1"):setString(g_tr("maxDefenseValue"))--建筑防御值
        local defenseValue = mapBuildInfo.starting_num
        --重置为服务器数据 当前防御值
        defenseValue = serverData.durability
        
        buildInfoNode:getChildByName("text_property_value1")
        :setString(string.formatnumberthousands(defenseValue).."/"..string.formatnumberthousands(serverData.max_durability))
        
        
        --消灭敌军数量
        buildInfoNode:getChildByName("text_property_name3"):setString("")--驻防部队数
        --TODO:重置为服务器数据 消灭敌军数量
        local value = 0
        buildInfoNode:getChildByName("text_property_value3")
        :setString(--[[string.formatnumberthousands(value)]]"")
        
        
        --驻防部队数
        local statusStr = ""
        local addTip = ""
        local playerActionName = ""
        if serverData.status == require("game.maplayer.worldMapLayer_helper").m_MapBuildStatus.build then
            playerActionName = g_tr("allianceBuildConstructionNum")
            statusStr = g_tr("allianceBuildConstructing")
            if selfHaveJoined == false then
                statusStr = g_tr("allianceBuildCanConstruct")
            end
            maxSize = mapBuildInfo.max_construction
            addTip = g_tr("allianceBuildConstructJoinNow")
        else
            if serverData.durability < serverData.max_durability then
                playerActionName = g_tr("allianceBuildRepaireNum")
                statusStr = g_tr("allianceBuildRepairing")
                 if selfHaveJoined == false then
                    statusStr = g_tr("allianceBuildCanRepaire")
                end
                maxSize = mapBuildInfo.max_construction
                addTip = g_tr("allianceBuildRepaireJoinNow")
            else
                statusStr = g_tr("allianceBuildDefing")
            end
        end
        buildInfoNode:getChildByName("text_property_name3"):setString(playerActionName)
        buildInfoNode:getChildByName("text_tips"):setString(statusStr)
        
        if playerActionName ~= "" then
            buildInfoNode:getChildByName("text_property_value3")
            :setString(string.formatnumberthousands(#players))
        end
        
        if #players > 0 and addTip ~= "" then
            local listItem = cc.CSLoader:createNode("alliance_building_defense_list_1.csb")
            --listSize = listItem:getChildByName("scale_node"):getContentSize()
            for key, var in ipairs(players) do
                local item = listItem:clone()
                self:updateBuildOrGarrisonListItem(item,var)
                listView:pushBackCustomItem(item)
            end
        end
        
        local remainSize = maxSize - #players
        if remainSize > 0 and addTip ~= "" then
            local listItem = cc.CSLoader:createNode("alliance_building_defense_list_4.csb")
            listItem:getChildByName("army_item"):getChildByName("text_tips"):setString(addTip)
            for i = 1, remainSize do
                local item = listItem:clone()
                listView:pushBackCustomItem(item)
                item:setTouchEnabled(true)
                item:addClickEventListener(function(sender)
                   local buildServerData = serverData
                   self:onClick_107(buildServerData)
                   --require("game.maplayer.worldMapLayer_smallMenuClick").onClick_107(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
                end)
            end
        end
        
    elseif mapBuildInfo.alliance_type == 3 then --联盟矿产
        local statusStr = ""
        local playerActionName = ""
        local addTip = ""
        if serverData.status == require("game.maplayer.worldMapLayer_helper").m_MapBuildStatus.build then
            playerActionName = g_tr("allianceBuildConstructionNum")
            statusStr = g_tr("allianceBuildConstructing")
            if selfHaveJoined == false then
                statusStr = g_tr("allianceBuildCanConstruct")
            end
            maxSize = mapBuildInfo.max_construction
            addTip = g_tr("allianceBuildConstructJoinNow")
            --建筑防御值
            buildInfoNode:getChildByName("text_property_name1"):setString(g_tr("maxDefenseValue"))--建筑防御值
            local defenseValue = mapBuildInfo.starting_num
            --重置为服务器数据 当前防御值
            defenseValue = serverData.durability
            
            buildInfoNode:getChildByName("text_property_value1")
            :setString(string.formatnumberthousands(defenseValue).."/"..string.formatnumberthousands(serverData.max_durability))
            buildInfoNode:getChildByName("text_property_name3"):setString(playerActionName)
        else
            
            if serverData.durability < serverData.max_durability then
                playerActionName = g_tr("allianceBuildRepaireNum")
                statusStr = g_tr("allianceBuildRepairing")
                if selfHaveJoined == false then
                    statusStr = g_tr("allianceBuildCanRepaire")
                end
                addTip = g_tr("allianceBuildRepaireJoinNow")
                maxSize = mapBuildInfo.max_construction
                --建筑防御值
                buildInfoNode:getChildByName("text_property_name1"):setString(g_tr("maxDefenseValue"))--建筑防御值
                local defenseValue = mapBuildInfo.starting_num
                --重置为服务器数据 当前防御值
                defenseValue = serverData.durability
                
                buildInfoNode:getChildByName("text_property_value1")
                :setString(string.formatnumberthousands(defenseValue).."/"..string.formatnumberthousands(serverData.max_durability))
                buildInfoNode:getChildByName("text_property_name3"):setString(playerActionName)

            else
                --剩余资源
                buildInfoNode:getChildByName("text_property_name1"):setString(g_tr("residualResources"))--剩余资源
                
                --根据策划需求 联盟矿的容量是无限的
                --[[local currentResources = 0
                --重置为服务器数据 已采集的资源
                currentResources = serverData.resource
                buildInfoNode:getChildByName("text_property_value1")
                :setString(string.formatnumberthousands(mapBuildInfo.max_res - currentResources))
                ]]
                
                buildInfoNode:getChildByName("text_property_value1")
                :setString(g_tr("allianceBuildResourceINFINITI"))
                
                statusStr = g_tr("allianceBuildCollecting")
                if selfHaveJoined == false then
                    statusStr = g_tr("allianceBuildCanCollect")
                end
            end
        end
        
        if playerActionName ~= "" then
            buildInfoNode:getChildByName("text_property_value3")
            :setString(string.formatnumberthousands(#players))
        end
        
        buildInfoNode:getChildByName("text_tips"):setString(statusStr)
        if #players > 0 then
        
            local listItem = cc.CSLoader:createNode("alliance_building_defense_list_1.csb")
            --listSize = listItem:getChildByName("scale_node"):getContentSize()
            for key, var in ipairs(players) do
                local item = listItem:clone()
                self:updateBuildOrGarrisonListItem(item,var)
                listView:pushBackCustomItem(item)
            end
        end
    
        local remainSize = maxSize - #players
        if remainSize > 0 and addTip ~= "" then
            local listItem = cc.CSLoader:createNode("alliance_building_defense_list_4.csb")
            listItem:getChildByName("army_item"):getChildByName("text_tips"):setString(addTip)
            for i = 1, remainSize do
                local item = listItem:clone()
                listView:pushBackCustomItem(item)
                item:setTouchEnabled(true)
                item:addClickEventListener(function(sender)
                   local buildServerData = serverData
                   self:onClick_107(buildServerData)
                   --require("game.maplayer.worldMapLayer_smallMenuClick").onClick_107(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
                end)
            end
        end
        
        local queneData = isHaveSelfQueueDoing(serverData,QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_ING)
        if queneData then
            dump(queneData)
            if queneData.end_time - g_clock.getCurServerTime() <= 0 then
                return
            end
            
            buildInfoNode:getChildByName("text_property_name3"):setString(g_tr("allianceManorCollectSpeed"))
            buildInfoNode:getChildByName("text_property_value3")
            :setString(string.formatnumberthousands(math.floor(queneData.target_info.speed * 60)).. "/h")
            
            buildInfoNode:getChildByName("text_property_name2"):setString(g_tr("allianceManorCollected"))
            local showLabel = buildInfoNode:getChildByName("text_property_value2")
            local updateShow = function()
                 showLabel:setString(string.formatnumberthousands(math.floor((queneData.target_info.speed/60) * (g_clock.getCurServerTime() - queneData.create_time))).. "")
            end
            local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateShow))
            local action = cc.RepeatForever:create(seq)
            showLabel:runAction(action)
            updateShow()
        
        end
        
    elseif mapBuildInfo.alliance_type == 4 then --联盟仓库
        local guildInfo = {}
        local serverResourceKeys =  {
            "store_gold",
            "store_food",
            "store_wood",
            "store_stone",
            "store_iron",
        }
        
        --请求已经存储的资源信息
        local totalSavedResource = 0
        local function onRecv(result, msgData)
          if(result==true)then
              --dump(msgData)
              guildInfo = msgData.PlayerGuild
          end
        end
        g_sgHttp.postData("data/index",{name = {"PlayerGuild",}},onRecv)

        for i = 1, #serverResourceKeys do
        	totalSavedResource = allianceManorHelper.convertToWarehouseSize(i,guildInfo[serverResourceKeys[i]]) + totalSavedResource
        end
        
        
        -------------------------
        --
        --建筑防御值
        buildInfoNode:getChildByName("text_property_name1"):setString(g_tr("maxDefenseValue"))--建筑防御值
        local defenseValue = mapBuildInfo.starting_num
        -- 重置为服务器数据 当前防御值
        defenseValue = serverData.durability
        
        buildInfoNode:getChildByName("text_property_value1")
        :setString(string.formatnumberthousands(defenseValue).."/"..string.formatnumberthousands(serverData.max_durability))
        
        --驻防部队数
        local statusStr = g_tr("allianceBuildUnJoined")
        local playerActionName = ""
        local addTip = ""
        if serverData.status == require("game.maplayer.worldMapLayer_helper").m_MapBuildStatus.build then
            playerActionName = g_tr("allianceBuildConstructionNum")
            statusStr = g_tr("allianceBuildConstructing")
            if selfHaveJoined == false then
                statusStr = g_tr("allianceBuildCanConstruct")
            end
            maxSize = mapBuildInfo.max_construction
            addTip = g_tr("allianceBuildConstructJoinNow")
            
            buildInfoNode:getChildByName("text_property_name3"):setString(playerActionName)
            buildInfoNode:getChildByName("text_tips"):setString(statusStr)
            
            --重置为服务器数据 当前驻防数量
            local garrisonValue = currentBuildPlayerCnt
            buildInfoNode:getChildByName("text_property_value3")
            :setString(string.formatnumberthousands(garrisonValue).."/"..string.formatnumberthousands(maxSize))
            
            if #players > 0 then
                local listItem = cc.CSLoader:createNode("alliance_building_defense_list_1.csb")
                --listSize = listItem:getChildByName("scale_node"):getContentSize()
                for key, var in ipairs(players) do
                    local item = listItem:clone()
                    self:updateBuildOrGarrisonListItem(item,var)
                    listView:pushBackCustomItem(item)
                end
            end
            
            local remainSize = maxSize - #players
            if remainSize > 0 then
                local listItem = cc.CSLoader:createNode("alliance_building_defense_list_4.csb")
                listItem:getChildByName("army_item"):getChildByName("text_tips"):setString(addTip)
                for i = 1, remainSize do
                    local item = listItem:clone()
                    listView:pushBackCustomItem(item)
                    item:setTouchEnabled(true)
                    item:addClickEventListener(function(sender)
                       local buildServerData = serverData
                       self:onClick_107(buildServerData)
                       --require("game.maplayer.worldMapLayer_smallMenuClick").onClick_107(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
                    end)
                end
            end
        else
            if serverData.durability < serverData.max_durability then
                playerActionName = g_tr("allianceBuildRepaireNum")
                statusStr = g_tr("allianceBuildRepairing")
                 if selfHaveJoined == false then
                    statusStr = g_tr("allianceBuildCanRepaire")
                end
                maxSize = mapBuildInfo.max_construction
                addTip = g_tr("allianceBuildRepaireJoinNow")
            else
                playerActionName = g_tr("garrisonTroops")--驻防部队数
                statusStr = g_tr("allianceBuildGarrisoning")
                if selfHaveJoined == false then
                    statusStr = g_tr("allianceBuildUnJoined")
                end
                maxSize = mapBuildInfo.max_stationed
                addTip = g_tr("allianceBuildGarrisonJoinNow")
                
                
                --startbegan
                                
                --资源容量
                buildInfoNode:getChildByName("text_property_name3"):setString(g_tr("totalResourcesCapacity"))--资源容量
        
                buildInfoNode:getChildByName("text_property_value3")
                :setString(string.formatnumberthousands(totalSavedResource))
                
                --建筑状态
                local statusStr = ""
                if serverData.status == require("game.maplayer.worldMapLayer_helper").m_MapBuildStatus.build then
                    statusStr = g_tr("allianceBuildConstructing") --建造中
                    if selfHaveJoined == false then
                        statusStr = g_tr("allianceBuildCanConstruct") --可建造
                    end
                else
                    if serverData.durability < serverData.max_durability then
                        statusStr = g_tr("allianceBuildRepairing") --修理中
                         if selfHaveJoined == false then
                            statusStr = g_tr("allianceBuildCanRepaire") --可修理
                        end
                    else
                        statusStr = g_tr("allianceBuildStoreing") --存储中
                    end
                end
                
                buildInfoNode:getChildByName("text_tips"):setString(statusStr)
                
                --startend
            end
        end
        
        
        ------------------

    end
    
    local isBuildingOrRepairing = false
    if serverData.status == require("game.maplayer.worldMapLayer_helper").m_MapBuildStatus.build then
        isBuildingOrRepairing = true
    else
        if serverData.durability < serverData.max_durability then
            isBuildingOrRepairing = true
        end
    end
    
    --增长
    if isBuildingOrRepairing then
        local finishTime = require ("game.maplayer.worldMapLayer_queueHelper").getBuildOrRepairTime(serverData.x, serverData.y, serverData.map_element_origin_id)
        
        if not finishTime then
            return
        end
        
        --local needTime = finishTime - g_clock.getCurServerTime()
        local needTime = finishTime - serverData.build_time
        if needTime <= 0 or serverData.durability >= serverData.max_durability or #players <= 0 then
            return
        end
        
        local secondStep = (serverData.max_durability - serverData.durability )/needTime
        
        local durability = serverData.durability + (g_clock.getCurServerTime() - serverData.build_time)*secondStep
        
        local showLabel = buildInfoNode:getChildByName("text_property_value3")
        local updateShow = function()
              durability = durability + secondStep
              print("durability:",durability)
              if durability >= serverData.max_durability then
                  durability = serverData.max_durability
                  showLabel:stopAllActions()
              end
              
              buildInfoNode:getChildByName("text_property_value1")
              :setString(string.formatnumberthousands(math.floor(durability)).."/"..string.formatnumberthousands(serverData.max_durability))
        end
        local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateShow))
        local action = cc.RepeatForever:create(seq)
        showLabel:runAction(action)
        updateShow()
    end
    
    
end

function AllianceManorInfoLayer:onClick_107(buildServerData)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    require("game.uilayer.battleSet.battleManager").gotoBuildGuild({ buildServerData = buildServerData })
    --[[local function callback(ArmyID,PlaySound,isUseMove)
        --选择军团建造联盟建筑
        local function onRecv(result, msgData)
            if(result==true)then
                require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                if PlaySound then
                    PlaySound()
                end
                self:removeFromParent()
            end
        end
        g_sgHttp.postData("Guild/gotoGuildBuild",{ x = buildServerData.x , y = buildServerData.y , army_id = ArmyID , useMove = isUseMove},onRecv)
    
    end
    local setLayer = require("game.uilayer.battleSet.battleSettingView")
    setLayer:createLayer(callback,{ x = buildServerData.x , y = buildServerData.y},g_Consts.FightType.Expedition)]]
end

local orginalPosList =  nil
function AllianceManorInfoLayer:updateBuildOrGarrisonListItem(item,data,isDefing)

    if isDefing == nil then
        isDefing = false
    end
    
    local army_item = item:getChildByName("army_item")
    army_item:getChildByName("Button_1"):setVisible(false)
    army_item:getChildByName("label_soldier"):setString(g_tr("allianceBuildSoldierNum"))
    
    
    local targetPlayerRank = data.rank
    
    if isDefing == true and g_AllianceMode.isAllianceManager() then
        army_item:getChildByName("Button_1"):setVisible(true)
    
        local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
        local myRank = myInfo.rank
        
        if targetPlayerRank >= myRank then
            army_item:getChildByName("Button_1"):setVisible(false)
        end
    end
    
    if army_item:getChildByName("Button_1"):isVisible() then
        army_item:getChildByName("Button_1"):addClickEventListener(function(sender)
            
            local doDelete = function()
                
                local resultHandler = function(result, msgData)
                  if result then
                     item:removeFromParent()
                  end
                end
                g_sgHttp.postData("guild/kickDefendArmyFromGuildBase",{ppq_id = data.ppq_id},resultHandler)
            
            end
            
            g_msgBox.show(g_tr("guildBuildArmyFireTip"),nil,nil,function(event)
                if event == 0 then
                    doDelete()
                end
            end,1)
            
        end)
    end
    
    local iconId = g_data.res_head[data.avatar_id].head_icon
    army_item:getChildByName("pic_0"):loadTexture(g_resManager.getResPath(iconId))
    army_item:getChildByName("pic"):loadTexture(g_resManager.getResPath(1010007)) --boader
    
    if orginalPosList == nil then
        orginalPosList = {}
        for i = 1, 4 do
            local iconPos = army_item:getChildByName("soldier_type_"..i):getPositionX()
            local labelPos = army_item:getChildByName("num_soldier_"..i):getPositionX()
            orginalPosList[i] = {}
            orginalPosList[i].iconX = iconPos
            orginalPosList[i].labelX = labelPos
        end
    end
    
    local soldierTypes = {}
    for i = 1, 4 do
    	army_item:getChildByName("soldier_type_"..i):setVisible(false)
        army_item:getChildByName("num_soldier_"..i):setVisible(false)
        soldierTypes[i] = 0
    end
    
    for i = 1, #data.army do
        local armyData = data.army[i]
        print("soldier_id:",armyData.soldier_id)
        local soldierInfo = g_data.soldier[armyData.soldier_id]
        if soldierInfo then
            soldierTypes[soldierInfo.soldier_type] = soldierTypes[soldierInfo.soldier_type] + armyData.soldier_num
    	end
    end
    
    local idx = 1
    for i = 1, 4 do
        if soldierTypes[i] > 0 then
            army_item:getChildByName("soldier_type_"..i):setVisible(true)
            army_item:getChildByName("num_soldier_"..i):setVisible(true)
            army_item:getChildByName("soldier_type_"..i):loadTexture(g_resManager.getResPath(1002003 + (i-1)))
            army_item:getChildByName("num_soldier_"..i):setString(soldierTypes[i].."")
            
            army_item:getChildByName("soldier_type_"..i):setPositionX(orginalPosList[idx].iconX)
            army_item:getChildByName("num_soldier_"..i):setPositionX(orginalPosList[idx].labelX)
            
            idx = idx + 1
        end
    end
    
    army_item:getChildByName("name"):setString(data.player_nick)
    army_item:getChildByName("label_battle"):setString(g_tr("allianceBuildSoldierPower"))
    army_item:getChildByName("num_battle"):setString(data.total_power.."")
    army_item:getChildByName("label_general"):setString(g_tr("allianceBuildSoldierArmy"))
    army_item:getChildByName("num_current"):setString(data.total_soldier_num.."")
end

return AllianceManorInfoLayer