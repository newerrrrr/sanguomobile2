--region NewFile_1.lua
--Author : luqingqing
--Date   : 2016/3/24
--此文件由[BabeLua]插件自动生成

local TowerPlayerView = class("TowerPlayerView", require("game.uilayer.base.BaseWidget"))

function TowerPlayerView:ctor(data)
    self.data = data

    --dump(self.data)

    self.layer = self:LoadUI("tower_popup_army_row_1.csb")
    self.root = self.layer:getChildByName("scale_node")

    self.player_pic_0 = self.root:getChildByName("player_pic_0")
    self.player_pic = self.root:getChildByName("player_pic")
    self.player_name = self.root:getChildByName("player_name")
    self.player_level = self.root:getChildByName("player_level")
    self.Text_3 = self.root:getChildByName("Text_3")
    self.Text_jijie = self.root:getChildByName("Text_jijie")

    local iconid = g_data.res_head[self.data.avatar_id].head_icon
    self.player_pic_0:loadTexture( g_resManager.getResPath(iconid))
    self.player_pic:loadTexture(g_resManager.getResPath(1010007))
    self.player_name:setString(self.data.player_nick)
    self.player_level:setString("Lv "..self.data.level)
    self.Text_3:setString("x:"..self.data.x.."     y:"..self.data.y)
end

return TowerPlayerView

--endregion
