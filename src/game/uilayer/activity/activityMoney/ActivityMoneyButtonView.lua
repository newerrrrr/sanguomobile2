local ActivityMoneyButtonView = class("ActivityMoneyButtonView", function() 
	return cc.Sprite:create()
end)

function ActivityMoneyButtonView:ctor()
	self.layer = cc.CSLoader:createNode("AdvertisingGifts_anniu.csb")
  	self:addChild(self.layer)
	self.Image_fy1 = self.layer:getChildByName("Image_fy1")
end

function ActivityMoneyButtonView:show(value)
	self.Image_fy1:setVisible(value)
end

return ActivityMoneyButtonView