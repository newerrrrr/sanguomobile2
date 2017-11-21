--region UseResourceView.lua
--Author : luqingqing
--Date   : 2016/1/22
--此文件由[BabeLua]插件自动生成

local UseResourceView = class("UseResourceView", require("game.uilayer.base.BaseLayer"))

function UseResourceView.show(showType, callback)
    if showType == g_Consts.AllCurrencyType.Food then
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.food) then
            local view = require("game.uilayer.shop.UseResourceView").new(showType, callback)
            g_sceneManager.addNodeForUI(view)
        else
            g_airBox.show(g_tr("notUseResource"))
        end
    elseif showType == g_Consts.AllCurrencyType.Wood then
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.wood) then
            local view = require("game.uilayer.shop.UseResourceView").new(showType, callback)
            g_sceneManager.addNodeForUI(view)
        else
            g_airBox.show(g_tr("notUseResource"))
        end
    elseif showType == g_Consts.AllCurrencyType.Gold then
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.gold) then
            local view = require("game.uilayer.shop.UseResourceView").new(showType, callback)
            g_sceneManager.addNodeForUI(view)
        else
            g_airBox.show(g_tr("notUseResource"))
        end
    elseif showType == g_Consts.AllCurrencyType.Iron then
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.iron) then
            local view = require("game.uilayer.shop.UseResourceView").new(showType, callback)
            g_sceneManager.addNodeForUI(view)
        else
            g_airBox.show(g_tr("notUseResource"))
        end
    elseif showType == g_Consts.AllCurrencyType.Stone then
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.stone) then
            local view = require("game.uilayer.shop.UseResourceView").new(showType, callback)
            g_sceneManager.addNodeForUI(view)
        else
            g_airBox.show(g_tr("notUseResource"))
        end
    else
        local view = require("game.uilayer.shop.UseResourceView").new(showType, callback)
        g_sceneManager.addNodeForUI(view)
    end
end

function UseResourceView:ctor(showType, callback)

    UseResourceView.super.ctor(self)

    self.showType = showType
    self.callback = callback
    self.player = g_PlayerMode.GetData()

    self.layer = self:loadUI("Resources_main.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.Text_c2 = self.root:getChildByName("Text_c2")
    self.Button_x = self.root:getChildByName("Button_x")
    self.ListView_1 = self.root:getChildByName("ListView_1")
    self.ListView_1_0 = self.root:getChildByName("ListView_1_0")
    self.Text_c2:setString(g_tr("Resources"))

    self.uilist = {}
    self.contentList = {}

    self.mode = require("game.uilayer.bag.BagMode").new()

    self:initFun()
    self:showTitle()
    self:showContent()
    self:addEvent()
end

local function getShopItemDropByShopId(shopId)
    local dropId = g_data.shop[shopId].commodity_data
    local dropGroups = g_gameTools.getDropGroupByDropIdArray({dropId})
    if #dropGroups > 1 then
        g_airBox.show("商品drop里配置了多个符合条件的掉落物品，界面上只能显示一个！！")
    end
    local dropGroup = dropGroups[1]
    return dropGroup
end

function UseResourceView:initFun()
    self.updateContent = function(item)
        for key, value in pairs(self.uilist) do
            value:clear(false)
        end
        self.showType = item:getItemType()
        self:showContent()
    end

    self.useItem = function(data, useItemView, ui)
        self.selectItemView = useItemView
        self.selectData = data
        self.selectUI = ui
        
        local dropGroup = getShopItemDropByShopId(data)
        local type = dropGroup[1]
        local configId = dropGroup[2]
        local count = dropGroup[3]
        
        local bagData = g_BagMode.FindItemByID(configId)
        local itemView = require("game.uilayer.bag.BabItemInfoView").new(bagData,self.itemUse)
        g_sceneManager.addNodeForUI(itemView)
    end

    self.itemUse = function(itemId, num)
        self.mode:itemUse(itemId, num, function() 
            self.selectItemView:updateNum(self.selectUI, self.selectData)
            
            local dropGroup = getShopItemDropByShopId(self.selectData)
            local type = dropGroup[1]
            local configId = dropGroup[2]
            local count = dropGroup[3]
            
            local bagData = g_BagMode.FindItemByID(configId)
            
            local itemData = g_data.item[configId]
            g_airBox.show(g_tr("useItem")..g_tr(itemData.item_name).."x"..num)
            self:updateTitle()
            if self.callback ~= nil then
                self.callback()
            end
        end)
    end

    self.buyItem = function(shopId)
        local needTip = false
        local shopItemData = g_playerShop.GetShopItemDataByShopId(shopId)
        if shopItemData then
            local itemConfigId = shopItemData:getItemConfigId()
            needTip = g_playerShop.IsShouldNoticeToBuyOrUse(itemConfigId)
        end
        
        local doBuyHandler = function()
            self.mode:shopBuy(shopId, function()
                self:updateTitle()
                g_airBox.show(g_tr("buyAndUseSus"))
                self:showContent()
                if self.callback ~= nil then
                    self.callback()
                end
            end)
        end
        
        if needTip then
            g_msgBox.show(g_tr("bagUseResourceTip"), nil, 2, function(event)
                if event == 0 then
                    doBuyHandler()
                end
            end,1)
        else
            doBuyHandler()
        end
    end
end

function UseResourceView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_x then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            end
        end
    end

    self.Button_x:addTouchEventListener(proClick)
end

function UseResourceView:showTitle()
   
    if self.showType == g_Consts.AllCurrencyType.Coin or self.showType == g_Consts.AllCurrencyType.Gouyu then --铜钱勾玉（只会创建一个）
        local item = require("game.uilayer.shop.UseTitleItem").new(self.showType, self.updateContent)
        self.ListView_1_0:pushBackCustomItem(item)
        item:update(self.showType)
        self.uilist[self.showType] = item
    
    else --普通资源（创建多个）
        
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.gold) then
            local item = require("game.uilayer.shop.UseTitleItem").new(g_Consts.AllCurrencyType.Gold, self.updateContent)
            self.ListView_1_0:pushBackCustomItem(item)
            item:update(g_Consts.AllCurrencyType.Gold)
            self.uilist[g_Consts.AllCurrencyType.Gold] = item
        end
        
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.food) then
            local item = require("game.uilayer.shop.UseTitleItem").new(g_Consts.AllCurrencyType.Food, self.updateContent)
            self.ListView_1_0:pushBackCustomItem(item)
            item:update(g_Consts.AllCurrencyType.Food)
            self.uilist[g_Consts.AllCurrencyType.Food] = item
        end
    
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.wood) then
            local item = require("game.uilayer.shop.UseTitleItem").new(g_Consts.AllCurrencyType.Wood, self.updateContent)
            self.ListView_1_0:pushBackCustomItem(item)
            item:update(g_Consts.AllCurrencyType.Wood)
            self.uilist[g_Consts.AllCurrencyType.Wood] = item
        end
    
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.stone) then
            local item = require("game.uilayer.shop.UseTitleItem").new(g_Consts.AllCurrencyType.Stone, self.updateContent)
            self.ListView_1_0:pushBackCustomItem(item)
            item:update(g_Consts.AllCurrencyType.Stone)
            self.uilist[g_Consts.AllCurrencyType.Stone] = item
        end
    
        if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.iron) then
            local item = require("game.uilayer.shop.UseTitleItem").new(g_Consts.AllCurrencyType.Iron, self.updateContent)
            self.ListView_1_0:pushBackCustomItem(item)
            item:update(g_Consts.AllCurrencyType.Iron)
            self.uilist[g_Consts.AllCurrencyType.Iron] = item
        end
    
    end


    
end

local getDataByCostType = function(type)
    local data = nil
    --local level = g_PlayerMode.GetData().level
    local level = g_PlayerBuildMode.getMainCityBuilding_lv()
    for key, var in pairs(g_data.quick_bug) do
    	if var.type == type 
    	and level >= var.min_level and level <= var.max_level then
    	   data = var
    	   break
    	end
    end
    return data
end

function UseResourceView:showContent()
    self.data = getDataByCostType(self.showType)   
    if self.uilist[self.showType] then
       self.uilist[self.showType]:clear(true)
    end

    local len = 0
    if #self.data.shop_id%2 == 1 then
        len = (#self.data.shop_id + 1)/2
    else
        len = #self.data.shop_id/2
    end

    for i=1, len do
        local item = nil
        if self.contentList[i] == nil then
            item = require("game.uilayer.shop.UseItemView").new(self.useItem, self.buyItem)
            self.ListView_1:pushBackCustomItem(item)
            self.contentList[i] = item
        else
            item = self.contentList[i]
        end
        item:show(self.data.shop_id[i*2-1], self.data.shop_id[i*2])
    end
end

function UseResourceView:updateTitle()
    for key, var in pairs(self.uilist) do
    	   var:update(key)
    end
end

return UseResourceView

--endregion
