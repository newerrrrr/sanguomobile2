local ActivityFundLayer = class("ActivityFundLayer",function()
    return cc.Layer:create()
end)

local costs = g_gameTools.getCostsByCostId(601,1)

--local _checkIsGetedNumAward = function(id)
--    local isGeted = false
--    local data = g_playerGrownFundData.GetData()
--    local getedNumAwards = data.num_reward
--    
--    for key, var in pairs(getedNumAwards) do
--        if tonumber(var) == id then
--           isGeted = true 
--           break
--        end
--    end
--    return isGeted
--end
    
function ActivityFundLayer:ctor()
    local uiLayer =  cc.CSLoader:createNode("fund_main1.csb")
    self:addChild(uiLayer)
    self._uiLayer = uiLayer
    
    self:registerScriptHandler(function(eventType)
        if eventType == "enter" then
            g_playerGrownFundData.SetView(self)
        elseif eventType == "exit" then
			g_gameCommon.removeEventHandler(g_Consts.CustomEvent.Money,self)
            g_playerGrownFundData.SetView(nil)
        end 
    end )
    
    local helpBtn = self._uiLayer:getChildByName("Button_wenhao")
    helpBtn:addClickEventListener(function(sender)
        require("game.uilayer.common.HelpInfoBox"):show(12) 
    end)
    
    local background = self._uiLayer:getChildByName("Image_21")
    local projName = "Effect_ChengZhangJiJing"
    local animPath = "anime/"..projName.."/"..projName..".ExportJson"
    local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
    background:addChild(armature)
    armature:setPosition(cc.p(background:getContentSize().width * 0.5,background:getContentSize().height * 0.5))
    animation:play("Effect_ChengZhangJiJingBeiJingFX")
    
    local data = g_playerGrownFundData.GetData()
    local buyBtn = self._uiLayer:getChildByName("Panel_vip"):getChildByName("Button_14")
    if data.buy == 0 then --未购买
        
        local projName = "Effect_AnNiuSaoGuangOne"
        local animPath = "anime/"..projName.."/"..projName..".ExportJson"
        local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
        buyBtn:addChild(armature)
        armature:setPosition(cc.p(buyBtn:getContentSize().width * 0.5,buyBtn:getContentSize().height * 0.5))
        animation:play("Animation1")
    
        buyBtn:addClickEventListener(function(sender)
            self:buyHandler()
        end)
        buyBtn:getChildByName("Text_40"):setString(g_tr("fundBuy"))
    else --已购买
        buyBtn:setEnabled(false)
        buyBtn:getChildByName("Text_40"):setString(g_tr("fundBuyDone"))
    end
    --self._uiLayer:getChildByName("Panel_vip"):getChildByName("Text_vip"):setString(g_tr("longCardUser"))
    
    self._uiLayer:getChildByName("Panel_vip"):getChildByName("Text_1"):setString(g_tr("fundCost"))
    self._uiLayer:getChildByName("Panel_vip"):getChildByName("Text_3"):setString(g_tr("fundNumExt"))
    self._uiLayer:getChildByName("Panel_vip"):getChildByName("Text_3_0"):setString(g_tr("fundNumExt"))
    self._uiLayer:getChildByName("Panel_vip"):getChildByName("Text_1_0"):setString(g_tr("fundGet"))
    
   
    self._uiLayer:getChildByName("Panel_vip"):getChildByName("Text_2"):setString(tostring(costs[1].cost_num)) --花费
    self._uiLayer:getChildByName("Panel_vip"):getChildByName("Text_2_0"):setString("10000") --返回
    
    
    
    for i = 1, 8 do
        local icon = self._uiLayer:getChildByName("Panel_bx"..i)
        icon:setTouchEnabled(true)
        
        if i == 3 then --显示第三个位置的第一个掉落
            local maxNum = g_data.growth_number_reward[#g_data.growth_number_reward].number
            local loadingBar = self._uiLayer:getChildByName("LoadingBar_1")
            local startX = loadingBar:getPositionX() - loadingBar:getContentSize().width/2
            local number = g_data.growth_number_reward[i].number
            local posPercent = number/maxNum
            local iconExtr = self._uiLayer:getChildByName("Panel_zf")
            local posX = startX + loadingBar:getContentSize().width * posPercent
            iconExtr:setPositionX(posX)
            
            local dropGroups = g_gameTools.getDropGroupByDropIdArray({ g_data.growth_number_reward[i].drop},1)
            local itemView = require("game.uilayer.common.DropItemView"):create(dropGroups[1][1],dropGroups[1][2],dropGroups[1][3])
            itemView:enableTip()
            local imgCon = iconExtr:getChildByName("Image_18")
            imgCon:addChild(itemView)
            local size = imgCon:getContentSize()
            itemView:setPosition(cc.p(size.width*0.5,size.height*0.5))
            local scale = size.width/itemView:getContentSize().width
            itemView:setScale(scale)
            
            local generalInfo = g_data.general[2010501]--张飞武将信息
            if generalInfo then
                self._uiLayer:getChildByName("Image_zfdt"):loadTexture(g_resManager.getResPath(generalInfo.general_big_icon))
            end
        end
  
        icon:addClickEventListener(function(sender)
            local rewardInfo = sender.rewardInfo
            local dropGroups = g_gameTools.getDropGroupByDropIdArray({rewardInfo.drop},1)
--            local awardLayer = require("game.uilayer.activity.common.AwardList"):create(dropGroups)
--            g_sceneManager.addNodeForUI(awardLayer)
            
            local btnTxt = g_tr("commonAwardGet")
            local isGeted = g_playerGrownFundData.checkIsGetedNumAward(rewardInfo.id)
            if isGeted  then
                btnTxt = g_tr("commonAwardGeted")
            end
            
            local currentNum = data.total_num
            local maxNum = g_data.growth_number_reward[#g_data.growth_number_reward].number
            local btnEnabled = (currentNum >= rewardInfo.number) and (isGeted == false)
    
            local getAwardFunc = function()
                local data = g_playerGrownFundData.GetData()
                if data.buy == 0 then
                    g_msgBox.show(g_tr("fundGetAwardTip"),nil,nil,function(event)
                        if event == 0 then
                           self:buyHandler()
                        end
                    end,1)
                    return
                end
                
                g_sgHttp.postData("activity/growthGain",{type = 2 ,id = rewardInfo.id},function(result, msgData)
                    if result then
                        require("game.uilayer.task.AwardsToast").show(dropGroups)
                    end
                end)
            end

            local view = require("game.uilayer.task.TaskAwardAlertLayer"):create(dropGroups,getAwardFunc,btnEnabled,btnTxt)
            g_sceneManager.addNodeForUI(view)
        end)
    end
    
    self:updateView()
end

function ActivityFundLayer:buyHandler()
    if g_playerInfoData.GetData().long_card == 1 then
       self:tipBuyGrownth()
    else
       self:tipBuyLongCard()
     end
end

function ActivityFundLayer:tipBuyGrownth()
    local doBuyHandler = function()
        g_sgHttp.postData("activity/growthBuy",{},function(result, msgData)
            if result then
                g_airBox.show(g_tr("fundBuySuccessTip"))
            end
        end)
    end
    
    g_msgBox.showConsume(costs[1].cost_num, g_tr("fundBuyTip"), title, g_tr("fundBuy"),doBuyHandler)
end

function ActivityFundLayer:tipBuyLongCard()

    local priceInfo = g_moneyData.findPriceByGoodsType(2,g_channelManager.GetPayWayList()[1])
    local price = priceInfo.type..""..priceInfo.price
    
    g_msgBox.show(g_tr("fundVipBuyTip",{price = price}),nil,nil,function(event)
        if event == 0 then
           local payComplete = function(_,data)
               if data and data.goods_type == "2" then
                   g_airBox.show(g_tr("fundVipBuyTipSuccess"))
                   self:updateView()
               end
           end
           g_gameCommon.removeEventHandler(g_Consts.CustomEvent.Money,self)
           g_gameCommon.addEventHandler(g_Consts.CustomEvent.Money, payComplete, self)
           g_moneyData.payProduct(2) --传入goods_type
        end
    end,1)
end

function ActivityFundLayer:updateView()

    local data = g_playerGrownFundData.GetData()
    if not data then
        return
    end
    
--    local getedLvAwards = data.level_reward
--    
--    local checkIsGetedLvAward = function(id)
--        local isGeted = false
--        for key, var in pairs(getedLvAwards) do
--        	if tonumber(var) == id then
--        	   isGeted = true 
--        	   break
--        	end
--        end
--        return isGeted
--    end
    
    self._uiLayer:getChildByName("Panel_vip"):setVisible(data.buy == 0)
    
    --府衙等级
    local mainCityLevel = g_PlayerBuildMode.getMainCityBuilding_lv()
    local listView = self._uiLayer:getChildByName("ListView_1")
    listView:removeAllChildren()
    local listItem = cc.CSLoader:createNode("fund_list1.csb")
    
    local getedFlag = 0
    local allLength = table.nums(g_data.growth_level_reward)
    for key, var in ipairs(g_data.growth_level_reward) do
        --if not checkIsGetedLvAward(var.id) then
            local isGeted = g_playerGrownFundData.checkIsGetedLvAward(var.id)
          
            if getedFlag == 0 and not isGeted then
                getedFlag = key
            end
            
            if getedFlag == 0 and key == allLength then --全部已领取
                getedFlag = allLength
            end
        
        	local item = listItem:clone()
        	local dropGroups = g_gameTools.getDropGroupByDropIdArray({var.drop},1)
            item:getChildByName("Panel_1"):getChildByName("Text_6"):setString(dropGroups[1][3].."")
        	item:getChildByName("Panel_1"):getChildByName("Button_2"):addClickEventListener(function(sender)
        	   
        	   local data = g_playerGrownFundData.GetData()
               if data.buy == 0 then
                    g_msgBox.show(g_tr("fundGetAwardTip"),nil,nil,function(event)
                        if event == 0 then
                           self:buyHandler()
                        end
                    end,1)
                    return
               end
        	
        	   g_sgHttp.postData("activity/growthGain",{type = 1 ,id = var.id},function(result, msgData)
        	       if result then
        	           local view = require("game.uilayer.task.TaskAwardAlertLayer").new(dropGroups)
                       g_sceneManager.addNodeForUI(view)
        	       end
        	   end)
        	end)

        	--icon
        	local itemView = require("game.uilayer.common.DropItemView"):create(dropGroups[1][1],dropGroups[1][2],dropGroups[1][3])
        	itemView:setCountEnabled(false)
        	local imgCon = item:getChildByName("Panel_1"):getChildByName("Image_4")
        	imgCon:addChild(itemView)
            local size = imgCon:getContentSize()
            itemView:setPosition(cc.p(size.width*0.5,size.height*0.5))
            local scale = size.width/itemView:getContentSize().width
            itemView:setScale(scale)
        	
        	local btnStr = g_tr("commonAwardGet")
        	if isGeted then
        	   btnStr = g_tr("commonAwardGeted")
        	end
        	
        	item:getChildByName("Panel_1"):getChildByName("Button_2"):getChildByName("Text_7"):setString(btnStr)
        	item:getChildByName("Panel_1"):getChildByName("Button_2"):setEnabled((mainCityLevel >= var.level) and not isGeted)
        	item:getChildByName("Panel_1"):getChildByName("Text_5"):enableOutline(cc.c4b(0, 0, 0,255),2)
        	item:getChildByName("Panel_1"):getChildByName("Text_5_0"):enableOutline(cc.c4b(0, 0, 0,255),2)
        	item:getChildByName("Panel_1"):getChildByName("Text_ji"):enableOutline(cc.c4b(0, 0, 0,155),1)
        	item:getChildByName("Panel_1"):getChildByName("Text_5"):setString(g_tr("fundLevelType"))
        	item:getChildByName("Panel_1"):getChildByName("Text_5_0"):setString(g_tr("fundLevelExt"))
        	item:getChildByName("Panel_1"):getChildByName("Text_ji"):setString(var.level.."")
        	
        	listView:pushBackCustomItem(item)
    	--end
    end
    
    --print(getedFlag,table.nums(g_data.growth_level_reward),"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    
    if getedFlag >= 6 then
        listView:refreshView() 
        listView:scrollToPercentHorizontal(getedFlag/table.nums(g_data.growth_level_reward)*100,0.5,true)
    end
    
    --人数
    local currentNum = data.total_num
    local maxNum = g_data.growth_number_reward[#g_data.growth_number_reward].number
    if currentNum > maxNum then
        currentNum = maxNum
    end
    
    local percent = currentNum/maxNum*100
    
    local loadingBar = self._uiLayer:getChildByName("LoadingBar_1")
    loadingBar:setPercent(percent)
    
    local startX = loadingBar:getPositionX() - loadingBar:getContentSize().width/2
    for i = 1, 8 do
        local number = g_data.growth_number_reward[i].number
        local posPercent = number/maxNum
        local icon = self._uiLayer:getChildByName("Panel_bx"..i)
        icon:getChildByName("Text_1"):setString(number.."")
        local posX = startX + loadingBar:getContentSize().width * posPercent - icon:getContentSize().width/2
        icon:setPositionX(posX)
        icon.rewardInfo = g_data.growth_number_reward[i]
        
        icon:getChildByName("Image_x1"):removeAllChildren()
        
        local isGeted = g_playerGrownFundData.checkIsGetedNumAward(icon.rewardInfo.id)
        icon:getChildByName("Image_x1"):setVisible(not isGeted)
        icon:getChildByName("Image_x1_0"):setVisible(isGeted)
        
        local getAwardEnabled = --[[(g_playerGrownFundData.GetData().buy ~= 0) and]] (currentNum >= icon.rewardInfo.number) and (isGeted == false)
        if getAwardEnabled then
            local aniCon = icon:getChildByName("Image_x1")
            local projName = "Effect_ChengZhangJiJingBaoXiang"
            local animPath = "anime/"..projName.."/"..projName..".ExportJson"
            local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
            aniCon:addChild(armature)
            armature:setPosition(cc.p(aniCon:getContentSize().width * 0.5,aniCon:getContentSize().height * 0.5))
            animation:play("Animation1")
        end
        
    end
    
    local totalPosx = startX + loadingBar:getContentSize().width * percent/100
    self._uiLayer:getChildByName("Panel_gyhd"):setPositionX(totalPosx)
    self._uiLayer:getChildByName("Panel_gyhd"):getChildByName("Text_time"):setString(currentNum.."")
end

return ActivityFundLayer