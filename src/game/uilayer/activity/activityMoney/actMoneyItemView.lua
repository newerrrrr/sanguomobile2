--region actMoneyItemView.lua
--Author : luqingqing
--Date   : 2016/4/21
--此文件由[BabeLua]插件自动生成

local actMoneyItemView = class("actMoneyItemView", require("game.uilayer.base.BaseWidget"))

function actMoneyItemView:ctor(clickCallback)
    self.clickCallback = clickCallback

    self.layer = self:LoadUI("activity2_Package2.csb")

    self.Image_4 = self.layer:getChildByName("Image_4")
    self.Button_1 = self.layer:getChildByName("Button_1")
    self.Text_1 = self.layer:getChildByName("Text_1")
    self.Text_2 = self.layer:getChildByName("Text_2")
    self.Text_4 = self.layer:getChildByName("Text_4")
    self.Text_5 = self.layer:getChildByName("Text_5")
    self.Text_n1 = self.layer:getChildByName("Text_n1")
    self.Text_n2 = self.layer:getChildByName("Text_n2")
    self.Panel_texiao = self.layer:getChildByName("Panel_texiao")
    self.Text_webzh = self.layer:getChildByName("Text_webzh")
--[[
    local armature1 , animation1 = g_gameTools.LoadCocosAni("anime/Effect_ZiYuanLiBaoShuZi/Effect_ZiYuanLiBaoShuZi.ExportJson", "Effect_ZiYuanLiBaoShuZi")
    self.Panel_texiao:addChild(armature1)
    armature1:setPosition(cc.p(self.Panel_texiao:getContentSize().width*0.5,self.Panel_texiao:getContentSize().height*0.5))
    animation1:play("Animation1")
]]
    self.BitmapFontLabel_1 = self.layer:getChildByName("BitmapFontLabel_1")
    self.Text_2_0 = self.layer:getChildByName("Text_2_0")

    self.Text_n1:setString(g_tr("giftContain"))
    self.Text_webzh:setString(g_tr("moreRewardLook"))

    self:addEvent()
end

function actMoneyItemView:show(data)
    self.data = data
    self.content = g_data.activity_commodity[tonumber(self.data.aci)]
    self.price = g_data.pricing[tonumber(self.data.id)]

    self.Text_2_0:setString(g_tr(self.content.desc))
    if self.content.desc2 == 0 then
        self.Text_4:setString(g_tr("priceOnlyOne"))
    else
        self.Text_4:setString("")
    end
    
    self.BitmapFontLabel_1:setString(self.content.ratio.."%")
    self.Text_1:setString(g_channelManager.GetMoneyType(self.price.type)..self.content.show_price)
    self.Text_2:setString(g_channelManager.GetMoneyType(self.price.type)..self.price.price)
    self.Image_4:loadTexture(g_resManager.getResPath(self.content.gift_icon))
    self.Text_n2:setString(self.price.count.."")
    
    self:setTime()
end

function actMoneyItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Image_4 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.clickCallback ~= nil then
                    self.clickCallback(self.data)
                end
            elseif sender == self.Button_1 then
                if #g_channelManager.GetPayWayList() == 1 then
                    g_moneyData.RequestData(self.data.id, self.data.aci, g_channelManager.GetPayWayList()[1])
                else
                    g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyTypeView").new(self.data.id, self.data.aci))
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            end
        end
    end
    self.Image_4:addTouchEventListener(proClick)
    self.Button_1:addTouchEventListener(proClick)
end

function actMoneyItemView:setTime()
    local function update()
        local dt = self.data.endTime - g_clock.getCurServerTime()

        if dt <= 0 then 
            dt = 0 
            self:unschedule(self.time)
            self.time = nil
        end

        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)

        self.Text_5:setString(string.format("%02d:%02d:%02d", hour, min, sec))      
    end

    if self.time ~= nil then
        self:unschedule(self.time)
        self.time = nil
    end

    if self.data.endTime > g_clock.getCurServerTime() then 
        self.time = self:schedule(update, 1.0)
        update()
    end 
end

function actMoneyItemView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function actMoneyItemView:unschedule(action)
  self:stopAction(action)
end

return actMoneyItemView

--endregion
