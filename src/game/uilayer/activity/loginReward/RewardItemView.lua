local RewardItemView = class("RewardItemView", require("game.uilayer.base.BaseWidget"))

function RewardItemView:ctor(data)
	self.layer = self:LoadUI("Cumulative_main1_list2.csb")
	self.Image_1 = self.layer:getChildByName("Image_1")

	local item = require("game.uilayer.common.DropItemView").new(tonumber(data[1]),tonumber(data[2]),tonumber(data[3]))
	self.Image_1:addChild(item)
	item:setPosition(self.Image_1:getContentSize().width/2, self.Image_1:getContentSize().height/2)
	item:enableTip()
end

return RewardItemView