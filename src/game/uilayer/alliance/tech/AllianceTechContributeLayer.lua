local AllianceTechContributeLayer = class("AllianceTechContributeLayer",function()
    return cc.Layer:create()
end)

local buttonPosX = 0
local btnClickProtect = {}
function AllianceTechContributeLayer:ctor()
	local uiLayer = cc.CSLoader:createNode("alliance_tech_contribute_content.csb")
	self:addChild(uiLayer)
	self._uiLayer = uiLayer
	
	self._uiLayer:getChildByName("time_text"):setString(g_tr("donateCd"))--捐献冷却时间
	
	buttonPosX = self._uiLayer:getChildByName("Panel_contribute"):getChildByName("panel_contribute_1"):getChildByName("btn_contribute"):getChildByName("text")
    :getPositionX()
    
    self._uiLayer:getChildByName("Panel_contribute"):getChildByName("Panel_getStr"):getChildByName("text_tips_1"):setString(g_tr("allianceTechGet"))
    
    local touchContributeHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           
            print("scienceDonate:",sender.btnIdx)
            self:scienceDonate(sender.btnIdx)
        end
    end
    
	for i = 1, 3 do
        local currentPanelContribute = self._uiLayer:getChildByName("Panel_contribute"):getChildByName("panel_contribute_"..i)
        currentPanelContribute:getChildByName("pic_rewards_1"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + g_Consts.AllCurrencyType.PlayerHonor))
        currentPanelContribute:getChildByName("pic_rewards_2"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + g_Consts.AllCurrencyType.AllianceTechExp))
        
        local contributeBtn =  currentPanelContribute:getChildByName("btn_contribute")
        contributeBtn.btnIdx = i
        contributeBtn:addTouchEventListener(touchContributeHandler)
        contributeBtn:getChildByName("text"):setString(g_tr("donate"))
    end
    
    uiLayer:getChildByName("Image_3"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + g_Consts.AllCurrencyType.AllianceTechExp))
    
    local scienceUpBtn = self._uiLayer:getChildByName("Panel_4"):getChildByName("Button_learn")
    scienceUpBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("scienceUpBtn click")
            self:scienceUpHandler()
        end
    end)
    
    --effect container
    self._effectContainer = cc.Node:create()
    self._uiLayer:getChildByName("bg_LoadingBar"):addChild(self._effectContainer)
end

function AllianceTechContributeLayer:scienceUpHandler()
    local resultHandler = function(result, msgData)
        if result then
            g_airBox.show(g_tr("startLearning"))
            self._techContributeServerData = msgData
            self._Data:updateExtraInfo(self._techContributeServerData.GuildScience)
            self:updateView()
        end
    end
    g_sgHttp.postData("Guild/scienceUp",{scienceType = self:getData():getConfig().science_type},resultHandler)
end

------
--  Getter & Setter for
--      AllianceTechContributeLayer._LeftMenu
-----
function AllianceTechContributeLayer:setLeftMenu(LeftMenu)
		self._LeftMenu = LeftMenu
end

function AllianceTechContributeLayer:getLeftMenu()
		return self._LeftMenu
end

------
--  Getter & Setter for
--      AllianceTechContributeLayer._Delegate
-----
function AllianceTechContributeLayer:setDelegate(Delegate)
		self._Delegate = Delegate
end

function AllianceTechContributeLayer:getDelegate()
		return self._Delegate
end

function AllianceTechContributeLayer:scienceDonate(buttonIdx)

     if self._techContributeServerData == nil then
        return
     end
     
     local lastClickTime = btnClickProtect[buttonIdx] or 0
     local currentTime = g_clock.getCurServerTime()
--     if currentTime - lastClickTime <= 1 then
--        return
--     end
     btnClickProtect[buttonIdx] = currentTime
     
     g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
     
     if self._techContributeServerData.PlayerGuildDonate.status ~= 0 then
        local finishTime = self._techContributeServerData.PlayerGuildDonate.finish_time
        local doSpeedUpHandler = function(costGem)
            local resultHandler = function(result, msgData)
              if result then
                  print("clear success")
                  self._techContributeServerData.PlayerGuildDonate = msgData.PlayerGuildDonate
                  self:updateView()
              end
            end
            g_sgHttp.postData("Guild/scienceClearTime",{},resultHandler)
        end
        g_msgBox.showSpeedUp(finishTime, g_tr("tipClearDonateCD"), nil, nil, doSpeedUpHandler)
        return
     end
     
     local scienceType = self._techContributeServerData.GuildScience.science_type

     local resultHandler = function(result, msgData)
        if result then
            local data = self:getData()
            local award1 = string.formatnumberthousands(data:getConfig()["button"..buttonIdx.."_honor"])
            local award2 = string.formatnumberthousands(data:getConfig()["button"..buttonIdx.."_exp"])
            local award1Str = award1..g_tr("assets"..g_Consts.AllCurrencyType.PlayerHonor)
            local award2Str = award2..g_tr("assets"..g_Consts.AllCurrencyType.AllianceTechExp)
            
            g_airBox.show(g_tr("donateSuccess",{award1 = award1Str,award2 = award2Str}))
            self._techContributeServerData = msgData
            self._Data:updateExtraInfo(self._techContributeServerData.GuildScience)
            self:updateView()
        else
            --g_airBox.show("Donate fail")
            print("Donate fail")
        end
    end
    g_sgHttp.postData("Guild/scienceDonate",{scienceType = scienceType,btn = buttonIdx},resultHandler)
end

------
--  Getter & Setter for
--      AllianceTechContributeLayer._Data
--      param: AllianceTech.lua
-----
function AllianceTechContributeLayer:setData(allianceTech)
    self:setVisible(false)
	self._Data = allianceTech
	if allianceTech then
        self:refreshSeverData()
	end
end

function AllianceTechContributeLayer:refreshSeverData()
    if self:getDelegate().lockPanle then
        self:getDelegate().lockPanle:setVisible(false)
    end

    local allianceTech = self:getData()
    
    local resultHandler = function(result, msgData)
        g_busyTip.hide_1()
        if result then
            self._techContributeServerData = msgData
            self:setVisible(true)
            allianceTech:updateExtraInfo(self._techContributeServerData.GuildScience)
            self:updateView()
            
            self:getDelegate():updateAwardStatus(self._techContributeServerData.PlayerGuildDonate)
        else
            self:getDelegate().lockPanle:setVisible(true)
            local leftMeunItem = self:getLeftMenu()
            leftMeunItem:getChildByName("tech_item"):getChildByName("Button_yx"):setVisible(false)
            if self:getDelegate().lockPanle then
                local currentStar = 0
                local needStar = allianceTech:getConfig().open_task
                for key, var in pairs( g_AllianceMode.getAllAllianceTechs()) do
                    if var:getStatus() == 0 then
                       currentStar = currentStar + var:getServerConfigLevel()
                    else
                       if var:getConfig().level == var:getConfig().max_level then
                           currentStar = currentStar + var:getServerConfigLevel()
                       else
                           currentStar = currentStar + var:getServerConfigLevel() - 1
                       end
                    
                       
                    end
                    
                    
                end
                
                self:getDelegate().lockPanle:getChildByName("Text_2"):setString(currentStar.."/"..needStar)
--                if currentStar < needStar then
--                    self:getDelegate().lockPanle:setVisible(true)
--                end
            end
        end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("Guild/getDonate",{scienceType = allianceTech:getConfig().science_type},resultHandler,true)
end

function AllianceTechContributeLayer:getData()
		return self._Data
end

function AllianceTechContributeLayer:updateView()
   --[[ self._techContributeServerData
      {
    "code": 0,
    "data": {
        "GuildScience": {
            "id": 40,
            "science_type": 12,
            "science_level": 1,
            "science_exp": 1280,
            "science_level_type": 1,
            "finish_time": 1448343854,
            "status": 0
        },
        "PlayerGuildDonate": {
            "id": 110,
            "status": 0,
            "finish_time": 1448344574
        },
        "PlayerGuildDonateButton": {
            "id": 116,
            "science_type": 12,
            "level": 2,
            "btn1_cost": 20001,
            "btn1_unit": 3,
            "btn1_num": 3000,
            "btn2_cost": 0,
            "btn2_unit": 0,
            "btn2_num": 0,
            "btn2_counter": 0,
            "btn3_cost": 0,
            "btn3_unit": 0,
            "btn3_num": 0,
            "btn3_counter": 0
        }
    },
    "basic": []
}
    
    ]]
    if self._techContributeServerData == nil then
       return
    end
    local data = self:getData()
    
    local leftMeunItem = self:getLeftMenu()
    assert(leftMeunItem)
    self:getDelegate():updateListItem(leftMeunItem,data)
    self:getDelegate():updateView()

    self._uiLayer:getChildByName("tech_info_text"):setString(g_tr(data:getConfig().description))
    self:stopAllActions()
    self._effectContainer:removeAllChildren()
    
    --local exp = self._techContributeServerData.GuildScience.science_exp
    local exp = data:getExp()
    local maxExp = data:getConfig().levelup_exp
    local percent = exp/maxExp * 100
    
    self._uiLayer:getChildByName("Text_time"):setString(string.formatnumberthousands(exp).."/"..string.formatnumberthousands(maxExp))
    
    self._uiLayer:getChildByName("bg_LoadingBar"):getChildByName("LoadingBar"):setPercent(percent)
    
    self._uiLayer:getChildByName("level"):getChildByName("Text_1"):setString("lv."..data:getLevel())
    
    self._uiLayer:getChildByName("Text_2"):setString(g_tr(data:getConfig().name))
    
    local buffId = data:getConfig().buff[1][1]
    print("buffId:",buffId)
    local type = g_data.buff[buffId].buff_type
    local value = data:getConfig().buff_num
    local valueStr = ""
    local nextValueStr = ""
    print("~~~~~~~~~~~~~~~~~~~~~~~~~level",data:getLevel())
    if data:getLevel() < 1 and data:getConfig().star < 1 then
        if type == 2 then
            valueStr = "0"
            nextValueStr = string.formatnumberthousands(value)
        elseif type == 1 then
            valueStr = "0.00%"
            nextValueStr = string.format("%.2f",(value/10000)*100).."%"
        end
    else
        if type == 2 then
            valueStr = string.formatnumberthousands(value)
            nextValueStr = string.formatnumberthousands(data:getConfig().next_buff_num)
        elseif type == 1 then
            valueStr = string.format("%.2f",value/10000*100).."%"
            nextValueStr = string.format("%.2f",(data:getConfig().next_buff_num)/10000 * 100).."%"
        end
    end
    
    self._uiLayer:getChildByName("num_text_1"):setString(valueStr)
    self._uiLayer:getChildByName("num_text_2"):setString(nextValueStr)
    
    self._uiLayer:getChildByName("label_text_1"):setString(g_tr("currentLevelEffect"))--当前效果：
    self._uiLayer:getChildByName("label_text_2"):setString(g_tr("nextLevelEffect"))--下级效果：
    
    self._uiLayer:getChildByName("Text_tips"):setString("") --R4 ,R5联盟成员才有权限研究联盟科技

    self._uiLayer:getChildByName("Panel_contribute"):setVisible(false)
    self._uiLayer:getChildByName("Panel_4"):setVisible(false)
    
    local techStatus = data:getStatus()
    local updateStarShow = function(techData)
        --星级信息显示
        for i = 1, 5 do
            self._uiLayer:getChildByName("Panel_xingxing"):getChildByName("Panel_"..i):setVisible(false)
            self._uiLayer:getChildByName("Panel_xingxing"):getChildByName("Panel_"..i):getChildByName("Image_02"):setVisible(false)
            self._uiLayer:getChildByName("Panel_xingxing"):getChildByName("Panel_"..i):getChildByName("Image_01"):removeAllChildren()
        end
        local maxStar = techData:getConfig().max_star
        local star = techData:getConfig().star
        print("star:",star,maxStar)
        print("techData:",techData:getConfig().id)
        local targetStar = nil
        for i = 1, maxStar do
            self._uiLayer:getChildByName("Panel_xingxing"):getChildByName("Panel_"..i):setVisible(true)
            --if techData:getServerConfigLevel() > 0  then
                --if  star < maxStar or techStatus ~= 0 then
                    self._uiLayer:getChildByName("Panel_xingxing"):getChildByName("Panel_"..i):getChildByName("Image_02"):setVisible(i <= star)
                --end
            --end
            
            if not self._uiLayer:getChildByName("Panel_xingxing"):getChildByName("Panel_"..i):getChildByName("Image_02"):isVisible()
            and targetStar == nil then
                targetStar = self._uiLayer:getChildByName("Panel_xingxing"):getChildByName("Panel_"..i):getChildByName("Image_01")
            end
        end
        
        local exp = techData:getExp()
        if targetStar and exp > 0 then
           --星星动画
           local projName = "Effect_StarKuang"
           local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName)
           targetStar:addChild(armature)
           armature:setPosition(cc.p(targetStar:getContentSize().width*0.5,targetStar:getContentSize().height*0.5))
           animation:play("Animation1")
        end
    
    end
   
    updateStarShow(data)
    
    dump(self._techContributeServerData)
    
    local haveButtonInfo = table.nums(self._techContributeServerData.PlayerGuildDonateButton) > 0
    self._uiLayer:getChildByName("Panel_contribute"):setVisible(false)
    
    self._uiLayer:getChildByName("time_text"):setVisible(false)
    self._uiLayer:getChildByName("time_num"):setString("")
    
    local imageId = data:getConfig().icon_img
    if imageId > 0 then
        self._uiLayer:getChildByName("tech_pic"):loadTexture(g_resManager.getResPath(imageId))
    end

    if techStatus == 1 or techStatus == 2 then
          local techConfigId = data:getConfig().id - 1
          local lastTechInfo = g_data.alliance_science[techConfigId]
          if lastTechInfo then
             self._uiLayer:getChildByName("Text_time"):setString(string.formatnumberthousands(lastTechInfo.levelup_exp).."/"..string.formatnumberthousands(lastTechInfo.levelup_exp))
          end
          self._uiLayer:getChildByName("bg_LoadingBar"):getChildByName("LoadingBar"):setPercent(100)
          self._uiLayer:getChildByName("label_text_2"):setString("")--下级效果：
          self._uiLayer:getChildByName("num_text_2"):setString("")
         
          if techStatus == 1 then --可升级
              local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
              if myInfo.rank >= 4 then
                  self._uiLayer:getChildByName("Panel_4"):setVisible(true)
                  local needTime = data:getConfig().up_time
                  self._uiLayer:getChildByName("Panel_4"):getChildByName("time_num"):setString(g_gameTools.convertSecondToString(needTime))
              else
                  self._uiLayer:getChildByName("Text_tips"):setString(g_tr("allianceTechLearnLimits")) --R4 ,R5联盟成员才有权限研究联盟科技
              end
              
          elseif techStatus == 2 then --升级中
              --显示升级剩余CD
              self._uiLayer:getChildByName("time_text"):setString(g_tr("upgradeCD"))--升级剩余时间
              self._uiLayer:getChildByName("time_text"):setVisible(true)
              
              
              local timeLabel = self._uiLayer:getChildByName("time_num")
              local updateTimeStr = function()
              
                  local currentTime = g_clock.getCurServerTime()
                  local secondsLeft = data:getFinishTime() - currentTime + 3
                  if secondsLeft < 0 then
                      secondsLeft = 0
                      self:stopAllActions()
                      timeLabel:setString("")
                      self._uiLayer:getChildByName("time_text"):setVisible(false)
                      self:refreshSeverData()
                  else
                      timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft))
                  end
              end
              
              local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
              local action = cc.RepeatForever:create(seq)
              self:runAction(action)
              
              local size = self._uiLayer:getChildByName("bg_LoadingBar"):getContentSize()
              
              local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_JinDuTiao/Effect_JinDuTiao.ExportJson", "Effect_JinDuTiao")
              self._effectContainer:addChild(armature)
              armature:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
              animation:play("Animation1")
              
              updateTimeStr()
          end

    end
    
    if haveButtonInfo and techStatus == 0 then
        self._uiLayer:getChildByName("Panel_contribute"):setVisible(true)
        self._uiLayer:getChildByName("time_text"):setString(g_tr("donateCd"))--捐献冷却时间
        local color = cc.c4b(255,255,255,255)
        local btnLabelColor = cc.c4b(255,255,255,255)
        if self._techContributeServerData.PlayerGuildDonate.status > 0 then
            color = cc.c4b(255,0,0,255)
            btnLabelColor = cc.c4b(255,0,0,255)
        end
        self._uiLayer:getChildByName("time_num"):setTextColor(color)
        
        --显示捐赠CD
        self._uiLayer:getChildByName("time_text"):setVisible(true)
        
        local timeLabel = self._uiLayer:getChildByName("time_num")
        local updateTimeStr = function()
            local currentTime = g_clock.getCurServerTime()
            local secondsLeft = self._techContributeServerData.PlayerGuildDonate.finish_time - currentTime + 1
            --secondsLeft = secondsLeft - 1
            if secondsLeft < 0 then
                secondsLeft = 0
                self:stopAllActions()
                timeLabel:setString("")
                self._uiLayer:getChildByName("time_text"):setVisible(false)
            else
                timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft))
            end
        end
        
        local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
        local action = cc.RepeatForever:create(seq)
        self:runAction(action)
        updateTimeStr()
        
        --按钮下方获得信息
        for i = 1, 3 do
            local currentPanelContribute = self._uiLayer:getChildByName("Panel_contribute"):getChildByName("panel_contribute_"..i)
            currentPanelContribute:getChildByName("text_num_1"):setString(string.formatnumberthousands(data:getConfig()["button"..i.."_honor"]))
            currentPanelContribute:getChildByName("text_num_2"):setString(string.formatnumberthousands(data:getConfig()["button"..i.."_exp"]))
            
            local costNum = self._techContributeServerData.PlayerGuildDonateButton["btn"..i.."_num"]
            local strNum = "???"
            if costNum > 0 then
                strNum = string.formatnumberthousands(costNum)
            end
            local costType = self._techContributeServerData.PlayerGuildDonateButton["btn"..i.."_unit"]
            local picCost = currentPanelContribute:getChildByName("pic_cost")
            picCost:setVisible(false)
            local offsetX = 25
            if costNum > 0 and costType > 0 then
              picCost:setVisible(true)
              offsetX = 0
              picCost:loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
            end
            
            currentPanelContribute:getChildByName("btn_contribute"):setEnabled((costNum > 0))
            
            local btnLabel = currentPanelContribute:getChildByName("btn_contribute"):getChildByName("text")
            btnLabel:setString(strNum)
            btnLabel:setPositionX(buttonPosX - offsetX)
            btnLabel:setTextColor(btnLabelColor)
            if costNum <= 0 then
                btnLabel:setTextColor(cc.c4b(255,255,255,180))
            end
        end
    end
    
     --MAX LEVEL
     if data:getConfig().level == data:getConfig().max_level then
         self._uiLayer:getChildByName("Panel_4"):setVisible(false)
         self._uiLayer:getChildByName("Text_tips"):setString(g_tr("allianceTechLevelMax")) --该科技已升级至最高等级
         self._uiLayer:getChildByName("label_text_2"):setString("")--下级效果：
         self._uiLayer:getChildByName("num_text_2"):setString("")
         self._uiLayer:getChildByName("bg_LoadingBar"):getChildByName("LoadingBar"):setPercent(100)
         self._uiLayer:getChildByName("Panel_contribute"):setVisible(false)
         local maxExp = data:getConfig().levelup_exp
         self._uiLayer:getChildByName("Text_time"):setString(string.formatnumberthousands(maxExp).."/"..string.formatnumberthousands(maxExp))
     end
    
end


return AllianceTechContributeLayer