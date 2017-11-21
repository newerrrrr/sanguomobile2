local BattleGodInfoView = class("BattleGodInfoView", require("game.uilayer.base.BaseLayer"))

function BattleGodInfoView:ctor(data, player1, player2)
	BattleGodInfoView.super.ctor(self)

	self.data = data

	self.player1 = player1
	self.player2 = player2

	self.layer = self:loadUI("mail_battle_content_pop.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.text = self.root:getChildByName("text")
	self.btn_close = self.root:getChildByName("btn_close")
	self.ListView_1 = self.root:getChildByName("ListView_1")

	self.text:setString(g_tr("playerTroop"))

	self:addEvent()
	self:setData()
end

function BattleGodInfoView:setData()
	for i=1, #self.data do
		local item = require("game.uilayer.battleHall.BattleGodInfoItemView").new(self.data[i], self.player1, self.player2)
		self.ListView_1:pushBackCustomItem(item)
	end
end

function BattleGodInfoView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.btn_close then
				self:close()
			end
		end
	end

	self.btn_close:addTouchEventListener(proClick)
end

return BattleGodInfoView