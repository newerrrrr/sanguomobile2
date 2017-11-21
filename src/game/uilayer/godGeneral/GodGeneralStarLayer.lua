--region 升星
--Author : liuyi
--Date   : 2016/10/28
local GodGeneralStarLayer = class("GodGeneralStarLayer",require("game.uilayer.base.BaseLayer"))

function GodGeneralStarLayer:ctor()
    GodGeneralStarLayer.super.ctor(self)
    self:initUI()
end

function GodGeneralStarLayer:initUI()
    self.layer = self:loadUI("GodGenerals_RisingStar.csb")
    self.root = self.layer:getChildByName("scale_node")
end


return GodGeneralStarLayer