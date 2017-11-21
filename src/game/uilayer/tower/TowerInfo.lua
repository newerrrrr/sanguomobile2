--region TowerInfo.lua
--Author : luqingqing
--Date   : 2015/11/16
--此文件由[BabeLua]插件自动生成

local TowerInfo = class("TowerInfo", require("game.uilayer.base.BaseLayer"))

function TowerInfo:ctor()
    TowerInfo.super.ctor(self)

    self.layer = self:loadUI("tower_popup_msg.csb")

    self.root = self.layer:getChildByName("scale_node")

    self.close_btn = self.root:getChildByName("close_btn")

    self.bg_content = self.root:getChildByName("bg_content")
    self.player_pic = self.bg_content:getChildByName("player_pic")
    self.player_name = self.bg_content:getChildByName("player_name")
    self.player_level = self.bg_content:getChildByName("player_level")
    self.Text_3 = self.bg_content:getChildByName("Text_3")
    self.Text_2 = self.bg_content:getChildByName("Text_2")
    self.ListView_1 = self.bg_content:getChildByName("ListView_1")

    self:addEvent()
end

function TowerInfo:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
end

return TowerInfo

--endregion
