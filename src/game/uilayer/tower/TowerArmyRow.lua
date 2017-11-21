--region TowerArmyRow.lua
--Author : luqingqing
--Date   : 2015/11/17
--此文件由[BabeLua]插件自动生成

local TowerArmyRow = class("TowerArmyRow", function()
    return ccui.Widget:create()
end)

function TowerArmyRow:ctor()
    self.layout = cc.CSLoader:createNode("tower_popup_army_row.csd")

    self:setContentSize(cc.size(self.layout:getContentSize().width, self.layout:getContentSize().height))

    self:addChild(self.layout)
    self.root = self.layout:getChildByName("scale_node")

end

return TowerArmyRow

--endregion
