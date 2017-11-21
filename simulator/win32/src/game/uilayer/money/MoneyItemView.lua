--region MoneyItemView.lua
--Author : luqingqing
--Date   : 2016/4/9
--此文件由[BabeLua]插件自动生成

local MoneyItemView = class("MoneyItemView")

function MoneyItemView:ctor(ui, data, desc)
    self.ui = ui
    self.data = data
    self.name = self.ui:getChildByName("name")
    self.Image_9 = self.ui:getChildByName("Image_9")
    self.Image_10 = self.ui:getChildByName("Image_10")
    self.Button_7 = self.ui:getChildByName("Button_7")
    self.Text_1 = self.Button_7:getChildByName("Text_1")
    self.Text_2 = self.ui:getChildByName("Text_2")
    if desc ~= nil then
        self.Text_3 = self.ui:getChildByName("Text_3")
        self.Text_3:setString(desc)
    end
    

    self:addEvent()
    self:show()
end

function MoneyItemView:show()
    if self.data == nil then
        self.ui:setVisible(false)
        return
    end

    local pData = g_data.pricing[tonumber(self.data.id)]
    self.playerInfo = g_playerInfoData.GetData()

    self.name:setString(g_tr(pData.desc))
    self.Text_1:setString(g_channelManager.GetMoneyType(pData.type)..pData.price)
    if pData.goods_type == 1 then
        local tag = false
        for key, value in pairs(self.playerInfo.first_pay) do
            if tonumber(pData.gift_type) == tonumber(value) then
                tag = true
                break
            end
        end

        if tag == false then
            self.Text_2:setString(g_tr("priceType1fc", {money=pData.first_add_count}))
        else
            self.Text_2:setString(g_tr("priceType1nor", {money=pData.add_count}))
        end
        
    elseif pData.goods_type == 2 then
        self.Text_2:setString(g_tr("priceType2", {money = g_data.starting[65].data}))
    elseif pData.goods_type == 3 then
        if self.playerInfo.month_card_deadline == 0 then
            self.Text_2:setString(g_tr("priceType3", {money = g_data.starting[64].data}))
        else
            self:processTime()
        end
    end
end

function MoneyItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:pay()
        end
    end

    self.Button_7:addTouchEventListener(proClick)
end

function MoneyItemView:pay()
    if (#g_channelManager.GetPayWayList()) == 1 then
        if self.data == nil then
            return
        end

        if self.data.aci == nil then
            self.data.aci = 0
        end
        print(self.data.id, self.data.aci, g_channelManager.GetPayWayList()[1])
        g_moneyData.RequestData(self.data.id, self.data.aci, g_channelManager.GetPayWayList()[1])
    else
        g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyTypeView").new(self.data.id))
    end
end


function MoneyItemView:processTime()
    local function updateTime()
        local time = self.playerInfo.month_card_deadline - g_clock.getCurServerTime()
        if time <= 0 then
            self:unschedule(self.time)
            self.time = nil
            return
        end

        self.Text_2:setString(g_gameTools.convertSecondToString(time))
    end

    self.needTime = self.playerInfo.month_card_deadline - g_clock.getCurServerTime()
    if self.needTime > 0 then
        self.time = self:schedule(updateTime, 1.0)
        updateTime()
    else
        self.Text_2:setString(g_tr("priceType3", {money = g_data.starting[64].data}))
    end
end

function MoneyItemView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self.ui:runAction(action)
  return action
end 

function MoneyItemView:unschedule(action)
  self.ui:stopAction(action)
end

return MoneyItemView

--endregion
