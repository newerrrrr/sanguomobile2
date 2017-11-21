--region activityZhuanPanLayer.lua
--Author : liuyi
--Date   : 2016/6/12

--这个界面没有做多语言
local ActivityZhuanPanLayer = class("ActivityZhuanPanLayer", require("game.uilayer.base.BaseLayer"))

local TBCost = 1000
local GYCost = {0,1,2,4,8,16,32,64,128}

function ActivityZhuanPanLayer:ctor()
    
    ActivityZhuanPanLayer.super.ctor(self)
    
    self.initData = {}
    self.drawData = {}

   
end


function ActivityZhuanPanLayer:onEnter()


    local function callback(result,msgData)
        g_busyTip.hide_1()
        if result == true then
            local PlayerLotteryInfo = g_zhuanPanData.GetZhuanPanData()
            local PlayerDrawCard = g_zhuanPanData.GetFanPaiData()
            if PlayerLotteryInfo and PlayerDrawCard then
                self.initData = PlayerLotteryInfo
                self.drawData = PlayerDrawCard.data or {}
                self.chestId = PlayerDrawCard.chest_type_id or 1
                self.isStart = PlayerDrawCard.is_start or 0
                self:initUI()
            end
        end
    end

    g_busyTip.show_1()
    g_zhuanPanData.RequestAsyData(callback)
    
end

function ActivityZhuanPanLayer:initUI()

    self.masterData = g_PlayerMode.GetData()
    
    self.layer = cc.CSLoader:createNode("turntable_main3.csb")

    self:addChild(self.layer)
    
    self.layer:getChildByName("Panel_renwu"):loadTexture( g_resManager.getResPath(1030092) )

    self.tongbanStr = self.layer:getChildByName("Text_1")
    self.gouyuStr = self.layer:getChildByName("Text_3")
    --铜板数量
    self.tongbanNum = 0
    --勾玉数量
    self.gouyuNum = 0
    --掷骰子免费次数
    self.freeNum = 0
    --初始位置
    self.stopIndex = 1
    --保存初始位置 移动主公头像使用

    self.isFanPai = false
    
    if self.initData then
        self.tongbanNum = self.initData.coin_num or 0
        self.tongbanStr:setString( string.formatnumberthousands(self.tongbanNum or 0 ) )
        self.gouyuNum = self.initData.jade_num or 0
        self.gouyuStr:setString( string.formatnumberthousands(self.gouyuNum or 0 ) )
        self.freeNum = self.initData.free_times or 0
        self.stopIndex = self.initData.current_position or 1
        if self.initData.draw_card_id and  self.initData.draw_card_id ~= 0 then
            self.isFanPai = true
        end
    end

    --self.isFanPai = false

    if self.daFuWengLayer == nil then
        self.daFuWengLayer = self:createDaFuWengView()
    end

    if self.fanPaiLayer == nil then
        self.fanPaiLayer = self:createFanPaiView()
    end

    self:daFuWengLayerSetVisible( not self.isFanPai)
    self:fanPaiSetVisible( self.isFanPai )

end

--大富翁
function ActivityZhuanPanLayer:createDaFuWengView()
    
    local layer = self.layer:getChildByName("Panel_luxian")
    local itemMode = cc.CSLoader:createNode("turntable_parts1.csb")

    local index = 1
    local items = {}
    local movetb = {}

    local stopItem = nil    --当前停留在那个格子
    local runMap = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}

    local minHeadID = g_data.res_head[self.masterData.avatar_id].min_head
    local head = ccui.ImageView:create(g_resManager.getResPath(minHeadID))
    layer:addChild(head)
    
    while true do
        local panel = layer:getChildByName( string.format("Panel_%d",index) )
        if panel then
            local item = itemMode:clone()
            panel:addChild(item)
            if index == self.stopIndex then
                --高亮
                item:getChildByName("Image_faguang"):setVisible(true)
                --蒙板

                stopItem = item

                local showImg = item:getChildByName("Image_1")

                head:setPosition( cc.p( panel:getPositionX() + panel:getContentSize().width/2,  panel:getPositionY() + panel:getContentSize().height/2  )  )

            else
                item:getChildByName("Image_faguang"):setVisible(false)
            end
            item:getChildByName("Image_hui"):setVisible(false)
            item.index = index
            table.insert( items,index,item)
            index = index + 1
        else
            break
        end
    end

    local configData = g_data.wheel
    local sortConfigData = {}

    for key, var in ipairs(configData) do
        if self.masterData.level >= var.lv_min and self.masterData.level <= var.lv_max then
            sortConfigData[var.grid_id] = var
        end
    end

    for index, item in ipairs(items) do
        local config = sortConfigData[index]
        if config then
            
            local showImg = item:getChildByName("Image_1")
            local sp = cc.Sprite:create(g_resManager.getResPath(config.res_icon))
            sp:setPosition( cc.p( showImg:getContentSize().width/2,showImg:getContentSize().height/2 ) )
            showImg:addChild(sp)
            item:setTouchEnabled(true)
            
           --刘毅，翻牌介绍改成tips了
           local dropID = config.drop
           if dropID and dropID ~= 0 then
              item:addTouchEventListener( function (sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        dump(config)
                        local dropID = config.drop
                        if dropID and dropID ~= 0 then
                            g_sceneManager.addNodeForUI( require("game.uilayer.activity.activityZhuanPan.DropShowView"):create(dropID) )
                        else
                            --g_msgBox.show( g_tr("zhuanpanBaoXiangDsc"),nil,nil)
                        end
                    end
              end )
           else
              g_itemTips.tipStr(item,g_tr("zhuanpanFanTitle"), g_tr("zhuanpanBaoXiangDsc"))
           end
            
        end
    end
    
    local armature = nil
    local animation = nil
    local istouch = true   --播放特效之后才可以重新投色子
    --local isFanPai = false --是否当前翻牌
    local touzi = self.layer:getChildByName("Panel_touzi"):getChildByName("Image_34")

    self.layer:getChildByName("Panel_touzi"):getChildByName("Text_2_0"):setString(g_tr("zhuanpanStart"))

    self.costNumTx = self.layer:getChildByName("Panel_touzi"):getChildByName("Text_34")

    if self.freeNum > 0 then
        self.costNumTx:setString(g_tr("battleMoveFree"))
    else
        self.costNumTx:setString(tostring(TBCost))
    end
    
    
    local function jumpMove(groups)
        local map1 = {1,2,3,4,5,6,7,8,9,10,11,12,13,14}
        local map2 = {1,2,3,15,16,10,11,12,13,14}

        local movetb = {}
        
        local sIndex = 0
        local eIndex = 0

        sIndex = stopItem.index
        stopItem = items[ runMap[self.stopIndex] ]
        eIndex = stopItem.index
        
        

        local function goMove(si,ei,selMap)
            print("si,ei",si,ei)
            --      15     10
            if eIndex < sIndex and ei < si then
                for var = si, #selMap do
                    table.insert(movetb,selMap[var])
                end

                for var = 1, ei do
                    table.insert(movetb,selMap[var])
                end
            else
                for var = si, ei do
                    table.insert(movetb,selMap[var])
                end
            end
        end

        --如果开始索引能在map1找到
        local si = table.indexof(map1,sIndex) --这是找到下标
        local ei = table.indexof(map1,eIndex) --这是找到下标
        local selMap = map1

        if si and ei and si ~= 3 then
            --goMove(si,ei,map1)
        else
            selMap = map2
            si = table.indexof(selMap,sIndex)
            ei = table.indexof(selMap,eIndex)
        end

        goMove(si,ei,selMap)
        
        dump(movetb)

        local runIndex = 1

        local function createAction()
            local item
            if movetb[runIndex] then
                if runIndex ~= #movetb then
                    
                    item = items[movetb[runIndex]]
                    local panel = item:getParent()
                    item:getChildByName("Image_faguang"):setVisible(true)

                    head:setPosition( cc.p( panel:getPositionX() + panel:getContentSize().width/2,  panel:getPositionY() + panel:getContentSize().height/2  )  )

                    local fadeIn = cc.FadeIn:create(0)
                    local fadeOut = cc.FadeOut:create(0.15)
                    local callFun = cc.CallFunc:create(function ()
                        item:getChildByName("Image_faguang"):setVisible(false)
                        runIndex = runIndex + 1
                        createAction()
                    end)
                    item:getChildByName("Image_faguang"):runAction( cc.Sequence:create(fadeIn,fadeOut,callFun))
                    
                else
                    local panel = stopItem:getParent()
                    head:setPosition( cc.p( panel:getPositionX() + panel:getContentSize().width/2 ,  panel:getPositionY() + panel:getContentSize().height/2  )  )
                    stopItem:getChildByName("Image_faguang"):setOpacity(255)
                    stopItem:getChildByName("Image_faguang"):setVisible(true)
                    require("game.uilayer.common.dropFlyEffect").show(groups,stopItem:convertToWorldSpace(cc.p(0,0)),true)

                    --进入翻牌游戏
                    if self.isFanPai then
                        self:createFanPaiView()
                        self:daFuWengLayerSetVisible( false )
                        self:fanPaiSetVisible( true )
                    end

                    self.isFanPai = false
                    istouch = true
                end
            end
        end
        
        createAction()
        print("sIndex,eIndex",sIndex,eIndex)

    end


    local drop = {}

    --特效播放结束
    local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            local groups = {}
            if type(drop) == "table" then
                --local groups = {}
                for key, var in ipairs(drop) do
                    table.insert( groups,{ var.type,var.id,var.num } )
                end
            end
            jumpMove(groups)
            
        end
	end
    
    touzi:setTouchEnabled(true)
    touzi:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended and istouch then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if self.tongbanNum < TBCost and self.freeNum <= 0 then
                --"铜板不足 跳转到商城购买"
                g_msgBox.show( g_tr("zhuanpanItemNoEnoughTQ"),nil,nil,
                    function ( eventtype )
                        --确定
                        if eventtype == 0 then 
                            local function getCallBack()
                                self:refRes()
                            end
--                            local shop = require("game.uilayer.activity.activityZhuanPan.ResourceView"):create(g_Consts.AllCurrencyType.Coin,getCallBack,self.tongbanNum)
--                            g_sceneManager.addNodeForUI(shop)
                            require("game.uilayer.shop.UseResourceView").show(g_Consts.AllCurrencyType.Coin,getCallBack)
                            
                        end
                    end , 1)
                return
            end

            local function callback(result,data)
                g_busyTip.hide_1()
                if result == true then
                    dump(data)
                    drop = {}
                    drop = data.drop

                    if drop.drawCardTypeId then
                        --进入翻牌
                        self.chestId = tonumber(drop.drawCardTypeId)
                        self.isFanPai = true
                    end
                    
                    istouch = false
                    local point = tonumber(data.randP)       
                    
                    self.stopIndex = table.indexof(runMap,data.endPosition)

                    --if self.stopIndex >= 1 and self.stopIndex <= 6 then
                        self:refRes()
                    --end

                    if armature and animation then
                        armature:removeFromParent()
                        armature = nil
                        animation = nil
                    end

                    if armature == nil  and animation == nil then
                        armature,animation = g_gameTools.LoadCocosAni(
                        "anime/anim_ssz_001/anim_ssz_001.ExportJson",
                        "anim_ssz_001",
                        onMovementEventCallFunc
                        )
                        armature:setPositionX( 225 )
                        armature:setPositionY( 300 )

                        layer:addChild(armature,1)
                        animation:play( tostring(point) )
                    end

                end
            end
            g_busyTip.show_1()
            g_sgHttp.postData("Lottery/playerGo",nil,callback,true)

        end
    end)

    --dump(sortConfigData)
    
    layer.shaiZiPanel = self.layer:getChildByName("Panel_touzi")
    --layer:setVisible(false)
    return layer
end

function ActivityZhuanPanLayer:daFuWengLayerSetVisible(isShow)
    if self.daFuWengLayer then
        self.daFuWengLayer:setVisible(isShow)
        if self.daFuWengLayer.shaiZiPanel then
            self.daFuWengLayer.shaiZiPanel:setVisible(isShow)
        end
    end
end

--翻牌
function ActivityZhuanPanLayer:createFanPaiView()
    --self.daFuWengLayer:setVisible(false)

    local layer = self.layer:getChildByName("Panel_huoqu")
    layer.fanPaiRuleBtn = self.layer:getChildByName("Button_1")
    layer.restartFanPaiBtn = self.layer:getChildByName("Button_3")
    layer.quitBtn = self.layer:getChildByName("Button_fq")
    layer.ckBtn = self.layer:getChildByName("Button_ck")
    
    if layer.fanPaiRuleBtn.isEvent == nil then
        layer.fanPaiRuleBtn:addTouchEventListener(function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                require("game.uilayer.common.HelpInfoBox"):show(13)
            end
        end)
    end

    layer.fanPaiRuleBtn.isEvent = true
    --zhcn
    layer.restartFanPaiBtn:getChildByName("Text_b3"):setString(g_tr("zhuanpanXiPaiStr"))
    layer.ckBtn:getChildByName("Text_b1"):setString(g_tr("zhuanpanCk"))
    layer.quitBtn:getChildByName("Text_b1"):setString(g_tr("zhuanpanQuit"))


    if table.nums(self.drawData) >= table.nums(GYCost) then
        layer.quitBtn:getChildByName("Text_b1"):setString(g_tr("zhuanpanOver"))
    end
    
    local chestConfig = g_data.chest
    local isQuit = false
    local index = 1
    local items = {}
    
    local function touchFanPai(sender,touchType)
        if touchType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if self.isStart == 0 then
                --print("请洗牌")
                g_airBox.show(g_tr("zhuanpanXiPai"))
                return
            end

            if self.drawData == nil then
                print(" get cost data drawData is nil:")
                return
            end
            
            local nowCost = GYCost[table.nums(self.drawData) + 1]

            if nowCost == nil then
                print(" get cost error ,index is :",table.nums(self.drawData) + 1)
                return
            end
            
            local function isTrueOpen()
                --当前需要花费的勾玉
                if self.gouyuNum < nowCost then
                    print(" 勾玉数量不足 ")
                    
                    g_msgBox.show( g_tr("zhuanpanItemNoEnoughGY"),nil,nil,
                    function ( eventtype )
                        --确定
                        if eventtype == 0 then 
                            local function getCallBack()
                                self:refRes()
                            end
                            --local shop = require("game.uilayer.activity.activityZhuanPan.ResourceView"):create(g_Consts.AllCurrencyType.Gouyu,getCallBack,self.gouyuNum)
                            --g_sceneManager.addNodeForUI(shop)
                            require("game.uilayer.shop.UseResourceView").show(g_Consts.AllCurrencyType.Gouyu,getCallBack)
                            
                        end
                    end , 1)

                    return
                end

                local function onMovementEventCallFunc(armature , eventType , name)
                    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
                        armature:removeFromParent()
                    end
                end

                local function playAnimation()
                    local armature,animation = g_gameTools.LoadCocosAni(
                        "anime/Effecy_DaZhuanPanBaoXiangDianKai/Effecy_DaZhuanPanBaoXiangDianKai.ExportJson",
                        "Effecy_DaZhuanPanBaoXiangDianKai",
                        onMovementEventCallFunc
                    )
                    
                    armature:setPosition(cc.p(sender:getContentSize().width/2,sender:getContentSize().height/2))
                    sender:addChild(armature,1)
                    animation:play( "Animation1" )
                end
                
                local position = sender.pos
                local function callback(result,data)
                    g_busyTip.hide_1()
                    if result == true then
                        --dump(data)
                        playAnimation()
                        self.drawData[tostring(tostring(position))] = tonumber(data.chest.id)
                        local cData = chestConfig[ tonumber(data.chest.id)]

                        --[[local dTime = cc.DelayTime:create(0.3)
                        local dfun = cc.CallFunc:create(function ()
                            
                        end)]]

                        local icon = self:createShowItem(cData,sender)
                        icon:setOpacity(0)
                        sender.icon = icon
                        sender:addChild(icon)
                        
                        local fadeIn = cc.FadeIn:create(1)
                        local ffun = cc.CallFunc:create(function ()
                            self:itemFly(icon,data.times)
                        end)

                        icon:runAction( cc.Sequence:create( fadeIn,ffun ) )
                        
                        self:refRes()

                        --最后一个翻牌结束
                        if table.nums(self.drawData) >= table.nums(GYCost) then
                            layer.quitBtn:getChildByName("Text_b1"):setString(g_tr("zhuanpanOver"))
                        end

                        sender.fx:setVisible(false)
                    end
                end
                g_busyTip.show_1()
                g_sgHttp.postData("Lottery/playerDraw",{ position = position },callback,true)
            end

           

            if table.nums(self.drawData) > 0 then
                if self.drawData[tostring(sender.pos)] == nil then
                    g_msgBox.show( g_tr( "zhuanpanFanPai",{count = nowCost}) ,nil,nil,
                        function ( eventType )
                            --确定
                            if eventType == 0 then 
                                isTrueOpen()
                            end
                        end,1
                     )
                 end
            else
                --免费
                if self.drawData[tostring(sender.pos)] == nil then
                    g_msgBox.show( g_tr( "zhuanpanFanPaiFree") ,nil,nil,
                        function ( eventType )
                            --确定
                            if eventType == 0 then 
                                isTrueOpen()
                            end
                        end,1
                     )
                 end     
            end
        end    
    end

    while true do
        local item = layer:getChildByName( string.format("Panel_%d",index))
        if item then
            
            if item.icon then
                item.icon:removeFromParent()
                item.icon = nil
            end

            item:setTouchEnabled(true)
            item.pos = index
            
            if item.isListener == nil then
                item:addTouchEventListener(touchFanPai)
            end

            item.isListener = true

            item:getChildByName("Image_3"):setVisible(false)

            if item.fx == nil then
                local armature,animation = g_gameTools.LoadCocosAni(
                "anime/Effect_DaZhuanPanBaoXiangDiPaiXunHuan/Effect_DaZhuanPanBaoXiangDiPaiXunHuan.ExportJson",
                "Effect_DaZhuanPanBaoXiangDiPaiXunHuan"
                )
                armature:setPosition(cc.p(item:getContentSize().width/2,item:getContentSize().height/2))
                item:addChild(armature,1)
                animation:play( "Animation1" )
            
                item.fx = armature
            end

            item.fx:setVisible(false)
            table.insert(items,item)
            index = index + 1
        else
            break
        end
    end

    if self.drawData then
        --没有洗过牌 展示所有结果
        if self.isStart == 0 then
            local sortConfig = {}
            for key, var in pairs(chestConfig) do
                if var.chest_id == self.chestId then
                    table.insert( sortConfig,var)
                end
            end
            
            table.sort( sortConfig,function (a,b)
                return a.id < b.id
            end )

            for index, item in ipairs(items) do
                item:setVisible(true)
                local cData = sortConfig[index]

                if item.icon then
                    item.icon:removeFromParent()
                    item.icon = nil
                end
                if item.icon == nil then
                    local icon = self:createShowItem(cData,item,false)
                    item.icon = icon
                    item:addChild(icon)
                end
                item.fx:setVisible(false)
            end
        end

        --已经洗过牌
        if self.isStart == 1 then
            for pos, item in ipairs(items) do
                local chestId = self.drawData[tostring(pos)]
                if chestId then
                    local cData = chestConfig[chestId]
                    local icon = self:createShowItem(cData,item)
                    item.icon = icon
                    item:addChild(icon)
                else
                    item.fx:setVisible(true)
                    item.icon = nil
                end
            end
        end
    end
    
    --洗牌
    local function restartPai(sender,touchType)
        if touchType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            --洗牌不能放弃
            layer.quitBtn:setTouchEnabled(false)
            for _, item in ipairs(items) do
                print("item.icon",item,item.icon)

                if item.icon then
                    print("remove............")
                    item.icon:removeFromParent()
                    item.icon = nil
                end
            end

            --播放动画
            local function runAnimation()
                local bones = nil

                --洗牌完成
                local function onMovementEventCallFunc(armature , eventType , name)
                    if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
                        armature:removeFromParent()
                        --洗牌结束才能放弃
                        layer.quitBtn:setTouchEnabled(true)
                        --显示牌节点隐藏
                        for _, item in ipairs(items) do
                            item:setVisible(true)
                            if item.fx then
                                item.fx:setVisible(true)
                            end
                        end
                    end
                end
                --隐藏牌节点播放动画
                for _, item in ipairs(items) do
                    item:setVisible(false)
                end
            
                local armature,animation = g_gameTools.LoadCocosAni(
                "anime/Effect_DaZhuanPanBaoXiangXiPai/Effect_DaZhuanPanBaoXiangXiPai.ExportJson",
                "Effect_DaZhuanPanBaoXiangXiPai",
                onMovementEventCallFunc
                --,onFrameEventCallFunc
                )

                armature:setPosition( cc.p(self.layer:getContentSize().width/2,self.layer:getContentSize().height/2) )
                self.layer:addChild(armature,1)
            
                bones = 
                {   
                    armature:getBone("Layer19"),
                    armature:getBone("Layer18"),
                    armature:getBone("Layer17"),
                    armature:getBone("Layer16"),
                    armature:getBone("Layer11"),
                    armature:getBone("Layer15"),
                    armature:getBone("Layer14"),
                    armature:getBone("Layer13"),
                    armature:getBone("Layer12"),
                }

                for index, bone in ipairs(bones) do
                    local node = items[1]:getChildByName("Image_1_0"):clone()
                    node:setAnchorPoint(cc.p(0.5,0.5))
                    node:setPosition( cc.p(0,0) )
                    bone:addDisplay(node,0)
                end

                animation:play( "Animation1" )
            end

            local function callback(result,data)
                g_busyTip.hide_1()
                if result == true then
                    self.isStart = 1
                    layer.quitBtn:setVisible(true)
                    layer.restartFanPaiBtn:setVisible(false)
                    runAnimation()
                end
            end
            g_busyTip.show_1()
            g_sgHttp.postData("Lottery/startDrawCard",nil,callback,true)
            --runAnimation()
            
        end
    end
    
    layer.restartFanPaiBtn:addTouchEventListener(restartPai)
    --放弃/结束游戏
    local function gamQuit(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local function isTrueQuit()
                --[ [
                local function callback(result,data)
                    g_busyTip.hide_1()
                    if result == true then
                        dump(data)
                        self.drawData = {}
                        self.isStart = 0
                        self.chestId = 1
                        self.isFanPai = false

                        for _, item in ipairs(items) do
                            item:setVisible(true)
                            if item.icon then
                                item.icon:removeFromParent()
                                item.icon = nil
                            end
                        end

                        self:daFuWengLayerSetVisible( true )
                        self:fanPaiSetVisible( false )
                    end
                end
                g_busyTip.show_1()
                g_sgHttp.postData("Lottery/quitDrawCard",nil,callback,true)
                --]]
            end

            if  table.nums(self.drawData) < table.nums(GYCost) then
                g_msgBox.show( g_tr("zhuanpanFangQi"),nil,0,
                function ( eventType )
                    --确定
                    if eventType == 0 then 
                        --print("1111111111")
                        isTrueQuit()
                    end
                end , 1)
            else
                isTrueQuit()
            end
        end
    end
    
    layer.quitBtn:addTouchEventListener(gamQuit)
    
    layer.changeBtn = function ()
        --洗过牌 洗牌按钮隐藏
        if self.isStart == 0 then
            layer.restartFanPaiBtn:setVisible(true)
            layer.quitBtn:setVisible(false)
        end

        if self.isStart == 1 then
            layer.restartFanPaiBtn:setVisible(false)
            layer.quitBtn:setVisible(true)
        end
    end

    layer.ckBtn:addTouchEventListener( function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_sceneManager.addNodeForUI( require("game.uilayer.activity.activityZhuanPan.ActivitySurplusShow"):create( self.chestId,self.drawData ) )
        end
    end )

    --layer.changeBtn()

    return layer
end


function ActivityZhuanPanLayer:fanPaiSetVisible(isShow)
    if self.fanPaiLayer then
        self.fanPaiLayer:setVisible(isShow)
        if self.fanPaiLayer.fanPaiRuleBtn then
            self.fanPaiLayer.fanPaiRuleBtn:setVisible(isShow)
        end

        if self.fanPaiLayer.ckBtn then
            self.fanPaiLayer.ckBtn:setVisible(isShow)
        end

        if isShow then
            self.fanPaiLayer.changeBtn()
        else
            self.fanPaiLayer.restartFanPaiBtn:setVisible(isShow)
            self.fanPaiLayer.quitBtn:setVisible(isShow)
        end
    end
end

--根据配置逻辑创建 有结果道具的图标
function ActivityZhuanPanLayer:createShowItem(cData,item,isCreateFx)
    local icon = nil

    if isCreateFx == nil then
        isCreateFx = true
    end

    if cData.type == 1 then
        local dropData = g_data.drop[cData.value].drop_data[1]
        local iItemType = dropData[1]
        local iItemId = dropData[2]
        local iItemNum = dropData[3]
        print("=======================",iItemType,iItemId,iItemNum)
        local iconMode = require("game.uilayer.common.DropItemView").new(iItemType, iItemId,iItemNum)
        icon = self:createItem(iconMode)
        icon.path = iconMode:getIconPath()
        icon.drop = { itemType = iItemType,itemId = iItemId,itemNum = 1}
    else
        --暴击图标
        local baojiImgId= { [2] = 1019016, [3] = 1019017,[5] = 1019018,[8] = 1019019,[10] = 1019020 }
        icon = self:createItem()
        local iconPic = ccui.ImageView:create( g_resManager.getResPath(baojiImgId[cData.value]) )
        iconPic:setPosition( cc.p(icon:getContentSize().width/2,icon:getContentSize().height/2) )
        icon:addChild(iconPic)
        if isCreateFx then self:createBaoJiFx(icon) end

    end
    
    icon:setPosition( cc.p( item:getContentSize().width/2,item:getContentSize().height/2 ) )

    return icon
end

function ActivityZhuanPanLayer:createItem(itemMode)
    local rankBorderId = {1005201,1005202,1005203,1005204,1005205}
    
    if itemMode == nil then
        return ccui.ImageView:create( g_resManager.getResPath(1005205) )
    else
        local rank = itemMode:getRank()

        local rank = ccui.ImageView:create( g_resManager.getResPath(rankBorderId[rank]))
        local icon = ccui.ImageView:create( itemMode:getIconPath())
        icon:setPosition( cc.p(rank:getContentSize().width/2,rank:getContentSize().height/2) )
        rank:addChild(icon)
        
        local numText = ccui.Text:create( tostring(itemMode:getCount()), "cocos/cocostudio_res/simhei.TTF", 30)
        numText:setAnchorPoint(cc.p(1,0.5))
        numText:setPosition( cc.p( rank:getContentSize().width - 21, 30) )
        numText:enableOutline(cc.c4b(0, 0, 0,255),2)
        rank:addChild(numText)
        return rank
    end
    
end

--创建暴击光圈特效
function ActivityZhuanPanLayer:createBaoJiFx(node)
    local armature,animation = g_gameTools.LoadCocosAni(
    "anime/Effecy_DaZhuanPanBaoXiangXunHuan/Effecy_DaZhuanPanBaoXiangXunHuan.ExportJson",
    "Effecy_DaZhuanPanBaoXiangXunHuan"
    )
    armature:setPosition(cc.p(node:getContentSize().width/2,node:getContentSize().height/2))
    node:addChild(armature,1)
    animation:play( "Animation1" )
end


function ActivityZhuanPanLayer:refRes()

    local data = g_zhuanPanData.GetZhuanPanData()

    if data then
        self.tongbanNum = data.coin_num or 0
        self.tongbanStr:setString( string.formatnumberthousands(self.tongbanNum or 0 ) )
        self.gouyuNum = data.jade_num or 0
        self.gouyuStr:setString( string.formatnumberthousands(self.gouyuNum or 0 ) )
        self.freeNum = data.free_times or 0
        if self.freeNum > 0 then
            self.costNumTx:setString(g_tr("battleMoveFree"))
        else
            self.costNumTx:setString(tostring(TBCost))
        end
    end
end

function ActivityZhuanPanLayer:itemFly(item,times)
    
    local path = item.path
    local icon = nil
    if path == nil then
        return
    end

    local panel = self.layer:getChildByName("Panel_huoqu")

    if times == 1 then
        icon = ccui.ImageView:create( path )
        icon:setPosition( item:convertToWorldSpace( cc.p(item:getContentSize().width/2,item:getContentSize().height/2) ) )
        g_sceneManager.addNodeForSceneEffect(icon)
        local delay = cc.DelayTime:create( 1 )
        local move = cc.MoveTo:create(   0.15,require("game.uilayer.mainSurface.mainSurfaceMenu").getBagBtnPos())
        local backFun = cc.CallFunc:create( function ()
            icon:removeFromParent()
        end )

        icon:runAction( cc.Sequence:create(delay,move,backFun)  )
    else
        
        local armature,animation

        local function onMovementEventCallFunc(armature , eventType , name)
            if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
                armature:removeFromParent()
            end
        end
        
        armature,animation = g_gameTools.LoadCocosAni(
        "anime/Effect_DaZhuanPanBaoXiangXiPaiBaoZha/Effect_DaZhuanPanBaoXiangXiPaiBaoZha.ExportJson",
        "Effect_DaZhuanPanBaoXiangXiPaiBaoZha"
        )
        armature:setPosition(cc.p( panel:getContentSize().width/2 + 120,panel:getContentSize().height/2))
        panel:addChild(armature,1)
        animation:play( "Animation1" )

        
        icon = {}
        for var = 1, times do
            local _icon = ccui.ImageView:create( path )
            _icon:setPosition( panel:convertToWorldSpace( cc.p( math.random(panel:getContentSize().width), math.random(panel:getContentSize().height) ) ) )
            g_sceneManager.addNodeForSceneEffect(_icon)
            _icon:setScale(0.8)
            local delay = cc.DelayTime:create( 1.25 )
            local move = cc.MoveTo:create( 0.1 + math.random( 150 ) / 1000 ,require("game.uilayer.mainSurface.mainSurfaceMenu").getBagBtnPos())
            local backFun = cc.CallFunc:create( function ()
                _icon:removeFromParent()
            end )

            _icon:runAction( cc.Sequence:create(delay,move,backFun)  )
           
        end
    end

end


function ActivityZhuanPanLayer.redPointShow()
    local data = g_zhuanPanData.GetZhuanPanData()
    local tongBan = 0
    local freeTimes = 0
    if data then
        tongBan = data.coin_num or 0
        freeTimes = data.free_times or 0
        return tongBan >= TBCost or data.free_times > 0
    end

    return false
    
end

function ActivityZhuanPanLayer:onExit()
   
end


return ActivityZhuanPanLayer



