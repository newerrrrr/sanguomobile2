local AllianceManageAdsLayer = class("AllianceManageAdsLayer",function()
    return cc.Layer:create()
end)

function AllianceManageAdsLayer:ctor(isNotice)
    self._isNotice = isNotice
    local uiLayer = cc.CSLoader:createNode("alliance_manage_notice.csb")
    self:addChild(uiLayer)
    
    if self._isNotice == true then
        uiLayer:getChildByName("text_3"):setString(g_tr("allianceNotice"))--联盟公告
    else
        uiLayer:getChildByName("text_3"):setString(g_tr("allianceAds"))--联盟宣言
    end
    uiLayer:getChildByName("tips"):setString("")
    
    self._uiLayer = uiLayer

    local saveBtn = uiLayer:getChildByName("btn_save")
    saveBtn:getChildByName("Text"):setString(g_tr("save"))
    
    self._input = uiLayer:getChildByName("TextField")
    self._input = g_gameTools.convertTextFieldToEditBox(self._input)
    
    self:updateView()

    saveBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            --TODO:Save ads
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("save handler")
            uiLayer:getChildByName("tips"):setString("")
            local str = self._input:getString()
            str = string.trim(str)
            
            print("to save:"..str)
            uiLayer:getChildByName("tips"):setString("")
            
            if str == "" then
                local tipStr = g_tr("inputAllianceDesc")
                if self._isNotice == true then
                    tipStr = g_tr("inputAllianceNotice")
                end
                uiLayer:getChildByName("tips"):setString(tipStr)
                return
            end
            
            if self._isNotice == true then
                local descLength = string.utf8len(str)
                if descLength > 100 then
                    uiLayer:getChildByName("tips"):setString(g_tr("allianceNoticeRule"))
                    return
                end
            else --宣言
                local descLength = string.utf8len(str)
                if descLength > 20 then
                    uiLayer:getChildByName("tips"):setString(g_tr("allianceAdsRule"))
                    return
                end
            end
            
            if self._lastDesc == str then
                return
            end
            
            local resultHandler = function(result, msgData)
                if result then
                    print("success")
                    g_airBox.show(g_tr("changeSuccess"))
                    self:updateView()
                else
                    --g_airBox.show(g_tr("changeFail"))
                end
            end
            
            local data = {type = 1,desc = str}
            if self._isNotice == true then
                data = {type = 5,notice = str}
            end
            g_AllianceMode.reqAlterGuild(data,resultHandler)
        end
    end)

end

function AllianceManageAdsLayer:updateView()
    local baseData = g_AllianceMode.getBaseData()
    local str = baseData.desc
    if self._isNotice == true then
      str = baseData.notice
    end
    self._input:setString(str)
    self._lastDesc = str
end

return AllianceManageAdsLayer