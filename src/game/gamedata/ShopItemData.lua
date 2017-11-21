local ShopItemData = class("ShopItemData")

function ShopItemData:ctor(shopId,shopType)
   self:setId(shopId)
   self:setMaxPrice(0)
   self:setShopType(shopType)
   self:updatePirce()
end

------
--  Getter & Setter for
--      ShopItemData._Type
-----
function ShopItemData:setType(Type)
		self._Type = Type
end

function ShopItemData:getType()
		return self._Type
end

------
--  Getter & Setter for
--      ShopItemData._ShopType
-----
function ShopItemData:setShopType(ShopType)
		self._ShopType = ShopType
end

function ShopItemData:getShopType()
		return self._ShopType
end

------
--  Getter & Setter for
--      ShopItemData._ItemConfigId
-----
function ShopItemData:setItemConfigId(ItemConfigId)
		self._ItemConfigId = ItemConfigId
end

function ShopItemData:getItemConfigId()
		return self._ItemConfigId
end

------
--  Getter & Setter for
--      ShopItemData._Id
-----
function ShopItemData:setId(Id)
		self._Id = Id
end

function ShopItemData:getId()
		return self._Id
end

------
--  Getter & Setter for
--      ShopItemData._Count
-----
function ShopItemData:setCount(Count)
		self._Count = Count
end

function ShopItemData:getCount()
		return self._Count
end

------
--  Getter & Setter for
--      ShopItemData._CostType
-----
function ShopItemData:setCostType(CostType)
    self._CostType = CostType
end

function ShopItemData:getCostType()
    return self._CostType
end


------
--  Getter & Setter for
--      ShopItemData._Price
-----
function ShopItemData:setPrice(Price)
		self._Price = Price
end

function ShopItemData:getPrice()
		return self._Price
end

------
--  Getter & Setter for
--      ShopItemData._MaxPrice
-----
function ShopItemData:setMaxPrice(MaxPrice)
    self._MaxPrice = MaxPrice
end

function ShopItemData:getMaxPrice()
    return self._MaxPrice
end

------
--  Getter & Setter for
--      ShopItemData._Config
-----
function ShopItemData:setConfig(Config)
    self._Config = Config
end

function ShopItemData:getConfig()
    return self._Config
end

function ShopItemData:updatePirce()
    local shopItemInfo = g_data.shop[self:getId()]
    self:setConfig(shopItemInfo)
    if shopItemInfo == nil then
       return
    end
    
    local costId = shopItemInfo.cost_id
    local costGroup = g_gameTools.getCostsByCostId(costId)
    table.sort(costGroup,function(a,b)
        return a.cost_num > b.cost_num
    end)
    self.shopItemConfig = shopItemInfo
    local dropId = shopItemInfo.commodity_data
    print("dropId:",dropId)
    local dropGroups = g_gameTools.getDropGroupByDropIdArray({dropId})
    if #dropGroups > 1 then
        g_airBox.show("商品drop里配置了多个符合条件的掉落物品，界面上只能显示一个！！")
    end
    
    assert(#dropGroups >= 1,"drop error,pls check data")
    
    local dropGroup = dropGroups[1]
    self:setType(dropGroup[1])
    self:setItemConfigId(dropGroup[2])
    self:setCount(dropGroup[3])
    
    --self:setShopType(self._shopType)
    
    self:setCostType( costGroup[1].cost_type)
    self:setPrice(costGroup[#costGroup].cost_num)
    self:setMaxPrice( costGroup[1].cost_num)
            

    local boughtCount = 0 --已购买次数
    local shopInfos = g_playerShop.GetData()
    for key, var in pairs(shopInfos) do
      local costInfo = nil
      if var.shop_id == shopItemInfo.id then
         boughtCount = var.num + 1 --下一个的价格
         for key, cost in pairs(costGroup) do
            if cost.cost_id == costId and boughtCount >= cost.min_count and boughtCount <= cost.max_count then
                costInfo = cost
                break
            end
         end 
         if costInfo then
              self:setPrice(costInfo.cost_num)
              self:setCostType(costInfo.cost_type)
         end
         break
      end
    end
end

return ShopItemData