local AllianceShop = {}

local baseData = nil
local shopList = {}
local shopLayerView = nil

function AllianceShop.reqBaseDataAsync(callback)
    local function onRecv(result, msgData)
      if result == true then
        AllianceShop.setBaseData(msgData.GuildShop)
      end
      if callback then
         callback(result, msgData)
      end
    end
    g_sgHttp.postData("data/index",{name = {"GuildShop",}},onRecv,true)
end

function AllianceShop.reqBaseData()
    local function onRecv(result, msgData)
      if result == true then
        AllianceShop.setBaseData(msgData.GuildShop)
      end
    end
    g_sgHttp.postData("data/index",{name = {"GuildShop",}},onRecv)
end

function AllianceShop.setBaseData(data)
    baseData = data
    shopList = {}
    --dump(data)
    for key, var in pairs(data) do
      local shopItemInfo = g_data.alliance_shop[var.item_id]
      assert(shopItemInfo)
      local costId = shopItemInfo.player_cost
      local costGroup = g_gameTools.getCostsByCostId(costId,1)
      local itemData = require("game.gamedata.ShopItemData").new()
      itemData:setType(g_Consts.DropType.Props)
      itemData:setItemConfigId(shopItemInfo.item_id)
      itemData:setShopType(g_Consts.ShopType.ALLIANCE_PLAYER)
      itemData:setPrice(costGroup[1].cost_num)
      itemData:setCostType(costGroup[1].cost_type)
      itemData:setCount(var.num)
      itemData:setId(var.id)
    	table.insert(shopList,itemData)
    end
end

--读取联盟商店基本信息
function AllianceShop.getBaseData(isForceRefresh)
    if baseData == nil or isForceRefresh == true then
      AllianceShop.reqBaseData()
    end
    return baseData
end

function AllianceShop.setShopLayerView(layer)
    shopLayerView = layer
end

function AllianceShop.getShopLayerView(isForceRefresh)
    return shopLayerView
end

function AllianceShop.setShopItemList(ShopItemList)
		shopList = ShopItemList
end

function AllianceShop.getShopItemList(isForceRefresh)
    if shopList == nil or isForceRefresh == true then
       AllianceShop.reqBaseData(isForceRefresh)
    end
		return shopList
end

function AllianceShop.getShopItemDataByItemId(itemId)
    local list = AllianceShop.getShopItemList()
    local data = nil
    for key, var in pairs(list) do
    	if itemId == var:getItemConfigId() then
    	   data = var
    	   break
    	end
    end
    return data
end

function AllianceShop.notificationUpdateShow()
    
end

return AllianceShop