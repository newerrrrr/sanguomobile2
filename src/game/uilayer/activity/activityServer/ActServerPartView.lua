local ActServerPartView = class("ActServerPartView", require("game.uilayer.base.BaseWidget"))

function ActServerPartView:ctor(idx, clickCallback)
	self.idx = idx

	self.data = g_data.activity[self.idx]

	self.clickCallback = clickCallback

	self.layer = self:LoadUI("activity3_parts.csb")

	self.Image_huodong = self.layer:getChildByName("Image_huodong")
	self.Image_2 = self.layer:getChildByName("Image_2")
	self.Text_1 = self.layer:getChildByName("Text_1")
	self.Image_3 = self.layer:getChildByName("Image_3")
	self.Panel_dj = self.layer:getChildByName("Panel_dj")

	self.Image_2:setVisible(false)
	self.Image_3:setVisible(false)

	self.Text_1:setString(g_tr(self.data.activity_name))
	self.Image_huodong:loadTexture(g_resManager.getResPath(self.data.type_icon))

	self:addEvent()
end

function ActServerPartView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Panel_dj then
				if self.clickCallback ~= nil then
					self.clickCallback(self.idx)
				end
			end
		end
	end

	self.Panel_dj:addTouchEventListener(proClick)
end

function ActServerPartView:isSelected(value)
	self.Image_2:setVisible(value)
end

function ActServerPartView:showTip(value)
	self.Image_3:setVisible(value)
end

return ActServerPartView