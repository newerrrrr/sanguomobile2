local WheelHelpView = class("WheelHelpView", require("game.uilayer.base.BaseLayer"))

function WheelHelpView:ctor(value)
	WheelHelpView.super.ctor(self)

	self.layer = self:loadUI("LargeTurntable_main2.csb")
	self.mask = self.layer:getChildByName("mask")
	self.root = self.layer:getChildByName("scale_node")

	self.Text_c2 = self.root:getChildByName("Text_c2")
	self.Text_2_0 = self.root:getChildByName("Text_2_0")
	self.ListView_1 = self.root:getChildByName("ListView_1")
	self.Text_nr =self.ListView_1:getChildByName("Text_nr")

	self.Text_c2:setString(g_tr("wheelInfo"))
	self.Text_2_0:setString(g_tr("clickhereclose"))

--[[
	if self.txtRich == nil then
		self.txtRich = g_gameTools.createRichText(self.Text_nr, "")
	end

	self.txtRich:setRichText(value)
]]

	self.Text_nr:setString(value)
	self.Text_nr:setContentSize(cc.size(600,400))
	self:addEvent()
end

function WheelHelpView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.mask then
				self:close()
			end
		end
	end

	self.mask:addTouchEventListener(proClick)
end

return WheelHelpView