local MillLayer = class("MillLayer",function()
    return cc.Layer:create()
end)

local maxLevelCanMake = 0 --最高有多少个等级可以制造

local currentSelectedLevel = 0
local maxLevelIdx = 0

 local unlockCostId = 308
local costGroup = g_gameTools.getCostsByCostId(unlockCostId,8)
table.sort(costGroup,function(a,b)
    return a.min_count < b.min_count
end)

local doBuyHandler = function(buyCnt)
    g_sgHttp.postData("mill/buyPosition",{num = buyCnt},function(result, msgData)
        if result then
            --basic 里面会更新页面 这里不做处理
        end
    end)
end
        
function MillLayer:ctor()
    --load cocos studio ui00
    local node = g_gameTools.LoadCocosUI("workshop_main.csb",5)
    self:addChild(node)
    g_resourcesInterface.installResources(node)
    
    g_guideManager.registGameFeature(self,g_guideManager.gameFeatures.MOFANG)
    
    self._baseNode = node:getChildByName("scale_node")
    
    local projName = "Effect_MoFang"
    local animPath = "anime/"..projName.."/"..projName..".ExportJson"
                
    local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
    self._baseNode:getChildByName("Panel_dingweidonghua"):addChild(armature)
    self._animation = animation
    
    self._baseNode:getChildByName("Image_lu"):setVisible(false)
    
    local btnClose = self._baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    self:registerScriptHandler(function(eventType)
        if eventType == "enter" then
            g_millData.SetView(self)
        elseif eventType == "exit" then
            g_millData.SetView(nil)

        end 
    end )
  
    self._baseNode:getChildByName("Text_mingc"):setString(g_tr("millTitle"))
    self._baseNode:getChildByName("Text_jieshao"):setString(g_tr("millRule"))
    self._baseNode:getChildByName("Text_cl"):setString(g_tr("millEmptyTip"))
    self._baseNode:getChildByName("Text_bt1"):setString(g_tr("millCurrentWorkTitle"))
    self._baseNode:getChildByName("Panel_sx"):getChildByName("Text_sx1"):setString(g_tr("millFaskDone"))

    local millRanks = {}
    do
        for key, var in pairs(g_data.mill) do
        	if millRanks[var.level_min] == nil then
        	   millRanks[var.level_min] =  {}
        	end
        	table.insert(millRanks[var.level_min],var)
        end
    end
    maxLevelCanMake = table.nums(millRanks)
    
    --当前玩家等级能选择的列表
    local mainCityLevel = g_PlayerBuildMode.getMainCityBuilding_lv()
    --local playerLevel = 50
    local currentVaildRanks = {}
    local allRanks = {}
    do
        for level_min, var in pairs(millRanks) do
        	if mainCityLevel >= level_min then
        	   table.insert(currentVaildRanks,var)
        	end
        	table.insert(allRanks,var)
        end
        
        local sortFunc = function(a,b)
            return a[1].level_min < b[1].level_min
        end
        table.sort(currentVaildRanks,sortFunc)
        table.sort(allRanks,sortFunc)
        
    end
    self._currentVaildRanks = currentVaildRanks
    
    if currentSelectedLevel == 0 then
        currentSelectedLevel = #currentVaildRanks
    end
    
    maxLevelIdx = #currentVaildRanks
    
    local switchBtn = self._baseNode:getChildByName("Button_qh")
    --新手引导
    g_guideManager.registComponent(9999998,switchBtn)
    
    if g_guideManager.execute() then
        currentSelectedLevel = maxLevelIdx - 1
    end
    
    --切换
    switchBtn:getChildByName("Text_1"):setString(g_tr("millSwitchRank"))
    switchBtn:addClickEventListener(function(sender)
        --if #currentVaildRanks <= 1 then
           -- g_airBox.show(g_tr("millSwitchTip"))
            
        --else
            currentSelectedLevel = currentSelectedLevel + 1
            if currentSelectedLevel > maxLevelIdx then
                if maxLevelIdx < maxLevelCanMake then
                    local nextInfo = allRanks[currentSelectedLevel]
                    g_airBox.show(g_tr("millSwitchTip",{build_level = nextInfo[1].level_min,item_level = currentSelectedLevel}))
                end
                currentSelectedLevel = 1
            end
            self:updateSelectList()
            g_guideManager.execute()
       -- end
    end)
    
    --添加生产队列
    do
        for i= 1, 8 do
            local itemCon = self._baseNode:getChildByName("Image_wu"..i)
            itemCon:addClickEventListener(function(sender)
                print(i)
                
                --还没有购买过队列
                if g_millData.getWorkingInfo() and g_millData.GetData().num == 1 then
                    local cost = costGroup[1].cost_num
                    g_msgBox.showConsume(cost, g_tr("millBuyTip",{price = cost,cnt = 1}), title, g_tr("millBuy"),function()
                        doBuyHandler(1)
                    end)
                else
                    local currentLevelItems = self._currentVaildRanks[currentSelectedLevel]
                    local itemInfo = g_data.item[currentLevelItems[i].item]
                    g_sgHttp.postData("mill/addItem",{itemId = itemInfo.id},function(result, msgData)
                        if result then
                            --basic 里面会更新页面 这里不做处理
                        end
                    end)
                end
                
              
            end)
        end
    end
    
    --删除生产队列
    do
        for i= 1, 8 do
            local removeBtn = self._baseNode:getChildByName("Panel_"..i):getChildByName("Image_1")
            removeBtn:addClickEventListener(function(sender)
                local pos = sender.itemInfo.pos
                 g_sgHttp.postData("mill/delItem",{num = pos},function(result, msgData)
                    if result then
                        --basic 里面会更新页面 这里不做处理
                    end
                 end)
            end)
        end
    end
    
    --元宝加速
    self._baseNode:getChildByName("Panel_sx"):getChildByName("Button_sx1"):addClickEventListener(function(sender)
        assert(self._makingItem)
        local beganTime = g_millData.GetData().begin_time
        local endTime = beganTime + self._makingItem.second
        --local itemInfo = g_data.item[self._makingItem.item_id]
        g_msgBox.showSpeedUp(endTime, g_tr("millFaskDoneTip"), title, g_tr("millFaskDone"), function()
            local itemId = self._makingItem.item_id
            g_sgHttp.postData("mill/acceItem",{itemId = itemId},function(result, msgData)
                if result then
                    --basic 里面会更新页面 这里只显示掉落信息
                    
                     --组织dropGroups
                    local dropGroups = {}
                    do
                        local dropG = {}
                        dropG[1] = g_Consts.DropType.Props
                        dropG[2] = itemId
                        dropG[3] = 1
                        table.insert(dropGroups,dropG)
                    end
                    
                    local size = self._baseNode:getChildByName("Image_lu"):getContentSize()
                    local startPos = self._baseNode:getChildByName("Image_lu"):convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
                    --显示掉落
                    require("game.uilayer.common.dropFlyEffect").show(dropGroups,startPos,true)
                    
                end
            end)
        end)
    end)
    
    --界面上的元宝图标
    local gem,icon = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)
    self._baseNode:getChildByName("Panel_sx"):getChildByName("Image_yb"):loadTexture(icon)
    
    do
       
        for i= 1, 8 do
            local _,iconPath = g_gameTools.getPlayerCurrencyCount(costGroup[i].cost_type)
            local cnt = costGroup[i].cost_num
            self._baseNode:getChildByName("Panel_"..i):getChildByName("Panel_suo"):getChildByName("Image_4"):loadTexture(iconPath)
            self._baseNode:getChildByName("Panel_"..i):getChildByName("Panel_suo"):getChildByName("Text_1"):setString(string.formatnumberthousands(cnt))
            
            local unlockBtn = self._baseNode:getChildByName("Panel_"..i):getChildByName("Panel_suo"):getChildByName("Image_2")
            unlockBtn:setTouchEnabled(true)
            unlockBtn.idx = i
            unlockBtn:addClickEventListener(function(sender)
                print("pos:",sender.idx)
                local startPos = g_millData.GetData().num
                local buyCnt = i - startPos + 1
                local totalCost = 0
                --计算价格
                do
                    for i= startPos, #costGroup do
                        if costGroup[i].min_count <= sender.idx then
                            totalCost = totalCost + costGroup[i].cost_num
                        end
                    end
                end
                
                
                if totalCost > 0 then
                    print("cost:",totalCost,"buyCnt:",buyCnt)
                    g_msgBox.showConsume(totalCost, g_tr("millBuyTip",{price = totalCost,cnt = buyCnt}), title, g_tr("millBuy"),function()
                        doBuyHandler(buyCnt)
                    end)
                else
                    doBuyHandler(buyCnt)
                end
            end)
        end
    end
    self:updateView()

end

function MillLayer:updateSelectList()
      --选择列表
    local currentLevelItems = self._currentVaildRanks[currentSelectedLevel]
    --dump(currentLevelItems)
    assert(#currentLevelItems == 8)
    do
        for i= 1, 8 do
            local itemCon = self._baseNode:getChildByName("Image_wu"..i)
            itemCon:removeAllChildren()
            local itemInfo = g_data.item[currentLevelItems[i].item]
            itemCon:loadTextureNormal(g_resManager.getResPath(1994001 + itemInfo.rank - 1))
            local res = g_resManager.getRes(itemInfo.res_icon)
            itemCon:addChild(res)
            res:setPosition(cc.p(itemCon:getContentSize().width/2,itemCon:getContentSize().height/2))
            res:setScale(0.8)
        end
    end
    
    --切换按钮
    local switchBtn = self._baseNode:getChildByName("Button_qh")
    local itemInfo = g_data.item[currentLevelItems[1].item]
    switchBtn:loadTextureNormal(g_resManager.getResPath(1995001 + itemInfo.rank - 1))
    
end

function MillLayer:updateView()
    self:updateSelectList()
    
    --重置正在制造的物品显示
    self._baseNode:getChildByName("Image_tu1"):removeAllChildren()
    
    self._makingItem = nil
    self._waitingList = {}
    local playerMillItems = g_millData.GetData().item_ids
    do
        --{"item_id":30101,"second":1500,"status":2}
        for key, var in ipairs(playerMillItems) do
             var.pos = key
            if  var.status == 0 then --status 0排队中1完成2正在生产
                table.insert(self._waitingList,var)
            elseif var.status == 2 then
                self._makingItem = var
            end
        end
    end
    
    local unlockNum = g_millData.GetData().num
    --已选择物品/解锁列表
    do
        for i= 1, 8 do
            local removeBtn = self._baseNode:getChildByName("Panel_"..i):getChildByName("Image_1")
            removeBtn.itemInfo = nil
            removeBtn:setVisible(false)
            local itemCon = self._baseNode:getChildByName("Panel_"..i):getChildByName("Image_12")
            itemCon:removeAllChildren()
            if self._waitingList[i] then
                local itemView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.Props,self._waitingList[i].item_id,1)
                itemView:setCountEnabled(false)
                itemView:setNameVisible(true)
                itemCon:addChild(itemView)
                itemView:setPosition(cc.p(itemCon:getContentSize().width*0.5,itemCon:getContentSize().height*0.5))
                g_itemTips.tip(itemView,g_Consts.DropType.Props,self._waitingList[i].item_id)
                if self._waitingList[i].status == 0 then
                    removeBtn:setVisible(true)
                    removeBtn.itemInfo = self._waitingList[i]
                end
            end
            
            local islocked = i >= unlockNum
        	self._baseNode:getChildByName("Panel_"..i):getChildByName("Panel_suo"):setVisible(islocked)
        end
    end
    
    self._baseNode:getChildByName("Text_cl"):setVisible(true)
    self._baseNode:getChildByName("Panel_sx"):setVisible(false)
    self._baseNode:getChildByName("Panel_jindutiao"):setVisible(false)
    self._baseNode:getChildByName("Panel_jindutiao"):stopAllActions()
    
    if self._makingItem then
        self._animation:play("Effect_MoFangJianZhaoZhong")
    else
        self._animation:play("Effect_MoFangLuHuoXunHuan")
    end
    
    
    
    if self._makingItem then
        
        --右侧物品信息
        self._baseNode:getChildByName("Text_cl"):setVisible(false)
        self._baseNode:getChildByName("Panel_sx"):setVisible(true)
        self._baseNode:getChildByName("Panel_jindutiao"):setVisible(true)
        
        local itemCon = self._baseNode:getChildByName("Image_tu1")
        local itemView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.Props,self._makingItem.item_id,1)
        itemView:setCountEnabled(false)
        itemView:setNameVisible(true)
        itemCon:addChild(itemView)
        itemView:setPosition(cc.p(itemCon:getContentSize().width*0.5,itemCon:getContentSize().height*0.5))
        g_itemTips.tip(itemView,g_Consts.DropType.Props,self._makingItem.item_id)
        
        local beganTime = g_millData.GetData().begin_time
        local endTime = beganTime + self._makingItem.second
        local itemInfo = g_data.item[self._makingItem.item_id]
        
        --倒计时
        local updateTimeStr = function()

            local totalSeconds = endTime - beganTime
            local goneSeconds = g_clock.getCurServerTime() - beganTime
            --print("goneSeconds:",totalSeconds,goneSeconds)
            
            local loadingBar = self._baseNode:getChildByName("Panel_jindutiao"):getChildByName("LoadingBar_1")
            if goneSeconds > totalSeconds then
               self._baseNode:getChildByName("Panel_jindutiao"):stopAllActions()
               local size = self._baseNode:getChildByName("Image_lu"):getContentSize()
               local startPos = self._baseNode:getChildByName("Image_lu"):convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
               g_millData.RequestCollect_Async(startPos) --界面是开着的时候自动收货
            else
               local secondsLeft = endTime - g_clock.getCurServerTime()
               local secondStr = g_gameTools.convertSecondToString(secondsLeft)
               self._baseNode:getChildByName("Panel_jindutiao"):getChildByName("Text_sj1"):setString(secondStr)
               loadingBar:setPercent(goneSeconds/totalSeconds*100)
               
               self._baseNode:getChildByName("Panel_sx"):getChildByName("Text_time1"):setString(secondStr)
               
               local cost = g_gameTools.getGemCostBySeconds(secondsLeft)
               self._baseNode:getChildByName("Panel_sx"):getChildByName("Text_sx2"):setString(string.formatnumberthousands(cost))
               
            end
        end
        local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
        local action = cc.RepeatForever:create(seq)
        self._baseNode:getChildByName("Panel_jindutiao"):runAction(action)
        updateTimeStr()
        
        self._baseNode:getChildByName("Panel_sx"):setVisible(true)
        self._baseNode:getChildByName("Panel_jindutiao"):getChildByName("Text_mingcheng1"):setString(g_tr(itemInfo.item_name))
    end

end

return MillLayer