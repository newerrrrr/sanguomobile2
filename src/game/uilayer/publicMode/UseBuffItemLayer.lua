--region UseBuffItemLayer.lua  --城池增益，与行军加速界面
--Author : liuyi
--Date   : 2016/3/3
--此文件由[BabeLua]插件自动生成

local UseBuffItemLayer = class("UseBuffItemLayer", require("game.uilayer.base.BaseLayer"))
local changeMapScene = require("game.maplayer.changeMapScene")
local UseActions = nil

function UseBuffItemLayer:createLayer( showType,data)
    if data then
        UseActions = require("game.uilayer.publicMode.UseActions").new()
        g_sceneManager.addNodeForUI( UseBuffItemLayer:create(showType,data) )
    end
end

function UseBuffItemLayer:ctor(showType,data)
    UseBuffItemLayer.super.ctor(self)
    self.showType = showType or 1
    if self.showType == 1 then
        self.rundata = data
    end
    self.mapStatus = changeMapScene.getCurrentMapStatus()
    self:initUI()
end

function UseBuffItemLayer:initUI()
    self.layer = self:loadUI("CityGain_main.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("Button_x")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
        return
	end)

    self.panel = self.root:getChildByName("Panel_2")
    self.list = self.root:getChildByName("ListView_1")

    if self.showType == 1 then
        self.root:getChildByName("Panel_1"):setVisible(false)
        self.root:getChildByName("Panel_3"):setVisible(false)
        
        self:runingUI()
        --dump(self.rundata)
        --dump(self.rundata.accelerate_info.log)
        if self.rundata then
            --测试代码注释
            self.panel:scheduleUpdateWithPriorityLua( handler( self,self.updateRunLength), 0)
        end
        --self:updateRunLength()
    end

    if self.mapStatus == changeMapScene.m_MapEnum.guildwar or self.mapStatus == changeMapScene.m_MapEnum.citybattle then
        local zsPanel = self.panel:getChildByName("Panel_12")
        zsPanel:setVisible(true)
        self.zsTx = zsPanel:getChildByName("Text_30")
        self.zsTx:setString(tostring( g_PlayerMode.getDiamonds() ))
    end
    --[[local function update()
        print("111111111111")
    end]]
end


function UseBuffItemLayer:runingUI()
    self.root:getChildByName("Text_c2"):setString(g_tr("RunQuickTitle"))
    self.panel:getChildByName("Text_1"):setString(g_tr( "RunQuickModLength" ))
    self.panel:getChildByName("Text_3"):setString(g_tr( "RunQuickModTime" ))
    self.panel:getChildByName("Text_2"):setString(g_tr( "RunQuickMoveUse" ))
    self.panel:getChildByName("Text_7"):setString(g_tr( "RunQuickMoveFinish" ))
    
   
    local quickConfigData = g_data.quick_bug
    local quickData
    local filter = {}

     --从quick_bug配置中获取使用道具对应在shop表中的数据
    for _, value in ipairs(quickConfigData) do
        if self.mapStatus == changeMapScene.m_MapEnum.guildwar  or self.mapStatus == changeMapScene.m_MapEnum.citybattle  then
            if value.type == g_Consts.UseItemType.GuildQuick then
                quickData = value.shop_id
            end
        else
            if value.type == g_Consts.UseItemType.Quick then
                quickData = value.shop_id
            end
        end
    end
    
    --取出数据获取道具的drop id 从drop表中获取对应的item id并使用key value形式保存在filter中
    for i, shop_id in ipairs(quickData) do
        local shopConfigData = g_data.shop[shop_id]
        
        --对应道具的价格ID
        local cost_id
        local item_id
        
        if shopConfigData then
            cost_id = shopConfigData.cost_id 
        end

        --掉落表里查找
        local dropConfigData = g_data.drop[ shopConfigData.commodity_data ]
        
        if dropConfigData then
            item_id = dropConfigData.drop_data[1][2]
        end

        if cost_id and item_id then
            filter[item_id] = { item_id = item_id, cost_id = cost_id,shop_id = shop_id }
        end
    end
    
    --在item表中获取对应道具的配置信息显示使用
    local filterdata = {}
    for _ , value in pairs(filter) do
        table.insert(filterdata,g_data.item[value.item_id])
    end
    
    
    local function UseItem(item,item_id,upStatus)
        if UseActions:useQuickItem(self.rundata.id,item_id) then
            if self.zsTx then
                self.zsTx:setString(tostring( g_PlayerMode.getDiamonds() ))
            end
            if self.mapStatus == changeMapScene.m_MapEnum.guildwar then
                self.rundata = require("game.mapguildwar.worldMapLayer_bigMap").getCurrentQueueDatas().Queue[tostring(self.rundata.id)]
            elseif self.mapStatus == changeMapScene.m_MapEnum.citybattle then
                self.rundata = require("game.mapcitybattle.worldMapLayer_bigMap").getCurrentQueueDatas().Queue[tostring(self.rundata.id)]
            else
                self.rundata = require("game.maplayer.worldMapLayer_bigMap").getCurrentQueueDatas().Queue[tostring(self.rundata.id)]
            end
            if self.rundata == nil  then
                self.panel:unscheduleUpdate()
                self:close()
                return
            else
                local item_type = g_Consts.DropType.Props
                local newCount = g_BagMode.findItemNumberById( item_id )
                item:updateInfo(item_type, item_id, newCount) 
                upStatus(newCount)           
            end
            return true
        end
        return false
    end
    
    local itemMode = cc.CSLoader:createNode("CityGain_list.csb")
    local count = math.ceil(#filterdata/2)
    local index = 1

    for i = 1, count do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size( itemMode:getContentSize().width * 2 , itemMode:getContentSize().height ))
        for j = 1, 2 do
            local data = filterdata[index]
            if data then
                local itemPanel = itemMode:clone()
                itemPanel:setPositionX(  (j - 1) * (itemPanel:getContentSize().width + 12 )  )
                layout:addChild(itemPanel)
                local itemborder = itemPanel:getChildByName("Image_3")
                local item_type = g_Consts.DropType.Props
                local item_id = data.id
                local item_num = g_BagMode.findItemNumberById( data.id )

                print("item_type, item_id,item_num",item_type, item_id,item_num)

                local item = require("game.uilayer.common.DropItemView").new(item_type, item_id,item_num)
                item:setPosition(cc.p( itemborder:getContentSize().width/2,itemborder:getContentSize().height/2 ))
                itemborder:addChild(item)

                itemPanel:getChildByName("Text_n1"):setString(g_tr(data.item_name))
                itemPanel:getChildByName("Text_n1_0"):setString(g_tr(data.item_introduction))
                
                local ownNum,pic = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)
                --print("picpicpic",ownNum,tostring(pic))
                --local cost =  0
                --local shopId = filter[item_id].shop_id
                --local shopItemData = g_playerShop.GetShopItemDataByShopId(shopId)
                --local cost = shopItemData:getPrice()
                --local costType = shopItemData:getCostType()

                print("price,costType",price,costType)

                --[[for key, var in pairs(g_data.cost) do
                    if var.cost_id == filter[item_id].cost_id then
                        cost = var.cost_num
                        break
                    end
                end]]
                
                local useBtn = itemPanel:getChildByName("Button_2")
                
                local maxCostTx = itemPanel:getChildByName("Text_9_0")
                maxCostTx:setVisible(false)
                itemPanel:getChildByName("Line"):setVisible( false )

                local buyAndUseBtn = itemPanel:getChildByName("Button_2_0")
                --buyAndUseBtn:getChildByName("Text_9"):setString( tostring(cost) )
                buyAndUseBtn:getChildByName("Image_9"):loadTexture(tostring(pic))
                --zhcn
                local useZHCNtxt = useBtn:getChildByName("Text_5")
                useZHCNtxt:setString(g_tr("bagUse"))
                --zhcn
                local buyZHCNtxt = buyAndUseBtn:getChildByName("Text_6")
                buyZHCNtxt:setString(g_tr("buy"))
                

                local function upCost()
                    local shopId = filter[item_id].shop_id

                    local shopItemData = g_playerShop.GetShopItemDataByShopId(shopId)

                    --dump(shopItemData)

                    local cost = shopItemData:getPrice()
                    local costType = shopItemData:getCostType()
                    local maxPrice = shopItemData:getMaxPrice()

                    buyAndUseBtn:getChildByName("Text_9"):setString( tostring(cost) )
                    maxCostTx:setString(  g_tr( "marketOriginalPrice",{ price = maxPrice } ))
                    --local isThanMax = cost < maxPrice
                    --maxCostTx:setVisible( isThanMax )
                    --itemPanel:getChildByName("Line"):setVisible( isThanMax )

                    return cost
                end

                --更新状态
                local function upStatus(num)
                    if num > 0 then
                        buyAndUseBtn:setVisible(false)
                        useBtn:setVisible(true)
                        item:setCountEnabled(true)
                    else
                        buyAndUseBtn:setVisible(true)
                        useBtn:setVisible(false)
                        item:setCountEnabled(false)
                    end
                    upCost()
                end
                
                upStatus(item_num)
                
                --使用道具
                --local last_time = 0
                useBtn:addTouchEventListener( function (sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                        --间隔1.5秒
                        --local current_time = os.time()
                        --if current_time - last_time > 2 then
                            --last_time = current_time
                            UseItem(item,item_id,upStatus)
                        --end
                    end
                end )
                
                buyAndUseBtn:addTouchEventListener( function (sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

                        local function buy2Use()
                            local shop_id = filter[item_id].shop_id
                            if UseActions:shopBuy(shop_id,1) then
                                local newCount = g_BagMode.findItemNumberById( item_id )
                                item:updateInfo(item_type, item_id, newCount)
                                upStatus(newCount)
                                --并且使用此道具
                                return UseItem(item,item_id,upStatus)
                            end
                            return false
                        end
    
                        if self.mapStatus == changeMapScene.m_MapEnum.guildwar or self.mapStatus == changeMapScene.m_MapEnum.citybattle then
                            if buy2Use() then
                                g_airBox.show(g_tr("buyAndUseSus"))
                            end
                        else
                            --确认购买
                            g_msgBox.showConsume(upCost(), g_tr("RunQuickUseGemBuyTrue"), nil, nil, function ()
                                if self.rundata == nil then
                                    print("部队已经到达目的地")
                                    g_airBox.show(g_tr("RunQuickComplete"),1)
                                    return
                                end
                                buy2Use()
                            end)
                        end


                    end
                end )         
                index = index + 1
            end
        end
        self.list:pushBackCustomItem(layout)
    end
    
    --立即加速
    local useMoveBtn = self.panel:getChildByName("Image_7")
    --判断是否集结完成群体出发 这个时候是不能使用行动力加速
    local isJJGoto = require("game.maplayer.worldMapLayer_queueHelper").isGatherGotoType(self.rundata)

    if isJJGoto or self.mapStatus == changeMapScene.m_MapEnum.guildwar or self.mapStatus == changeMapScene.m_MapEnum.citybattle then
        useMoveBtn:setVisible(false)
        self.panel:getChildByName("Text_2"):setVisible(false)
        self.panel:getChildByName("Text_2_0"):setVisible(false)
        self.panel:getChildByName("Text_7"):setVisible(false)
    end

    useMoveBtn:addTouchEventListener( function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            --print("直达直达",self:updateRunLength())
            --当前需要的体力
            local needMove = self:updateRunLength()
            --玩家剩余的体力
            local playerMove = g_PlayerMode.getMove() or 0
            --是否体力足够不够使用元宝购买
            local useOverMove = playerMove - needMove
            
            --不够
            if useOverMove < 0 then
                local needGem = math.abs(useOverMove) * 2
                g_msgBox.showConsume(needGem, g_tr("RunQuickUseGemIsTrue"), nil, nil, function ()
                    if self.rundata == nil then
                        print("部队已经到达目的地")
                        g_airBox.show(g_tr("RunQuickComplete"),1)
                        return
                    end

                    if g_PlayerMode.getDiamonds() < needGem then
                        g_airBox.show(g_tr("no_enough_money"),3)
                        return
                    end

                    if UseActions:useQuickItem(self.rundata.id,-1) then
                        --self.rundata = require("game.maplayer.worldMapLayer_bigMap").getCurrentQueueDatas().Queue[tostring(self.rundata.id)]
                        --if self.rundata == nil then
                            --self.panel:unscheduleUpdate()
                            --self:close()
                            --return
                        --end
                        self:close()
                        return
                    end
                    --print("使用")
                end)
            else --足够
                local function msgBoxCallBack(event)
                    if event == 0 then
                        --print("1111111")
                        if self.rundata == nil then
                            return
                        end

                        if UseActions:useQuickItem(self.rundata.id,-1) then
                            --self.rundata = require("game.maplayer.worldMapLayer_bigMap").getCurrentQueueDatas().Queue[tostring(self.rundata.id)]
                            --dump(self.rundata)
                            --dump(self.rundata.accelerate_info.log)
                            --if self.rundata == nil then
                                --self.panel:unscheduleUpdate()
                                --self:close()
                                --return
                            --end
                            self:close()
                            return
                        end
                    end
                end

                --大于十五分钟加以提示
                if needMove >= 15 then
                    g_msgBox.show(g_tr("RunQuickUseMoveIsTrue",{num = needMove}),nil,nil,msgBoxCallBack,1)
                else
                    if UseActions:useQuickItem(self.rundata.id,-1) then
                        self:close()
                        return
                    end
                end
            end
        end
    end)
end

function UseBuffItemLayer:updateRunLength()
    
    local end_pos = cc.p( self.rundata.to_x,self.rundata.to_y )
    local now_pos
    local queueDisplay

    --联盟战
    if self.mapStatus == changeMapScene.m_MapEnum.guildwar then
        queueDisplay = require("game.mapguildwar.worldMapLayer_bigMap").getTeamInterface(self.rundata)
        if queueDisplay then
            now_pos = require ("game.mapguildwar.worldMapLayer_helper").position_2_bigTileIndex(cc.p(queueDisplay:getPositionX(),queueDisplay:getPositionY())) or cc.p(0,0)
        end
    elseif self.mapStatus == changeMapScene.m_MapEnum.citybattle then
        queueDisplay = require("game.mapcitybattle.worldMapLayer_bigMap").getTeamInterface(self.rundata)
        if queueDisplay then
            now_pos = require ("game.mapcitybattle.worldMapLayer_helper").position_2_bigTileIndex(cc.p(queueDisplay:getPositionX(),queueDisplay:getPositionY())) or cc.p(0,0)
        end
    else
        queueDisplay = require("game.maplayer.worldMapLayer_bigMap").getTeamInterface(self.rundata)
        if queueDisplay then
            now_pos = require ("game.maplayer.worldMapLayer_helper").position_2_bigTileIndex(cc.p(queueDisplay:getPositionX(),queueDisplay:getPositionY())) or cc.p(0,0)
        end
    end
    
    if self.rundata == nil or now_pos == nil or end_pos == nil then
        self.panel:unscheduleUpdate()
        self:close()
        return
    end

    --剩余距离
    local runLength = cc.pGetDistance(now_pos,end_pos)
    --使用体力
    local moveNum = math.max(  math.floor(math.pow(runLength,0.911) * 0.45),5)

    if self.rundata.type == require("game.maplayer.worldMapLayer_queueHelper").QueueTypes.TYPE_CITYBATTLE_GOTO then
        moveNum = moveNum * ( tonumber( g_data.starting[104].data) or 1)
    end

    self.panel:getChildByName("Text_1_0"):setString( tostring(math.floor(runLength)) .. g_tr("worldmap_KM") )
    self.panel:getChildByName("Text_2_0"):setString( tostring(moveNum) )
    --print("需要体力",math.floor(math.pow(runLength,0.45)),math.max(  math.floor(math.pow(runLength,0.45)),5  ) )

    --max(int(（距离^0.911）*0.45),5)

    --再说看看是用路程判断关闭还是时间判断关闭
    --[[if runLength <= 0 then
        self.panel:unscheduleUpdate()
    end]]

    local timebar = self.panel:getChildByName("LoadingBar_1")
    local timetxt = self.panel:getChildByName("Text_4")
    local all_time = self.rundata.end_time - self.rundata.create_time
    
    --剩余时间
    local mod_time = self.rundata.end_time - g_clock.getCurServerTime() 
    
    timebar:setPercent( 100 - ( mod_time / all_time * 100 ) )
    timetxt:setString( string.format( "%02d:%02d:%02d",g_clock.formatTimeHMS( mod_time )) )

    if mod_time <= 10 then
        local useMoveBtn = self.panel:getChildByName("Image_7") 
        useMoveBtn:setTouchEnabled(false)
        useMoveBtn:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
    end

    if mod_time == nil or mod_time <= 0 then
        self.panel:unscheduleUpdate()
        self:close()
        return
    end


    return moveNum
    --print("runLength",runLength)

end




return UseBuffItemLayer




--endregion
