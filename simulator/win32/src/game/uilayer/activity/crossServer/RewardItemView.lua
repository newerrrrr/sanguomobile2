local RewardItemView = class("RewardItemView", require("game.uilayer.base.BaseWidget"))

function RewardItemView:ctor(data, txt)
	self.layer = self:LoadUI("activity3_popup1_list1.csb")

	self.Image_1_0 = self.layer:getChildByName("Image_1_0")
	self["Text_1"] = self.layer:getChildByName("Text_1")
	self["Text_5"] = self.layer:getChildByName("Text_5")

	local item = require("game.uilayer.common.DropItemView").new(data[1], data[2], data[3])
	self.Image_1_0:addChild(item)
	item:setPosition(item:getContentSize().width/2, item:getContentSize().height/2)
	item:enableTip()

	self.Text_1:setString(item:getName())
	self.Text_5:setString(txt)
end

return RewardItemView