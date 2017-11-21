local AllianceTechMainLayer = class("AllianceTechMainLayer",function()
    return cc.Layer:create()
end)

local maxCnt = 30
local eachCnt = 10

local defaultScienceType = 11

function AllianceTechMainLayer:ctor(onCloseCallback)
    local node = g_gameTools.LoadCocosUI("alliance_technology.csb",5)
    self:addChild(node)
    g_resourcesInterface.installResources(node)
    local baseNode = node:getChildByName("scale_node")
    self._baseNode = baseNode
    
    baseNode:getChildByName("Text_1"):setString(g_tr("allianceTechTitle"))
    
    baseNode:getChildByName("btn_menu_1"):getChildByName("Text"):setString(g_tr("allianceTechRank1"))
    baseNode:getChildByName("btn_menu_2"):getChildByName("Text"):setString(g_tr("allianceTechRank2"))
    baseNode:getChildByName("btn_menu_3"):getChildByName("Text"):setString(g_tr("allianceTechRank3"))
    
    local techContent = cc.CSLoader:createNode("alliance_tech_content.csb")
    self._techContent = techContent
    baseNode:getChildByName("container"):addChild(techContent)
    
    self._leftListViewOrginal = techContent:getChildByName("content"):getChildByName("ListView")
   
   
    local leftItem = cc.CSLoader:createNode("alliance_tech_list_item.csb")
    leftItem:getChildByName("tech_item"):getChildByName("Image_28_0"):setVisible(false)
    leftItem:getChildByName("tech_item"):getChildByName("Button_yx"):setVisible(false)
    self._leftListViewOrginal:setItemModel(leftItem)
    
    self._currentLevelType = 0
    self._currentTechIdx = 1
    
    self:resetListView()
   
    local contributeLayer = require("game.uilayer.alliance.tech.AllianceTechContributeLayer"):create()
    techContent:getChildByName("content"):getChildByName("container"):addChild(contributeLayer)
    contributeLayer:setDelegate(self)
    self._contributeLayer = contributeLayer
    
    techContent:getChildByName("content"):getChildByName("Panel_1"):setVisible(false)
    self.lockPanle = techContent:getChildByName("content"):getChildByName("Panel_1")
    self.lockPanle:getChildByName("Text_1"):setString(g_tr("allianceTechNeedStar"))
    
    techContent:getChildByName("content"):getChildByName("Text_cnt"):setString(g_tr("guildTechPeopleCnt"))
    
    local loadingBar = techContent:getChildByName("content"):getChildByName("LoadingBar_1")
    loadingBar:setPercent(0)
    
    defaultScienceType = g_AllianceMode.getBaseData().science_type
    if defaultScienceType == 0 then
        defaultScienceType = 11
    end
    
    for i = 1, 3 do
        techContent:getChildByName("content"):getChildByName("Image_xz"..i):getChildByName("Text_9")
        :setString((i*eachCnt).."")
        
        local icon = techContent:getChildByName("content"):getChildByName("Image_xz"..i)
        icon:setTouchEnabled(true)
        icon.idx = i
        icon:getChildByName("Image_4"):setVisible(false)
        icon:getChildByName("Image_x1"):setVisible(true)
        icon:addClickEventListener(function(sender)
           
            local dropId = 0
            if sender.idx ==1 then
                dropId = 1310001
            elseif sender.idx == 2 then
                dropId = 1310002
            elseif sender.idx == 3 then
                dropId = 1310003
            end
            
            local dropGroups = g_gameTools.getDropGroupByDropIdArray({dropId})
            
            local btnTxt = g_tr("commonAwardGet")
            local btnEnabled = true
            
            local haveDonateNum = g_AllianceMode.getBaseData().donate_counter
            local lastCntupdateTime = g_AllianceMode.getBaseData().donate_date
            if not g_clock.isSameDay(tonumber(lastCntupdateTime),tonumber(g_clock.getCurServerTime())) then
                haveDonateNum = 0
            end
            if haveDonateNum >= i*10 then
                
                local donateReward = self._playerGuildDonate.donate_reward or {}
                for key, var in ipairs(donateReward) do
                    if i == tonumber(var) then
                        btnEnabled = false
                        btnTxt = g_tr("commonAwardGeted")
                    end
                end
            else
                btnEnabled = false
            end
                
            local getAwardFunc = function()
                local resultHandler = function(result,msgData)
                    if result == true then
                      require("game.uilayer.task.AwardsToast").show(dropGroups)
                      table.insert(self._playerGuildDonate.donate_reward,i)
                      self:updateAwardStatus(self._playerGuildDonate)
                    end
                end
                g_sgHttp.postData("Guild/donateReward",{id = i},resultHandler)
            end

            local view = require("game.uilayer.task.TaskAwardAlertLayer"):create(dropGroups,getAwardFunc,btnEnabled,btnTxt)
            g_sceneManager.addNodeForUI(view)
        end)
    end
    
    --关闭本页
    local btnClose = baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent(true)
            if onCloseCallback then
                onCloseCallback()
            end
        end
    end)
    
    --帮助
    local btnHelp = baseNode:getChildByName("Image_4")
    btnHelp:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            require("game.uilayer.common.HelpInfoBox"):show(10) 
        end
    end)
    
    local menu1 = baseNode:getChildByName("btn_menu_1")
    menu1:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabMenu(1)
        end
    end)
    
    local menu2 = baseNode:getChildByName("btn_menu_2")
    menu2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabMenu(2)
        end
    end)
    
    local menu3 = baseNode:getChildByName("btn_menu_3")
    menu3:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabMenu(3)
        end
    end)
    
    self._baseNode:getChildByName("Text_2"):setString(g_tr("allianceHonor"))--联盟荣誉
    
    local costType = g_Consts.AllCurrencyType.PlayerHonor
    local resPath = g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType)
    self._baseNode:getChildByName("Image_3_0"):loadTexture(resPath)
    
    self._tabMenus = {menu1,menu2,menu3}
    
    self:updateView()
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
      
        self._contributeLayer:setVisible(false)
        --请求科技列表
        g_busyTip.show_1()
        g_AllianceMode.reqTechDataAsync(function(result,msgData)
            g_busyTip.hide_1()
            if result then
                self._contributeLayer:setVisible(true)
                
                local startIdx = 1
                local techList = g_AllianceMode.getAllianceTechListByScienceType(defaultScienceType)
                for key, var in ipairs(techList) do
                    startIdx = var:getConfig().level_type
                end
                print("startIdx:",startIdx)
                self:tabMenu(startIdx)
                
            else
                self:removeFromParent()
            end
        end)
      
      elseif eventType == "exit" then
          
      end 
    end )
    
    
    
end

function AllianceTechMainLayer:updateAwardStatus(playerGuildDonate)
    if playerGuildDonate == nil then
       return
    end
    
    self._playerGuildDonate = playerGuildDonate
    
    if self._playerGuildDonate.donate_reward == nil then
       self._playerGuildDonate.donate_reward = {}
    end
    
    local haveDonateNum = g_AllianceMode.getBaseData().donate_counter
    local lastCntupdateTime = g_AllianceMode.getBaseData().donate_date
    if not g_clock.isSameDay(tonumber(lastCntupdateTime),tonumber(g_clock.getCurServerTime())) then
        haveDonateNum = 0
    end
    
    local loadingBar = self._techContent:getChildByName("content"):getChildByName("LoadingBar_1")
    loadingBar:setPercent(haveDonateNum/30*100)
    
     for i = 1, 3 do
        local icon = self._techContent:getChildByName("content"):getChildByName("Image_xz"..i)
        icon:getChildByName("Panel_2"):removeAllChildren()
        local needAnima = false
        local conditionMatch = (haveDonateNum >= i*10)
        icon:getChildByName("Image_4"):setVisible(false)
        icon:getChildByName("Image_x1"):setVisible(true)
        if conditionMatch then
            needAnima = true
            local donateReward = self._playerGuildDonate.donate_reward or {}
            for key, var in ipairs(donateReward) do
            	if tonumber(var) == i then
            	   needAnima = false
            	   icon:getChildByName("Image_4"):setVisible(true)
                 icon:getChildByName("Image_x1"):setVisible(false)
            	   break
            	end
            end
        end
        
        if needAnima then
            local aniCon = icon:getChildByName("Panel_2")
            local projName = "Effect_ChengZhangJiJingBaoXiang"
            local animPath = "anime/"..projName.."/"..projName..".ExportJson"
            local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
            aniCon:addChild(armature)
            --armature:setPosition(cc.p(aniCon:getContentSize().width * 0.5,aniCon:getContentSize().height * 0.5))
            animation:play("Animation1")
        end
        
     end
    
end

function AllianceTechMainLayer:resetListView()
     if  self._leftListView then
          self._leftListView:removeFromParent()
     end
     
     self._leftListViewOrginal:setVisible(false)
     self._leftListView = self._leftListViewOrginal:clone()
     self._leftListView:setVisible(true)
     self._leftListViewOrginal:getParent():addChild(self._leftListView)
     
     
     local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if self._currentTechIdx == sender:getCurSelectedIndex() + 1 then
                return 
            end
            --print("touched:",sender:getCurSelectedIndex() + 1)
            
            self._lastSelectedItem = self._leftListView:getItem(self._currentTechIdx - 1)
            self:selectedListItem(self._lastSelectedItem,false)
    
            
            self._currentTechIdx = sender:getCurSelectedIndex() + 1
            self:updateDetailPage(self._currentTechIdx)
        end
     end
    
     self._leftListView:addEventListener(listViewEvent)
    
     
end


--切换联盟科技阶段标签
function AllianceTechMainLayer:tabMenu(idx)
    if self._currentLevelType == idx then
        return
    end
    
    self._currentLevelType = idx
    self._currentTechIdx = 1

    for key, btn in pairs(self._tabMenus) do
        btn:setEnabled(true)
    end
    if self._tabMenus[idx] then
        self._tabMenus[idx]:setEnabled(false)
    end
    
    self:resetListView()
    
    local menusData = g_AllianceMode.getTechDataByLevelType(idx)
    self._menusData = menusData

    for key, var in pairs(menusData) do
       self._leftListView:pushBackDefaultItem()
    end
    
    local items = self._leftListView:getItems()
    for i =1, #items do
      local item = self._leftListView:getItem(i - 1)
      if item then
          if menusData[i]:getConfig().science_type == defaultScienceType then
             self._currentTechIdx = i
          end
          self:updateListItem(item,menusData[i])
          item:getChildByName("tech_item"):getChildByName("Button_yx"):addClickEventListener(function()
              local targetScienceType = menusData[i]:getConfig().science_type
              local resultHandler = function(result,msgData)
                  if result then
                      defaultScienceType = targetScienceType
                      g_airBox.show(g_tr("guildTechFirstSetSuccess"))
                  end
              end
              g_sgHttp.postData("Guild/donateRecommend",{scienceType = targetScienceType},resultHandler)
          end)
      end
    end
    if self._currentTechIdx > 3 then
        self._leftListView:refreshView() 
        self._leftListView:scrollToPercentVertical(self._currentTechIdx/#items*100,0.5,true)
    end
    self:updateDetailPage(self._currentTechIdx)
end

--更新捐献页面
function AllianceTechMainLayer:updateDetailPage(idx)
    local item = self._leftListView:getItem(idx - 1)
    self:selectedListItem(item,true)
    
    local allianceTech = self._menusData[idx]
    if allianceTech then
      self._contributeLayer:setLeftMenu(item)
      self._contributeLayer:setData(allianceTech)
      self:updateView()
    end
end

function AllianceTechMainLayer:selectedListItem(item,isSelected)
    item:getChildByName("tech_item"):getChildByName("Image_28_0"):setVisible(isSelected)
    item:getChildByName("tech_item"):getChildByName("Button_yx"):setVisible(isSelected)
    if isSelected and g_AllianceMode.isAllianceLeader() then
        item:getChildByName("tech_item"):getChildByName("Button_yx"):setVisible(true)
    end
    if item:getChildByName("tech_item"):getChildByName("Image_29"):isVisible() then
        item:getChildByName("tech_item"):getChildByName("Button_yx"):setVisible(false)
    end
end

--更新列表信息
function AllianceTechMainLayer:updateListItem(item,allianceTech)
    item:getChildByName("tech_item"):getChildByName("name"):setString(g_tr(allianceTech:getConfig().name))
    item:getChildByName("tech_item"):getChildByName("level"):getChildByName("Text_1"):setString("Lv."..allianceTech:getLevel())
    --item:getChildByName("tech_item"):getChildByName("Button_yx"):setVisible(false)
    item:getChildByName("tech_item"):getChildByName("Button_yx"):getChildByName("Text_27"):setString(g_tr("guildTechFirst"))
    item:getChildByName("tech_item"):getChildByName("Button_yx"):getChildByName("Text_28"):setString("")

--    local exp = allianceTech:getExp()
--    local maxExp = allianceTech:getConfig().levelup_exp
--    local percent = exp/maxExp * 100
--    item:getChildByName("tech_item"):getChildByName("bg_LoadingBar"):getChildByName("LoadingBar"):setPercent(percent)
--    
    --星级信息显示
    for i = 1, 5 do
        item:getChildByName("tech_item"):getChildByName("Panel_6"):getChildByName("Panel_"..i):setVisible(false)
        item:getChildByName("tech_item"):getChildByName("Panel_6"):getChildByName("Panel_"..i):getChildByName("Image_02"):setVisible(false)
        item:getChildByName("tech_item"):getChildByName("Panel_6"):getChildByName("Panel_"..i):getChildByName("Image_01"):removeAllChildren()
    end
    local maxStar = allianceTech:getConfig().max_star
    local star = allianceTech:getConfig().star
    
    local targetStar = nil
    for i = 1, maxStar do
        item:getChildByName("tech_item"):getChildByName("Panel_6"):getChildByName("Panel_"..i):setVisible(true)
        item:getChildByName("tech_item"):getChildByName("Panel_6"):getChildByName("Panel_"..i):getChildByName("Image_02"):setVisible(i <= star and allianceTech:getServerData() ~= nil)
        if not item:getChildByName("tech_item"):getChildByName("Panel_6"):getChildByName("Panel_"..i):getChildByName("Image_02"):isVisible()
        and targetStar == nil then
            targetStar = item:getChildByName("tech_item"):getChildByName("Panel_6"):getChildByName("Panel_"..i):getChildByName("Image_01")
        end
    end
    local exp = allianceTech:getExp()
    if targetStar and exp > 0 then
       --星星动画
       local projName = "Effect_StarKuang"
       local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName)
       targetStar:addChild(armature)
       armature:setPosition(cc.p(targetStar:getContentSize().width*0.5,targetStar:getContentSize().height*0.5))
       animation:play("Animation1")
    end
    
    local isMaxLevel = allianceTech:getLevel() >= allianceTech:getConfig().max_level
    item:getChildByName("tech_item"):getChildByName("Image_29"):setVisible(isMaxLevel)
    
    local imageId = allianceTech:getConfig().icon_img
    if imageId > 0 then
      item:getChildByName("tech_item"):getChildByName("pic"):loadTexture(g_resManager.getResPath(imageId))
    end
    
end

function AllianceTechMainLayer:updateView()
    self._baseNode:getChildByName("Text_3"):setString(string.formatnumberthousands(g_PlayerMode.GetData().guild_coin))
end

return AllianceTechMainLayer