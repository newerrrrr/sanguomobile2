local CityShop = class("CityShop",require("game.uilayer.base.BaseLayer"))
local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode"):GetInstance()

function CityShop:ctor(cityId)
    CityShop.super.ctor(self)
    self.cityId = cityId
    self.mCampId = g_PlayerMode.GetData().camp_id
    self.belongCampID = CityBattleMode:GetCityCamp(self.cityId)
    self.nData = nil
end

function CityShop:onEnter()
    local function onRecv(result,msgData)
        g_busyTip.hide_1()
        if true == result then
            --self.leftTime = self:_GetFinishTime()
            --msgData.left_time
            self.nData = msgData.shop_info

            --dump(self.nData)
            if self.nData then
                self.shopData = CityBattleMode:GetShopConfig(self.cityId)
                self:_InitUI()
            else
                self:close()
            end
        else
            self:close()
        end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("guild_mission/getCityShop", { cityId = self.cityId }, onRecv, true)
    
end

function CityShop:_InitUI()
    self.layer = self:loadUI("TreasureChest_panel.csb")
    self.root = self.layer:getChildByName("scale_node")
    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:addClickEventListener( function ( sender )
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
    end)


    self.root:getChildByName("Panel_renw"):getChildByName("Image_renw"):loadTexture( g_resManager.getResPath(1031091) )
    local config = g_data.country_city_map[self.cityId]
    self.root:getChildByName("Text_1"):setString(g_tr(config.ctiy_name) .. g_tr("city_battle_shop_str"))

    self.page = self.root:getChildByName("PageView_1")
    self:_LoadPage()
    self.page:addEventListener( handler(self,self._PageViewEvent) )
    
    self.previousBtn = self.root:getChildByName("Image_j1")
    self.previousBtn:setVisible(false)
    self.previousBtn:addClickEventListener(handler(self,self._TouchPrevious) )

    self.nextBtn = self.root:getChildByName("Image_j2")
    self.nextBtn:addClickEventListener(handler(self,self._TouchNext))
    self:_GetFinishTime()
    self:_UpdateTime()
    self:_UpdateRes()
    self:schedule(handler(self,self._UpdateTime),1)

end

function CityShop:_LoadPage()
    local pageMode = cc.CSLoader:createNode("TreasureChest_panel_list1.csb")
    local pageCol = 3
    local pageCount = math.ceil( #self.shopData / pageCol )
    local index = 1
    for i = 1, pageCount do
        local layout = ccui.Layout:create()
        local page = pageMode:clone()
        for j = 1, pageCol do
            local data = self.shopData[index]
            local panel = page:getChildByName( string.format("Panel_%d",j) )
            if data then
                local dropid = data.commodity_data
                local drop = g_data.drop[tonumber(dropid)].drop_data[1]
                local t = drop[1]
                local id = drop[2]
                local num = drop[3]
                local icon = require("game.uilayer.common.DropItemView").new(t,id,num)
                icon:enableTip()
                local posImg = panel:getChildByName("Image_3")
                icon:setPosition( cc.p( posImg:getPosition() ) )
                panel:addChild(icon)
                local nameTx = panel:getChildByName("Text_gm1")
                nameTx:setString(icon:getName())
                local cost = g_data.cost[ tonumber(data.cost_id) ]
                local count,path = g_gameTools.getPlayerCurrencyCount( cost.cost_type )
                local costImg = panel:getChildByName("Image_yuan2")
                costImg:setScale(1.25)    
                costImg:loadTexture(path)
                local costTx = panel:getChildByName("Text_y1")
                costTx:setString(tostring( cost.cost_num ))
                local buyBtn = panel:getChildByName("Button_1")
                buyBtn:getChildByName("Text_y1_0"):setString(g_tr("queue_buy"))
                buyBtn.shopId = tonumber( data.id )
                buyBtn.count = tonumber( self.nData[tostring(data.id)] )
                buyBtn.cost = { cost.cost_num , path } 
                buyBtn.upNum = function ()
                    local numTx = panel:getChildByName("Text_gm2")
                    local num = self.nData[tostring(data.id)]
                    if num == nil then
                        numTx:setVisible(false)
                        buyBtn:setVisible(false)
                    else
                        local count = tonumber( self.nData[tostring(data.id)])
                        buyBtn.count = count
                        numTx:setString( g_tr("leftNum") .. count )
                        if count <= 0 then
                            buyBtn:getChildByName("Text_y1_0"):setString(g_tr("city_battle_buy_over"))
                        end
                    end
                end
                buyBtn.upNum()
                buyBtn:addClickEventListener( handler( self,self._Buy ) )
                buyBtn:setEnabled( self.mCampId == self.belongCampID and buyBtn.count > 0  )
            else
                panel:setVisible(false)
            end
            index = index + 1
        end
        layout:setContentSize( page:getContentSize() )
        layout:addChild(page)
        self.page:addPage(layout)
    end

    self.ps = {}
    local ann = self.root:getChildByName("Panel_ann")
    local pMode = ann:getChildByName("P")
    if pageCount > 0 then
        ann:setContentSize( (pMode:getContentSize().width + 10) * pageCount , ann:getContentSize().height )
        for i = 1, pageCount do
            local p = pMode:clone()
            p:setPositionX( ( p:getContentSize().width + 10 ) * i  )
            pMode:getParent():addChild(p)
            p:getChildByName("Image"):setVisible( i == (self.page:getCurPageIndex() + 1) )
            table.insert(self.ps,p)
        end
    end
    pMode:setVisible(false)

end

function CityShop:_TouchPrevious(sender)
    self.page:scrollToPage(self.page:getCurPageIndex() - 1 )
end

function CityShop:_TouchNext(sender)
    self.page:scrollToPage(self.page:getCurPageIndex() + 1 )
end

function CityShop:_PageViewEvent(sender, eventType)
    if eventType == ccui.PageViewEventType.turning then
        self.previousBtn:setVisible(true)
        self.nextBtn:setVisible(true)
        if self.page:getCurPageIndex() <= 0 then
            self.previousBtn:setVisible(false)
        end
        if self.page:getCurPageIndex() >= (#self.page:getPages() - 1) then
            self.nextBtn:setVisible(false)
        end

        for index , p in ipairs(self.ps) do
            p:getChildByName("Image"):setVisible( index == (self.page:getCurPageIndex() + 1) )
        end
    end
end

function CityShop:_Buy(sender)
    
    local shopId = sender.shopId
    local shopConfig = g_data.shop[shopId]
    local dropConfig = g_data.drop[shopConfig.commodity_data].drop_data[1]
    local canBuyCount = sender.count
    local cost = sender.cost
    local callback =  function ( count )
        local buyCount = count
        if buyCount ~= nil and buyCount > 0 then
            local function onRecv(result,msgData)
                g_busyTip.hide_1()
                if true == result then
                    local data = msgData.shop_info
                    if data then
                        g_airBox.show(g_tr("buySuccess"))
                        self.nData[tostring(data.shop_id)] = tonumber(data.total)
                        self:_UpdateRes()
                        sender.upNum()
                    end
                end
            end
            g_busyTip.show_1()
            g_sgHttp.postData("guild_mission/cityShopBuy", { shopId = tonumber(sender.shopId) , itemNum = buyCount }, onRecv, true)
        end
    end

    local buyDialog = require("game.uilayer.cityBattle.CityShopBuy"):create( dropConfig,callback,canBuyCount,cost)
    g_sceneManager.addNodeForUI(buyDialog)

    --dump(itemConfig)


    --[[if self.mCampId ~= self.belongCampID then
        g_airBox.show(g_tr("city_battle_no_belong"))
        return 
    end
    
    local function onRecv(result,msgData)
        g_busyTip.hide_1()
        if true == result then
            local data = msgData.shop_info
            if data then
                g_airBox.show(g_tr("buySuccess"))
                self.nData[tostring(data.shop_id)] = tonumber(data.total)
                self:_UpdateRes()
                sender.upNum()
            end
        end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("guild_mission/cityShopBuy", { shopId = tonumber(sender.shopId) , itemNum = 1 }, onRecv, true)
    ]]
end


function CityShop:_UpdateTime()
    
    local prepareData = CityBattleMode:GetPrepareInfo()
    if prepareData == nil then
        return
    end

    --print("==============shop===============",prepareData.status)

    if prepareData.status == nil
    or prepareData.status == g_Consts.CityBattleStatus.SELECT_PLAYER
    or prepareData.status == g_Consts.CityBattleStatus.SELECT_PLAYER_FINISH 
    or prepareData.status == g_Consts.CityBattleStatus.DOING 
    or prepareData.status == g_Consts.CityBattleStatus.CLAC_REWARD then
        self.root:getChildByName("Text_gm1"):setString( g_tr("city_battle_nocan_buy") )
        return
    end


    local time = self.time - g_clock.getCurServerTime()
    if time <= 0 then
        time = 0
    end

    self.root:getChildByName("Text_gm1"):setString( g_tr("city_battle_city_buy") .. g_gameTools.convertSecondToString(time) )
end

function CityShop:_UpdateRes()
    local count,path = g_gameTools.getPlayerCurrencyCount( 23 )
    local resPanel = self.root:getChildByName("Panel_junling")
    resPanel:getChildByName("Image_3"):loadTexture(path)
    resPanel:getChildByName("Text_2"):setString(tostring(count))
end

function CityShop:_GetFinishTime()
    
    local sTime,eTime = CityBattleMode:GetSignOverTime()
    --下一次报名时间
    if eTime == nil then
        --加上结束时间
        local s = string.split(g_data.country_basic_setting[7].data,":")
        local e = string.split(g_data.country_basic_setting[9].data,":")
        local overTime = ( (tonumber(e[1]) * 3600 + tonumber(e[2]) * 60 + tonumber(e[3])) - ( tonumber(s[1]) * 3600 + tonumber(s[2]) * 60 + tonumber(s[3])) )
        self.time = sTime + overTime
    end

    if sTime == nil then
        self.time = eTime
    end

end

return CityShop