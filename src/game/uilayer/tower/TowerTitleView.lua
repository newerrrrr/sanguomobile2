--region TowerTitleView.lua
--Author : luqingqing
--Date   : 2015/12/31
--此文件由[BabeLua]插件自动生成

local TowerTitleView = class("TowerTitleView", require("game.uilayer.base.BaseWidget"))

function TowerTitleView:ctor(key, value, visible)
    self.layout = self:LoadUI("tower_popup_title.csb")
    self.root = self.layout:getChildByName("scale_node")
    self.Image_1 = self.root:getChildByName("Image_1")
    self.title_text_left = self.root:getChildByName("title_text_left")
    self.title_text_right = self.root:getChildByName("title_text_right")

    self.Image_1:setVisible(visible)
    self.title_text_left:setString(key.."")
    if value == nil or value == 0 then
    	self.title_text_right:setString("")
    else
    	self.title_text_right:setString(value.."")
    end
    
end

return TowerTitleView

--endregion
