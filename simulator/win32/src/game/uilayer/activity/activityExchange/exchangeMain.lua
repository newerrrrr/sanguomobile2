local exchangeMain = class("exchangeMain", require("game.uilayer.base.BaseLayer"))
local exchangeMode = require("game.uilayer.activity.activityExchange.exchangeMode"):instance()


function exchangeMain:ctor()
    exchangeMain.super.ctor(self)
end

function exchangeMain:onEnter()
    self.netData = exchangeMode:getExchangeData()
    if self.netData then
        self.endTime = self.netData.end_time
        --dump(self.netData.activity_para.reward)
        self:_InitUI()
        self:_OverTime()
        self:schedule(handler(self,self._OverTime),1)
    else
        self:close()
    end
end

function exchangeMain:_InitUI()
    self.layer = cc.CSLoader:createNode("activity4_mian3.csb")
    self:addChild(self.layer)
    self.layer:getChildByName("Text_8"):setString(g_tr("exchange_end"))
    self.layer:getChildByName("Text_n1"):setString(g_tr("exchange_title1"))
    self.layer:getChildByName("Text_n2"):setString(g_tr("exchange_title2"))

    self.list = self.layer:getChildByName("ListView_1")
    self.list:setScrollBarEnabled(false)
    self:_LoadList()
end

function exchangeMain:_LoadList()
    if self.netData.activity_para == nil then return end
    if self.netData.activity_para.reward == nil then return end
    local itemList = {}
    local reward = self.netData.activity_para.reward
    local iconMode = cc.CSLoader:createNode("activity4_mian3_list1.csb")

    --消耗道具propId
    --道具类型propType
    --消耗数量lessNum
    local function updateItemList(propId,propType,lessNum)
        for index, root in ipairs(itemList) do
            local sender = root.exchangeBtn
            for itemId, var in pairs(sender.nodes) do
                if tonumber(itemId) == tonumber(propId) and tonumber(var.type) == tonumber(propType) then
                    var.num = var.num - lessNum
                    var.icon:setCount(var.num .."/".. var.needNum)
                    if var.num < var.needNum then
                        var.icon:setCountColor( cc.c3b(230,30,30) )
                    else
                        var.icon:setCountColor( cc.c3b(30,230,30) )
                    end
                end
            end
        end
    end
    
    for _, data in pairs(reward) do
        local item = iconMode:clone()
        local root = item:getChildByName("Panel_4")
        local list = root:getChildByName("ListView_1")
        list:setScrollBarEnabled(false)
        list:setItemsMargin(8)
        table.insert(itemList,root)

        local plusImg = root:getChildByName("Image_jh")
        local changeImg = root:getChildByName("Image_j1")

        local timesTx = root:getChildByName("Text_lj4")
        timesTx:enableOutline(cc.c4b(0, 0, 0,255),1)
        local exchangId = data.exchangId
        local consumeNodes = {}
        local dLimit = tonumber(data.limit)
        local dHas = tonumber(data.has)
        local size
        for index, var in ipairs(data.consume) do
            local itemType = var[1]
            local itemId = var[2]
            local itemNeedNum = var[3]
            local itemNum = var[4]
            local icon = require("game.uilayer.common.DropItemView").new(itemType,itemId,0)
            g_itemTips.tip(icon,itemType,itemId)
            icon:setScale(0.9)
            icon:setCount(itemNum .."/".. itemNeedNum)
            if itemNum < itemNeedNum then
                icon:setCountColor( cc.c3b(230,30,30) )
            else
                icon:setCountColor( cc.c3b(30,230,30) )
            end
            list:pushBackCustomItem( icon )
            consumeNodes[tostring(itemId)] = { needNum = itemNeedNum,icon = icon,num = itemNum,type = itemType }
        end

        local change = changeImg:clone()
        change:getChildByName("Image"):getChildByName("Text_6_0"):enableOutline(cc.c4b(0, 0, 0,255),1)
        change:getChildByName("Image"):getChildByName("Text_6_0"):setString(g_tr("exchange_can_change"))

        --change:setContentSize( cc.size(size.width,size.height) )
        list:pushBackCustomItem( change )
        
        local drop = data.drop
        for key, var in ipairs(drop) do
            local itemType = var[1]
            local itemId = var[2]
            local itemNum = var[3]
            local icon = require("game.uilayer.common.DropItemView").new(itemType,itemId,itemNum)
            g_itemTips.tip(icon,itemType,itemId)
            icon:setScale(0.9)
            list:pushBackCustomItem( icon )
        end

        timesTx:setString( ( dLimit - dHas ) .. "/" ..dLimit )

        local exchangeBtn = root:getChildByName("Button_1")
        root.exchangeBtn = exchangeBtn
        exchangeBtn.nodes = consumeNodes
        exchangeBtn.exchangId = exchangId
        exchangeBtn.has = dHas
        exchangeBtn.limit = dLimit

        root:getChildByName("Text_lj5"):setString( g_tr("exchange_times") )
        if dLimit <= 0 then
            root:getChildByName("Text_lj5"):setVisible(false)
            timesTx:setVisible(false)
        else
            if dHas >= dLimit then
                exchangeBtn:setEnabled( false )
                timesTx:setTextColor(cc.c3b(230,30,30))
            end
        end
        
        exchangeBtn:getChildByName("Text_6"):setString(g_tr("exchange_exchange"))
        exchangeBtn:getChildByName("Text_6"):enableOutline(cc.c4b(0, 0, 0,255),1)

        if exchangeBtn.addTouch == nil then
            exchangeBtn:addTouchEventListener( function (sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    local limit = sender.limit
                    if limit > 0 then
                        print("limit,sender.has",limit,sender.has)
                        if sender.has >= limit then
                            --print("没有次数")
                            g_airBox.show(g_tr("exchange_no_times"))
                            return
                        end
                    end
                    
                    for itemId, var in pairs( sender.nodes) do
                        if var.num < var.needNum then
                            --print("缺少道具")
                            g_airBox.show(g_tr("exchange_no_item"))
                            return
                        end
                    end

                    if exchangeMode:exchange( sender.exchangId ) then
                        g_airBox.show(g_tr("exchange_ok"))
                        sender.has = sender.has + 1
                        timesTx:setString( ( limit - sender.has ) .. "/" ..limit )
                        if sender.has >= limit then
                            sender:setEnabled(false)
                            timesTx:setTextColor(cc.c3b(230,30,30))
                        end 
                        --更新道具，检查是否有相同兑换道具同样更新
                        for itemId, var in pairs(sender.nodes) do
                            updateItemList(itemId,var.type,var.needNum)
                        end

                       
                    end
                    exchangeBtn.addTouch = true
                end
            end )
        end
        
        plusImg:setVisible(false)
        changeImg:setVisible(false)
        self.list:pushBackCustomItem( item )
        
    end

end

function exchangeMain:_OverTime()
    local overTime = self.endTime - g_clock.getCurServerTime()
    local timeTx = self.layer:getChildByName("Text_8_0")
    if overTime >= 0 then
        timeTx:setString(g_gameTools.convertSecondToString(overTime))
    else
        timeTx:setString(g_tr("exchange_over"))
    end
end

return exchangeMain