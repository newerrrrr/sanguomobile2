local RegistInfoInputLayer = class("RegistInfoInputLayer",function()
    return cc.Layer:create()
end)

local countryCodes = g_Account.countryCodes

function RegistInfoInputLayer:ctor(successCallBack,tempUserInfo)
    self._tempUserInfo = tempUserInfo
    self._callBack = successCallBack
    self._tabIdx = 1
    
    local defaultCountryKey = require("public.localization").countryKey
    self._countryCode = countryCodes[defaultCountryKey] or 86
    
    local uiLayer =  g_gameTools.LoadCocosUI("login_regist.csb",5)
    self:addChild(uiLayer)
    
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
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
    
    baseNode:getChildByName("Panel_3"):getChildByName("Text_1"):setString(g_tr("regAgreement"))
    local btnAgreement = baseNode:getChildByName("Panel_3"):getChildByName("Text_1")
    btnAgreement:addClickEventListener(function()
    	local layer = require("game.uilayer.regist.RegisterAgreementLayer"):create()
      g_sceneManager.addNodeForUI(layer)
    end)
    
    local btnReg = baseNode:getChildByName("btn_register")
    local agreeCheckBox = baseNode:getChildByName("Panel_3"):getChildByName("CheckBox_1")
    local function selectedEvent(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            btnReg:setEnabled(true)
        elseif eventType == ccui.CheckBoxEventType.unselected then
            btnReg:setEnabled(false)
        end
    end   
    agreeCheckBox:setTouchEnabled(true)
    agreeCheckBox:addEventListenerCheckBox(selectedEvent) 
    
    baseNode:getChildByName("Panel_3"):setVisible(false)
    --简体中文版才有用户协议
    if require("localization.langConfig").getCountryCode() == "zhcn" then
    	 baseNode:getChildByName("Panel_3"):setVisible(true)
    end
    
    self._userNameEditBox = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("Panel_1"):getChildByName("TextField_1"))
    self._userPhoneEditBox = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("Panel_2"):getChildByName("TextField_1"))
    self._passCodeEditBox = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("bg_input_2"):getChildByName("TextField_2"))
    self._passwordEditBox = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("TextField_3"))
    self._firstPasswordEditBox = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("bg_input_4"):getChildByName("TextField_4"))
    
    local editBoxHandler = function(eventType)
        if eventType == "began" then
          
        elseif eventType == "customEnd" then
           self:clearTip()
           self:updatePasscodeStatus()
        end
    end
    self._userPhoneEditBox:registerScriptEditBoxHandler(editBoxHandler)
    
    
    self._userPhoneEditBox:setPlaceHolder(g_tr("accountRegistPhoneUserNamePlaceHolder"))
    self._userNameEditBox:setPlaceHolder(g_tr("accountRegistEmailUserNamePlaceHolder"))
    self._passCodeEditBox:setPlaceHolder(g_tr("accountRegistTelPassCodePlaceHolder"))
    
    local sendBtn = baseNode:getChildByName("bg_input_2"):getChildByName("btn_send")
    sendBtn:getChildByName("Text"):setString(g_tr("accountRegistPasscodeSend"))
    sendBtn:setTouchEnabled(true)
    
    self:updatePasscodeStatus()
    sendBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
           self:clearTip()
           local telNum = self._userPhoneEditBox:getString()
           if g_Account.isRightTel(telNum,self._countryCode) then
              local resultHandler = function(result,data)
                  if data.status == "success" then
                      local str = g_tr("accountRegistVcodeSendSuccess")
                      if g_logicDebug == true then
                          str = g_tr("accountRegistVcode",{vcode = data.vcode})
                      end
                      g_airBox.show(str)
                      self:updatePasscodeStatus()
                  else
                      g_airBox.show(g_tr("userPlatform_"..data.message))
                  end
              end
              
              g_Account.userPlatformMobileGetVerification(telNum,self._countryCode,resultHandler)
        
           else
              baseNode:getChildByName("text_1"):setString(g_tr("accountRegistTelErr"))
           end
        end
    end)
    
    baseNode:getChildByName("btn_register"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:clearTip()
            if self._tabIdx == 1 then
                self:mobileUserRegist()
            elseif self._tabIdx == 2 then
                self:emailUserRegist()
            end
        end
    end)
    
    self._baseNode:getChildByName("Panel_2"):getChildByName("label_id1"):setString( self._countryCode.."")
    local listView = baseNode:getChildByName("bg_list"):getChildByName("ListView_1")
    local itemOrginal = cc.CSLoader:createNode("login_regist_listitem.csb")
    itemOrginal:setTouchEnabled(true)
    for key, var in pairs(countryCodes) do
    	local item = itemOrginal:clone()
    	item:getChildByName("Text_1"):setString(var.."")
    	item.countryKey = key
    	listView:pushBackCustomItem(item)
    end
    
    local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local item = listView:getItem(sender:getCurSelectedIndex())
            self._countryCode = countryCodes[item.countryKey]
            print(item.countryKey)
            baseNode:getChildByName("bg_list"):setVisible(false)
            self._baseNode:getChildByName("Panel_2"):getChildByName("label_id1"):setString(self._countryCode.."")
            self:clearTip()
        end
    end
    listView:addEventListener(listViewEvent)
    
    baseNode:getChildByName("bg_list"):setVisible(false)
    baseNode:getChildByName("Panel_2"):getChildByName("Panel_dianji"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            baseNode:getChildByName("bg_list"):setVisible(not baseNode:getChildByName("bg_list"):isVisible())
        end
    end)
    
    
    local btn1 = baseNode:getChildByName("btn_tab_1")
    local btn2 = baseNode:getChildByName("btn_tab_2")
    btn1:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabMenu(1)
        end
    end)
    
    btn2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabMenu(2)
        end
    end)

    self._tabMenus = {btn1,btn2}
   
    if countryCodes[defaultCountryKey] then
    	self:tabMenu(1)
    else
    	btn1:setVisible(false)
    	btn2:setVisible(false)
    	self:tabMenu(2)
    end
    
        
    if tempUserInfo == nil then
        btn1:getChildByName("Text"):setString(g_tr("accountRegistTel"))
        btn2:getChildByName("Text"):setString(g_tr("accountRegistEmail"))
        baseNode:getChildByName("btn_register"):getChildByName("Text"):setString(g_tr("accountRegistLabel"))
    else
        btn1:getChildByName("Text"):setString(g_tr("accountBindTel"))
        btn2:getChildByName("Text"):setString(g_tr("accountBindEmail"))
        baseNode:getChildByName("btn_register"):getChildByName("Text"):setString(g_tr("accountBindLabel"))
    end
end

function RegistInfoInputLayer:updatePasscodeStatus()
    print(self._tabIdx)

    if self._tabIdx ~= 1 then
        return
    end
    
    local inputTelNum = self._userPhoneEditBox:getString()
    local nextPasscodeTime = g_Account.getNextPasscodeTime(inputTelNum)

    local sendBtn = self._baseNode:getChildByName("bg_input_2"):getChildByName("btn_send")
    sendBtn:stopAllActions()
    local timeLabel = sendBtn:getChildByName("Text")
    
    if g_clock.getCurServerTime() > nextPasscodeTime then
        sendBtn:setEnabled(true)
        timeLabel:setString(g_tr("accountRegistPasscodeSend"))
    else
        sendBtn:setEnabled(false)
        
        local updateTimeStr = function()
          
              local currentTime = g_clock.getCurServerTime()
              local secondsLeft = nextPasscodeTime - currentTime
              if secondsLeft < 0 then
                  secondsLeft = 0
                  sendBtn:stopAllActions()
                  timeLabel:setString(g_tr("accountRegistPasscodeSend"))
                  sendBtn:setEnabled(true)
              else
                  timeLabel:setString(g_tr("accountRegistPasscodeSendAgin").."("..secondsLeft.."s)")
              end
        end
        
        updateTimeStr()
        
        local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
        local action = cc.RepeatForever:create(seq)
        sendBtn:runAction(action)
       
    end
    
end

function RegistInfoInputLayer:clearTip()
    self._baseNode:getChildByName("text_1"):setString("")
    self._baseNode:getChildByName("text_2"):setString("")
    self._baseNode:getChildByName("text_3"):setString("")
end

function RegistInfoInputLayer:tabMenu(idx)
    if self._lastIdx == idx then
        return
    end
    self._lastIdx = idx
    self._tabIdx = idx
    for key, btn in pairs(self._tabMenus) do
    	btn:setEnabled(true)
    	if self._tabMenus[idx] == btn then
    	   btn:setEnabled(false)
    	end
    end
    
    self:clearTip()
    
    if idx == 1 then --手机注册
        self._baseNode:getChildByName("Panel_2"):setVisible(true)
        self._baseNode:getChildByName("Panel_1"):setVisible(false)
        
        self._baseNode:getChildByName("bg_input_2"):setVisible(true)
        self._baseNode:getChildByName("bg_input_2"):getChildByName("label_iden"):setString(g_tr("accountRegistTelPassCode"))
        
        self._baseNode:getChildByName("bg_input_4"):setVisible(false)
        
        self._baseNode:getChildByName("Panel_2"):getChildByName("label_id"):setString(g_tr("accountRegistTelTitle"))
        self._baseNode:getChildByName("label_psd"):setString(g_tr("accountPassword"))
        self._passwordEditBox:setPlaceHolder(g_tr("accountRegistPasswordPlaceHolder"))
        
    elseif idx == 2 then --邮箱注册
        
        self._baseNode:getChildByName("bg_list"):setVisible(false)
       
        self._baseNode:getChildByName("Panel_2"):setVisible(false)
        self._baseNode:getChildByName("Panel_1"):setVisible(true)
        
        self._baseNode:getChildByName("bg_input_2"):setVisible(false)
        self._baseNode:getChildByName("bg_input_4"):setVisible(true)
        
        self._baseNode:getChildByName("bg_input_4"):getChildByName("label_psd_4"):setString(g_tr("accountPassword"))
        self._firstPasswordEditBox:setPlaceHolder(g_tr("accountRegistPasswordPlaceHolder"))
        
        self._baseNode:getChildByName("Panel_1"):getChildByName("label_id"):setString(g_tr("accountNameEmailLabel"))
        self._baseNode:getChildByName("label_psd"):setString(g_tr("accountPasswordMakesure"))
        self._passwordEditBox:setPlaceHolder(g_tr("accountRegistMakeSurePasswordPlaceHolder"))
    end
end

function RegistInfoInputLayer:emailUserRegist()
   --do regist
    print("do regist")
    local userName = self._userNameEditBox:getString()
    local firstPassword = self._firstPasswordEditBox:getString()
    local password = self._passwordEditBox:getString()
    print(userName,password)
    
    self:clearTip()
    
    if g_Account.isRightEmail(userName) then
        
    else
       self._baseNode:getChildByName("text_1"):setString(g_tr("accountRegistEmailErr"))
       return --g_airBox.show(g_tr("accountRegistEmailErr"))
    end
    
    if firstPassword == "" then
       self._baseNode:getChildByName("text_2"):setString(g_tr("accountInputPasswordTip"))
       return --g_airBox.show(g_tr("accountInputPasswordTip"))
    end
    
    if g_Account.isRightPassword(password) then
    
    else
       self._baseNode:getChildByName("text_2"):setString(g_tr("accountPasswordErr"))
       return --g_airBox.show(g_tr("accountPasswordErr"))
    end
    
    if password == "" then
       self._baseNode:getChildByName("text_3"):setString(g_tr("accountInputMakeSurePasswordTip"))
       return --g_airBox.show(g_tr("accountInputMakeSurePasswordTip"))
    end
    
    if password ~= firstPassword then
       self._baseNode:getChildByName("text_3"):setString(g_tr("accountPasswordMakeSureErr"))
       return --g_airBox.show(g_tr("accountPasswordMakeSureErr"))
    end
    
    if self._tempUserInfo ~= nil then
        local resultHandler = function(result,data)
            if result then
               if data.status == "success" then
                  g_airBox.show(g_tr("accountUserBindSuccess"))
                  if self._callBack then
                      self._callBack()
                  end
                  self:removeFromParent()
               else
                   g_airBox.show(g_tr("userPlatform_"..data.message))
               end
            end
        end
        g_Account.userPlatformBind(self._tempUserInfo.user_account,self._tempUserInfo.password,userName,password,resultHandler)
    else
        local resultHandler = function(result,data)
            if result then
               if data.status == "success" then
                  g_airBox.show(g_tr("accountUserRegistSuccess"))
                  if self._callBack then
                      self._callBack()
                  end
                  self:removeFromParent()
               else
                   g_airBox.show(g_tr("userPlatform_"..data.message))
               end
            else
               if data == "userPlatformVerifyError" then --登录服务器（login server）出错， 但是注册成功，这种情况注册的账号不会自动登录出现在选择列表，需自行输入
                   g_airBox.show(g_tr("accountUserRegistSuccess"))
                   if self._callBack then
                      self._callBack()
                   end
                   self:removeFromParent()
               end
            end
        end
        g_Account.userPlatformRegist(userName,password,resultHandler)
    end
end

function RegistInfoInputLayer:mobileUserRegist()
   --do regist
    print("do mobile regist")
    
    self:clearTip()
    
    local countryCode = self._countryCode
    
    local userName = self._userPhoneEditBox:getString()
    local passCode = self._passCodeEditBox:getString()
    passCode = string.trim(passCode)
   
    local password = self._passwordEditBox:getString()
    print(userName,password)
    
    if g_Account.isRightTel(userName,self._countryCode) then
       
    else
       self._baseNode:getChildByName("text_1"):setString(g_tr("accountRegistTelErr"))
       return --g_airBox.show(g_tr("accountRegistTelErr"))
    end
    
    if passCode == "" then
       self._baseNode:getChildByName("text_2"):setString(g_tr("accountRegistTelPassCodePlaceHolder"))
       return --g_airBox.show(g_tr("accountRegistTelPassCodePlaceHolder"))
    end
    
    if password == "" then
       self._baseNode:getChildByName("text_3"):setString(g_tr("accountInputPasswordTip"))
       return --g_airBox.show(g_tr("accountInputPasswordTip"))
    end
    
    if g_Account.isRightPassword(password) then
    
    else
       self._baseNode:getChildByName("text_3"):setString(g_tr("accountPasswordErr"))
       return
       --return g_airBox.show(g_tr("accountPasswordErr"))
    end
    
    local doBindMobileUserAccount = function(userName,password,countryCode,userNameNew,passwordNew)
        g_Account.userPlatformMobileBind(userName,password,countryCode,userNameNew,passwordNew,function(result,data)
            if result then
                if data.status == "success" then
                    g_airBox.show(g_tr("accountTelRigistSuccess"))
                    if self._callBack then
                      self._callBack()
                    end
                    self:removeFromParent()
                else
                    g_airBox.show(g_tr("userPlatform_"..data.message))
                end
            end
        end)
    end
    
    local doMobileRegist = function()
        if self._tempUserInfo ~= nil then
            doBindMobileUserAccount(self._tempUserInfo.user_account,self._tempUserInfo.password,countryCode,userName,password)
        else
            --申请一个临时账号
            g_Account.userPlatformRegisterQuick(function(result,data)
                if result then
                    if data.status == "success" then
                        --g_airBox.show(g_tr("accountTempUserCreated"))
                        local lastUserConfig = g_Account.getUserConfig().lastLoginAccount
                        local tmpUserInfo = lastUserConfig
                        self._tempUserInfo = tmpUserInfo
                        doBindMobileUserAccount(lastUserConfig.user_account,lastUserConfig.password,countryCode,userName,password)
                    else
                        g_airBox.show(g_tr("userPlatform_"..data.message))
                    end
                end
            end)
        end
    end
    
    if g_Account.vcodeCaches[userName] then
        doMobileRegist()
    else
        --验证手机号码
        local resultHandler = function(result,data)
            if result then
               if data.status == "success" then
                  --g_airBox.show("验证码验证成功")
                  g_Account.vcodeCaches[userName] = tostring(passCode)
                  doMobileRegist()
               else
                   g_airBox.show(g_tr("userPlatform_"..data.message))
               end
            end
        end
        g_Account.userPlatformMobileVerify(userName,countryCode,passCode,resultHandler)
    end
end


return RegistInfoInputLayer