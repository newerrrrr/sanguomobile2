--region MonthCard.lua
--Author : luqingqing
--Date   : 2016/6/21
--此文件由[BabeLua]插件自动生成

local MonthCard = class("MonthCard", function()
    return cc.Layer:create()
end)

function MonthCard:ctor()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            g_gameCommon.removeEventHandler(g_Consts.CustomEvent.Money,self)
        end 
    end )
    self.mode = require("game.uilayer.activity.ActivityMode").new()
    
    self:initFun()
    self:initUI()
    self:setData()

    self:addEvent()
end

function MonthCard:initFun()
    self.getReward = function(type)
        g_airBox.show(g_tr("fetchSucess"))

        if type == 1 then
            self.Button_anniu1:setVisible(false)
            self.Button_linqu1:setVisible(false)
        else
            self.Button_anniu2:setVisible(false)
            self.Button_linqu2:setVisible(false)
        end
    end
end

function MonthCard:initUI()
    self.layer = cc.CSLoader:createNode("Card_main1.csb")
    self:addChild(self.layer)

    for i=1,7 do
        self["text_"..i] = self.layer:getChildByName("Text_"..i)
    end

    self.Button_anniu1 = self.layer:getChildByName("Button_anniu1")
    self.Button_anniu2 = self.layer:getChildByName("Button_anniu2")
    self.Button_linqu1 = self.layer:getChildByName("Button_linqu1")
    self.Button_linqu2 = self.layer:getChildByName("Button_linqu2")

    self.txtba1 = self.Button_anniu1:getChildByName("Text_35")
    self.txtba2 = self.Button_anniu2:getChildByName("Text_35")
    self.txtbl1 = self.Button_linqu1:getChildByName("Text_35")
    self.txtbl2 = self.Button_linqu2:getChildByName("Text_35")

    self.Text_nr1 = self.layer:getChildByName("Text_nr1")
    self.Text_nr2 = self.layer:getChildByName("Text_nr2")

    self.Text_time = self.layer:getChildByName("Text_time")

    self.Text_nr1:setString(g_tr("longCardDesc"))
    self.Text_nr2:setString(g_tr("monthCardDesc"))

    local channel = g_channelManager.GetPayWayList()[1]
    local p1 = ""
    local p2 = ""
    for key, value in pairs(g_data.pricing) do
        if value.channel == channel and value.goods_type == 2 and value.isshow == 1 then
            p1 = g_channelManager.GetMoneyType(value.type)..value.price
        elseif value.channel == channel and value.goods_type == 3 and value.isshow == 1 then
            p2 = g_channelManager.GetMoneyType(value.type)..value.price
        end
    end

    self.txtba1:setString(p1)
    self.txtba2:setString(p2)
    self.txtbl1:setString(g_tr("fetch2"))
    self.txtbl2:setString(g_tr("fetch2"))

    self.text_1:setString(g_tr("monthCardActivited"))
    self.text_3:setString(g_tr("monthCardGet"))
    self.text_4:setString(g_tr("monthcardData"))
    self.text_6:setString(g_tr("monthCardSend"))
    self.text_7:setString(g_tr("monthCardNotice"))

    self.text_2:setString(g_data.starting[65].data)
    self.text_5:setString(g_data.starting[64].data)
end

function MonthCard:setData()

    g_playerInfoData.RequestData()
    self.playerInfo = g_playerInfoData.GetData()
    --至尊卡
    if self.playerInfo.long_card == 0 then
        --隐藏
        self:longCardShow(false)
    else
        local day = 0
        local cr = os.date("*t", g_clock.getCurServerTime())
        local uctime = os.time({year = cr.year, month=cr.month,day=cr.day,hour=0,min=0,sec=0})
        self.Button_anniu1:setVisible(false)

        if self.playerInfo.long_card_date >= uctime then
            self.Button_linqu1:setVisible(false)
        else
            self.Button_linqu1:setVisible(true)
        end
    end

    --月卡
    if self.playerInfo.month_card_deadline == 0 then
        self:monthCardShow(false)
        self.Text_time:setString("")
    else
        local day = 0
        local cr = os.date("*t", g_clock.getCurServerTime())
        local uctime = os.time({year = cr.year, month=cr.month,day=cr.day,hour=0,min=0,sec=0})
        self.Button_anniu2:setVisible(false)

        if self.playerInfo.month_card_deadline > uctime then
            if uctime - self.playerInfo.month_card_date > 0 then
                self.Button_linqu2:setVisible(true)
            else
                self.Button_linqu2:setVisible(false)
            end

            self:showTime()
        else
            self:monthCardShow(false)
            self.Text_time:setString("")
        end
    end
end

function MonthCard:showTime()
    local function updateTime()
        local dt = self.playerInfo.month_card_deadline - g_clock.getCurServerTime()

        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.time)
            self.time = nil
        end

        self.Text_time:setString(g_gameTools.convertSecondToString(dt))      
    end

    if self.time ~= nil then
        self:unschedule(self.time)
        self.time = nil
    end

    self.needTime = self.playerInfo.month_card_deadline - g_clock.getCurServerTime()

    if self.needTime > 0 then
        self.time = self:schedule(updateTime, 1.0)
        updateTime()
    end
end

function MonthCard:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_anniu1 then
                g_moneyData.payProduct(2)
            elseif sender == self.Button_anniu2 then
                g_moneyData.payProduct(3)
            elseif sender == self.Button_linqu1 then
                self.mode:getLongCardAward(self.getReward)
            elseif sender == self.Button_linqu2 then
                self.mode:getMonthCardAward(self.getReward)
            end
        end
    end

    local function update()
        self:setData()
    end

    self.Button_anniu1:addTouchEventListener(proClick)
    self.Button_linqu1:addTouchEventListener(proClick)
    self.Button_anniu2:addTouchEventListener(proClick)
    self.Button_linqu2:addTouchEventListener(proClick)

    g_gameCommon.addEventHandler(g_Consts.CustomEvent.Money, update, self)
end

function MonthCard:longCardShow(value)
    self.Button_anniu1:setVisible(not value)
    self.Button_linqu1:setVisible(value)
end

function MonthCard:monthCardShow(value)
    self.Button_anniu2:setVisible(not value)
    self.Button_linqu2:setVisible(value)
end

function MonthCard:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self.layer:runAction(action)
  return action
end 

function MonthCard:unschedule(action)
  self.layer:stopAction(action)
end

return MonthCard
--endregion
