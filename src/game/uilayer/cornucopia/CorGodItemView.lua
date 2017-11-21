local CorGodItemView = class("CorGodItemView", require("game.uilayer.base.BaseWidget"))

function CorGodItemView:ctor(type, updateData)
	self.type = type

	self.updateData = updateData

	self.layer = self:LoadUI("jitian_Panel_list"..self.type..".csb")
	self.Panel_1 = self.layer:getChildByName("Panel_1")
	self.Text_1 = self.Panel_1:getChildByName("Text_1")
	self.Text_1:setString(g_tr("enterGodInto"))

	self:addEvent()
end

function CorGodItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Panel_1 then
				g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CorShowGeneralView").new(self.type, self.updateData))
			end
		end
	end
	self.Panel_1:addTouchEventListener(proClick)
end

return CorGodItemView