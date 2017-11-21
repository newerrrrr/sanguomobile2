local AccountManagerLayer = class("AccountManagerLayer",function()
    return cc.Layer:create()
end)

function AccountManagerLayer:ctor()
    
    g_Account.sdkLogout()

    local uiLayer =  g_gameTools.LoadCocosUI("login_account_manager.csb",5)
    self:addChild(uiLayer)
    self._selectedUser = nil
    
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          g_Account.setAccountManagerLayer(self)
      elseif eventType == "exit" then
          g_Account.setAccountManagerLayer(nil)
      end 
    end )
    
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    baseNode:getChildByName("title"):getChildByName("Text"):setString(g_tr("accountManager"))
    baseNode:getChildByName("Panel_1"):getChildByName("Text_21"):setString(g_tr("accountOtherAccount"))
    baseNode:getChildByName("bg_list"):getChildByName("Text_21_0"):setString(g_tr("accountOtherAccount"))
    
    
    baseNode:getChildByName("btn_2"):getChildByName("Text"):setString(g_tr("accountLoginLabel"))
    baseNode:getChildByName("btn_3"):getChildByName("Text"):setString(g_tr("accountBindLabel"))
    
    local hideListHandler = function(sender)
        baseNode:getChildByName("bg_list"):setVisible(false)
    end
    
    local background = uiLayer:getChildByName("mask")
    background:setTouchEnabled(true)
    background:addClickEventListener(hideListHandler)

    local small_background = baseNode:getChildByName("bg")
    small_background:setTouchEnabled(true)
    small_background:addClickEventListener(hideListHandler)
    
    local loginSuccessHandler = function()
        self:removeFromParent()
        if g_Account.getLoginLayer() then
            g_Account.getLoginLayer():updateView()
        end
    end
    
    --使用其他账号登录
    baseNode:getChildByName("bg_list"):getChildByName("Text_21_0"):addClickEventListener(function(sender)
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local inputLayer = require("game.uilayer.regist.LoginInputLayer"):create(loginSuccessHandler)
        g_sceneManager.addNodeForUI(inputLayer)
        hideListHandler()
    end)
    
    baseNode:getChildByName("Panel_1"):setVisible(false)
    
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
--    if cc.PLATFORM_OS_ANDROID == targetPlatform
--    or cc.PLATFORM_OS_IPHONE == targetPlatform 
--    or cc.PLATFORM_OS_IPAD == targetPlatform
--    then
--        baseNode:getChildByName("Panel_1"):setVisible(true)
--    end
    
    --使用g+登录
    local googleLoginBtn = baseNode:getChildByName("Panel_1"):getChildByName("Button_1")
    googleLoginBtn:setVisible(g_sdkManager.isChannelVaild(g_sdkManager.SdkLoginChannel.googleplus))
    googleLoginBtn:addClickEventListener(function(sender)
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        if baseNode:getChildByName("bg_list"):isVisible() then
            hideListHandler()
            return
        end
        
        self:doVerfityUid(g_sdkManager.SdkLoginChannel.googleplus)
        
    end)
    
    --使用facebook登录
    local facebookLoginBtn = baseNode:getChildByName("Panel_1"):getChildByName("Button_1_0")
    facebookLoginBtn:setVisible(g_sdkManager.isChannelVaild(g_sdkManager.SdkLoginChannel.facebook))
    facebookLoginBtn:addClickEventListener(function(sender)
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        if baseNode:getChildByName("bg_list"):isVisible() then
            hideListHandler()
            return
        end
        
        self:doVerfityUid(g_sdkManager.SdkLoginChannel.facebook)
    end)
    
    if not googleLoginBtn:isVisible() then
        facebookLoginBtn:setPosition(googleLoginBtn:getPosition())
    end
    
    if googleLoginBtn:isVisible() or facebookLoginBtn:isVisible() then
       baseNode:getChildByName("Panel_1"):setVisible(true)
    end
    
    --简体中文版不提供其他方式登入
    if require("localization.langConfig").getCountryCode() == "zhcn" then
    	 baseNode:getChildByName("Panel_1"):setVisible(false)
    end
    
    baseNode:getChildByName("btn_2"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            --login
             local resultHandler = function(result,data)
                if result then
                   if data.status == "success" then
                      --g_airBox.show(g_tr("loginSuccess"))
                      self:removeFromParent()
                   else
                       g_airBox.show(g_tr("userPlatform_"..data.message))
                   end
                end
            end
            g_Account.userPlatformLogin(self._selectedUser.user_account,self._selectedUser.password,resultHandler)
        end
    end)
    
    baseNode:getChildByName("btn_3"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            --reg or bind
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local inputLayer
            local username = self._selectedUser.user_account
            if string.find(username,"@dsucsys.com") then
               --bind
               inputLayer = require("game.uilayer.regist.RegistInfoInputLayer"):create(handler(self,self.bindSuccessHandler),self._selectedUser)
            else
               --reg
               inputLayer = require("game.uilayer.regist.RegistInfoInputLayer"):create(handler(self,self.bindSuccessHandler))
            end
            g_sceneManager.addNodeForUI(inputLayer)
            
        end
    end)
    
    baseNode:getChildByName("bg_input_1"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            baseNode:getChildByName("bg_list"):setVisible(not baseNode:getChildByName("bg_list"):isVisible())
        end
    end)
    
    baseNode:getChildByName("bg_list"):setVisible(false)
    
    --self:rebuildAccountListView()
   
    local allAccounts = g_Account.getUserConfig().accountList
    local accountList = {}
    for key, userInfo in pairs(allAccounts) do
      table.insert(accountList,userInfo)
    end
    
    local lastUserName = g_Account.getUserConfig().lastLoginAccount.user_account
    self._selectedUser = g_Account.getUserConfig().lastLoginAccount
    if lastUserName == nil then
        self._selectedUser = accountList[1]
    end
    
    self:updateView()
    
end

function AccountManagerLayer:doVerfityUid(channel)
    assert(channel)
    local resultHandler = function(result,dataTable)
      
        if result then
            --{"status":"success","uid":1234,”message”:”获得用户信息成功”,"channel":"dsuc"}
            if dataTable.status == "success" then
                --g_airBox.show("login "..dataTable.channel.." success")
                --g_airBox.show(g_tr("loginSuccess"))
                self:removeFromParent()
            else
                g_msgBox.show("verfity fail"..dataTable.message)
            end
        end
        
    end
    g_Account.doVerfityUid(channel,resultHandler)
end

function AccountManagerLayer:rebuildAccountListView()

    local listView = self._baseNode:getChildByName("bg_list"):getChildByName("ListView_1")
    listView:removeAllChildren()
    
    local allAccounts = g_Account.getUserConfig().accountList
    local accountList = {}
    for key, userInfo in pairs(allAccounts) do
      table.insert(accountList,userInfo)
    end
    
    if table.nums(accountList) > 0 then
        local leftItem = cc.CSLoader:createNode("login_select_id_item.csb")
        leftItem:setTouchEnabled(true)
        
        local function selectHandler(sender)
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local idx = sender.idx
            if accountList[idx] then
                self._baseNode:getChildByName("bg_list"):setVisible(false)
                self._selectedUser = accountList[idx]
                dump(self._selectedUser)
                g_Account.updateLastUser(self._selectedUser)
                self:updateView()
            else
                --assert(false)
            end
        end
        
        local function deleteHandler(sender)
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            local idx = sender.idx
            local doDelete = function()
                local isDeleteCurrentAccount = false
                if self._selectedUser.uid == accountList[idx].uid then
                    isDeleteCurrentAccount = true
                end
                g_Account.getUserConfig().accountList[accountList[idx].uid] = nil
                if isDeleteCurrentAccount then
                    local accountList = {}
                    for key, userInfo in pairs(g_Account.getUserConfig().accountList) do
                      table.insert(accountList,userInfo)
                    end
                    self._selectedUser = accountList[1]
                end
                g_Account.updateLastUser(self._selectedUser)
                g_Account.saveToFile()
                self:updateView()
            end
            
            local username = accountList[idx].user_account
            if string.find(username,"@dsucsys.com") then
                g_msgBox.show(g_tr("accountDeleteTempUser"),nil,3,function(event)
                    if event == 0 then
                        doDelete()
                    end
                end,1)
            else
                doDelete()
            end
        end
        
        local idx = 1
        for key, userInfo in pairs(accountList) do
          local item = leftItem:clone()
          listView:pushBackCustomItem(item)
          self:updateItem(item,userInfo)
          item:getChildByName("btn_delete").idx = idx
          item:getChildByName("btn_delete"):addClickEventListener(deleteHandler)
          item:getChildByName("Panel_1").idx = idx
          item:getChildByName("Panel_1"):addClickEventListener(selectHandler)
          
          idx = idx + 1
          
        end
    else
        g_Account.updateLastUser(nil)
        g_Account.saveToFile()
        if g_Account.getLoginLayer() then
            g_Account.getLoginLayer():updateView()
            g_Account.getLoginLayer():onClickAccountManagerHandler()
        end
       
        self:removeFromParent()
    end
    
end

function AccountManagerLayer:bindSuccessHandler()
    self._selectedUser = g_Account.getUserConfig().lastLoginAccount
    self:updateView()
end

function AccountManagerLayer:updateItem(item,userInfo)
    local userName = self:convertUserName(userInfo.user_account)
    item:getChildByName("Text"):setString(userName)
end

function AccountManagerLayer:convertUserName(userName)
    local name = userName
    if string.utf8len(userName) > 24 then
        local tmpNameShowPreStr = string.sub(userName, 1, -35)
        local tmpNameShowLastStr = string.sub(userName, 23, -1)
        name = tmpNameShowPreStr.."..."..tmpNameShowLastStr
    end
    return name
end

function AccountManagerLayer:updateView()

    self:rebuildAccountListView()
    
    if self._selectedUser == nil then
        return
    end
    
    local lastUserName = self._selectedUser.user_account
    lastUserName = self:convertUserName(lastUserName)
    self._baseNode:getChildByName("text_username"):setString(lastUserName)
    
    local username = self._selectedUser.user_account
    if not string.find(username,"@dsucsys.com") then
        self._baseNode:getChildByName("btn_3"):getChildByName("Text"):setString(g_tr("accountRegistLabel"))
    else
        self._baseNode:getChildByName("btn_3"):getChildByName("Text"):setString(g_tr("accountBindLabel"))
    end
    
end


return AccountManagerLayer