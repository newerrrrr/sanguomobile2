local GeneralRecruitLayer = class("GeneralRecruitLayer",function()
    return cc.Layer:create()
end)

local baseNode = nil
local currentPageIdx = nil
local container = nil
local generals = nil
local tabBtns = nil
local allbuffs = {}
function GeneralRecruitLayer:ctor(buildId)

    local playerPubData = require("game.gamedata.PlayerPub")
    local serverData = playerPubData.getData()
    self._serverData = serverData
    --dump(serverData)
    
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          playerPubData.addUpdateView(self)
          
          g_BuffMode.RequestData()
          allbuffs = g_BuffMode.GetData()
          
          g_guideManager.execute()
      elseif eventType == "exit" then
          playerPubData.removeAllUpdateView()
      end 
    end )
  
    
    tabBtns = {}
    generals = {}
    currentPageIdx = 0
    self._playEnd = true
    
    local buildInfo = g_data.build[buildId]
    --assert(buildInfo and buildInfo.origin_build_id == 14)
    self._buildInfo = buildInfo
    
	local uiLayer =  g_gameTools.LoadCocosUI("Pub_Panel.csb",5)
    self:addChild(uiLayer)
    g_resourcesInterface.installResources(uiLayer)
    baseNode = uiLayer:getChildByName("scale_node")
    
    container = cc.Node:create()
    self:addChild(container)
    
    local closeBtn = baseNode:getChildByName("Button_1")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent(true)
        end
    end)
    
    local tabBtn1 = baseNode:getChildByName("Button_juntuan01")
    tabBtn1:getChildByName("Text_1")
    :setString(g_tr("tavern"))
    
    local tabBtn2 = baseNode:getChildByName("Button_juntuan02")
    tabBtn2:getChildByName("Text_1")
    :setString(g_tr("cottage"))
    
    tabBtn1:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabHandler(1)
        end
    end)
    
    tabBtn2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabHandler(2)
        end
    end)
    
    --tabBtns = {tabBtn1,tabBtn2}
    
    --暂时隐藏茅庐功能
    tabBtn2:setVisible(false)
    tabBtns = {tabBtn1}
    
    
    self:tabHandler(1)
end

function GeneralRecruitLayer:updateView()
    g_PlayerPubMode.requestData()
    self:tabHandler(currentPageIdx,true)
end

function GeneralRecruitLayer:tabHandler(idx,forceRefresh)
    if currentPageIdx == idx and not forceRefresh then
        return
    end
    currentPageIdx = idx
    container:stopAllActions()
    container:removeAllChildren()
    generals = {}
    self._serverData = g_PlayerPubMode.getData()

    --切换按钮高亮状态
    for key, btn in pairs(tabBtns) do
        btn:setEnabled(true)
    end
    if tabBtns[currentPageIdx] then
        tabBtns[currentPageIdx]:setEnabled(false)
    end
    
    
    local generalItem = cc.CSLoader:createNode("Pub_List.csb")
    
    local uiLayer
    --酒馆标签
    if currentPageIdx == 1 then
    
        uiLayer =  g_gameTools.LoadCocosUI("Pub_Panel_tavern.csb",5)
        container:addChild(uiLayer)

        generals = self._serverData.generals or {}
        assert(#generals <= 3)
        local currentTime = g_clock.getCurServerTime()
        local secondsLeft = self._serverData.next_free_time - currentTime + 1
        
        uiLayer:getChildByName("scale_node"):getChildByName("Text_1")
        :setString(g_tr("generalIllustrated"))--图鉴
        
        local freeBtn = uiLayer:getChildByName("scale_node"):getChildByName("Button_01")
        freeBtn:getChildByName("Text_42"):setString(g_tr("freeFefresh")) --免费刷新
        freeBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self:freeRefreshHandler()
            end
        end)
        
        local generalPreviewBtn = uiLayer:getChildByName("scale_node"):getChildByName("Image_54")
        generalPreviewBtn:setTouchEnabled(true)
        generalPreviewBtn:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                --提取掉落包里所有的武将
                local generals = {}
                local normalDrops = g_data.pub[self._buildInfo.id].gem_ordinary_drop
                local seniorDrops = g_data.pub[self._buildInfo.id].gem_senior_drop
                
                local allDrops = {}
                for key, var in pairs(normalDrops) do
                	  table.insert(allDrops,var)
                end
                
                for key, var in pairs(seniorDrops) do
                    table.insert(allDrops,var)
                end
                
                local allDropGenerals = {}
                local tmp = {}
                for key, dropId in pairs(allDrops) do
                    local dropInfo = g_data.drop[dropId]
                    assert(dropInfo)
                    local dropGroup = dropInfo.drop_data
                    for key, group in pairs(dropGroup) do
                        local dropType = group[1]
                        local itemId = group[2]
                        local dropCount = group[3]
                        if dropType == g_Consts.DropType.General then
                            local generalInfo = g_data.general[itemId]
                            if generalInfo then
                                local rootId = generalInfo.general_original_id
                                if tmp[rootId] == nil then
                                    tmp[rootId] = itemId
                                    table.insert(allDropGenerals,generalInfo)
                                end
                            end
                            
                        end
                    end
                end
                
                --未解锁的武将
                do
                    local unlockBuilds = {}
                    for key, var in pairs(g_data.build) do
                        if var.origin_build_id == 14 and var.build_level > self._buildInfo.build_level then
                            table.insert(unlockBuilds,var)
                        end
                    end
                    
                    table.sort(unlockBuilds,function(a,b)
                        return a.build_level < b.build_level
                    end)
                
                    for key, var in ipairs(unlockBuilds) do
                             
                        local generals = {}
                        local normalDrops = g_data.pub[var.id].gem_ordinary_drop
                        local seniorDrops = g_data.pub[var.id].gem_senior_drop
                        local allDrops = {}
                        for key, drop in pairs(normalDrops) do
                              table.insert(allDrops,drop)
                        end
                        
                        for key, drop in pairs(seniorDrops) do
                            table.insert(allDrops,drop)
                        end
                        
                        for key, dropId in pairs(allDrops) do
                        
                            local dropInfo = g_data.drop[dropId]
                            assert(dropInfo)
                            local dropGroup = dropInfo.drop_data
                            for key, group in pairs(dropGroup) do
                                local dropType = group[1]
                                local itemId = group[2]
                                local dropCount = group[3]
                                if dropType == g_Consts.DropType.General then
                                    local generalInfo = g_data.general[itemId]
                                    if generalInfo then
                                        local rootId = generalInfo.general_original_id
                                        if tmp[rootId] == nil then
                                            tmp[rootId] = itemId
                                            local newGeneralInfo = clone(generalInfo)
                                            newGeneralInfo.lockInfo = var
                                            table.insert(allDropGenerals,newGeneralInfo)
                                        end
                                    end
                                end
                            end
                            
                         end
                     
                    end --for end
                    
                end --do end
                
                --创建武将预览列表
                g_sceneManager.addNodeForUI(require("game.uilayer.illustrated.GeneralIllustratedLayer"):create(allDropGenerals))
            end
        end)
        
        local gemBtn = uiLayer:getChildByName("scale_node"):getChildByName("Button_02")
        gemBtn:getChildByName("Text_42"):setString(g_tr("gemFefresh")) --高级刷新
        gemBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self:gemRefreshHandler()
            end
        end)
        
        
        freeBtn:setEnabled( not (secondsLeft > 0))
        
        local timeLabel = uiLayer:getChildByName("scale_node"):getChildByName("Text_49")
        local updateTimeStr = function()
            currentTime = g_clock.getCurServerTime()
            secondsLeft = self._serverData.next_free_time - currentTime + 1
            --secondsLeft = secondsLeft - 1
            if secondsLeft < 0 then
                secondsLeft = 0
                container:stopAllActions()
                freeBtn:setEnabled(true)
            end
            
            timeLabel:setString(g_gameTools.convertSecondToString(secondsLeft))
        end
        
        local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
        local action = cc.RepeatForever:create(seq)
        container:runAction(action)
        
        updateTimeStr()

        print("self._buildInfo.id:",self._buildInfo.id)

        local costId = g_data.pub[self._buildInfo.id].cost
        local cnt = self._serverData.pay_day_counter + 1
        
        local cost = 0
        local costType = g_Consts.AllCurrencyType.Gem
        for key, var in pairs(g_data.cost) do
            if var.cost_id == costId then
                if cnt >= var.min_count and cnt <= var.max_count then
                   cost = var.cost_num
                   costType = var.cost_type
                   break
                end
            end
        end
        self._refreshCost = cost
    
        local _,iconPath = g_gameTools.getPlayerCurrencyCount(costType)
        uiLayer:getChildByName("scale_node"):getChildByName("Image_58"):loadTexture(iconPath)
        uiLayer:getChildByName("scale_node"):getChildByName("Text_49_0")
        :setString(cost.."") --高级花费
       
        local generalCon = uiLayer:getChildByName("scale_node"):getChildByName("Panel_2")
        for i = 1, #generals do
            print("create item")
            local generalId = generals[i]
            local generalItemc = generalItem:clone()
            local item = require("game.uilayer.recruit.GeneralComponentLayer"):create(generalItemc,generalId,currentPageIdx,i)
            local itemSize = item:getContentSize()
            item:setDelegate(self)
            generalCon:addChild(item)
            item:setPositionY(0)
            item:setPositionX((itemSize.width + 70) * (i - 1) + 30)
            g_guideManager.registComponent(1000200 + i,generalItemc:getChildByName("scale_node"):getChildByName("Button_10"))
        end
    
    --茅庐标签
    elseif currentPageIdx == 2 then
        generals = {2000701,2000101,2000201,2000301,2000401,2000501,2000601}
        uiLayer =  g_gameTools.LoadCocosUI("Pub_Panel_thatchedCottage.csb",5)
        container:addChild(uiLayer)
        uiLayer:getChildByName("scale_node"):getChildByName("Text_1")
        :setString(g_tr("recruiteGeneralInfo"))
        --local generals = g_GeneralMode.GetData()

        local listView = uiLayer:getChildByName("scale_node"):getChildByName("ListView_1")
        listView:setItemsMargin(60)
        for i = 1, #generals do
            print("create item")
            local item = require("game.uilayer.recruit.GeneralComponentLayer"):create(generalItem:clone(),generals[i],currentPageIdx,i)
            local itemSize = item:getContentSize()
            listView:pushBackCustomItem(item)
        end
    end
    
--    local max = 0
--    local output = self._buildInfo.output
--    for key, var in pairs(output) do
--        if var [1] == 33 then --武将招募上限
--           max = var[2]
--           break
--        end
--    end
--    
--    --buff 效果
--    local allbuffs = g_BuffMode.GetData()
--    local buffValue = 0
--    local buffId = 442
--    local buffKeyName = g_data.buff[buffId].name
--    assert( buffKeyName == "recruit_general_limit_plus" ,"recruit_general_limit_plus")--武将招募上限增加
--    if allbuffs and allbuffs[buffKeyName] then
--        if tonumber(allbuffs[buffKeyName].v) > 0 then
--           buffValue = allbuffs[buffKeyName].v
--        end
--        
--        local buffType = g_data.buff[buffId].buff_type
--        if buffType == 1 then --万分比
--           max = math.ceil(max * (10000 + buffValue)/10000)
--        elseif buffType == 2 then --固定值
--           max = max + buffValue
--        end
--    end
    local playerPubData = require("game.gamedata.PlayerPub")
    local max = playerPubData.getMaxGeneralToRecruit()
    
    --local currentPlayerLevel = require("game.gamedata.playerData"):GetData().level
    local ownGenerals = g_GeneralMode.GetData()
    local owenCount = #ownGenerals or 0
    uiLayer:getChildByName("scale_node"):getChildByName("Text_29")
    :setString(g_tr("recruited",{current = owenCount,max = max}))
end

function GeneralRecruitLayer:freeRefreshHandler()
    print("freeshHandler")
    
    local resultHandler = function(result, msgData)
        if result then
            self:updateView()
        end
    end
    
    --免费刷新请求
    g_sgHttp.postData("Pub/reload",{type = 1},resultHandler)
end

function GeneralRecruitLayer:playRecruitAnimation(generalInfo,type)
   
   if not self._playEnd then
      return
   end
   
   g_guideManager.clearGuideLayer()
   
   local onAnimationCloseHandler = function()
          self._animationNode:stopAllActions()
          self._animationNode:removeAllChildren()
          self._animationNode:setVisible(false)
                
          if g_guideManager.execute() then
            self:removeFromParent()
          else
            self:updateView()
          end
   end
   
   self._playEnd = false
   if self._animationNode == nil then
       self._animationNode = ccui.Widget:create()
       self:addChild(self._animationNode)
       self._animationNode:setContentSize(g_display.size)
       self._animationNode:setAnchorPoint(cc.p(0.5,0.5))
       self._animationNode:setPositionX(g_display.cx)
       self._animationNode:setPositionY(g_display.cy)
       self._animationNode:setTouchEnabled(true)
       self._animationNode:setScale(g_display.scale)
       self._animationNode:addClickEventListener(function()
            if self._playEnd then
                onAnimationCloseHandler()
            end
       end)
   end
   self._animationNode:removeAllChildren()
   self._animationNode:setVisible(true)
   
   --武将信息面板
   local nodePanleInfo = cc.CSLoader:createNode("Pub_general_info1.csb")
   nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_28"):setVisible(false)
   nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_1"):getChildByName("Text_xm")
   :setString(g_tr(generalInfo.general_name))
   nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_14")
   :setString(g_tr(generalInfo.description))
   
   --武将属性
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_1"):getChildByName("Text_6")
    :setString(g_tr("wu"))--武
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_1"):getChildByName("Text_7")
    :setString(generalInfo.general_force.."")
      
            nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_2"):getChildByName("Text_6")
    :setString(g_tr("zhi"))--智
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_2"):getChildByName("Text_7")
    :setString(generalInfo.general_intelligence.."")
    
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_3"):getChildByName("Text_6")
    :setString(g_tr("zheng"))--政
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_3"):getChildByName("Text_7")
    :setString(generalInfo.general_political.."")
    
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_4"):getChildByName("Text_6")
    :setString(g_tr("tong"))--统
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_4"):getChildByName("Text_7")
    :setString(generalInfo.general_governing.."")
    
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_5"):getChildByName("Text_6")
    :setString(g_tr("mei"))--魅
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_5"):getChildByName("Text_7")
    :setString(generalInfo.general_charm.."")
    
    --优势兵种
    local equipInfo = g_data.equipment[generalInfo.general_item_id*100]
    local str = ""
    for i=1, #equipInfo.equip_skill_id do
        local skillInfo =  g_data.equip_skill[equipInfo.equip_skill_id[i]]
        local troopType = skillInfo.equip_arm_type
        local troopStr = ""
        if troopType == 1 then
            troopStr = g_tr("infantry")
        elseif troopType == 2 then
            troopStr = g_tr("cavalry")
        elseif troopType == 3 then
            troopStr = g_tr("archer")
        elseif troopType == 4 then
            troopStr = g_tr("vehicles")
        end
        str = str..troopStr.." "
    end
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("Panel_6"):getChildByName("skill_effect2")
    :setString(str)
    
    nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("Panel_6"):getChildByName("skill_effect1")
    :setString(g_tr("betterArmy"))--优势兵种
    
   --招募动画播放事件
   local onMovementEventCallFunc = function(armature , eventType , name)
       if 0 == eventType then --start
       elseif 1 == eventType then --end
           self._playEnd = true
           if nodePanleInfo then
               nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_28"):setVisible(true)
           end
       end
   end
   
   --招募动画加载
   local projName = "Effect_JiuGuanZhaoMu"
   local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName,onMovementEventCallFunc)
   self._animationNode:addChild(armature)
   armature:setPositionX(g_display.cx)
   armature:setPositionY(g_display.cy)
   
   if type == 1 then
      animation:play("Effect_JiuGuanZhaoMuYinXiongLeft")
   elseif type == 2 then
      animation:play("Effect_JiuGuanZhaoMuYinXiongCenter")
   else
      animation:play("Effect_JiuGuanZhaoMuYinXiongRight")
   end
    
    --武将半身像
    local container = cc.Node:create()
    local bg = cc.Sprite:create(g_resManager.getResPath(1005000 + generalInfo.general_quality))
    container:addChild(bg)
    local pic = cc.Sprite:create(g_resManager.getResPath(generalInfo.general_big_icon))
    container:addChild(pic)
    local frame = cc.Sprite:create(g_resManager.getResPath(1005100 + generalInfo.general_quality))--边框
    container:addChild(frame)
    armature:getBone("Layer5"):addDisplay(container,0)
    
    --武将信息面板动画
    local function showInfoPanle()
        for i = 1, 3 do
            local part = nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_"..i)
            if i == 3 then
                part = nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_14")
            end
            part:setCascadeOpacityEnabled(true)
            part:setOpacity(0)
            local action = cc.Sequence:create( 
                cc.DelayTime:create(0.20 * i),
                cc.FadeTo:create(1.0,255)
            )
            part:runAction(action)
        end
    end
    
    local action = cc.Sequence:create( 
        cc.Hide:create(),
        cc.DelayTime:create(2.5),
        cc.Show:create(),
        cc.CallFunc:create(showInfoPanle)
    )
    self._animationNode:addChild(nodePanleInfo)
    nodePanleInfo:runAction(action)
    
end

function GeneralRecruitLayer:gemRefreshHandler()
    print("gemRefreshHandler")
    
    local doHandler = function()
        local playerData = require("game.gamedata.playerData")
        local allGem = playerData.getDiamonds()
        
        local resultHandler = function(result, msgData)
            if result then
                self:updateView()
            end
        end
        
        if allGem >= self._refreshCost then
            --高级刷新请求
            g_sgHttp.postData("Pub/reload",{type = 2},resultHandler)
        else 
            g_airBox.show(g_tr("currencyLimit"))
        end
    end
    
    local text = g_tr("makeSureGemRefreshPub")
    local cost = self._refreshCost
    local buttonText = g_tr("gemRefreshPub")
    local title = nil
    g_msgBox.showConsume(cost, text, title, buttonText,doHandler)
    
end

return GeneralRecruitLayer