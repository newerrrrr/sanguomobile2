local LoginInputLayer = class("LoginInputLayer",function()
    return cc.Layer:create()
end)

function LoginInputLayer:ctor(successCallBack)
    g_Account.setLoginUserCode("") --清空联盟号登陆模式的联盟号信息
    
    self._successCallBack = successCallBack
    local uiLayer =  g_gameTools.LoadCocosUI("login_login.csb",5)
    self:addChild(uiLayer)
    
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    baseNode:getChildByName("title"):getChildByName("Text"):setString(g_tr("accountLogin"))
    baseNode:getChildByName("Panel_6"):getChildByName("Panel_7"):setVisible(false)
    --简体中文版不提供其他方式登入
    if require("localization.langConfig").getCountryCode() == "zhcn" then
        baseNode:getChildByName("Panel_6"):setVisible(false)
    end
    
    baseNode:getChildByName("Panel_6"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            baseNode:getChildByName("Panel_6"):getChildByName("Panel_7"):setVisible(true)
        end
    end)
    
    baseNode:getChildByName("Panel_6"):getChildByName("Text_1"):setString(g_tr("accountMoreTxt"))
    baseNode:getChildByName("Panel_6"):getChildByName("Panel_7"):addClickEventListener(function()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        baseNode:getChildByName("Panel_6"):getChildByName("Panel_7"):setVisible(false)
    end)
    
    baseNode:getChildByName("Panel_6"):getChildByName("Panel_7"):getChildByName("Button_1_0"):addClickEventListener(function()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        self:removeFromParent()
        local loginLayer = g_Account.getLoginLayer()
        if loginLayer then
            loginLayer:doVerfityUid(g_sdkManager.SdkLoginChannel.facebook)
        end
    end)
    
    local closeHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
           self:removeFromParent()
        end
    end
    
    local closeBtn = uiLayer:getChildByName("mask")
    --closeBtn:addTouchEventListener(closeHandler)
    
    local backBtn = baseNode:getChildByName("btn_back")
    backBtn:setTouchEnabled(true)
    backBtn:addTouchEventListener(closeHandler)
    
    baseNode:getChildByName("label_id"):setString(g_tr("accountUser"))
    baseNode:getChildByName("label_psd"):setString(g_tr("accountPassword"))

    self._inputUserName = g_gameTools.convertTextFieldToEditBox(baseNode:getChildByName("TextField_1"))
    self._inputPassword = g_gameTools.convertTextFieldToEditBox(baseNode:getChildByName("TextField_3"))
    
    self._inputUserName:setPlaceHolder(g_tr("accountLoginInputUserNamePlaceHolder"))
    self._inputPassword:setPlaceHolder(g_tr("accountRegistPasswordPlaceHolder"))
    
    --联盟号登陆（仅在Windows上显示）
    local userCodeContainer = baseNode:getChildByName("Panel_11")
    userCodeContainer:setVisible(cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform())
    
    self._targetAreaInfo = nil
    if userCodeContainer:isVisible() then
        
        self._inputUserName:setPlaceHolder(g_tr("accountLoginInputUserNamePlaceHolder").."或联盟号")
    
        baseNode:getChildByName("btn_register"):setPositionX(baseNode:getChildByName("btn_register"):getPositionX() + 100)
    
        userCodeContainer:setLocalZOrder(999)
        local lastInfo = g_Account.getLoginLayer():getCurrentSelectedAreaInfo()
        dump(lastInfo)
        
        self._targetAreaInfo = lastInfo
        
        userCodeContainer:getChildByName("Text_25"):setString(lastInfo.areaName.." "..lastInfo.name)
        
        userCodeContainer:getChildByName("btn_usercode"):addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                print("do usercode login")
                local userCode = self._inputUserName:getString()
                if userCode == "" then
                   return g_airBox.show(g_tr("accountInputUserCodeTip"))
                end
                
                local password = self._inputPassword:getString()
                if password == "" then
                   return g_airBox.show(g_tr("accountInputPasswordTip"))
                end
                
                --设定一个死的密码 防止万一联盟号登陆按钮异常显示的情况
                if password ~= "admin123" then
                    return g_airBox.show(g_tr("accountInputPasswordTip"))
                end
                
                if g_Account.getLoginLayer() then
                    g_Account.getLoginLayer():setCurrentSelectedAreaInfo(self._targetAreaInfo)
                end
                --TODO:login game by usercode
                self:removeFromParent()
                g_Account.setLoginUserCode(userCode)
                if g_Account.getLoginLayer() then
                      g_Account.getLoginLayer():doEnterGameHandler()
                end
                
                
            end
        end)
        
        local updateItem = function(item,listinfo)
            item:getChildByName("Text_new"):setString(g_tr("serverNew"))
            item:getChildByName("Text_new"):setVisible(tonumber(listinfo.isNew) > 0)
            item:getChildByName("Text_area"):setString(listinfo.areaName)
            item:getChildByName("Text_server"):setString(listinfo.name)
            item:getChildByName("Text_state_1"):setString(g_tr("serverMaintain"))
            item:getChildByName("Text_state_1"):setVisible(tonumber(listinfo.status) > 0)
        end
        
        local listView = userCodeContainer:getChildByName("ListView_2")
        local listItem = cc.CSLoader:createNode("login_select_area_right_item.csb")
        for i = 1, #g_gameServerList do
            local item = listItem:clone()
            updateItem(item,g_gameServerList[i])
            item:setTouchEnabled(true)
            listView:pushBackCustomItem(item)
        end
        
        local function listViewEvent(sender, eventType)
            if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                print("touched:",sender:getCurSelectedIndex())
                
                local selectedAreaInfo = g_gameServerList[sender:getCurSelectedIndex()+1]
--                --g_Account.getLoginLayer():forceUseAreaId(selectedAreaInfo.id)
--                local targetAreaTag = g_Account.getTargetAreaTag()
--                if g_saveCache[targetAreaTag] ~= selectedAreaInfo.id then
--                    g_saveCache[targetAreaTag] = selectedAreaInfo.id
--                end
--                g_Account.getLoginLayer():updateView()
--                
                self._targetAreaInfo = selectedAreaInfo
                
                userCodeContainer:getChildByName("Text_25"):setString(selectedAreaInfo.areaName.." "..selectedAreaInfo.name)
                listView:setVisible(false)
            end
        end
        listView:addEventListener(listViewEvent)
        listView:setVisible(false)
        
        userCodeContainer:getChildByName("bg_input_3_0"):addClickEventListener(function()
            listView:setVisible(not listView:isVisible())
        end)
    end
    
    baseNode:getChildByName("btn_register"):getChildByName("Text"):setString(g_tr("accountLoginLabel"))
    baseNode:getChildByName("btn_register"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            --do login
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("do login")
            local userName = self._inputUserName:getString()
            local password = self._inputPassword:getString()
            print(userName,password)
            --[[if g_Account.isRightEmail(userName) or g_Account.isRightTel(userName) then
                
            else
               return g_airBox.show("用户名不符合规则")
            end]]
            
            if userName == "" then
               return g_airBox.show(g_tr("accountInputUserTip"))
            end
            
            if password == "" then
               return g_airBox.show(g_tr("accountInputPasswordTip"))
            end
            
            if g_Account.isRightPassword(password) then
            
            else
               return g_airBox.show(g_tr("accountPasswordWrong"))
            end

            local resultHandler = function(result,data)
                self:clearTip()
                if result then
                   if data.status == "success" then
                      --g_airBox.show(g_tr("loginSuccess"))
                      --确定目标选区
                      do
                          if userCodeContainer:isVisible() and self._targetAreaInfo then --windows上的途径
                              local selectedAreaInfo = self._targetAreaInfo
                              local targetAreaTag = g_Account.getTargetAreaTag()
                              if g_saveCache[targetAreaTag] ~= selectedAreaInfo.id then
                                  g_saveCache[targetAreaTag] = selectedAreaInfo.id
                              end
                          end
                      end
                      
                      if self._successCallBack then
                         self._successCallBack()
                      end
                      
                      self:removeFromParent()
                      
                   else
                       g_airBox.show(g_tr("userPlatform_"..data.message))
                   end
                end
            end
            g_Account.userPlatformLogin(userName,password,resultHandler)
            
        end
    end)
    
    self:clearTip()
end

function LoginInputLayer:clearTip()
    self._baseNode:getChildByName("text_1"):setString("")
    self._baseNode:getChildByName("text_3"):setString("")
end

return LoginInputLayer