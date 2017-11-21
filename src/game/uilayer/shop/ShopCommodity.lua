local ShopCommodity = class("ShopCommodity",function()
    return ccui.Widget:create()
end)

function ShopCommodity:ctor(uiLayer,data,updateCallBack)
    --local uiLayer = cc.CSLoader:createNode("alliance_store_goods.csb")
    self._updateCallBack = updateCallBack
    assert(uiLayer)
    self:addChild(uiLayer)
    self._baseNode = uiLayer:getChildByName("goods")
    
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._baseNode:getContentSize())

    if data then
        self:setData(data)
    end
    
    --点击商品
    self._baseNode:addClickEventListener(function(sender,eventType)
        --if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("clicked")
            local data = self:getData()
            if data:getShopType() == g_Consts.ShopType.ALLIANCE then
                local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
                if myInfo and myInfo.rank < 4 then
                    g_airBox.show(g_tr("permissionDenied"))
                    return 
                end
            elseif data:getShopType() == g_Consts.ShopType.ALLIANCE_PLAYER then
--                local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
--                if myInfo and myInfo.rank < 4 then
--                    g_airBox.show(g_tr("permissionDenied"))
--                    return 
--                end
            end
            
            local del = self:getDelegate()
            if del and del:getIsBusy() == true then
                return
            end
            
            local alertLayer = require("game.uilayer.shop.ShopBuyAlertLayer"):create(self:getData())
            alertLayer:setDelegate(self)
            g_sceneManager.addNodeForUI(alertLayer)
            
        --end
    end)

end

------
--  Getter & Setter for
--      ShopCommodity._Delegate
-----
function ShopCommodity:setDelegate(Delegate)
    self._Delegate = Delegate
end

function ShopCommodity:getDelegate()
    return self._Delegate
end

------
--  Getter & Setter for
--      ShopCommodity._Data
-----
function ShopCommodity:setData(Data)
    self._Data = Data
    self:setPrice(Data:getPrice())
    self:updateView()

end

function ShopCommodity:getData()
    return self._Data
end

------
--  Getter & Setter for
--      ShopCommodity._IconWidget
-----
function ShopCommodity:setIconWidget(IconWidget)
    self._IconWidget = IconWidget
end

function ShopCommodity:getIconWidget()
    return self._IconWidget
end

function ShopCommodity:updateView()
    local Data = self:getData()
    
    self._baseNode:getChildByName("Text_2"):setVisible(false)
    local pic = self._baseNode:getChildByName("pic")
    local size = pic:getContentSize()
    pic:removeAllChildren()
    local icon = require("game.uilayer.common.DropItemView"):create(Data:getType(),Data:getItemConfigId(),Data:getCount())
    pic:addChild(icon)
    icon:setPositionX(size.width/2)
    icon:setPositionY(size.height/2)
    self:setName(icon:getName())
    self._baseNode:getChildByName("ico_gold"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + Data:getCostType()))
    if Data:getShopType() == g_Consts.ShopType.ALLIANCE then
      icon:setCountEnabled(false)
    end
    
    self:setIconWidget(icon)
    
    self._baseNode:getChildByName("price"):setString(string.formatnumberthousands(Data:getPrice()))
    
    self._baseNode:getChildByName("price1"):setVisible(false)
    self._baseNode:getChildByName("Image_dik_0"):setVisible(false)
    if Data:getMaxPrice() and Data:getPrice() < Data:getMaxPrice() then
        self._baseNode:getChildByName("price1"):setVisible(true)
        self._baseNode:getChildByName("Image_dik_0"):setVisible(true)
        local priceStr= string.formatnumberthousands(Data:getMaxPrice())
        self._baseNode:getChildByName("price1"):setString(g_tr("marketOriginalPrice",{price = priceStr}))
    end
    
    if self._updateCallBack then
      self._updateCallBack()
    end
end

------
--  Getter & Setter for
--      ShopCommodity._Name
-----
function ShopCommodity:setName(Name)
    self._Name = Name
    self._baseNode:getChildByName("name"):setString(Name)
end

function ShopCommodity:getName()
    return self._Name
end

------
--  Getter & Setter for
--      ShopCommodity._Price
-----
function ShopCommodity:setPrice(Price)
    self._Price = Price
    self._baseNode:getChildByName("price"):setString(string.formatnumberthousands(Price))
end

function ShopCommodity:getPrice()
    return self._Price
end

return ShopCommodity