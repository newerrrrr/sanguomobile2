local AllianceManageDissolutionLayer = class("AllianceManageDissolutionLayer",function()
    return cc.Layer:create()
end)

function AllianceManageDissolutionLayer:ctor(dissolutionSuccessHandler)
    local uiLayer = cc.CSLoader:createNode("alliance_manage_dissolution.csb")
    self:addChild(uiLayer)
    uiLayer:getChildByName("tips"):setString(g_tr("allianceDissolutionRule"))--解散提示
    local saveBtn = uiLayer:getChildByName("btn_dissolve")
    saveBtn:getChildByName("Text"):setString(g_tr("dissolution")) --解散
    saveBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("dissolution handler")
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local doDissolution = function()
                if g_AllianceMode.reqDismissGuild() and dissolutionSuccessHandler then
                    dissolutionSuccessHandler()
                end
            end
            
            g_msgBox.show(g_tr("allianceDissolutionTip"),nil,3,function(event)
                if event == 0 then
                    doDissolution()
                end
            end,1)
                
            
        end
    end)

end

return AllianceManageDissolutionLayer