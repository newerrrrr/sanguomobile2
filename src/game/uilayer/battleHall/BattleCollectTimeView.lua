--region BattleCollectTimeView.lua
--Author : luqingqing
--Date   : 2015/12/4
--此文件由[BabeLua]插件自动生成

local BattleCollectTimeView = class("BattleCollectTimeView", require("game.uilayer.base.BaseLayer"))

function BattleCollectTimeView:ctor(click)
    BattleCollectTimeView.super.ctor(self)
    self.callback = click
    self:initUI()
end

function BattleCollectTimeView:initUI()
    self.layout = self:loadUI("alliance_Aggregation.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_2 = self.root:getChildByName("Text_2")
    self.Text_1:setString(g_tr("collectTime"))

    self.Button_1 = self.root:getChildByName("Button_1")
    self.b1_txt = self.Button_1:getChildByName("Text_3")
    self.Button_2 = self.root:getChildByName("Button_2")
    self.b2_txt = self.Button_2:getChildByName("Text_3")
    self.Button_3 = self.root:getChildByName("Button_3")
    self.b3_txt = self.Button_3:getChildByName("Text_3")
    self.Button_4 = self.root:getChildByName("Button_4")
    self.b4_txt = self.Button_4:getChildByName("Text_3")

    self.b1_txt:setString((g_data.starting[32].data/60)..g_tr("minute"))
    self.b2_txt:setString((g_data.starting[34].data/60)..g_tr("minute"))
    self.b3_txt:setString((g_data.starting[33].data/60)..g_tr("minute"))
    self.b4_txt:setString((g_data.starting[35].data/60)..g_tr("minute"))

    self.Text_2:setString(g_tr("collectTypeInfo"))

    self:addEvent()
end

function BattleCollectTimeView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                 g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.callback(1)
            elseif sender == self.Button_2  then
                 g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.callback(3)
            elseif sender == self.Button_3 then
                 g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.callback(2)
            elseif sender == self.Button_4 then
                 g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.callback(4)
            elseif sender == self.close_btn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            end
            self:close()
        end
    end

    self.Button_1:addTouchEventListener(proClick)
    self.Button_2:addTouchEventListener(proClick)
    self.Button_3:addTouchEventListener(proClick)
    self.Button_4:addTouchEventListener(proClick)
    self.close_btn:addTouchEventListener(proClick)
end

return BattleCollectTimeView

--endregion
