local CitySign = class("CitySign",require("game.uilayer.base.BaseLayer"))
local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode"):GetInstance()

local str = 
{
    g_tr("city_battle_zhuhou"),
    g_tr("city_battle_lingjian"),
    g_tr("city_battle_putong"),
}

function CitySign:ctor(cityId)
    CitySign.super.ctor(self)
    self.cityId = cityId
    --self.time = time
    self.campId = g_PlayerMode.GetData().camp_id
    self.signBtns = {}
    self.signData = false
    self.upTime = 0
    self.nData = nil
end

function CitySign:onEnter()
    local function _GetSign(r,d)
        if r == true then
            local isFinish = d.signNum
            if isFinish == false then
                g_airBox.show(g_tr("city_battle_battle_over"))
                self:close()
                return
            end
            self.nData = clone( d.signNum[tostring(self.campId)] )
            self.signData = d.player
            if self.nData then
                 self:_InitUI()
            else
                self:close()
            end
        else
            self:close()
        end
    end

    CityBattleMode:AsyncGetSignInfo(_GetSign,self.cityId,true)
end

function CitySign:_InitUI()
    self.layer = self:loadUI("CityBattle_popup01.csb")
    self.root = self.layer:getChildByName("scale_node")
    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:addClickEventListener( function ( sender )
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
    end)
    
    self.root:getChildByName("Text_1"):setString(g_tr("city_battle_sign_tips"))

    --阵容修改按钮
    local btnChangeTeam = self.root:getChildByName("Image_24") 
    btnChangeTeam:getChildByName("Text_21"):setString(g_tr("myTeam"))
    btnChangeTeam:addClickEventListener( function ( sender )
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        if not self.signData then
            g_airBox.show(g_tr("city_battle_sign_nosign"))
            return
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.FormationView").new(1))
    end)

    local qBtn = self.root:getChildByName("Image_wenh") 
    qBtn:addClickEventListener( function ( sender )
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        require("game.uilayer.common.HelpInfoBox"):show(111)
    end)

    self.list = self.root:getChildByName("ListView_1")
    self:_LoadList()
    self.signNumTx = self.root:getChildByName("Text_15")
    local signCount = (self.nData[1] or 0) + (self.nData[2] or 0)
    local maxCount = g_data.country_city_map[tonumber(self.cityId)].join_max_num
    local canCount = maxCount - signCount
    self.signNumTx:setString( string.format("%s%d/%d(%s%d)",g_tr("city_battle_sign_count"),signCount,maxCount,g_tr("city_battle_sign_caninnum"),canCount) )
end
 

function CitySign:_LoadList()
    local nodeMode = cc.CSLoader:createNode("CityBattle_popup01_list1.csb")

    local pic = 
    {
        g_resManager.getResPath(1031102),
        g_resManager.getResPath(1031095),
        g_resManager.getResPath(1031053),
    }

    self.timeTxs = {}
    self.numTxs = {}

    local itemIds = 
    {
        tonumber(g_data.country_basic_setting[66].data),
        tonumber(g_data.country_basic_setting[18].data)
    }
    for i = 1, 3 do
        local panel = nodeMode:getChildByName( string.format("Panel_%d",i) )
        if panel then
            panel:getChildByName("Text_gm1"):setString( str[i] )
            local signBtn = panel:getChildByName("Button_1")
            signBtn:getChildByName("Text_y1_0"):setString( str[i] .. g_tr("city_battle_sign") )
            signBtn.index = i
            if self.signData then
                --报名属于当前城池，则所有按钮禁用（已经报名的按钮文字增加报名描述）
                if tonumber(self.cityId) == tonumber(self.signData.city_id) then
                    signBtn:setEnabled(false)
                    if tonumber(self.signData.sign_type) == signBtn.index then
                        local tx = signBtn:getChildByName("Text_y1_0")
                        tx:setString( string.format("%s(%s)", str[i].. g_tr("city_battle_sign"),g_tr("city_battle_alread_sign")) )
                    end
                else--报名不属于当前城池，则报名标志按钮显示切换，其他按钮禁用
                    if tonumber(self.signData.sign_type) ~= signBtn.index then
                        signBtn:setEnabled(false)
                    else
                        local tx = signBtn:getChildByName("Text_y1_0")
                        tx:setString( string.format("%s(%s)", str[i].. g_tr("city_battle_sign"),g_tr("millSwitchRank")) )
                    end
                end
            end

            signBtn:addClickEventListener(handler(self,self[string.format("_TouchSign%d",i)]))
            panel:getChildByName("Panel_renw"):getChildByName("Image_3"):loadTexture(pic[i])

            local numTx = panel:getChildByName("Text_nn1")
            numTx:setString(g_tr("city_battle_sign_num") .. self.nData[i] )
            table.insert( self.numTxs,numTx)

            local timeTx = panel:getChildByName("Text_nn2")
            table.insert( self.timeTxs,timeTx)

            if i < 3 then
                local itemId = itemIds[i]
                local itemRes = g_resManager.getResPath(g_data.item[itemId].res_icon)
                panel:getChildByName("Image_pic"):loadTexture(itemRes)
                signBtn.upRes = function ()
                    local itemId = itemIds[i]
                    local num = g_BagMode.findItemNumberById(itemId)
                    local tx = panel:getChildByName("Text_nn2_0")
                    tx:setString(string.format("%d/%d",num,1))
                    if num >= 1 then
                        tx:setTextColor(cc.c3b(30,230,30))
                    else
                        tx:setTextColor(cc.c3b(230,30,30))
                    end
                end
                signBtn.upRes()
            end

            table.insert(self.signBtns,signBtn)
        end
    end
    self.list:pushBackCustomItem(nodeMode)
    self:_GetOverTime()
    self:_UpdateTime()
    if self.timer == nil then
        self.timer = self:schedule(handler(self,self._UpdateTime),1)
    end

end

function CitySign:_Sign(index,fun)
    local function onRecv(result,msgData)
        g_busyTip.hide_1()
        if result == true then
            g_airBox.show(g_tr("signSucc"))
            for key, var in ipairs(self.signBtns) do
                if key == index then
                    local tx = var:getChildByName("Text_y1_0")
                    tx:setString( string.format("%s(%s)", str[key].. g_tr("city_battle_sign"),g_tr("city_battle_alread_sign")) )
                end
                var:setEnabled(false)
            end

            CityBattleMode:SetSignData(msgData.player)
            self.signData = msgData.player
            self.nData = clone(msgData.signNum[tostring(self.campId)])
            self:upDateNumTxs()

            if fun then
                fun()
            end
        end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("city_battle/signCityBattle", { cityId = self.cityId , signType = index }, onRecv, true)
end

function CitySign:_ChangeSign()
    local function onRecv(result,msgData)
        g_busyTip.hide_1()
        if result == true then
            g_airBox.show(g_tr("signSucc"))
            for key, var in ipairs(self.signBtns) do
                if self.signData.sign_type and tonumber(self.signData.sign_type) == key then
                    local tx = var:getChildByName("Text_y1_0")
                    tx:setString( string.format("%s(%s)",  str[key].. g_tr("city_battle_sign"),g_tr("city_battle_alread_sign")) )
                end
                var:setEnabled(false)
            end

            CityBattleMode:SetSignData(msgData.player)
            self.signData = msgData.player
            self.nData = clone(msgData.signNum[tostring(self.campId)])
            self:upDateNumTxs()
        end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("city_battle/changeSignCity", { cityId = self.cityId }, onRecv, true)
end

function CitySign:_TouchSign1(sender)

    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

    local singInfo = CityBattleMode:GetPrepareInfo()

    --诸侯报名与普通报名都可以切换
    if singInfo.status == g_Consts.CityBattleStatus.SIGN_FIRST or singInfo.status == g_Consts.CityBattleStatus.SIGN_NORMAL then
        if self.signData --[[and self.signData.]] then
            self:_ChangeSign()
            return
        end
    end

    if singInfo.status == g_Consts.CityBattleStatus.SIGN_FIRST then
       
        local totalRmb = tonumber(g_PlayerMode.GetData().total_rmb)
        local needTotalRmb = tonumber(g_data.country_basic_setting[17].data)

        if totalRmb < needTotalRmb then
            g_airBox.show(g_tr("city_battle_sign_noprince"))
            return
        end

        local itemId = tonumber(g_data.country_basic_setting[66].data)
        local num = g_BagMode.findItemNumberById(itemId)
        if num <= 0 then
            local itemConfig = g_data.item[itemId]
            local callfun = function ()
                self:_Sign(sender.index,sender.upRes)
            end
            self:_BuyItem(2091,itemConfig,callfun)
            return
        end

        self:_Sign(sender.index,sender.upRes)
    else
        if singInfo.status == g_Consts.CityBattleStatus.NOT_START then
            g_airBox.show( g_tr("city_battle_sign") .. g_tr("city_battle_sign_noopen") )
        else
            g_airBox.show( g_tr("city_battle_sign") .. g_tr("zhuanpanOver") )
        end
    end
end

function CitySign:_TouchSign2(sender)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local singInfo = CityBattleMode:GetPrepareInfo()
    if singInfo.status == g_Consts.CityBattleStatus.SIGN_NORMAL then
        
        if self.signData --[[and self.signData.]] then
            self:_ChangeSign()
            return
        end

        local itemId = tonumber(g_data.country_basic_setting[18].data)
        local num = g_BagMode.findItemNumberById(itemId)
        if num <= 0 then
            local itemConfig = g_data.item[itemId]
            local callfun = function ()
                self:_Sign(sender.index,sender.upRes)
            end
            self:_BuyItem(2090,itemConfig,callfun)
            return
        end

        self:_Sign(sender.index,sender.upRes)

    else
        if singInfo.status == g_Consts.CityBattleStatus.NOT_START or singInfo.status == g_Consts.CityBattleStatus.SIGN_FIRST then
            g_airBox.show(g_tr("city_battle_sign") .. g_tr("city_battle_sign_noopen") )
        else
            g_airBox.show(g_tr("city_battle_sign") .. g_tr("zhuanpanOver") )
        end
    end
end

function CitySign:_TouchSign3(sender)
    
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

    local singInfo = CityBattleMode:GetPrepareInfo()
    if singInfo.status == g_Consts.CityBattleStatus.SIGN_NORMAL then
        if self.signData --[[and self.signData.]] then
            self:_ChangeSign()
            return
        end
        self:_Sign(sender.index)
    else
        if singInfo.status == g_Consts.CityBattleStatus.NOT_START or singInfo.status == g_Consts.CityBattleStatus.SIGN_FIRST then
            g_airBox.show(g_tr("city_battle_sign") .. g_tr("city_battle_sign_noopen") )
        else
            g_airBox.show(g_tr("city_battle_sign") .. g_tr("zhuanpanOver") )
        end
    end
end


function CitySign:_GetOverTime()
    self.startTime,self.endTime = CityBattleMode:GetSignOverTime()
    if self.endTime == nil then
        self.time = self.startTime
    end

    if self.startTime == nil then
        self.time = self.endTime
    end
end

function CitySign:_UpdateTime()
    --self.overTime = self.overTime or 0
    --self.overTime = self.overTime - 1
    if self.time == nil then
        return
    end

    local time = self.time - g_clock.getCurServerTime()

    local singInfo = CityBattleMode:GetPrepareInfo()
    if singInfo.status == g_Consts.CityBattleStatus.SIGN_FIRST then
        for index, var in ipairs(self.timeTxs) do
            if index == 1 then
                var:setString( g_tr("leftTime") .. g_gameTools.convertSecondToString(time))
            else
                var:setString( g_tr("leftTime") .. g_tr("city_battle_sign_noopen"))
            end
        end
    elseif singInfo.status == g_Consts.CityBattleStatus.SIGN_NORMAL then
        for index, var in ipairs(self.timeTxs) do
            if index == 1 then
                var:setString( g_tr("leftTime") .. g_tr("city_battle_sign") .. g_tr("zhuanpanOver") )
            else
                var:setString( g_tr("leftTime") .. g_gameTools.convertSecondToString(time))
            end
        end
    else
        for _, var in ipairs(self.timeTxs) do
            if singInfo.status == g_Consts.CityBattleStatus.NOT_START then
                var:setString( g_tr("leftTime") .. g_tr("city_battle_sign_noopen"))
            else
                var:setString( g_tr("leftTime") .. g_tr("city_battle_sign") .. g_tr("zhuanpanOver") )
            end
        end
    end

    if time <= 0 then
        time = 0
        if self.timer then
            self:unschedule(self.timer)
            self.timer = nil
            g_airBox.show( g_tr("city_battle_sign") .. g_tr("zhuanpanOver") )
            self:close()
            --require("game.uilayer.cityBattle.CityShow").UpdateTimeTx()
            --self:_UpdateTime()
        end
    end
end

function CitySign:upDateNumTxs()
    
    if self.nData == nil or self.nData == false then
        return
    end

    for i, numTx in ipairs(self.numTxs) do
        numTx:setString(g_tr("city_battle_sign_num") .. self.nData[i] )
    end

    local signCount = (self.nData[1] or 0) + (self.nData[2] or 0)
    local maxCount = g_data.country_city_map[tonumber(self.cityId)].join_max_num
    self.signNumTx:setString( string.format("%s%d/%d",g_tr("city_battle_sign_count"),signCount,maxCount) )

    require("game.uilayer.cityBattle.CityMap").UpdateSign()

end

function CitySign:onExit()
    if self.timer then
        self:unschedule(self.timer)
    end
    self.timer = nil
end


function CitySign:_BuyItem(shopId,itemConfig,fun)
    local costGroup = g_gameTools.getCostsByCostId(g_data.shop[shopId].cost_id,1)
    if costGroup == nil then
        return
    end
    local costNum = costGroup[1].cost_num

    local function isBuy()
        local mode = require("game.uilayer.publicMode.UseActions").new()
        if mode:shopBuy(shopId,1) then
            if fun then
                fun()
            end
        end
    end
    
    g_msgBox.showConsume(costNum, g_tr("shopBuyCostLimit",{ name = g_tr(itemConfig.item_name)}) .. g_tr("city_battle_buy"), nil, g_tr("queue_buy"),isBuy)
    
end

return CitySign
