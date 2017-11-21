local BuildingUpgradeLayer = class("BuildingUpgradeLayer",function()
  return cc.Layer:create()
end)

local baseNode = nil
local m_callbacks = {
    ["onStart"] = nil,
    ["onCancle"] = nil,
    ["onMoveCancle"] = nil,
    ["onFastDone"] = nil,
    ["onClose"] = nil
}
function BuildingUpgradeLayer:ctor(buildingId,callbacks,isUpgrade,serverData)
    
    m_callbacks = callbacks
    if isUpgrade == nil then
        isUpgrade = true
    end
    
    --建造
    if not isUpgrade then
       local buildInfo = g_data.build[buildingId]
       if buildInfo.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.gold
       or buildInfo.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.wood
       or buildInfo.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.food
       or buildInfo.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.stone
       or buildInfo.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.iron
       then
           local mainCityLv = g_PlayerBuildMode.getMainCityBuilding_lv()
           for key , var in pairs(g_data.build) do
            if(var.origin_build_id == buildInfo.origin_build_id and var.build_level == mainCityLv)then
              buildingId = var.id
              break
            end
          end
       end
    end
    
    self._isUpgrade = isUpgrade
    self._serverData = serverData or {}
    self.callbacks = m_callbacks
    
    --load cocos studio ui
    local node = g_gameTools.LoadCocosUI("building_upgrade_main.csb",5)
    self:addChild(node)
    g_resourcesInterface.installResources(node)
    baseNode = node:getChildByName("scale_node")
    
    baseNode:getChildByName("Button_cancle"):setVisible(false)
    
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          g_guideManager.execute()
      elseif eventType == "exit" then
      end 
    end )
    
    
    local checkFreeQueue = function()
        local isFreeQueueEnabled = true
        local freeBuild = g_PlayerBuildMode.FindBuild_InFree()
        local currentTime = g_clock.getCurServerTime()
        if freeBuild ~= nil and freeBuild.build_finish_time - currentTime > 0 then
            isFreeQueueEnabled = false
        end
        
        return isFreeQueueEnabled
    end
    
    --判断收费队列是否可用
--    local checkChargeQueue = function()
--        local isChargeEnabled = true
--        local isHaveBuyQueue = false
--        local timeRemain = require("game.uilayer.mainSurface.mainSurfaceQueue").chargeQueueResidualTime() - self._buildInfo.construction_time --收费队列剩余时间
--        if timeRemain <= 0 then --如果收费队列没有购买或失效
--            isChargeEnabled = false
--        else
--            isHaveBuyQueue = true
--            local build = g_PlayerBuildMode.FindBuild_InCharge() --如果收费队列有建筑正在使用
--            local currentTime = g_clock.getCurServerTime()
--            if build ~= nil and build.build_finish_time - currentTime > 0 then
--                isChargeEnabled = false
--            end
--        end
--        return isChargeEnabled,isHaveBuyQueue
--    end
    
    --reset ui text
    local fastDoneBtn = baseNode:getChildByName("Panel_9"):getChildByName("Button_6_0_0_0")
    fastDoneBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local doHandler = function()
                self:removeFromParent(true)
                if m_callbacks.onFastDone then
                    m_callbacks.onFastDone()
                end
            end
            local text = g_tr("fastUpgradeBuildTip",{build_name = g_tr(self._buildInfo.build_name)})
            local buttonText = g_tr("fastLvUp")
            local title = nil
            if not isUpgrade then
                text = g_tr("fastCreateBuildTip",{build_name = g_tr(self._buildInfo.build_name)})
                buttonText = g_tr("fastBuild")
                title = nil
            end
            
            local doStartHandler = function()
                g_msgBox.showConsume(self._buildInfo.gem_cost, text, title, buttonText,doHandler)
            end
            
            local mbuildInfo = g_PlayerBuildMode.FindBuildConfig_lv_Next_ConfigID(buildingId)
            if mbuildInfo 
            and mbuildInfo.origin_build_id == 1
            and mbuildInfo.build_level >= tonumber(g_data.starting[54].data)
            and g_PlayerMode.hasNewPlayerAvoid() then --新手保护期间
                g_msgBox.show(g_tr("protectBrokenTip"),nil,nil,function(event)
                    if event == 0 then
                        doStartHandler()
                    end
                end,1)
            else
                doStartHandler()
            end
            
            
        end
    end)
    
    local startBuildBtn = baseNode:getChildByName("Panel_9_0"):getChildByName("Button_6_0_0_0")
    startBuildBtn:getChildByName("Text_26_0")
    :setString(g_tr("startBuild"))  --开始建造
    
    g_guideManager.registComponent(1000102,startBuildBtn)
    
    startBuildBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            
            local isChargeEnabled,isHaveBuyQueue = require("game.uilayer.buildupgrade.BuildingUIHelper").checkChargeQueue(self._buildInfo,self._serverData)
            if isChargeEnabled or checkFreeQueue() then
                g_musicManager.playEffect(g_data.sounds[5000035].sounds_path)
                
                local doStartHandler = function()
                    self:removeFromParent(true)
                    if m_callbacks.onStart then
                        m_callbacks.onStart()
                    end
                end
                
                local mbuildInfo = g_PlayerBuildMode.FindBuildConfig_lv_Next_ConfigID(buildingId)
                if mbuildInfo 
                and mbuildInfo.origin_build_id == 1
                and mbuildInfo.build_level >= tonumber(g_data.starting[54].data)
                and g_PlayerMode.hasNewPlayerAvoid() then --新手保护期间
                    g_msgBox.show(g_tr("protectBrokenTip"),nil,nil,function(event)
                        if event == 0 then
                            doStartHandler()
                        end
                    end,1)
                else
                    doStartHandler()
                end
            else
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if not isHaveBuyQueue then
                    local needTime = self._buildInfo.construction_time
                    needTime = require("game.uilayer.buildupgrade.BuildingUIHelper").calculateCostTime(needTime,self._serverData.position)
                    local buySuccessHandler = function()
                        g_airBox.show(g_tr("buyQueueSuccess"))
                        self:updateView()
                    end
                    if needTime > 0 then
                        require("game.uilayer.mainSurface.mainSurfaceQueue").showBuyInterface_with_needTime(needTime,buySuccessHandler)
                    else
                        require("game.uilayer.mainSurface.mainSurfaceQueue").showBuyInterface_with_needCount(1,buySuccessHandler)
                    end
                    
                else
                    g_airBox.show(g_tr("queueMax"))
                end
            end
        end
    end)
    
    if isUpgrade then
        baseNode:getChildByName("Panel_9_0"):getChildByName("Button_6_0_0_0"):getChildByName("Text_26_0")
        :setString(g_tr("startLvUp"))  --开始升级
        fastDoneBtn:getChildByName("Text_26_0")
        :setString(g_tr("fastLvUp"))--立刻升级
    else
        baseNode:getChildByName("Panel_9"):setVisible(false)
        baseNode:getChildByName("Panel_9_0"):setPositionX(baseNode:getChildByName("Panel_9_0"):getPositionX() - 300)
        fastDoneBtn:getChildByName("Text_26_0")
        :setString(g_tr("fastBuild"))--立刻建造
    end
    
    baseNode:getChildByName("Button_6_0_0"):setVisible(false)
     
    local btnClose = baseNode:getChildByName("Button_xhao")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent(true)
            if m_callbacks.onCancle then
                m_callbacks.onCancle()
            end
        end
    end)
    
    local scrolleView = baseNode:getChildByName("ScrollView_1")
    scrolleView.viewSize = scrolleView:getContentSize()
    self:changeBuilding(buildingId)
    
end

function BuildingUpgradeLayer:updateView()
    self:changeBuilding(self._buildingId)
end



function BuildingUpgradeLayer:changeBuilding(buildingId)
    local buildInfo = g_data.build[buildingId]
    assert(buildInfo,"cannot found build with id:"..buildingId)
    self._buildingId = buildingId
    
    baseNode:getChildByName("Text_1_1"):setString(g_tr(buildInfo.build_name))
    baseNode:getChildByName("Text_1_2"):setString(g_tr(buildInfo.build_name))
    
    if self._isUpgrade then
        --showNextLevelInfo
        buildInfo = g_PlayerBuildMode.FindBuildConfig_lv_Next_ConfigID(self._serverData.build_id)
        if buildInfo == nil then
            return
        end
    end
    self._buildInfo = buildInfo
     
    --local listView = self._listView
    --listView:removeAllItems()
    
    --buildInfo.serverData = self._serverData

    
    
    local currentLevelStr = ""
    local lvStr = ""
    
    if self._isUpgrade then
        lvStr = "Lv"..(buildInfo.build_level - 1)
        currentLevelStr = g_tr("currentLevel")
    else
        --lvStr = "Lv"..buildInfo.build_level
    end
    
    baseNode:getChildByName("Panel_2"):getChildByName("Text_1"):setString(currentLevelStr)
    baseNode:getChildByName("Panel_2"):getChildByName("Text_1_0"):setString(lvStr)
    baseNode:getChildByName("Panel_2"):setVisible(not self._isUpgrade)
    
    baseNode:getChildByName("Panel_2_0"):setVisible(self._isUpgrade)
    baseNode:getChildByName("Panel_2_0"):getChildByName("Text_1"):setString(g_tr("currentLevel"))
    baseNode:getChildByName("Panel_2_0"):getChildByName("Text_1_0"):setString(lvStr)
    baseNode:getChildByName("Panel_2_0"):getChildByName("Text_2"):setString(g_tr("nextLevel"))
    baseNode:getChildByName("Panel_2_0"):getChildByName("Text_2_0"):setString("Lv"..buildInfo.build_level)
    

    --建筑图标显示
    --baseNode:getChildByName("Image_9"):loadTexture(g_resManager.getResPath(buildInfo.img))
    local icon = g_resManager.getRes(buildInfo.img)
    if icon then
        baseNode:getChildByName("Image_9"):getParent():addChild(icon)
        icon:setPosition(baseNode:getChildByName("Image_9"):getPosition())
        local size = baseNode:getChildByName("Image_9"):getContentSize()
        if icon:getContentSize().width > size.width then
            local scale = (size.width - 30)/icon:getContentSize().width
            icon:setScale(scale)
        end
    end
    baseNode:getChildByName("Image_9"):setVisible(false)
    
    --详细信息
    local scrolleView = baseNode:getChildByName("ScrollView_1")
    scrolleView:removeAllChildren(true)
    scrolleView:setTouchEnabled(true)
    
    local jumpToHandler = function(buildid)
        if m_callbacks.onMoveCancle then
            m_callbacks.onMoveCancle(buildid)
            self:removeFromParent()
        end
    end
    
    local con,isMatch,isResourceEnough,isQueueMatch = require("game.uilayer.buildupgrade.BuildingUIHelper").createInfoPanle(g_data.build[buildingId],jumpToHandler,self,self._isUpgrade)
    scrolleView:addChild(con)
    
    local startBuildBtn = baseNode:getChildByName("Panel_9_0"):getChildByName("Button_6_0_0_0")
    local fastDoneBtn = baseNode:getChildByName("Panel_9"):getChildByName("Button_6_0_0_0")
    startBuildBtn:setEnabled(isMatch and isResourceEnough)
    fastDoneBtn:setEnabled(isMatch)
    
    local innerHeight = con:getContentSize().height
    if innerHeight > 0 then
        scrolleView:setInnerContainerSize(cc.size(scrolleView.viewSize.width,innerHeight))
        if innerHeight < scrolleView.viewSize.height then
           scrolleView:getInnerContainer():setPositionY(scrolleView.viewSize.height - innerHeight)
           scrolleView:setTouchEnabled(false)
        end
    end
    
    --快速完成元宝显示
    local _,iconPath = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)
    baseNode:getChildByName("Panel_9"):getChildByName("Image_61"):loadTexture(iconPath)
    baseNode:getChildByName("Panel_9"):getChildByName("Text_63")
    :setString(tostring(buildInfo.gem_cost))

    --花费时间显示
    local costTime = buildInfo.construction_time
    costTime = require("game.uilayer.buildupgrade.BuildingUIHelper").calculateCostTime(costTime,self._serverData.position)
    
    --建造不需要花费时间
    if not self._isUpgrade then
      costTime = 0
    end
    
    baseNode:getChildByName("Panel_9_0"):getChildByName("Text_63")
    :setString(g_gameTools.convertSecondToString(costTime))
    
end


return BuildingUpgradeLayer