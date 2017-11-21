--region BattleClassItemView.lua
--Author : luqingqing
--Date   : 2015/12/4
--此文件由[BabeLua]插件自动生成

local BattleClassItemView = class("BattleClassItemView", require("game.uilayer.base.BaseWidget"))

function BattleClassItemView:ctor()
    self.layout = self:LoadUI("alliance_Members02.csb")
    self.root = self.layout:getChildByName("scale_node")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1_0 = self.root:getChildByName("Text_1_0")
end

return BattleClassItemView
--endregion
