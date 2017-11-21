--region TowerTitle.lua
--Author : luqingqing
--Date   : 2015/11/17
--此文件由[BabeLua]插件自动生成

local TowerTitle = class("TowerTitle", function() 
    return ccui.Widget:create()
end)

function TowerTitle:ctor()
    self.layout = cc.CSLoader:createNode("tower_popup_title.csd")
    self:setContentSize(cc.size(self.layout:getContentSize().width, self.layout:getContentSize().height))
    self:addChild(self.layout)

    self.root = self.layout:getChildByName("scale_node")

    self.title_text_left = self.root:getChildByName("title_text_left")
    self.title_text_right = self.root:getChildByName("title_text_right")
end

return TowerTitle

--endregion
