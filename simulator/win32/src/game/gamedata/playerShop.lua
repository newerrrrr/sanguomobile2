--g_playerShop
local playerShop = {}
setmetatable(playerShop,{__index = _G})
setfenv(1,playerShop)

local baseData = nil
local shopItemDataList = nil
local lastUpdateTime = 0

--更新显示
function NotificationUpdateShow()
end


function SetData(data)
    baseData = data
    lastUpdateTime = g_clock.getCurServerTime()
    for key, var in pairs(GetShopItemDataList()) do
        var:updatePirce()
    end
    
end


--请求数据
function RequestData()
    local ret = false
    local function onRecv(result, msgData)
        if(result==true)then
            ret = true
            SetData(msgData.PlayerShop)
            NotificationUpdateShow()
        end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerShop",}},onRecv)
    return ret
end

function GetData()
    if(baseData == nil or not g_clock.isSameDay(g_clock.getCurServerTime(),lastUpdateTime))then
        RequestData()
    end
    return baseData
end

function initShopItemDataList()
    shopItemDataList = {}
    for key, shopItemInfo in pairs(g_data.shop) do
      if shopItemInfo.if_onsale > 0 
      then
        local itemData = require("game.gamedata.ShopItemData").new(shopItemInfo.id,g_Consts.ShopType.NORMAL)
        table.insert(shopItemDataList,itemData)
      end
    end
    
    table.sort(shopItemDataList,function(a,b)
        return a.shopItemConfig.priority < b.shopItemConfig.priority
    end)
end

--普通商城的数据
function GetShopItemDataList(tagType)
    GetData()
    local list = {}
    if shopItemDataList == nil then
        initShopItemDataList()
    end

    local mainCityLevel = g_PlayerBuildMode.getMainCityBuilding_lv()
    for key, shopItemData in pairs(shopItemDataList) do
      local shopItemInfo = shopItemData:getConfig()
      local isVaildType = false
      if tagType == nil then
         isVaildType = true
      else
         isVaildType = shopItemInfo.type == tagType
      end
      if shopItemInfo.if_onsale > 0 
      and isVaildType == true 
      and mainCityLevel >= shopItemInfo.min_level 
      and mainCityLevel <= shopItemInfo.max_level 
      then
         table.insert(list,shopItemData)
      end
    end

    return list
end

function GetShopItemDataByShopId(shopId)
    local shopData = nil
    for key, var in pairs(GetShopItemDataList()) do
    	 if var:getId() == tonumber(shopId) then
    	     shopData = var
    	     break
    	 end
    end
    return shopData
end

function IsShouldNoticeToBuyOrUse(itemId)
    local shouldTip = false
    
    local itemInfo = g_data.item[itemId]
    if itemInfo.item_original_id == 201
    or itemInfo.item_original_id == 202
    or itemInfo.item_original_id == 203
    or itemInfo.item_original_id == 204
    or itemInfo.item_original_id == 205
    then
        local wareHouselist = require("game.uilayer.buildupgrade.BuildingUIHelper").getWarehouseInfo()
        --19 黄金保护
        --20 粮食保护
        --21 木材保护
        --22 石材保护
        --23 铁材保护
        
    
        local drops = g_gameTools.getDropGroupByDropIdArray(itemInfo.drop)
        assert(#drops == 1,"found drops > 1")--找到了多個符合條件的drop
        local num = drops[1][3]
        
        if itemInfo.item_original_id == 201 then --黄金
            local cnt = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gold)
            if cnt + num > wareHouselist[19] then
               shouldTip = true
            end
        elseif itemInfo.item_original_id == 202 then --粮食
            local cnt = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Food)
            if cnt + num > wareHouselist[20] then
               shouldTip = true
            end
        elseif itemInfo.item_original_id == 203 then --木材
            local cnt = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Wood)
            if cnt + num > wareHouselist[21] then
               shouldTip = true
            end
        elseif itemInfo.item_original_id == 204 then --石头
            local cnt = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Stone)
             if cnt + num > wareHouselist[22] then
               shouldTip = true
            end
        elseif itemInfo.item_original_id == 205 then --铁矿
            local cnt = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Iron)
            if cnt + num > wareHouselist[23] then
               shouldTip = true
            end
        end
    end

    return shouldTip
end

return playerShop