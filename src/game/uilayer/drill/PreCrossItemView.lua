local PreCrossItemView = class("PreCrossItemView")

function PreCrossItemView:ctor(mc, data, armyData, clickCallback)
	self.layer = mc
	self.data = data

	self.clickCallback = clickCallback

	self.Text_qzsz = self.layer:getChildByName("Text_qzsz")
	self.Text_2 = self.layer:getChildByName("Text_2")
	self.ListView_1 = self.layer:getChildByName("ListView_1")
	self.Image_2faguan = self.layer:getChildByName("Image_2faguan")
	self.Image_6 = self.layer:getChildByName("Image_6")
	self.Panel_heisemengban = self.layer:getChildByName("Panel_heisemengban")

	self.Text_qzsz:setString(g_tr("corp")..g_tr("num"..armyData.position))
	self.Text_2:setString(g_tr("includeGeneral"))

	self:setSelected(false)

	self:setData()
	self:addEvent()
end

function PreCrossItemView:setData()
	for i=1, #self.data do
		local item = require("game.uilayer.drill.PreGeneralView").new(self.data[i].general_id)
		self.ListView_1:pushBackCustomItem(item)
	end
end

function PreCrossItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.layer or sender == self.ListView_1 then
				if self.clickCallback ~= nil then
					self.clickCallback(self, self.data)
				end
			end
		end
	end

	self.layer:addTouchEventListener(proClick)
	self.ListView_1:addTouchEventListener(proClick)
end

function PreCrossItemView:setSelected(value)
	self.Image_2faguan:setVisible(value)
	self.Image_6:setVisible(value)
	if value == true then
		self.Panel_heisemengban:setVisible(false)
	else
		self.Panel_heisemengban:setVisible(true)
	end
	
end

return PreCrossItemView