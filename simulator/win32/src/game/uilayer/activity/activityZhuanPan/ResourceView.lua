local ResourceView = class("ResourceView", require("game.uilayer.base.BaseLayer"))

--showType = g_Consts.AllCurrencyType.Gold
function ResourceView:ctor(showType, callback, num)
	ResourceView.super.ctor(self)

    self.mode = require("game.uilayer.bag.BagMode").new()
	self.showType = showType
	self.callback = callback
	self.num = num or 0

	self.layer = self:loadUI("Resources_main.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.Text_c2 = self.root:getChildByName("Text_c2")
    self.Button_x = self.root:getChildByName("Button_x")
    self.ListView_1 = self.root:getChildByName("ListView_1")
    self.ListView_1_0 = self.root:getChildByName("ListView_1_0")
    self.Text_c2:setString(g_tr("Resources"))


    self.Button_x:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:close()
        end
    end)

    self:initFun()
    self:setTitle()
    self:setData()
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

function ResourceView:initFun()
	self.buyItem = function(shopId)
        self.mode:shopBuy(shopId, function()
            self.title:update(self.showType)
            g_airBox.show(g_tr("buyAndUseSus"))
            if self.callback ~= nil then
                self.callback()
            end
        end)
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
            self.title:update(self.showType)
            if self.callback ~= nil then
                self.callback()
            end
        end)
    end
end

function ResourceView:setTitle()
	self.title = require("game.uilayer.shop.UseTitleItem").new(self.showType, nil, self.num)
	self.ListView_1_0:pushBackCustomItem(self.title)
	self.title:update(self.showType)
end

function ResourceView:setData()
	self.quickData = {}
	local list = g_data.quick_bug
	for key, value in pairs(list) do
		if value.type == self.showType then
			self.quickData = value
			break
		end
	end

	local len = 0
	if (#self.quickData.shop_id)%2 == 1 then
		len = (#self.quickData.shop_id)/2 + 1
	else
		len = #self.quickData.shop_id
	end

	for i= 1, len do
		local item = require("game.uilayer.shop.UseItemView").new(self.useItem, self.buyItem)
        self.ListView_1:pushBackCustomItem(item)
        item:show(self.quickData.shop_id[i*2-1], self.quickData.shop_id[i*2])
	end
end

return ResourceView