local BattleDamageInfoView = class("BattleDamageInfoView", require("game.uilayer.base.BaseLayer"))


function BattleDamageInfoView:ctor(data)
	BattleDamageInfoView.super.ctor(self)

	self.data = data

	self.layer = self:loadUI("mail_battle_content_pop.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.text = self.root:getChildByName("text")
	self.btn_close = self.root:getChildByName("btn_close")
	self.ListView_1 = self.root:getChildByName("ListView_1")

	self.text:setString(g_tr("playerTroop"))

	self:processData()

	self:addEvent()
	self:setData()
end

function BattleDamageInfoView:processData()
	self.max = 0

	for key, value in pairs(self.data.unit) do
		if key ~= "trap" then
			if value.doDamage > self.max then
				self.max = value.doDamage
			end

			if value.takeDamage > self.max then
				self.max = value.takeDamage
			end
		end
	end
end

function BattleDamageInfoView:setData()
	for key, value in pairs(self.data.unit) do
		if key ~= "trap" then
			local item = require("game.uilayer.battleHall.BattleDamageInfoItemView").new(value, self.max)
			self.ListView_1:pushBackCustomItem(item)
		end
	end
end

function BattleDamageInfoView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.btn_close then
				self:close()
			end
		end
	end

	self.btn_close:addTouchEventListener(proClick)
end

return BattleDamageInfoView