local cityGainLayer = class("cityGainLayer",require("game.uilayer.base.BaseLayer"))

local item_buffer_data = nil
local getSeverBuffInfo = function(buffTempInfo)
    local serverBuffInfo = nil
    if buffTempInfo.buff_id[1] == 9 then --免战保护要从player信息中读取
        serverBuffInfo = {}
        serverBuffInfo.expire_time = g_PlayerMode.GetData().avoid_battle_time
        serverBuffInfo.begin_time = g_clock.getCurServerTime()
        serverBuffInfo.num = 0
    else
        for key, var in pairs(item_buffer_data) do
            for _, buffId in ipairs(buffTempInfo.buff_id) do
                if tonumber(key) == buffId then
                   serverBuffInfo = var
                   break
                end
            end
            if serverBuffInfo then
                break
            end
        end
    end
    return serverBuffInfo
end

local reqItemBuff = function()
    local function callback( result , data )
        if true == result then
            item_buffer_data = data.PlayerItemBuff
        end
    end

    g_sgHttp.postData("player/getItemBuff", tb1, callback)
    
end

function cityGainLayer:ctor(data,serverBuffInfo,updateHandler)

    self._updateHandler = updateHandler
    
    self._layout = self:loadUI("CityGain_main.csb")
    self._root = self._layout:getChildByName("scale_node")
    
    local close_btn = self._root:getChildByName("Button_x")
    close_btn:addClickEventListener(function()
        self:removeFromParent()
    end)
    
    self._listView = self._root:getChildByName("ListView_1")

    self:updateInfo(data,serverBuffInfo)
end

function cityGainLayer:updateInfo(data,serverBuffInfo)
    self._data = data
    self._serverBuffInfo = serverBuffInfo
    self:updateView()
end

function cityGainLayer:updateView()
    
    local serverBuffInfo = self._serverBuffInfo
    local data = self._data
    
    self:stopAllActions()
    
    self._root:getChildByName("Panel_1"):setVisible(false)
    self._root:getChildByName("Panel_2"):setVisible(false)
    self._root:getChildByName("Panel_3"):setVisible(false)
    
    self._root:getChildByName("Text_c2"):setString(g_tr(data.name))
    
    self:buildShopList()

    local buffIsWorking = false
    if serverBuffInfo then
        local currentTime = g_clock.getCurServerTime()
        local secondsLeft = serverBuffInfo.expire_time - currentTime
        buffIsWorking = secondsLeft > 0
        
        self._root:getChildByName("Panel_1"):getChildByName("LoadingBar_1"):setVisible(buffIsWorking and data.buff_id[1] ~= 9)
        if buffIsWorking then
            self._root:getChildByName("Panel_1"):setVisible(true)
            self._root:getChildByName("Panel_1"):getChildByName("Text_1"):setString(g_tr("leftTime"))
            self._root:getChildByName("Panel_1"):getChildByName("Text_3"):setString(g_tr(data.dec))
            
            local percent = (currentTime - serverBuffInfo.begin_time)/(serverBuffInfo.expire_time - serverBuffInfo.begin_time)*100
            self._root:getChildByName("Panel_1"):getChildByName("LoadingBar_1"):setPercent(100 - percent)
            self._root:getChildByName("Panel_1"):getChildByName("Text_1_0"):setString(g_gameTools.convertSecondToString(secondsLeft))
            local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                  local currentTime = g_clock.getCurServerTime()
                  local secondsLeft = serverBuffInfo.expire_time - currentTime
                  if secondsLeft < 0 then
                      secondsLeft = 0
                  else
                      local percent = (currentTime - serverBuffInfo.begin_time)/(serverBuffInfo.expire_time - serverBuffInfo.begin_time)*100
                      self._root:getChildByName("Panel_1"):getChildByName("LoadingBar_1"):setPercent(100 - percent)
                      self._root:getChildByName("Panel_1"):getChildByName("Text_1_0"):setString(g_gameTools.convertSecondToString(secondsLeft))
                  end
            end))
            local action = cc.RepeatForever:create(seq)
            self:runAction(action)
        end
    end
    
    if not buffIsWorking then
        self._root:getChildByName("Panel_3"):setVisible(true)
        self._root:getChildByName("Panel_3"):getChildByName("Text_1"):setString(g_tr(data.dec))
    end

end

function cityGainLayer:buildShopList()
    self._listView:removeAllChildren()
    
    local serverBuffInfo = self._serverBuffInfo
    local data = self._data
    
    local shopList = data.link
    if #shopList > 0 then
        local quickBuyItem = cc.CSLoader:createNode("CityGain_list.csb")
        local layout = nil
        for key, shopId in ipairs(shopList) do
        
            if key % 2 ~= 0 then
                layout = ccui.Layout:create()
                layout:setContentSize( cc.size(self._listView:getContentSize().width,quickBuyItem:getContentSize().height ))
                self._listView:pushBackCustomItem(layout)
            end
            
            local item = quickBuyItem:clone()
            
            --check start
            local dropId = g_data.shop[shopId].commodity_data
            local dropGroups = g_gameTools.getDropGroupByDropIdArray({dropId})
            if #dropGroups > 1 then
                g_airBox.show("商品drop里配置了多个符合条件的掉落物品，界面上只能显示一个！！")
            end
            local dropGroup = dropGroups[1]
            local type = dropGroup[1]
            local configId = dropGroup[2]
            local count = dropGroup[3]
            
            assert(type == g_Consts.DropType.Resource or type == g_Consts.DropType.Props)
            --check end
            
            local shopItemData = g_playerShop.GetShopItemDataByShopId(shopId)
            assert(shopItemData) 
            
            local costNum = shopItemData:getPrice()
            local costType = shopItemData:getCostType()
            
            local bagData = g_BagMode.FindItemByID(configId)
            local dropItem = nil
            item:getChildByName("Button_2"):getChildByName("Text_5"):setString(g_tr("bagUse"))
            item:getChildByName("Button_2_0"):getChildByName("Text_6"):setString(g_tr("shopBuyAndUse"))
            
            item:getChildByName("Text_9_0"):setVisible(false)
            item:getChildByName("Line"):setVisible(false)
            
            if bagData and bagData.num > 0 then
                dropItem = require("game.uilayer.common.DropItemView").new(type, configId, bagData.num)
                item:getChildByName("Button_2_0"):setVisible(false)
                item:getChildByName("Button_2"):setVisible(true)
            else
                dropItem = require("game.uilayer.common.DropItemView").new(type, configId, 0)
                dropItem:setCountEnabled(false)
                item:getChildByName("Button_2_0"):setVisible(true)
                item:getChildByName("Button_2"):setVisible(false)
                
                if shopItemData:getPrice() < shopItemData:getMaxPrice() then
                  item:getChildByName("Text_9_0"):setVisible(true)
                  item:getChildByName("Text_9_0"):setString(g_tr("marketOriginalPrice",{price = string.formatnumberthousands(shopItemData:getMaxPrice())}))
                  item:getChildByName("Line"):setVisible(true)
                end
            end
            
            item:getChildByName("Image_3"):addChild(dropItem)
            local size = item:getChildByName("Image_3"):getContentSize()
            dropItem:setPosition(cc.p(size.width/2,size.height/2))
            item:getChildByName("Text_n1"):setString(dropItem:getName())
            item:getChildByName("Text_n1_0"):setString(dropItem:getDesc())
            
--            local costGroup = g_gameTools.getCostsByCostId(g_data.shop[shopId].cost_id,1)
--            local costNum = costGroup[1].cost_num
--            local costType = costGroup[1].cost_type

            item:getChildByName("Button_2_0"):getChildByName("Text_9"):setString(string.formatnumberthousands(costNum))
            item:getChildByName("Button_2_0"):getChildByName("Image_9"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
            
            layout:addChild(item)
            if key % 2 == 0 then
                item:setPositionX(self._listView:getContentSize().width/2)
            end
            
            --use
            item:getChildByName("Button_2"):addClickEventListener(function()
--                
--                local itemInfo = g_data.item[itemId]
--                if itemInfo then
--                       
--                   if itemInfo.item_original_id == 218 then
--                   
--                   end
--                end
            
                local itemView = require("game.uilayer.bag.BabItemInfoView").new(bagData, function(itemId, num)
                    local mode = require("game.uilayer.bag.BagMode").new()
                    mode:itemUse(itemId, num, function(data)
                        reqItemBuff()
                        local serverBuffInfo = getSeverBuffInfo(self._data)
                        self:updateInfo(self._data,serverBuffInfo)
                        --success
                        if self._updateHandler then
                            self._updateHandler(item_buffer_data)
                        end
                    end)
                end)
                g_sceneManager.addNodeForUI(itemView)
            end)
            
            --buy and use
            item:getChildByName("Button_2_0"):addClickEventListener(function()
                    
                    local itemInfo = g_data.item[configId]
                    if g_PlayerMode.hasNewPlayerAvoid() then --新手保护期间，不能使用战胜保护道具
                        if itemInfo then
                           if itemInfo.item_original_id == 218 then
                               g_airBox.show(g_tr("battleAvoidUseCondition"))
                               return
                           end
                        end
                    end
                    
                    local tipBuyHandler = function()
                        g_msgBox.showConsume(costNum, g_tr("tipShopBuyAndUse",{item_name = dropItem:getOriginalName()}), title, g_tr("shopBuyAndUse"), function()
                              local function onResult(result, msgData)
                              if result == true then
                                  --[[g_airBox.show(g_tr("buySuccess"))
                                    local mode = require("game.uilayer.bag.BagMode").new()
                                    mode:itemUse(configId, 1, function(data)
                                        reqItemBuff()
                                        local serverBuffInfo = getSeverBuffInfo(self._data)
                                        self:updateInfo(self._data,serverBuffInfo)
                                        --success
                                        if self._updateHandler then
                                            self._updateHandler(item_buffer_data)
                                        end
                                    end)]]
                                    
                                    reqItemBuff()
                                    local serverBuffInfo = getSeverBuffInfo(self._data)
                                    self:updateInfo(self._data,serverBuffInfo)
                                    --success
                                    if self._updateHandler then
                                        self._updateHandler(item_buffer_data)
                                    end
                              end
                            end
                            g_sgHttp.postData("Player/shopBuy",{shopId = shopId,itemNum = 1,use = 1},onResult)
                        end)
                    end
                    
                    if itemInfo.item_original_id == 218 then 
                        if g_PlayerMode.hasAvoid() then
                            g_msgBox.show(g_tr("protectedUsed"), nil, nil, 
                            function(event)
                                if event == 0 then
                                    tipBuyHandler()
                                end
                            end, 1)
                            return   
                        else
                            tipBuyHandler()
                        end
                    else
                        tipBuyHandler()
                    end
                    
            end)
        end
    end
end

return cityGainLayer