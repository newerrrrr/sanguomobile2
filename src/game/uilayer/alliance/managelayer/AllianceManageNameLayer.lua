local AllianceManageNameLayer = class("AllianceManageNameLayer",function()
    return cc.Layer:create()
end)

function AllianceManageNameLayer:ctor(isShortName)
    self._isShortName = isShortName

    local uiLayer = cc.CSLoader:createNode("alliance_manage_name.csb")
    self:addChild(uiLayer)
    
    if isShortName == true then
        uiLayer:getChildByName("text_3"):setString(g_tr("newAllianceShortName"))--输入新的联盟简称
        uiLayer:getChildByName("tips_2"):setString(g_tr("allianceShortNameRule"))--名称规则
    else
        uiLayer:getChildByName("text_3"):setString(g_tr("newAllianceName"))--输入新的联盟名称
        uiLayer:getChildByName("tips_2"):setString(g_tr("allianceNameRule"))--名称规则
    end
    
    uiLayer:getChildByName("tips_1"):setString("")--错误信息提示
    
    local costId = 106
    if isShortName == true then
        costId = 127
    else
        costId = 106
    end
    
    local costNum = 0
    local costType = 0
    
    for key, var in pairs(g_data.cost) do
      if costId == var.cost_id then
         costNum = var.cost_num
         costType = var.cost_type
         break
      end
    end
    assert(costType > 0)
   
    local saveBtn = uiLayer:getChildByName("btn_save")
    saveBtn:getChildByName("text_price"):setString(string.formatnumberthousands(costNum))--price
    saveBtn:getChildByName("ico_gold"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
        
    
    self._uiLayer = uiLayer
    self._input = g_gameTools.convertTextFieldToEditBox(self._uiLayer:getChildByName("TextField_1"))
    
    local editBoxHandler = function(eventType)
        if eventType == "began" then
          
        elseif eventType == "customEnd" then
            uiLayer:getChildByName("tips_1"):setString("")
        end
    end
    self._input:registerScriptEditBoxHandler(editBoxHandler)

    self:updateView()
    
    local saveBtnFree = uiLayer:getChildByName("btn_save1")
    saveBtnFree:setVisible(false)
--    local btnLabel = saveBtnFree:getChildByName("Text")
--    btnLabel:setString(g_tr("modification")) --保存
--    if self._isShortName then
--        btnLabel:setPositionY(btnLabel:getPositionY() - 12)
--    end
    saveBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local errorStr = ""
            uiLayer:getChildByName("tips_1"):setString(errorStr)
            local str = self._input:getString()
            str = string.trim(str)
            print(str)
            if str == "" then
                errorStr = g_tr("inputEmptyTip")
                uiLayer:getChildByName("tips_1"):setString(errorStr)
                return
            end
            
            if str == self._lastName then
                if isShortName == true then
                    errorStr = g_tr("allianceShortNameSame")
                else
                    errorStr = g_tr("allianceNameSame")
                end
                uiLayer:getChildByName("tips_1"):setString(errorStr)
                return
            end
            
            local maxLength = 7
            if isShortName == true then
                maxLength = 3
            end
            
            if isShortName == true then
            else
                local length = string.utf8len(str)
                if length < 3 then
                    uiLayer:getChildByName("tips_1"):setString(g_tr("allianceNameRule"))
                    return
                end
            end
            
            if string.utf8len(str) > maxLength then
               errorStr = g_tr("inputTooLongTip",{length = maxLength})
               uiLayer:getChildByName("tips_1"):setString(errorStr)
               return
            end
            
            --[[if string.find(str,"%d%d") then --数字
               print("不能包含数字")
               return
            end]]
            
            if string.find(str,"%p%p") then --标点
               --print("不能包含标点")
               errorStr = g_tr("inputRulePunctuation")
               uiLayer:getChildByName("tips_1"):setString(errorStr)
               return
            end
            
            
            local resultHandler = function(result, msgData)
                if result then
                    print("success")
                    g_AllianceMode.setBaseData(msgData)
                    g_airBox.show(g_tr("changeSuccess"))
                    self:updateView()
                else
                    --g_airBox.show(g_tr("changeFail"))
                end
            end
            
            local data = {}
            if self._isShortName then
                data.type = 6
                data.short_name = str
            else
                data.type = 3
                data.name = str
            end
            g_AllianceMode.reqAlterGuild(data,resultHandler)
        end
    end)

end

function AllianceManageNameLayer:updateView()
    --{"code":0,"data":{"id":9,"leader_player_id":100017,"name":"ssss","short_name":"","icon_id":1,"num":0,"max_num":50,"need_check":1,"guild_power":0,"desc":"ffff","condition_fuya_level":1,"condition_player_power":0,"coin":0,"create_time":1448092313,"update_time":1448092313},"basic":[]}
    local allianceData = g_AllianceMode.getBaseData()
    local name = ""
    if self._isShortName == true then
        name = allianceData.short_name
    else
        name = allianceData.name
    end
    self._input:setString(name)
    
    self._lastName = name
end


return AllianceManageNameLayer