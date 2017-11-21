
--激活VIP/提升VIP点数弹框

local VIPActiveExpUp = class("VIPActiveExpUp", require("game.uilayer.base.BaseLayer"))
local VIPMode = require("game.uilayer.vip.VIPMode")
local vipLevelMax = VIPMode:getVipLevelMax()

function VIPActiveExpUp:ctor()
  VIPActiveExpUp.super.ctor(self)
end 

function VIPActiveExpUp:onEnter()
  print("VIPActiveExpUp:onEnter")
  self.isPopDurty = false 
end


function VIPActiveExpUp:onExit() 
  if self.isPopDurty and self.callbackFunc then 
    self.callbackFunc()
  end 
end 

function VIPActiveExpUp:showActivePop(callback)
  local pop = VIPActiveExpUp.new()
  pop:init(true, callback)
  g_sceneManager.addNodeForUI(pop)
end 

function VIPActiveExpUp:showAdvancePop(callback)
  local pop = VIPActiveExpUp.new()
  pop:init(false, callback)
  g_sceneManager.addNodeForUI(pop)
end 

function VIPActiveExpUp:init(isActiveVip, callback)
  self.callbackFunc = callback 
  self.isActPop = isActiveVip 

  self.popLayer = cc.CSLoader:createNode("vip_activation_main.csb")
  local root = self.popLayer:getChildByName("scale_node") 
  local mask = root:getChildByName("filter") 
  self:regBtnCallback(mask, handler(self, self.close))
  root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))
  self:addChild(self.popLayer)
  if isActiveVip then 
    root:getChildByName("Text_c2"):setString(g_tr("vip_active"))
  end 
  self:updateVipShopList()
end 


--更新card/point列表
function VIPActiveExpUp:updateVipShopList()

  local root = self.popLayer:getChildByName("scale_node") 
  local listView = root:getChildByName("ListView_1")
  listView:removeAllChildren() 
  local canBuy = true 

  if self.isActPop then --激活vip

  else --升级vip点数
    local playerData = g_PlayerMode.GetData() 
    local id = math.min(vipLevelMax, playerData.vip_level+1)    
    local nextExp = g_data.vip[id].vip_exp
    local curExp = playerData.vip_level >= vipLevelMax and nextExp or playerData.vip_exp 
    root:getChildByName("Text_c2"):setString(g_tr("vip_point")..curExp.."/"..nextExp)  
    canBuy = curExp < g_data.vip[vipLevelMax].vip_exp
  end 
  

  local shopItems = self.isActPop and {2029, 2030, 2031} or {2032, 2033, 2034, 2035}
  for k, shopId in pairs(shopItems) do 
    local shopItem = g_data.shop[shopId] 
    local dropdata = g_data.drop[shopItem.commodity_data].drop_data
    if #dropdata > 0 then 
      local configId = dropdata[1][2]
      if g_data.item[configId] then 
        local itemMode = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, configId, 1)

        local widget = cc.CSLoader:createNode("vip_activation_main1.csb")
        local scale_node = widget:getChildByName("scale_node")
        scale_node:getChildByName("Image_4"):loadTexture(itemMode:getIconPath())
        scale_node:getChildByName("Text_1"):setString(itemMode:getName())
        scale_node:getChildByName("Text_2"):setString(itemMode:getDesc())

        local nodeUse = scale_node:getChildByName("Panel_1")
        local nodeBuy = scale_node:getChildByName("Panel_2")
        local myCount = g_BagMode.findItemNumberById(configId) 
        if myCount > 0 then 
          nodeUse:setVisible(true) 
          nodeBuy:setVisible(false) 
          local btnUse = nodeUse:getChildByName("Button_1")
          btnUse:setTag(configId)
          self:regBtnCallback(btnUse, handler(self, self.onUseItem))
          nodeUse:getChildByName("Text_3"):setString(g_tr("bagUse"))
          nodeUse:getChildByName("Text_5"):setString(g_tr("vip_own_num"))
          nodeUse:getChildByName("Text_6"):setString(""..myCount)
        else 
          nodeUse:setVisible(false) 
          nodeBuy:setVisible(true) 
          nodeBuy:getChildByName("Text_4"):setString(g_tr("shopBuyAndUse")) 

          local shopItemData = g_playerShop.GetShopItemDataByShopId(shopId)
          local price = shopItemData :getPrice()
          local maxPrice = shopItemData :getMaxPrice()
          local costType = shopItemData :getCostType()

          local oldPrice = nodeBuy:getChildByName("Panel_3")
          oldPrice:setVisible(maxPrice > price)
          if oldPrice:isVisible() then 
            oldPrice:getChildByName("Text_5"):setString(g_tr("marketOriginalPrice", {price = maxPrice}))
          end 
          if costType > 0 then 
            nodeBuy:getChildByName("Image_1"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
          end 
          nodeBuy:getChildByName("Text_4_0"):setString(""..price)

          local btnBuy = nodeBuy:getChildByName("Button_2")
          btnBuy:setTag(shopId)
          self:regBtnCallback(btnBuy, handler(self, self.onBuyAndUseItem)) 
          btnBuy:setEnabled(canBuy)    
        end 

        listView:pushBackCustomItem(widget)
      end 
    end 
  end 
end 


--使用
function VIPActiveExpUp:useItemById(itemId)

  local function useCallback()
    print("useCallback")
    if self.isActPop then 
      g_airBox.show(g_tr_original("vip_active_success"))
    elseif g_data.item[itemId] then  
      local itemMode = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, itemId, 1)
      g_airBox.show(itemMode:getDesc())
    end 

    self:updateVipShopList()
    self.isPopDurty = true 
  end 
  local BagMode = require("game.uilayer.bag.BagMode")
  BagMode:itemUse(itemId, 1, useCallback)  
end 

function VIPActiveExpUp:onUseItem(sender)
  local id = sender:getTag()
  print("onUseItem:", id)

  g_msgBox.show(g_tr("vip_use_tips"), g_tr("titleTip"), 2, 
                function(event) 
                  if event == 0 then  
                    self:useItemById(id)
                  end 
                end, 1)
end 

--购买并使用
function VIPActiveExpUp:onBuyAndUseItem(sender)
  local shopId = sender:getTag()
  print("onBuyAndUseItem:", shopId)

  local function buyToUse(shopId)
    local function onResult(result, msgData)
      if result == true then
        local shopItem = g_data.shop[shopId] 
        local dropdata = g_data.drop[shopItem.commodity_data].drop_data
        local configId = dropdata[1][2] 
        self:useItemById(configId) 
      end
    end
    g_sgHttp.postData("Player/shopBuy",{shopId = shopId, itemNum = 1},onResult)    
  end 

  g_msgBox.show(g_tr("vip_buy_use_tips"), g_tr("titleTip"), 2, 
    function(event) 
      if event == 0 then  
        buyToUse(shopId)
      end 
     end, 1)
end 

return VIPActiveExpUp 
