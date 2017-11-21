--region TowerProp.lua
--Author : luqingqing
--Date   : 2015/11/17
--此文件由[BabeLua]插件自动生成

local TowerProp = class("TowerProp", function() 
    return ccui.Widget:create()
end)

function TowerProp:ctor()
    self.layout = cc.CSLoader:createNode("tower_popup_prop.csd")

    self:setContentSize(cc.size(self.layout:getContentSize().width, self.layout:getContentSize().height))

    self:addChild(self.layout)
    self.root = self.layout:getChildByName("scale_node")

    self.Text_prop_1 = self.root:getChildByName("Text_prop_1")
    self.Text_prop_2 = self.root:getChildByName("Text_prop_2")
    self.Text_prop_3 = self.root:getChildByName("Text_prop_3")
end

return TowerProp

--endregion
