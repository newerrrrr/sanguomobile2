local RedeemCodeLayer = class("RedeemCodeLayer",function()
    return cc.Layer:create()
end)

function RedeemCodeLayer:ctor()
    local uilayer = g_gameTools.LoadCocosUI("setThe_main1_RedeemCode.csb", 5)
    self:addChild(uilayer)
    
    local baseNode = uilayer:getChildByName("scale_node")
    
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    baseNode:getChildByName("text"):setString(g_tr("cdkLayerTitle"))
    baseNode:getChildByName("Text_1"):setString(g_tr("cdkLayerInputTitle"))
    baseNode:getChildByName("Button_1"):getChildByName("Text_1_0"):setString(g_tr("inputCdkMakeSure"))
    
    local editBox = g_gameTools.convertTextFieldToEditBox(baseNode:getChildByName("TextField_1"))
    baseNode:getChildByName("Button_1"):addClickEventListener(function(sender)
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local cdkStr = string.trim(editBox:getText())
        if cdkStr == "" then
            return g_airBox.show(g_tr("inputCdkTip"))
        end
        
        local function onRecv(result, msgData)
            if result == true then
                 local dropGroups = {}
                 for key, var in pairs(msgData.dropData) do
                    local dropGroup = {}
                    dropGroup[1] = var.type
                    dropGroup[2] = var.id
                    dropGroup[3] = var.num
                    table.insert(dropGroups,dropGroup)
                 end
                 
                 if #dropGroups > 0 then
                     local view = require("game.uilayer.task.TaskAwardAlertLayer").new(dropGroups)
                     g_sceneManager.addNodeForUI(view)
                 end
                 
                 g_airBox.show(g_tr("cdkGetAward"))
                 self:removeFromParent()
            end
        end
        g_sgHttp.postData("Player/useCdk",{cdk = cdkStr},onRecv)
    end)
    
end

return RedeemCodeLayer