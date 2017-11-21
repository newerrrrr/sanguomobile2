local AllianceManageRankNameLayer = class("AllianceManageRankNameLayer",function()
    return cc.Layer:create()
end)

function AllianceManageRankNameLayer:ctor()
    local uiLayer = cc.CSLoader:createNode("alliance_manage_rank_name.csb")
    self:addChild(uiLayer)
    uiLayer:getChildByName("text_1"):setString(g_tr("allianceOldRankName"))--旧的称谓
    uiLayer:getChildByName("text_tips"):setString(g_tr("allianceRankNameRule"))--新的称谓可以输入1-5个中文
    self._uiLayer = uiLayer
    
    self._rankNameEditBoxs = {}
    for i = 1, 5 do
        local editBox = g_gameTools.convertTextFieldToEditBox(self._uiLayer:getChildByName("TextField_"..i))
        table.insert(self._rankNameEditBoxs,editBox)
    end
    
    local saveBtn = uiLayer:getChildByName("btn_save")
    saveBtn:getChildByName("Text"):setString(g_tr("modification")) --修改
    
    saveBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            --长度预判
            local matchLength = true
            local findPunctuation = false
            for i = 1, 5 do
                local newRankName = self._rankNameEditBoxs[i]:getString()
                newRankName = string.trim(newRankName)
                local length = string.utf8len(newRankName)
                if newRankName ~= "" then
                    if length <= 0 or length > 5 then
                       matchLength = false
                    end
                    
                    if string.find(newRankName,"%p%p") then
                        findPunctuation = true
                    end
                end
            end
            
            if not matchLength then
                g_airBox.show(g_tr("allianceRankNameRuleErrorTip"))
                return
            end
            
            if findPunctuation then --标点
               g_airBox.show(g_tr("inputRulePunctuation"))
               return
            end
            
            --各阶级名称不能重复
            local isNameRepeated = function(str)
                local isRepeat = false
                local cnt = 0
                for i = 1, 5 do
                    local newRankName = self._rankNameEditBoxs[i]:getString()
                    if newRankName ~= "" and newRankName == str then
                        cnt = cnt + 1
                    end
                end
                
                isRepeat = (cnt > 1)
                
                return isRepeat
            end
            
            local isRightName = true
            for i = 1, 5 do
                local newRankName = self._rankNameEditBoxs[i]:getString()
                newRankName = string.trim(newRankName)
                if isNameRepeated(newRankName) then
                    isRightName = false
                    break
                end
            end
            
            if not isRightName then
                g_airBox.show(g_tr("allianceRankNameRuleRepeated"))
                return
            end
            
            local errorIdxs ={}
            local changeCount = 0
            for i = 1, 5 do
                local newRankName = self._rankNameEditBoxs[i]:getString()
                newRankName = string.trim(newRankName)
                local oldName = tostring(self._lastNames[i])
                if newRankName ~= "" and newRankName ~= oldName then
                     local resultHandler = function(result, msgData)
                        if result then
                           changeCount = changeCount + 1
                        else
                           table.insert(errorIdxs,i)
                           g_airBox.show(g_tr("rankNameChangeFail",{rank = i}))
                        end
                        
                      end
                      print("change:",i,newRankName,self._lastNames[i])
                      g_sgHttp.postData("guild/changeRankName",{rank = i,name = newRankName},resultHandler)
                end
            end
            if #errorIdxs == 0 then
                if changeCount > 0 then
                   g_airBox.show(g_tr("changeSuccess"))
                   
                end
            end
            g_AllianceMode.reqBaseData()
            self:updateView()
            
        end
    end)

    self:updateView()
end

function AllianceManageRankNameLayer:updateView()
    local baseData = g_AllianceMode.getBaseData()
    self._lastNames = {}
    for i = 1, 5 do
         local lastRankName = baseData.GuildRankName[i]
         if lastRankName == nil or lastRankName == "" then
            lastRankName = g_tr("allianceRankName"..i)
         end
         
         self._lastNames[i] = lastRankName
         self._uiLayer:getChildByName("text_level_"..i):setString(lastRankName)
    end
end

return AllianceManageRankNameLayer