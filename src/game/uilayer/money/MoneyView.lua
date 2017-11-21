--region MoneyView.lua
--Author : luqingqing
--Date   : 2016/4/9
--此文件由[BabeLua]插件自动生成

local MoneyView = class("MoneyView", require("game.uilayer.base.BaseLayer"))

function MoneyView:ctor()
    MoneyView.super.ctor(self)

    g_moneyData.resetTag()

    self.layer = self:loadUI("Recharge_main.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_mingc = self.root:getChildByName("Text_mingc")
    self.Text_mingc:setString(g_tr("priceTitle"))

    self.Panel_5 = self.root:getChildByName("Panel_5")

    self.data = self:processData(g_data.pricing)

    self.uiList = {}

    self:initContent()
    self:addEvent()
end

function MoneyView:addEvent()
    local function proClick(sender , eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                g_gameCommon.removeAllEventHandlers(self)
                self:close()
            end
        end
    end

    local function onUpdateMoney()
        if self.uiList == nil  then
            return
        end
        
        for key, value in pairs(self.uiList) do
            value:show()
        end
    end
    
    self.close_btn:addTouchEventListener(proClick)
    g_gameCommon.addEventHandler(g_Consts.CustomEvent.Money, onUpdateMoney, self)
end

function MoneyView:initContent()
    for i=1, 8 do
        local ui = self.Panel_5:getChildByName("gm"..i)
        local item
        if i == 7 then
            item = require("game.uilayer.money.MoneyItemView").new(ui, self.data[i], g_tr("moneyLongCardDesc"))
        elseif i == 8 then
            item = require("game.uilayer.money.MoneyItemView").new(ui, self.data[i], g_tr("moneyMonthCardDesc"))
        else
            item = require("game.uilayer.money.MoneyItemView").new(ui, self.data[i], nil)
        end
        
        table.insert(self.uiList, item)
    end
end

function MoneyView:processData(data)
    --根据当前的下载渠道查找支付项
    local channel = g_channelManager.GetPayWayList()[1]
    local result = {}
    for i=1, #data do
        if data[i].channel == channel and data[i].isshow == 1 then
            table.insert(result, data[i])
        end
    end

    return result
end

return MoneyView

--endregion
