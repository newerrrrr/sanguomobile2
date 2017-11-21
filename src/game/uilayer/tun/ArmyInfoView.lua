--region ArmyInfoView.lua
--Author : luqingqing
--Date   : 2015/12/30
--此文件由[BabeLua]插件自动生成

local ArmyInfoView = class("ArmyInfoView", require("game.uilayer.base.BaseLayer"))

function ArmyInfoView:ctor(data)
    ArmyInfoView.super.ctor(self)

    self.data = data

    self.layout = self:loadUI("tunsuo_panel.csb")
    self.root = self.layout:getChildByName("scale_node")
    self.bg_goods_name_0_0 = self.root:getChildByName("bg_goods_name_0_0")
    self.text = self.bg_goods_name_0_0:getChildByName("text")
    self.close_btn_0 = self.root:getChildByName("close_btn_0")
    self.ListView_1 = self.root:getChildByName("ListView_1")

    self.text:setString(g_tr_original("tuoDetai"))

    self:addEvent()
    self:setData()
end

function ArmyInfoView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn_0 then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            end
        end
    end

    self.close_btn_0:addTouchEventListener(proClick)
end

function ArmyInfoView:setData()
    for i=1, #self.data.army do
        local item = require("game.uilayer.tun.ArmyInfoItemView").new(self.data.army[i])

        self.ListView_1:pushBackCustomItem(item)
    end
end

return ArmyInfoView

--endregion
