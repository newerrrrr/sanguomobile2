local ShopLayer = class("ShopLayer",function()
    return cc.Layer:create()
end)

local titlePosX = 0
local actionTag = 56586
function ShopLayer:ctor(shopType)
    assert(shopType)
    self._shopType = shopType
    
    self._lastIdx = 1
    self._lastTagIdx = 1
    self._tagMenus = {}
    
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
         require("game.gamedata.AllianceShop").setShopLayerView(self)
      elseif eventType == "exit" then
         require("game.gamedata.AllianceShop").setShopLayerView(nil)
         if self.closeCallBack then
            self.closeCallBack()
         end
      end 
    end )
    
    
	local uiLayer =  g_gameTools.LoadCocosUI("alliance_store_main.csb",5)
    self:addChild(uiLayer)
    g_resourcesInterface.installResources(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    titlePosX = baseNode:getChildByName("Panel_1"):getPositionX()
    
    self._emptyRuleLabel = g_gameTools.createRichText(baseNode:getChildByName("Text_2"),g_tr("allianceStoreRule"))
    self._emptyRuleLabel:setVisible(false)
    
    baseNode:getChildByName("Image_1"):setVisible(false)
    baseNode:getChildByName("Image_1"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if self._shopType == g_Consts.ShopType.ALLIANCE 
            or self._shopType == g_Consts.ShopType.ALLIANCE_PLAYER then
                require("game.uilayer.common.HelpInfoBox"):show(9) 
            elseif self._shopType == g_Consts.ShopType.NORMAL then
                if self._lastTagIdx == 6 then
                    require("game.uilayer.common.HelpInfoBox"):show(16) 
                end
            end
        end
    end)
    
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    self:initTabMenus()
    
    self:resetListView()
    
    assert(self._shopType)
    self:tabMenus(1,true)
end

function ShopLayer:initTabMenus()
    --self._tabMenus = {}
    for i = 1, 5 do
    	self._baseNode:getChildByName("menu_btn_"..i):setVisible(false)
    	self._baseNode:getChildByName("menu_btn_"..i):getChildByName("Text_1"):setString("")
    	
    end
    
    local itemsMargin = 6.0
    
    local menusTexts = {}
    local tagTexts = {}
    if self._shopType == g_Consts.ShopType.ALLIANCE 
    or self._shopType == g_Consts.ShopType.ALLIANCE_PLAYER then
       --联盟商城
       
       self._baseNode:getChildByName("Image_1"):setVisible(true)
       menusTexts = 
       {
          g_tr("shop"),
          g_tr("goodsList"),
       }
       
       tagTexts = 
       {
          g_tr("shop"),
          g_tr("goodsList"),
       }
       itemsMargin = 20.0
       g_guideManager.registGameFeature(self,g_guideManager.gameFeatures.ALLIANCE_SHOP)
    elseif self._shopType == g_Consts.ShopType.NORMAL then
        --普通商城标签
        menusTexts = 
        {
            g_tr("shop"),
        }
        
        
        tagTexts = {
            g_tr("goodsType1"),
            g_tr("goodsType2"),
            g_tr("goodsType3"),
            g_tr("goodsType4"),
            g_tr("goodsType5"),
            g_tr("goodsType6"),
        }
        
        self._baseNode:getChildByName("Panel_1"):setPositionX(titlePosX + 70)
        g_guideManager.registGameFeature(self,g_guideManager.gameFeatures.SHOP)
    end
    
    --标签
    local tagListView = self._baseNode:getChildByName("ListView_2")
    tagListView:setItemsMargin(itemsMargin)
    if #tagTexts <= 6 then
        tagListView:setTouchEnabled(false)
    end
    
    local tagBtn = cc.CSLoader:createNode("alliance_list_Button1.csb")
    self._tagMenus = {}
    for i = 1, #tagTexts do
        local tagItem = tagBtn:clone()
        tagItem:getChildByName("Panel_b1"):getChildByName("Text_1"):setString(tagTexts[i])
        tagListView:pushBackCustomItem(tagItem)
        
        local btn = tagItem:getChildByName("Panel_b1"):getChildByName("Button_1")
        btn:setTouchEnabled(true)
        table.insert(self._tagMenus,btn)
        btn.idx = i
        btn:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              self:tabTags(sender.idx)
            end
        end)
    end
        
    --大标签页不再使用
    --[[for i = 1, #menusTexts do
      local menuBtn = self._baseNode:getChildByName("menu_btn_"..i)
      menuBtn:setTitleText(menusTexts[i])
      table.insert(self._tabMenus,menuBtn)
      menuBtn.idx = i
      menuBtn:setVisible(true)
      menuBtn:setTouchEnabled(true)
      menuBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabMenus(sender.idx)
          end
      end)
      
    end]]
end

function ShopLayer:changeShopType(idx)
    if idx == 1 then
        if self._shopType == g_Consts.ShopType.ALLIANCE then
            self._shopType = g_Consts.ShopType.ALLIANCE_PLAYER
        end
    elseif idx == 2 then
        if self._shopType == g_Consts.ShopType.ALLIANCE_PLAYER then
            self._shopType = g_Consts.ShopType.ALLIANCE
        end
    end
end

function ShopLayer:tabTags(idx)
    if self._lastTagIdx == idx then
        return
    end
    self._lastTagIdx = idx
    
    if self._shopType == g_Consts.ShopType.ALLIANCE 
    or self._shopType == g_Consts.ShopType.ALLIANCE_PLAYER then
        self:tabMenus(self._lastTagIdx,true)
    elseif self._shopType == g_Consts.ShopType.NORMAL then
        self:tabMenus(self._lastIdx,true)
    end
end

function ShopLayer:updateView()
    print("ShopLayer:updateView~~~~~~~~~~~~~~")
    local position = self._listView:getInnerContainerPosition()
    self:tabMenus(self._lastIdx,true)
    self._listView:setInnerContainerPosition(position)
end

function ShopLayer:updateTitleView()
     if self._shopType == g_Consts.ShopType.ALLIANCE then
        self._baseNode:getChildByName("Panel_1"):getChildByName("bg_sw"):getChildByName("text"):setString(g_tr("allianceScore"))
        local costType = g_Consts.AllCurrencyType.AllianceHonor
        local count,iconPath = g_gameTools.getPlayerCurrencyCount(costType)
        self._baseNode:getChildByName("Panel_1"):getChildByName("Text_3"):setString(string.formatnumberthousands(count))
        self._baseNode:getChildByName("Panel_1"):getChildByName("Image_3_0"):loadTexture(iconPath)
     elseif self._shopType == g_Consts.ShopType.ALLIANCE_PLAYER then
        self._baseNode:getChildByName("Panel_1"):getChildByName("bg_sw"):getChildByName("text"):setString(g_tr("allianceHonor"))
        local costType = g_Consts.AllCurrencyType.PlayerHonor
        local count,iconPath = g_gameTools.getPlayerCurrencyCount(costType)
        self._baseNode:getChildByName("Panel_1"):getChildByName("Text_3"):setString(string.formatnumberthousands(count))
        self._baseNode:getChildByName("Panel_1"):getChildByName("Image_3_0"):loadTexture(iconPath)
     elseif self._shopType == g_Consts.ShopType.NORMAL then

        local costType = g_Consts.AllCurrencyType.Gem
        local costNameStr = g_tr("playerGem")
        if self._lastTagIdx == 6 then
            costType = g_Consts.AllCurrencyType.JinNang
            costNameStr = g_tr("goodsType6")
        elseif self._lastTagIdx == 5 then
            costType = g_Consts.AllCurrencyType.ZhanXun
            costNameStr = g_tr("goodsType5")
        end
        local count,iconPath = g_gameTools.getPlayerCurrencyCount(costType)
        self._baseNode:getChildByName("Panel_1"):getChildByName("Image_3_0"):loadTexture(iconPath)
        self._baseNode:getChildByName("Panel_1"):getChildByName("bg_sw"):getChildByName("text"):setString(costNameStr)
        self._baseNode:getChildByName("Panel_1"):getChildByName("Text_3"):setString(string.formatnumberthousands(count))
        
     end
     
     self._baseNode:getChildByName("Panel_1"):getChildByName("bg_sw"):getChildByName("text"):setVisible(false)
end

function ShopLayer:tabMenus(idx,forceRefresh)
    
    if self._lastIdx == idx and not forceRefresh then
        return
    end
    self._lastIdx = idx
    
    --[[for key, btn in pairs(self._tabMenus) do
    	btn:setEnabled(true)
    end
    self._tabMenus[idx]:setEnabled(false)]]
    
    --tag highlight
    for key, btn in pairs(self._tagMenus) do
        btn:setEnabled(true)
    end
    if self._tagMenus[self._lastTagIdx] then
        self._tagMenus[self._lastTagIdx]:setEnabled(false)
    end
    
    self:changeShopType(idx)
    
    self:updateTitleView()
    
    self._emptyRuleLabel:setVisible(false)
    
    local shopItems = {}
    if self._shopType == g_Consts.ShopType.ALLIANCE then
        --allianceScore
        local allianceShopGoods = {}
        do
            for key, shopItemInfo in pairs(g_data.alliance_shop) do
                table.insert(allianceShopGoods,shopItemInfo)
            end
              table.sort(allianceShopGoods,function(a,b)
                  return a.id < b.id
              end)
        end
      
        for key, shopItemInfo in ipairs(allianceShopGoods) do
          local costId = shopItemInfo.alliance_cost
          local costGroup = g_gameTools.getCostsByCostId(costId,1)
          local itemData = require("game.gamedata.ShopItemData").new()
          itemData:setType(g_Consts.DropType.Props)
          itemData:setItemConfigId(shopItemInfo.item_id)
          itemData:setShopType(self._shopType)
          local costNum = costGroup[1].cost_num
          local costType = costGroup[1].cost_type
          itemData:setPrice(costNum)
          itemData:setCostType(costType)
          itemData:setCount(1)
          table.insert(shopItems,itemData)
        end
    elseif self._shopType == g_Consts.ShopType.ALLIANCE_PLAYER then
--        shopItems = require("game.gamedata.AllianceShop").getShopItemList(true)
--        self._emptyRuleLabel:setVisible(#shopItems == 0)
    elseif self._shopType == g_Consts.ShopType.NORMAL then
        
        self._baseNode:getChildByName("Image_1"):setVisible(false)
        if self._lastTagIdx == 6 then
            self._baseNode:getChildByName("Image_1"):setVisible(true)
        end
        
        shopItems = g_playerShop.GetShopItemDataList(self._lastTagIdx)
        
--        local mainCityLevel = g_PlayerBuildMode.getMainCityBuilding_lv()
--        for key, shopItemInfo in pairs(g_data.shop) do
--          if shopItemInfo.type == self._lastTagIdx 
--          --and shopItemInfo.shop_type == idx
--          and shopItemInfo.if_onsale > 0 
--          and mainCityLevel >= shopItemInfo.min_level 
--          and mainCityLevel <= shopItemInfo.max_level 
--          then
--            local itemData = require("game.gamedata.ShopItemData").new(shopItemInfo.id,self._shopType)
--            table.insert(shopItems,itemData)
--          end
--        end
--        
--        table.sort(shopItems,function(a,b)
--            return a.shopItemConfig.priority < b.shopItemConfig.priority
--        end)
    else
        assert(false,"invaild shop type")
    end
    
    local prepareUpdateView = function()
        --dump(shopItems)
        self:resetListView()
        self:stopActionByTag(actionTag)
    
         --更新商品显示
        if self._shopType == g_Consts.ShopType.ALLIANCE_PLAYER then
            g_busyTip.show_1()
            require("game.gamedata.AllianceShop").reqBaseDataAsync(function(result,msgDatsa)
                g_busyTip.hide_1()
                shopItems = require("game.gamedata.AllianceShop").getShopItemList()
                self._emptyRuleLabel:setVisible(#shopItems == 0)
                self:updateShopShow(shopItems)
            end)
        else
            self:updateShopShow(shopItems,self._shopType)
        end
    end
    
    prepareUpdateView()

end

function ShopLayer:updateShopShow(shopItems)

   
    
    if #shopItems > 0 then
        
        
        local itemCapacity = 4
        local count = 1
        local maxRow = math.ceil(#shopItems/itemCapacity)
        local widthDistance = 30
        local heightDistance = 10
        
        
        self._listView:setItemsMargin(heightDistance)
        
        local createItem = function(shopItemData)
            local commodityItem = cc.CSLoader:createNode("alliance_store_goods.csb")
            commodityItem:getChildByName("goods"):getChildByName("price1"):setVisible(false)
            commodityItem:getChildByName("goods"):getChildByName("Image_rmai"):setVisible(false)
            commodityItem:getChildByName("goods"):getChildByName("Image_dik_0"):setVisible(false)
            
            --local commodityItem = require("game.uilayer.union.unionshop.UnionShopCommodity"):create()
            local itemSize = commodityItem:getChildByName("goods"):getContentSize()
            local rowSize = cc.size((itemSize.width + widthDistance) * itemCapacity,itemSize.height)
        
            local rowContainer = ccui.Widget:create()
            rowContainer:setContentSize(rowSize)
            for j = 1, itemCapacity do
                if count <= #shopItems then
                    local item = require("game.uilayer.shop.ShopCommodity"):create(commodityItem:clone(),shopItems[count],
                    handler(self,self.updateTitleView))
                    rowContainer:addChild(item)
                    item:setPositionX((itemSize.width + widthDistance) * (j-1) + itemSize.width*0.5)
                    item:setPositionY(itemSize.height * 0.5)
                    count = count + 1
                end
            end
            self._listView:pushBackCustomItem(rowContainer)
        end

        
        local startIdx = 2
        local idx = 1
        for key = 1, maxRow do
            if key > startIdx then
                break
            else
                createItem()
                idx = idx + 1
            end
        end
        
        local callback = function()
            createItem()
            idx = idx + 1
            if idx > maxRow then
                self:stopActionByTag(actionTag)
            end
        end
        
        if maxRow > startIdx then
            local sequence = cc.Sequence:create(cc.DelayTime:create(0.001), cc.CallFunc:create(callback))
            local action = cc.RepeatForever:create(sequence)
            action:setTag(actionTag)
            self:runAction(action)
        end
        
    end
end

function ShopLayer:resetListView()
     if  self._listView then
          self._listView:removeFromParent()
     end
     
     local listViewOrginal = self._baseNode:getChildByName("ListView_1")
     listViewOrginal:setVisible(false)
     self._listView = listViewOrginal:clone()
     self._listView:setVisible(true)
     listViewOrginal:getParent():addChild(self._listView)
end

function ShopLayer:setCloseCallBack(fun)
    self.closeCallBack = fun
end

return ShopLayer