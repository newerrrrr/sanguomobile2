local HospitalLayer = class("HospitalLayer",function()
  return cc.Layer:create()
end)

local baseNode = nil
local scrollView = nil



local maxCapacity = 0
local fastCureCost = 0
local currentTimeCost = 0

local selectedCapacity = 0
local soldiersConatainer = nil
local soldierItemToLayoff = nil
local listSize = cc.size(0,0)
local allbuffs = {}

local allCanCureMax = 0

function HospitalLayer:ctor(buildingId,serverData)
    
    self._itemArray = {}

    maxCapacity = 0
    soldiersConatainer = nil
    soldierItemToLayoff = nil
    fastCureCost = 0
    currentTimeCost = 0
    selectedCapacity = 0
    self._serverData = serverData or {}
    
    self._limitCostType = nil
    
    local outPut = g_data.build[buildingId].output
    for key, group in pairs(outPut) do
         local type = group[1]
         local value = group[2]
         if type == 8 then
             maxCapacity = value
         end
    end
    assert(maxCapacity > 0)
    
    local buffId = 119
    maxCapacity = g_BuffMode.calculateFinalValueByBuffId(maxCapacity,buffId,self._serverData.position)
   
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          g_PlayerSoldierInjuredMode.addUpdateView(self)
          
          self:showOrHideSomeNodes(false)
          baseNode:getChildByName("Text_5"):setString("")
--          g_busyTip.show_1()
--          g_PlayerSoldierInjuredMode.requestDataAsync(function(result,msgData)
--                g_busyTip.hide_1()
--                if result then
--                    local injuredSoldiers = require("game.gamedata.InjuredSoldierData").getData()
--                    
--                    local Soldier = require("game.gamedata.Soldier")
--                    for i = 1, #injuredSoldiers do
--                      local soldier = Soldier.new(injuredSoldiers[i])
--                        table.insert(soldiers,soldier)
--                    end
--                    self._soldiers = soldiers
--                    self:initHandler()
--                else
--                    self:removeFromParent()
--                end
--          end)


            local injuredSoldiers = require("game.gamedata.InjuredSoldierData").getData()
            local Soldier = require("game.gamedata.Soldier")
            local soldiers = {}
            for i = 1, #injuredSoldiers do
              local soldier = Soldier.new(injuredSoldiers[i])
              table.insert(soldiers,soldier)
            end
            self._soldiers = soldiers
            self:initHandler()
            
      elseif eventType == "exit" then
          g_PlayerSoldierInjuredMode.removeAllUpdateView()
      end 
    end )

    local node = g_gameTools.LoadCocosUI("TheMedicalCenter_Panel.csb",5)
    self:addChild(node)
    g_resourcesInterface.installResources(node)
    baseNode = node:getChildByName("scale_node")
    
    baseNode:getChildByName("Text_hf"):setString(g_tr("cureSoldierCost"))
    
    local closeBtn = baseNode:getChildByName("Button_1")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    scrollView = baseNode:getChildByName("ScrollView_1")
    scrollView.viewSize = scrollView:getContentSize()
    soldiersConatainer = cc.Node:create()
    scrollView:addChild(soldiersConatainer)
    
    local _,icon = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)
    baseNode:getChildByName("Panel_7"):getChildByName("Image_14"):loadTexture(icon)
    
    baseNode:getChildByName("Text_bt"):setString(g_tr("hospitalTitle"))
end

function HospitalLayer:initHandler()
    
    local soldiers = self._soldiers
    
    local listItem = self:createListItemModel()
    
    local function itemCloseHandler(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
          g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
          print(sender:getTag())
          soldierItemToLayoff = sender.item
          local alertLayer = require("game.uilayer.hospital.HospitalAlertLayer"):create(sender.item.soldierInfo,handler(self,self.updateView))
          self:addChild(alertLayer)
        end
    end
    
    local offsetCount = 0
    local startCount = 0
    local currentCount = 0
    local lastAllCount = 0
    
    local function goToPercent(targetPercent,slider)
        local currentCount = targetPercent
        if currentCount > slider:getMaxPercent() then
            currentCount = slider:getMaxPercent()
        end
        
        if currentCount < 0 then
            currentCount = 0
        end
        slider:setPercent(currentCount)
        
        offsetCount =  currentCount - startCount
        local newAllCount = lastAllCount + offsetCount
        
        selectedCapacity = newAllCount
        
        if selectedCapacity > maxCapacity then
           slider:setPercent(currentCount - (selectedCapacity - maxCapacity))
           selectedCapacity = maxCapacity
        end
        
        if selectedCapacity < 0 then
           selectedCapacity = 0
        end
        
        local percent = slider:getPercent()..""
        slider.inputTxt:setString(percent)

        self:updateCommonShow()
        
    end
    
    local function stepHandler(sender,isAdd)
        local slider = sender.slider
        
        startCount = sender.slider:getPercent() or 0
        lastAllCount = selectedCapacity
        
        local currentCount = startCount
        if isAdd == true then
            currentCount = startCount + 1
        else
            currentCount = startCount - 1
        end
        
        goToPercent(currentCount,slider)
    end
    
    local function reduceHandler(sender)
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        stepHandler(sender,false)
    end
    
    local function addHandler(sender)
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        stepHandler(sender,true)
    end
    
    for i = 1, 5 do
       local icon = baseNode:getChildByName("Panel_ziyuan"):getChildByName("Panel_"..i):getChildByName("Image_01")
       icon:loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + i))
       
       baseNode:getChildByName("Panel_ziyuan"):getChildByName("Panel_"..i):getChildByName("Text_shuzi01")
       :setString("0")
    end
    
    local function percentChangedEvent(sender,eventType)
        local slider = sender
        if eventType == ccui.SliderEventType.percentChanged then
            currentCount = slider:getPercent()

            offsetCount =  currentCount - startCount
            --print("startCount:",startCount,"currentCount:",currentCount,"offsetCount:",offsetCount)
            
            local newAllCount = lastAllCount + offsetCount
            
            selectedCapacity = newAllCount
            
            if selectedCapacity > maxCapacity then
               slider:setPercent(currentCount - (selectedCapacity - maxCapacity))
               selectedCapacity = maxCapacity
            end
            
            if selectedCapacity < 0 then
               selectedCapacity = 0
            end
            
            local percent = slider:getPercent()..""
            slider.inputTxt:setString(percent)
            
            --print("selectedCapacity:",selectedCapacity)
            self:updateCommonShow()
            
        elseif eventType == ccui.SliderEventType.slideBallDown then
            startCount = tonumber(slider.inputTxt:getString()) or 0
            lastAllCount = selectedCapacity
            
            print("down:",startCount)
            self:updateCommonShow()
        elseif eventType == ccui.SliderEventType.slideBallUp then
            self:updateCommonShow()
        elseif eventType == ccui.SliderEventType.slideBallCancel then

        end
    end
    
    selectedCapacity = 0
    local row = 0
    local maxRow = math.ceil(#soldiers/2)
    local heightDistance = 0
    --load soldiers list
    for i = 1, #soldiers do
        local soldierInfo = soldiers[i]
        local item = listItem:clone()
        item:getChildByName("scale_node"):getChildByName("Slider_1"):setPercent(0)
        
        soldiersConatainer:addChild(item)
        item:setContentSize(listSize)
        if i%2 == 0 then
          item:setPositionX(listSize.width + 10)
        else
          item:setPositionX(0)
        end
        item:setPositionY((listSize.height + heightDistance) * (maxRow - row - 1))
        
        item:getChildByName("scale_node"):getChildByName("Text_x"):setString(g_tr("layoff"))
        local itemCloseBtn = item:getChildByName("scale_node"):getChildByName("Image_x")
        itemCloseBtn.item = item
        itemCloseBtn:setTouchEnabled(true)
        itemCloseBtn:addTouchEventListener(itemCloseHandler)
        
            
        local reduceBtn = item:getChildByName("scale_node"):getChildByName("Text_zuixiao")
        reduceBtn:setTouchEnabled(true)
        reduceBtn:addClickEventListener(reduceHandler)
        
        local addBtn = item:getChildByName("scale_node"):getChildByName("Text_zuida")
        addBtn:setTouchEnabled(true)
        addBtn:addClickEventListener(addHandler)
        
        local slider = item:getChildByName("scale_node"):getChildByName("Slider_1")
        slider:addEventListener(percentChangedEvent)
        
        local input = item:getChildByName("scale_node"):getChildByName("TextField_1")
        local inputShowRender = item:getChildByName("scale_node"):getChildByName("Text_1_0")
        inputShowRender:setString("")
        
        input = g_gameTools.convertTextFieldToEditBox(input)
        input:setPlaceHolder("")
        
        local flagCnt = ""
        local editBoxHandler = function(eventType)
            if eventType == "began" then
                --flagCnt = input:getText()
                flagCnt = inputShowRender:getString()
                --input:setText(flagCnt)
                input:setText("")
                inputShowRender:setString("")
                inputShowRender:setVisible(false)
            elseif eventType == "customEnd" then
                local numStr = string.gsub(input:getText(), ",","")
                if tonumber(numStr) == nil then
                   --input:setText(flagCnt)
                   inputShowRender:setString(flagCnt)
                else
                   goToPercent(tonumber(numStr),slider)
                end
                input:setText("")
                inputShowRender:setVisible(true)
            end
        end
        input:registerScriptEditBoxHandler(editBoxHandler)
        
        local currentDefaultSelect = maxCapacity - selectedCapacity
        if currentDefaultSelect > soldierInfo:getMaxCureCount() then
            currentDefaultSelect = soldierInfo:getMaxCureCount()
        end
        
        --特別需求，默认不选择伤病
        currentDefaultSelect = 0
        
        selectedCapacity = selectedCapacity + currentDefaultSelect
        
        input:setString(" ")
        inputShowRender:setString(tostring(currentDefaultSelect))
        
        slider.inputTxt = inputShowRender
        slider.editBox = input
        slider:setMaxPercent(soldierInfo:getHurtedCount())
        
        slider:setPercent(currentDefaultSelect)
        
        reduceBtn.slider = slider
        addBtn.slider = slider
        
        item.soldierInfo = soldierInfo
        
        self:upateListItem(item,soldierInfo)
        
        --item:getChildByName("scale_node"):getChildByName("Text_1")
        --:setString("/"..soldierInfo:getHurtedCount())
        
        table.insert(self._itemArray,item)
        
        if i%2 == 0 then
          row = row + 1
        end
    end
    --scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width,(listSize.height + heightDistance) * maxRow))
    
    local innerHeight = (listSize.height + heightDistance) * maxRow
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width,innerHeight))
    if innerHeight < scrollView.viewSize.height then
       scrollView:getInnerContainer():setPositionY(scrollView.viewSize.height - innerHeight)
       scrollView:setTouchEnabled(false)
    end
        
    self:updateCommonShow()
    
    
    --reset ui text
    baseNode:getChildByName("Button_anniu01"):getChildByName("Text_42")
    :setString(g_tr("selectAll"))
    
    baseNode:getChildByName("Button_anniu02"):getChildByName("Text_42")
    :setString(g_tr("fastCure"))
    
    baseNode:getChildByName("Button_anniu03"):getChildByName("Text_42")
    :setString(g_tr("cure"))
    
    baseNode:getChildByName("Panel_dixiaxinxi"):getChildByName("Text_1")
    :setString(g_tr("hurtNumbers"))
    
    local unselectAllHandler = function()
         selectedCapacity = 0
          for i = 1, #self._itemArray do
              local item = self._itemArray[i]
              local slider = item:getChildByName("scale_node"):getChildByName("Slider_1")
              slider.inputTxt:setString(tostring(0))
              slider:setPercent(0)
          end
          self:updateCommonShow()
    end
    
    local selectAllHandler = function()
      
      selectedCapacity = 0
      for i = 1, #self._itemArray do
          local item = self._itemArray[i]
          local soldierInfo = item.soldierInfo
          local currentDefaultSelect = maxCapacity - selectedCapacity
          --print(soldierInfo:getMaxCureCount())
          if currentDefaultSelect > soldierInfo:getMaxCureCount() then
              currentDefaultSelect = soldierInfo:getMaxCureCount()
          end
          print(currentDefaultSelect)
          selectedCapacity = selectedCapacity + currentDefaultSelect
          
          local slider = item:getChildByName("scale_node"):getChildByName("Slider_1")
          slider.inputTxt:setString(tostring(currentDefaultSelect))
          slider:setPercent(currentDefaultSelect)
          
          allCanCureMax = selectedCapacity
          
--          if currentDefaultSelect < soldierInfo:getHurtedCount() then
--              break
--          end
      end
      
      self:updateCommonShow()
    end
    
    local selectHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if selectedCapacity > 0 and selectedCapacity == allCanCureMax then
                unselectAllHandler()
            else
                unselectAllHandler()
                selectAllHandler()
            end
        end
    end
    
    baseNode:getChildByName("Button_anniu01")
    :addTouchEventListener(selectHandler)
    
    local cureByType = function(gem_type)
           local resultHandler = function(result, msgData)
              if result then
                  if gem_type ~= 1 then
                    g_airBox.show(g_tr("cureSuccess"))
                  end
                  local position = self._serverData.position
                  local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(position,g_Consts.UseItemType.Health)
                  g_sceneManager.addNodeForUI(view)
                  
                  self:removeFromParent()
              else 
                  --g_airBox.show(g_tr("cureFail"))
              end
           end
           
           local data = {}
           local soldierData = {}
           for key, item in pairs(self._itemArray) do
              local id = item.soldierInfo:getId()
              local slider = item:getChildByName("scale_node"):getChildByName("Slider_1")
              local count = tonumber(slider.inputTxt:getString())
              print("id:",id,"count:",count)
              local config = {}
              config.id = id
              config.soldier_id = item.soldierInfo:getConfig().id
              config.num = count
              if count > 0 then
                  table.insert(soldierData,config)
              end
           end
           
           if #soldierData > 0 then
              local data = {}
              data.gem_flag = gem_type
              data.soldier_injured = soldierData
              g_sgHttp.postData("soldier/cureInjuredSoldier",data,resultHandler)
           end
    end
    
    local fastCureHandler = function(sender,eventType)
       if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
           print("fastCureHandler")
           
           local function doFastCure()
               cureByType(1)
           end  
           
           if selectedCapacity > 0 then
               g_msgBox.showConsume(fastCureCost, g_tr("hospitalFastCureMakeSure"), title, g_tr("fastCure"), doFastCure)
           else
               g_airBox.show(g_tr("hospitalSelectTip"))
           end
       end
    end
    
    baseNode:getChildByName("Button_anniu02")
    :addTouchEventListener(fastCureHandler)
    
    local cureHandler = function(sender,eventType)
       if eventType == ccui.TouchEventType.ended then
          g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
          print("cureHandler")
          if selectedCapacity > 0 then
              
              if self._limitCostType then
                  require("game.uilayer.shop.UseResourceView").show(self._limitCostType,function()
                     self:updateView()
                  end)
                  return 
              end
              
          
              if currentTimeCost >= 14400 then --超过4小时提示
                  local hour = math.floor(currentTimeCost/3600)
                  g_msgBox.show(g_tr("hospitalCureTip",{cost_time = hour}),nil,nil,function(event)
                        if event == 0 then
                           cureByType(0)
                        end
                  end,1)
              else
                  cureByType(0)
              end
          else
              g_airBox.show(g_tr("hospitalSelectTip"))
          end
       end
    end
    baseNode:getChildByName("Button_anniu03")
    :addTouchEventListener(cureHandler)
end

function HospitalLayer:createListItemModel()
    local listItem = cc.CSLoader:createNode("TheMedicalCenter_TipInformation.csb")
    listSize = listItem:getChildByName("scale_node"):getContentSize()
    local slider = listItem:getChildByName("scale_node"):getChildByName("Slider_1")
    slider:setPercent(100)
    listItem:getChildByName("scale_node"):setTouchEnabled(false)
    return listItem
end

function HospitalLayer:upateListItem(item,soldierInfo)
    
    if item == nil or soldierInfo == nil then
        return
    end
    
    item.soldierInfo = soldierInfo
    
    local scaleNode = item:getChildByName("scale_node")
    local imgCon = scaleNode:getChildByName("Image_22")
    imgCon:removeAllChildren()
    
    scaleNode:getChildByName("Text_shibingmingc"):setString(g_tr(soldierInfo:getConfig().soldier_name))
    local itemView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.Soldier,soldierInfo:getConfig().id,1)
    imgCon:addChild(itemView)
    --itemView:enableTip()
    itemView:setCountEnabled(false)
    local size = imgCon:getContentSize()
    itemView:setPosition(cc.p(size.width*0.5,size.height*0.5))
    local scale = size.width/itemView:getContentSize().width
    itemView:setScale(scale)
    
    local soldierTypeIcon = scaleNode:getChildByName("Image_tubiao")
    soldierTypeIcon:loadTexture(g_resManager.getResPath(soldierInfo:getConfig().img_type))
    item:getChildByName("scale_node"):getChildByName("Text_1")
        :setString("/"..soldierInfo:getHurtedCount())
    
    local slider = item:getChildByName("scale_node"):getChildByName("Slider_1")
    slider:setMaxPercent(soldierInfo:getHurtedCount())
    
    local selectedCount = tonumber(slider.inputTxt:getString())
    if selectedCount > soldierInfo:getMaxCureCount() then
        slider:setPercent(soldierInfo:getMaxCureCount())
        slider.inputTxt:setString(soldierInfo:getMaxCureCount().."")
    end

end

function HospitalLayer:updateCommonShow()
    baseNode:getChildByName("Panel_dixiaxinxi"):getChildByName("Text_shuzi01")
    :setString(selectedCapacity.."/"..maxCapacity)
    
    --update cost show
    local allCosts = {}
    fastCureCost = 0
    currentTimeCost = 0
    local costTime = 0
    self._limitCostType = nil
    
    --重置花费显示
    do
        for i=1, 5 do
           local costLabel = baseNode:getChildByName("Panel_ziyuan"):getChildByName("Panel_"..i):getChildByName("Text_shuzi01")
           costLabel:setTextColor(g_Consts.ColorType.Normal)
           costLabel:setString("0")
        end
    end
    
    if selectedCapacity > 0 then
        for key, item in pairs(self._itemArray) do
            local soldierInfo = item.soldierInfo
            local slider = item:getChildByName("scale_node"):getChildByName("Slider_1")
            
            local selectedCount = slider:getPercent()
    
            --print("selectedCount:",selectedCount,slider.inputTxt:getString())
            fastCureCost = fastCureCost + soldierInfo:getFastCureCost(selectedCount)
            costTime = costTime + soldierInfo:getCureTime(selectedCount)
            
            local costs = soldierInfo:getCureCosts(selectedCount)
            for costType, costValue in pairs(costs) do
                if allCosts[costType] == nil then
                    allCosts[costType] = 0 
                end
                allCosts[costType] =  allCosts[costType] + costValue
            end
     
        end
        
        for costType, costValue in pairs(allCosts) do
           if costType > 5 then
              break
           end
           --print("costType:",costType,"costValue:",costValue)
           baseNode:getChildByName("Panel_ziyuan"):getChildByName("Panel_"..costType):getChildByName("Image_01")
           :loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
           
           --buff 效果
            local buffId = 123
            local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,self._serverData.position)
            if buffType == 1 then --万分比
                costValue = math.ceil(costValue * (10000 - buffValue)/10000)
            elseif buffType == 2 then --固定值
                costValue = costValue - buffValue
            end
        
    --       local buffValue = 0
    --       local buffId = 123
    --       local buffKeyName = g_data.buff[buffId].name --cure_cost_minus
    --       if allbuffs and allbuffs[buffKeyName] then
    --            if tonumber(allbuffs[buffKeyName].v) > 0 then
    --               buffValue = allbuffs[buffKeyName].v
    --            end
    --            
    --            local buffType = g_data.buff[buffId].buff_type
    --            if buffType == 1 then --万分比
    --                costValue = math.ceil(costValue * (10000 - buffValue)/10000)
    --            elseif buffType == 2 then --固定值
    --                costValue = costValue - buffValue
    --            end
    --       end
           
           local costLabel = baseNode:getChildByName("Panel_ziyuan"):getChildByName("Panel_"..costType):getChildByName("Text_shuzi01")
           costLabel:setTextColor(g_Consts.ColorType.Normal)
           local nowHave = g_gameTools.getPlayerCurrencyCount(costType)
           if costValue > nowHave then
               costLabel:setTextColor(g_Consts.ColorType.Red)
               if self._limitCostType == nil then
                   self._limitCostType = costType
               end
           end
           costLabel:setString(costValue.."")
        end
    end
    
    baseNode:getChildByName("Panel_7"):getChildByName("Text_21")
    :setString(fastCureCost.."")
    
    --buff 效果
    local buffId = 122
    local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,self._serverData.position)
    if buffType == 1 then --万分比
        buffValue = buffValue / 10000
        costTime = costTime/(1 + buffValue)
    elseif buffType == 2 then --固定值
        costTime = costTime - buffValue
    end
    
--    local buffValue = 0
--    local buffId = 122
--    local buffKeyName = g_data.buff[buffId].name --cure_cost_minus
--    assert(buffKeyName == "cure_speed")
--    if allbuffs and allbuffs[buffKeyName] then
--        if tonumber(allbuffs[buffKeyName].v) > 0 then
--           buffValue = allbuffs[buffKeyName].v
--        end
--        
--        local buffType = g_data.buff[buffId].buff_type
--        if buffType == 1 then --万分比
--            buffValue = buffValue / 10000
--            costTime = costTime/(1 + buffValue)
--        elseif buffType == 2 then --固定值
--            costTime = costTime - buffValue
--        end
--    end
    
    currentTimeCost = costTime
    
    local time = g_gameTools.convertSecondToString(costTime)
    baseNode:getChildByName("Panel_7_0"):getChildByName("Text_21")
    :setString(time)
    
    local cnt = 0
    local tipStr = ""
    for i = 1, #self._itemArray do
        local item = self._itemArray[i]
        if item:isVisible() then
            cnt = cnt + 1
            break
        end
    end
    

    
    local showCostInfo = true
    if cnt <= 0 then
        tipStr = g_tr("hurtSoilderEmpty")
        showCostInfo = false
    end
    baseNode:getChildByName("Text_5"):setString(tipStr)
    
    self:showOrHideSomeNodes(showCostInfo)
    
end

function HospitalLayer:showOrHideSomeNodes(visible)
    
    local toHideNodes = {
        baseNode:getChildByName("Panel_dixiaxinxi"),
        baseNode:getChildByName("Button_anniu01"),
        baseNode:getChildByName("Button_anniu02"),
        baseNode:getChildByName("Button_anniu03"),
        baseNode:getChildByName("Panel_7"),
        baseNode:getChildByName("Panel_7_0"),
        baseNode:getChildByName("Panel_ziyuan"),
        baseNode:getChildByName("Text_hf"),
        baseNode:getChildByName("Image_heitiao"),
    }
    
    for key, var in pairs(toHideNodes) do
        var:setVisible(visible)
    end
    
end

function HospitalLayer:updateView()
    print("HospitalLayer:updateView()")
    local injuredSoldiers = require("game.gamedata.InjuredSoldierData").getData()
    local Soldier = require("game.gamedata.Soldier")
    self._soldiers = {}
    for i = 1, #injuredSoldiers do
      local soldier = Soldier.new(injuredSoldiers[i])
      table.insert(self._soldiers,soldier)
    end
    
    scrollView:setTouchEnabled(true)
    local row = 0
    local maxRow = math.ceil(#self._itemArray/2)
    local heightDistance = 0
    
    local cnt = 0
    selectedCapacity = 0
    for i = 1, #self._itemArray do
        local item = self._itemArray[i]
        item:setVisible(true)
        if self._soldiers[i] == nil then
            item:setVisible(false)
            local slider = item:getChildByName("scale_node"):getChildByName("Slider_1")
            slider:setPercent(0)
            slider:setMaxPercent(0)
            item.soldierInfo:setHurtedCount(0)
        else
            cnt = cnt + 1
            if i%2 == 0 then
              item:setPositionX(listSize.width + 10)
            else
              item:setPositionX(0)
            end
            item:setPositionY((listSize.height + heightDistance) * (maxRow - row - 1))
            if i%2 == 0 then
              row = row + 1
            end
            self:upateListItem(item,self._soldiers[i])
            local slider = item:getChildByName("scale_node"):getChildByName("Slider_1")
            selectedCapacity = selectedCapacity + slider:getPercent()
        end
    end
    
    local innerHeight = (listSize.height + heightDistance) * maxRow
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width,innerHeight))
    if innerHeight < scrollView.viewSize.height then
       scrollView:getInnerContainer():setPositionY(scrollView.viewSize.height - innerHeight)
       scrollView:setTouchEnabled(false)
    end
    self:updateCommonShow()
    
end

return HospitalLayer