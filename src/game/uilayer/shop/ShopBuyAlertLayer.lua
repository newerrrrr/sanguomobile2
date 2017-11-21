local ShopBuyAlertLayer = class("ShopBuyAlertLayer",function()
    return cc.Layer:create()
end)

local AllianceShop = require("game.gamedata.AllianceShop")
function ShopBuyAlertLayer:ctor(info)
	local uiLayer =  g_gameTools.LoadCocosUI("alliance_store_check_popup.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    
    local titleStr = g_tr("shopItemDetail")
    if info:getShopType() == g_Consts.ShopType.PUB then
        titleStr = g_tr("generalDuijiuTitle")
    end
    baseNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(titleStr)
    
    baseNode:getChildByName("goods_cannot_buy"):setString(g_tr("shopItemGeneralItemFull"))
    baseNode:getChildByName("goods_cannot_buy"):setVisible(false)
    
    
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    local showBar = true

    if info:getShopType() == g_Consts.ShopType.MARKET then
      showBar = false
    else
      if info:getMaxPrice() and info:getPrice() < info:getMaxPrice() then
        showBar = false
      end
    end
    baseNode:getChildByName("Panel_1"):setVisible(showBar)

    local pic = baseNode:getChildByName("goods_pic")
    local size = pic:getContentSize()
    local icon = require("game.uilayer.common.DropItemView"):create(info:getType(),info:getItemConfigId(),info:getCount())
    pic:addChild(icon)
    icon:setPositionX(size.width/2)
    icon:setPositionY(size.height/2)
    
    local currentCurrencyCount = g_gameTools.getPlayerCurrencyCount(info:getCostType())
    print("currentCurrencyCount:",currentCurrencyCount)
    
    local maxCount = math.floor(currentCurrencyCount/info:getPrice())
    
    
    if info:getShopType() ~= g_Consts.ShopType.ALLIANCE 
    and info:getType() == g_Consts.DropType.Props
    and g_data.item[info:getItemConfigId()].item_type == 4 --武将信物
    then 
        local generalInfo = g_PlayerPubMode.getGeneralInfoByPieceItemId(info:getItemConfigId())
--        
--        g_itemTips.tip(icon,g_Consts.DropType.General,generalInfo.id)
        
        icon:enableTip()

        local ownGenerals = g_GeneralMode.GetData()
        local keyOwnGenerals = {}
        
        local haveResuited = false
        for key, generalServerInfo in pairs(ownGenerals) do
            if generalServerInfo.general_id == generalInfo.general_original_id then
                haveResuited = true
                break
            end --服务器发送的generalServerInfo.general_id 为root id
        end
        
        local isFull = false
        if not haveResuited then
            local haveNum = 0
            local bagData = g_BagMode.FindItemByID(generalInfo.piece_item_id)
            if bagData and bagData.num then
               haveNum = bagData.num
            end
            
            if haveNum >= generalInfo.piece_required then
                isFull = true
            else
                maxCount = generalInfo.piece_required - haveNum
            end
            
        end
        
        --隐藏购买的按钮及相关信息
        if haveResuited or isFull then
            baseNode:getChildByName("goods_cannot_buy"):setVisible(true)
            baseNode:getChildByName("Panel_1"):setVisible(false)
            baseNode:getChildByName("btn_buy"):setVisible(false)
            baseNode:getChildByName("Image_4"):setVisible(false)
            baseNode:getChildByName("Text_num"):setVisible(false)
        end
        
    end
    
    if info:getShopType() == g_Consts.ShopType.ALLIANCE_PLAYER then
       maxCount = math.min(maxCount,info:getCount())
    end
    if maxCount < 1 then
       maxCount = 1
    end
    
    
    maxCount = math.min(maxCount,99)
      
    local currentCount = 1
    if currentCurrencyCount < info:getPrice() then
      currentCount = 1
    end
    
    local updateTotalPrice = function()
        self._editBox:setString(currentCount.."")
        
        local price = string.formatnumberthousands(info:getPrice()*currentCount)
        baseNode:getChildByName("Text_num")
        :setString(price)
        
        self._slider:setPercent(currentCount)
    end
    
    
    local editboxEventHandler = function(eventType)
        if eventType == "customEnd" then
            if self._editBox:getString() == "" then
                currentCount = 1
            elseif tonumber(self._editBox:getString()) == nil then
                currentCount = 1
            else
                currentCount =  tonumber(self._editBox:getString())
            end
            
            if currentCount <= 0 then
                currentCount = 1
            elseif currentCount > maxCount then
                currentCount = maxCount
            end
            self._editBox:setString(currentCount.."")
            self._slider:setPercent(currentCount)
            updateTotalPrice()
        end
    end
    
    self._editBox = g_gameTools.convertTextFieldToEditBox(baseNode:getChildByName("Panel_1"):getChildByName("TextField_1"))
    self._editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self._editBox:registerScriptEditBoxHandler(editboxEventHandler)
    
    self._editBox:setString(currentCount.."")
    
    local price = string.formatnumberthousands(info:getPrice())
    baseNode:getChildByName("Text_num")
    :setString(price)
    
    baseNode:getChildByName("price")
    :setString(price)
    
    baseNode:getChildByName("Image_4"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + info:getCostType()))
    
--    baseNode:getChildByName("bg_goods_name"):getChildByName("text")
--    :setString(icon:getName())

    baseNode:getChildByName("Text_6"):setString(icon:getName())
    
    baseNode:getChildByName("goods_info")
    :setString(icon:getDesc())
    
    if info:getType() == g_Consts.DropType.MasterEquipment then --主公宝物
        
        --icon:enableTip()
    
        local descStr = g_tr("equipmentTypeMaster").."\n"--icon:getDesc().."\n"
        local masterEquipData = g_data.equip_master[info:getItemConfigId()]
        local cnt = #masterEquipData.equip_skill_id 
        for i = 1, cnt do 
          local skill = g_data.equip_skill[masterEquipData.equip_skill_id[i]]
          if skill then 
              local buffId = skill.skill_buff_id[1]
              local buff = g_data.buff[buffId]
              if buff then 
                  local strNum = skill.min.."-"..skill.max
                  local unknowValue = "?"
                  if buff.buff_type == 1 then --万分比
                    strNum = (skill.min/100).."%-"..(skill.max/100).."%"
                    unknowValue = "?%%"
                  end 
                  local desc = g_tr(skill.skill_description,{num = unknowValue}).." ("..strNum..")"
                  descStr = descStr..desc.."\n"
              end 
              
          end
        end 
        baseNode:getChildByName("goods_info"):setString(descStr)
    end
    
    baseNode:getChildByName("Text_shuzi")
    :setString("")

    baseNode:getChildByName("ico_gold"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + info:getCostType()))
  
    --slider
    local slider = baseNode:getChildByName("Panel_1"):getChildByName("Slider_1")
    slider:setMaxPercent(maxCount)
    slider:setPercent(currentCount)
    self._slider = slider
    

    
    local function percentChangedEvent(sender,eventType)
        --print(eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            
            currentCount = slider:getPercent()
            if currentCount < 1 then
                currentCount = 1
            end
            updateTotalPrice()
            
            
        elseif eventType == ccui.SliderEventType.slideBallUp then
            
        elseif eventType == ccui.SliderEventType.slideBallDown then
           
        elseif eventType == ccui.SliderEventType.slideBallCancel then
            
        end
    end
    slider:addEventListener(percentChangedEvent)
    
    --reset ui text
    baseNode:getChildByName("btn_buy"):getChildByName("Text_3")
    :setString(g_tr("makeSureBuy"))
    
    local reduceBtn = baseNode:getChildByName("Panel_1"):getChildByName("btn_reduce")
    reduceBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            currentCount = currentCount - 1
            if currentCount < 1 then
                currentCount = 1
            end
            
            updateTotalPrice()
        end
    end)
    
    local addBtn = baseNode:getChildByName("Panel_1"):getChildByName("btn_add")
    addBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            currentCount = currentCount + 1
            if currentCount > maxCount then
                currentCount = maxCount
            end
            updateTotalPrice()
        end
    end)
    
    local buyBtn = baseNode:getChildByName("btn_buy")
    buyBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("buyhandler")
            local currentCurrencyCount = g_gameTools.getPlayerCurrencyCount(info:getCostType())
            if currentCount <= 0 or currentCurrencyCount < info:getPrice() * currentCount then
               --g_airBox.show(g_tr("currencyLimit"))
               g_gameTools.tipCostLimit(info:getCostType())
               return
            end
            if info:getShopType() == g_Consts.ShopType.ALLIANCE then
                local function onResult(result, msgData)
                  if result == true then
                    g_airBox.show(g_tr("buySuccess"))
                    self:getDelegate():updateView()
                  end
                end
                g_sgHttp.postData("Guild/shopStock",{itemId = info:getItemConfigId(),itemNum = currentCount},onResult)
            elseif info:getShopType() == g_Consts.ShopType.ALLIANCE_PLAYER then
                local function onResult(result, msgData)
                  if result == true then
                      g_airBox.show(g_tr("buySuccess"))
                      local itemData = AllianceShop.getShopItemDataByItemId(info:getItemConfigId())
                      if itemData == nil then
                          AllianceShop.getShopLayerView():updateView()
                      else
                          self:getDelegate():setData(itemData)
                      end
                  end
                end
                g_sgHttp.postData("Guild/shopBuy",{itemId = info:getItemConfigId(),itemNum = currentCount},onResult)
            elseif info:getShopType() == g_Consts.ShopType.NORMAL then
                print("normal buy")
                local function onResult(result, msgData)
                  if result == true then
                      g_airBox.show(g_tr("buySuccess"))
                      info:updatePirce()
                      self:getDelegate():updateView()
                  end
                end
                g_sgHttp.postData("Player/shopBuy",{shopId = info:getId(),itemNum = currentCount},onResult)
            elseif info:getShopType() == g_Consts.ShopType.MARKET then
                local function onResult(result, msgData)
                  if result == true then
                      g_airBox.show(g_tr("buySuccess"))
                  end
                end
                g_sgHttp.postData("market/buy",{id = info:getId()},onResult)
            elseif info:getShopType() == g_Consts.ShopType.PUB then
                local function onResult(result, msgData)
                  if result == true then
                      g_airBox.show(g_tr("buySuccess"))
                      self:getDelegate():onAfterBuyGeneralPiece()
                  end
                end
                local generalInfo = g_PlayerPubMode.getGeneralInfoByPieceItemId(info:getItemConfigId())
                local generalId = generalInfo.general_original_id
                g_sgHttp.postData("Pub/buyFragment",{generalId = generalId,num = currentCount},onResult)
            end
            
            self:removeFromParent()
        end
    end)
    
end

------
--  Getter & Setter for
--      ShopLayer._Delegate
-----
function ShopBuyAlertLayer:setDelegate(Delegate)
		self._Delegate = Delegate
end

function ShopBuyAlertLayer:getDelegate()
		return self._Delegate
end

return ShopBuyAlertLayer