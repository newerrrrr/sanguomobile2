local ShareLayer = class("ShareLayer",function()
    return cc.Layer:create()
end)

function ShareLayer:ctor()
    local uiLayer =  cc.CSLoader:createNode("share_main.csb")
    self:addChild(uiLayer)
    self._uiLayer = uiLayer
    
--    self:registerScriptHandler(function(eventType)
--        if eventType == "enter" then
--        elseif eventType == "exit" then
--        end 
--    end )
    local dropIdArray = g_data.activity[1016].drop
    local dropGroups = g_gameTools.getDropGroupByDropIdArray(dropIdArray)
    
    local ruleStr = g_tr("shareRule")
    if tonumber(g_playerInfoData.GetData().facebook_share_count) > 0 then
        ruleStr = ruleStr..g_tr("shareDoneTip")
    end
    self._uiLayer:getChildByName("Text_2_0"):setString(ruleStr)
    self._uiLayer:getChildByName("Panel_1"):getChildByName("Text_3"):setString(g_tr("shareItemAwardTitle"))
    
    local gemCnt = 0
    local itemCnt = 0
    for key, dropGroup in pairs(dropGroups) do
    	local type = dropGroup[1]
    	local configId = dropGroup[2]
    	local cnt = dropGroup[3]
    	if configId == 10700 then
    	   gemCnt = gemCnt + cnt
    	else
    	   local itemIcon = require("game.uilayer.common.DropItemView"):create(type,configId,cnt)
    	   itemIcon:enableTip()
    	   itemIcon:setAnchorPoint(cc.p(0.5,0.5))
    	   local listView = self._uiLayer:getChildByName("Panel_1"):getChildByName("ListView_1")
    	   local size = listView:getContentSize()
    	   local iconSize = itemIcon:getContentSize()
    	   listView:setItemsMargin(2)
    	   local scale = size.height/iconSize.height
    	   
    	   local targetSize = cc.size(iconSize.width*scale,iconSize.height*scale)
    	   local con = ccui.Widget:create()
           con:setContentSize(targetSize)
           itemIcon:setPosition(cc.p(targetSize.width/2,targetSize.height/2))
    	   itemIcon:setScale(scale)
    	   con:addChild(itemIcon)
    	   
    	   listView:pushBackCustomItem(con)
    	   itemCnt = itemCnt + 1
    	end
    end
    self._uiLayer:getChildByName("BitmapFontLabel_1"):setString(gemCnt.."")
    self._uiLayer:getChildByName("Panel_1"):setVisible(itemCnt > 0)
    
    self._uiLayer:getChildByName("Button_2"):addClickEventListener(function(sender)
        
        local target = cc.Application:getInstance():getTargetPlatform() 
        if target == cc.PLATFORM_OS_WINDOWS then
            return g_airBox.show("facebook share invalid on windows")
        end
        
        local currentPackageVersion = require("src.resUpdate.UpdateMgr").getLocalPkgVersion()
        print("currentPackageVersion:",currentPackageVersion)
        
        local canShare = true
        if cc.PLATFORM_OS_ANDROID == target then
            if currentPackageVersion == "0.0.0.2" then--不包含fb分享功能的包里的版本
                canShare = false
            end
        elseif cc.PLATFORM_OS_IPHONE == target or cc.PLATFORM_OS_IPAD == target then
            if currentPackageVersion == "0.0.0.1" then--不包含fb分享功能的包里的版本
                canShare = false
            end
        end
        
        if canShare then 
            local shareResult = function(status)
                if status == "success" then
                    local function onRecv(result, msgData)
                      if result == true then
                          if tonumber(g_playerInfoData.GetData().facebook_share_count) == 1 then
                             local view = require("game.uilayer.task.TaskAwardAlertLayer").new(dropGroups)
                             g_sceneManager.addNodeForUI(view)
                             local ruleStr = g_tr("shareRule")
                             if tonumber(g_playerInfoData.GetData().facebook_share_count) > 0 then
                                ruleStr = ruleStr..g_tr("shareDoneTip")
                             end
                             self._uiLayer:getChildByName("Text_2_0"):setString(ruleStr)
                          end
                      end
                    end
                    g_sgHttp.postData("player_info/facebookShare",{},onRecv)
                end
            end
            g_sdkManager.shareToFacebook(nil,shareResult)
        else
            g_airBox.show(g_tr("shareUpdateTip"))
        end
    end)
    
    
end

return ShareLayer