local BuildingInformationLayer = class("BuildingInformationLayer",function()
  return cc.Layer:create()
end)

local baseNode = nil
local buildDescLabel = nil
local infoContainer = nil
function BuildingInformationLayer:ctor(buildingId,serverData)
    dump(serverData)
    
    self._serverData = serverData
    
    --load cocos studio ui
    local node = g_gameTools.LoadCocosUI("building_upgrade_main.csb",5)
    self:addChild(node)
    g_resourcesInterface.installResources(node)
    baseNode = node:getChildByName("scale_node")
    
    baseNode:getChildByName("Panel_9")
    :setVisible(false)
    
    baseNode:getChildByName("Panel_9_0")
    :setVisible(false)
    
    baseNode:getChildByName("Button_6_0_0"):getChildByName("Text_26_0")
    :setString(g_tr("detailInfo")) --更多信息
    
    local btnMore = baseNode:getChildByName("Button_6_0_0")
    btnMore:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("more info")
            local detailLayer = require("game.uilayer.buildupgrade.BuildingDetailListLayer"):create(buildingId)
            g_sceneManager.addNodeForUI(detailLayer)
        end
    end)
    
    local btnCancle = baseNode:getChildByName("Button_cancle")
    btnCancle:setVisible(false)
    btnCancle:getChildByName("Text_26_0"):setString(g_tr("cancleUpgrade")) --取消升级
    btnCancle:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("cancle")
            local alertCallBack =  function(event)
              if event == 0 then
                  local function onRecv(result, msgData)
                      if(result==true)then
                        g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
						require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
                        self:removeFromParent()
                      end
                  end
                  g_sgHttp.postData("build/cancel",{position = serverData.position},onRecv)
              end
            end
            g_msgBox.show(g_tr("makeSureCancleUpgradeBuild",{build_name = g_tr(self._buildInfo.build_name)}),nil,nil,alertCallBack,1)
        end
    end)
    
    if serverData.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng then --升级中
        btnCancle:setVisible(true)
        btnMore:setPositionX(btnMore:getPositionX() + 130)
    end
    
    local btnClose = baseNode:getChildByName("Button_xhao")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent(true)
        end
    end)
    
    local scrolleView = baseNode:getChildByName("ScrollView_1")
    scrolleView.viewSize = scrolleView:getContentSize()

    infoContainer = cc.Node:create()
    scrolleView:addChild(infoContainer)
    
    self:changeBuilding(buildingId)
end

function BuildingInformationLayer:changeBuilding(buildingId)
    local buildInfo = g_data.build[buildingId]
    assert(buildInfo,"cannot found build with id:"..buildingId)
    
    self._buildInfo = buildInfo
    
    infoContainer:removeAllChildren()
    
    local infoPanel = cc.CSLoader:createNode("building_infomation_panel.csb")
    --infoPanel:setPositionY(info:getContentSize().height + 10)
    infoContainer:addChild(infoPanel)
    
    local buildingName = g_tr(buildInfo.build_name)
    baseNode:getChildByName("Text_1_1"):setString(buildingName)
    baseNode:getChildByName("Text_1_2"):setString(g_tr(buildInfo.build_name))
    
    local buildInfoWithServerData = clone(buildInfo)
    buildInfoWithServerData.serverData = self._serverData
    
    local info = require("game.uilayer.buildupgrade.BuildingUIHelper").createInfoPanle(buildInfoWithServerData)
    info:setPositionY(infoPanel:getChildByName("scale_node"):getContentSize().height + 10)
    infoContainer:addChild(info)
    
    baseNode:getChildByName("Panel_2_0"):setVisible(false)
    
    baseNode:getChildByName("Panel_2"):getChildByName("Text_1"):setString(g_tr("currentLevel"))
    baseNode:getChildByName("Panel_2"):getChildByName("Text_1_0"):setString("Lv"..buildInfo.build_level)
    
    local scrolleView = baseNode:getChildByName("ScrollView_1")
    local innerHeight = info:getContentSize().height + infoPanel:getChildByName("scale_node"):getContentSize().height + 10
    if innerHeight > 0 then
        scrolleView:setInnerContainerSize(cc.size(scrolleView.viewSize.width,innerHeight))
        if innerHeight < scrolleView.viewSize.height then
           scrolleView:getInnerContainer():setPositionY(scrolleView.viewSize.height - innerHeight)
           scrolleView:setTouchEnabled(false)
        end
    end
    
    local txtScrollView = infoPanel:getChildByName("scale_node"):getChildByName("ScrollView_2")
    txtScrollView.viewSize = txtScrollView:getContentSize()
    local tmpUIText = infoPanel:getChildByName("scale_node"):getChildByName("Text_31")
    tmpUIText:setVisible(false)
    buildDescLabel = cc.Label:createWithTTF("",tmpUIText:getFontName(),tmpUIText:getFontSize(),
      cc.size(600,0))
    txtScrollView:addChild(buildDescLabel)
    buildDescLabel:setAnchorPoint(cc.p(0,0))
    self._txtScrollView = txtScrollView

    infoPanel:getChildByName("scale_node"):getChildByName("Panel_tiao1"):getChildByName("Text_1")
    :setString(buildingName)
    
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
    --baseNode:getChildByName("Image_9"):loadTexture(g_resManager.getResPath(buildInfo.img))
   
    buildDescLabel:setString(g_tr(buildInfo.description).."\n")
    self._txtScrollView:setInnerContainerSize(buildDescLabel:getContentSize())
    local innerHeight = buildDescLabel:getContentSize().height
    if innerHeight < self._txtScrollView.viewSize.height then
        self._txtScrollView:getInnerContainer():setPositionY(self._txtScrollView.viewSize.height - innerHeight - 15)
        self._txtScrollView:setTouchEnabled(false)
    end

end

return BuildingInformationLayer