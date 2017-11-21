local ShopMarketLayer = class("ShopMarketLayer",function()
    return cc.Layer:create()
end)

local createShopData = function(configId,id)
    local shopItemInfo = g_data.market[configId]
    local costId = shopItemInfo.cost_id
    local costGroup = g_gameTools.getCostsByCostId(costId)
    local itemData = require("game.gamedata.ShopItemData").new()
    itemData:setId(id)
    local dropId = shopItemInfo.commodity_data
    local dropGroups = g_gameTools.getDropGroupByDropIdArray({dropId})
    if #dropGroups > 1 then
        g_airBox.show("商品drop里配置了多个符合条件的掉落物品，界面上只能显示一个！！")
    end
    local dropGroup = dropGroups[1]
    itemData:setType(dropGroup[1])
    itemData:setItemConfigId(dropGroup[2])
    itemData:setCount(dropGroup[3])
    
    itemData:setShopType(g_Consts.ShopType.MARKET)
    
    itemData:setPrice(costGroup[1].cost_num)
    itemData:setCostType( costGroup[1].cost_type)
    
    itemData.config = shopItemInfo
    
    return itemData
end

function ShopMarketLayer.show()
    local canShow = false
    if g_shopMarketData.GetData() == nil then
       canShow = g_shopMarketData.RequestData()
    else
       canShow = true
    end
    
    if canShow then
        g_sceneManager.addNodeForUI(ShopMarketLayer:create())
    end
    
end

function ShopMarketLayer:ctor()
    local uiLayer =  g_gameTools.LoadCocosUI("shop_market_main.csb",5)
    self:addChild(uiLayer)
    
    g_resourcesInterface.installResources(uiLayer)
    
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    baseNode:getChildByName("Text_mingc"):setString(g_tr("marketTitleName"))
    baseNode:getChildByName("Text_2"):setString(g_tr("marketSaleTitle"))

    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    self:registerScriptHandler(function(eventType)
        if eventType == "enter" then
            g_shopMarketData.setView(self)
        elseif eventType == "exit" then
            g_shopMarketData.setView(nil)
        end 
      end )
    
    self._listView = baseNode:getChildByName("ListView_1")
    
    baseNode:getChildByName("Text_mf"):setString(g_tr("marketRefreshFree")) --免费刷新
    baseNode:getChildByName("Panel_sx"):getChildByName("Text_sx1"):setString(g_tr("marketRefresh")) --刷新
    
    local onRefreshHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            
            local doHandler = function()
                local function onResult(result, msgData)
                  if result == true then
                      g_airBox.show(g_tr("marketRefreshSuccess"))
                  end
                end
                g_sgHttp.postData("market/reload",{},onResult)
            end
            
--            if costNum > 0 then
--                local text = g_tr("makeSureRefreshMarket")
--                local cost = costNum
--                local buttonText = g_tr("marketBtnRefresh")
--                local title = nil
--                g_msgBox.showConsume(cost, text, title, buttonText,doHandler)
--            else
--                doHandler()
--            end

            doHandler()
        end
    end
    
    self._baseNode:getChildByName("Button_mf"):addTouchEventListener(onRefreshHandler)
    self._baseNode:getChildByName("Panel_sx"):getChildByName("Button_sx1"):addTouchEventListener(onRefreshHandler)
    
    
    self:updateView()
    
end

------
--  Getter & Setter for
--      ShopMarketLayer._IsBusy
-----
function ShopMarketLayer:setIsBusy(IsBusy)
    self._IsBusy = IsBusy
end

function ShopMarketLayer:getIsBusy()
    return self._IsBusy
end

function ShopMarketLayer:updateView()
    local marketData = g_shopMarketData.GetData()
    
    if not marketData then
        return
    end
    
    self:setIsBusy(true)
    self:stopAllActions()
    
    local baseNode = self._baseNode
    
    local todayOnSaleShopItem = marketData.special_id
    local todayOnSaleItemData = createShopData(todayOnSaleShopItem)
    
    local showPrice = g_data.market[todayOnSaleShopItem].show_price
    self._baseNode:getChildByName("Panel_2"):getChildByName("price_0"):setString(showPrice.."")
    
    local pic = baseNode:getChildByName("Panel_2"):getChildByName("Image_12")
    pic:removeAllChildren()
    
    local size = pic:getContentSize()
    
    local icon = require("game.uilayer.common.DropItemView"):create(todayOnSaleItemData:getType(),todayOnSaleItemData:getItemConfigId(),todayOnSaleItemData:getCount())
    pic:addChild(icon)
    icon:setPositionX(size.width/2)
    icon:setPositionY(size.height/2)
   
    baseNode:getChildByName("Panel_2"):getChildByName("Text_3"):setString(icon:getName())
    baseNode:getChildByName("Panel_2"):getChildByName("Text_15"):setString(icon:getDesc())
    baseNode:getChildByName("Panel_2"):getChildByName("price"):setString(todayOnSaleItemData:getPrice().."")
    
    baseNode:getChildByName("Text_16"):setString("")
  
    baseNode:getChildByName("Panel_2"):getChildByName("Image_dik1_0"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + todayOnSaleItemData:getCostType()))
    baseNode:getChildByName("Panel_2"):getChildByName("Image_dik1"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + todayOnSaleItemData:getCostType()))
    
    local shopItemIds = marketData.market_ids
    
    local shopItems = {}
    for key, marketId in pairs(shopItemIds) do
        local itemData = createShopData(marketId,tonumber(key))
        shopItems[tonumber(key)] = itemData
    end
    
    self._listView:removeAllChildren()
    
    if #shopItems > 0 then
        local commodityItem = cc.CSLoader:createNode("alliance_store_goods.csb")
        commodityItem:getChildByName("goods"):getChildByName("price1"):setVisible(false)
        commodityItem:getChildByName("goods"):getChildByName("Image_rmai"):setVisible(false)
        commodityItem:getChildByName("goods"):getChildByName("Image_dik_0"):setVisible(false)
        
        --local commodityItem = require("game.uilayer.union.unionshop.UnionShopCommodity"):create()
        local itemSize = commodityItem:getChildByName("goods"):getContentSize()
        
        local itemCapacity = 3
        local count = 1
        local maxRow = math.ceil(#shopItems/itemCapacity)
        local widthDistance = 30
        local heightDistance = 10
        local rowSize = cc.size((itemSize.width + widthDistance) * itemCapacity,itemSize.height)
        
        self._listView:setItemsMargin(heightDistance)

        for i = 1, maxRow do
            local rowContainer = ccui.Widget:create()
            rowContainer:setContentSize(rowSize)
            for j = 1, itemCapacity do
                if count <= #shopItems then
                    local itemCsb = commodityItem:clone()
                    local item = require("game.uilayer.shop.ShopCommodity"):create(itemCsb,shopItems[count])
                    item:setDelegate(self)
                    rowContainer:addChild(item)
                    
                    local animType = 0
                    if shopItems[count].config.type == 2 then --今日特卖
                        animType = 1
                        itemCsb:getChildByName("goods"):getChildByName("Image_rmai"):setVisible(true)
                    else
                        if shopItems[count].config.if_onsale == 1 then
                            animType = 2
                        elseif shopItems[count].config.if_onsale == 2 then
                            animType = 3
                        end
                    end
                    
                    if animType > 0 then
                        
                        local costType = shopItems[count]:getCostType()
                        if costType == g_Consts.AllCurrencyType.Gem then
                            itemCsb:getChildByName("goods"):getChildByName("price1"):setVisible(true)
                            itemCsb:getChildByName("goods"):getChildByName("Image_dik_0"):setVisible(true)
                            
                            local priceStr= string.formatnumberthousands(shopItems[count].config.show_price)
                            itemCsb:getChildByName("goods"):getChildByName("price1"):setString(g_tr("marketOriginalPrice",{price = priceStr}))
                        end
                        
                        local contanier = item:getIconWidget()
                        local size = contanier:getContentSize()
                        local projName = "Effect_112PxWaiKuangXuanZhuan"
                        local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName)
                        contanier:addChild(armature)
                        armature:setPosition(cc.p(size.width/2,size.height/2))
                        if animType ==1 then
                            animation:play("Golden")
                        elseif animType == 2 then
                            animation:play("Blue")
                        elseif animType == 3 then
                            animation:play("Violet")
                        end
                        
                    end
                    
                    item:setPositionX((itemSize.width + widthDistance) * (j-1) + itemSize.width*0.5)
                    item:setPositionY(itemSize.height * 0.5)
                    count = count + 1
                end
            end
            self._listView:pushBackCustomItem(rowContainer)
        end
        
    end
    
    local refreshedCnt = g_shopMarketData.GetData().counter
    
    baseNode:getChildByName("Text_16"):setString("")
    self._baseNode:getChildByName("Panel_sx"):setVisible(true)
    
    local costNum = 0
    local costType = g_Consts.AllCurrencyType.Gem
    --免费刷新
    local freeCntToday = tonumber(g_data.starting[58].data)
    if refreshedCnt - freeCntToday < 0 then
       self._baseNode:getChildByName("Panel_sx"):setVisible(false)
       costNum = 0
       baseNode:getChildByName("Text_16"):setString(g_tr("marketFreeRefreshTimes",{times = freeCntToday - refreshedCnt}))
    else --收费刷新
        local targetCnt = refreshedCnt - freeCntToday + 1
        local costId = 4040 --集市刷新价格
        for key, var in pairs(g_data.cost) do
          if costId == var.cost_id 
          and targetCnt >= var.min_count
          and targetCnt <= var.max_count then
             costNum = var.cost_num
             costType = var.cost_type
             break
          end
        end
        assert(costType > 0)
    
    end

    self._baseNode:getChildByName("Panel_sx"):getChildByName("Text_sx2"):setString(costNum.."")
    self._baseNode:getChildByName("Panel_sx"):getChildByName("Image_yb"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
    
    
    local delay = cc.DelayTime:create(0.2)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
        self:setIsBusy(false)
    end))
    self:runAction(sequence)
end

return ShopMarketLayer