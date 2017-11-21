local BattleHeroInfoView = class("BattleHeroInfoView", require("game.uilayer.base.BaseLayer"))

function BattleHeroInfoView:ctor(data)
	BattleHeroInfoView.super.ctor(self)

	self.data = data
	
	self.layer = self:loadUI("HistoryReport_ReportDetails_battle_content_pop.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.text = self.root:getChildByName("text")
	self.btn_close = self.root:getChildByName("btn_close")
	self.ListView_1 = self.root:getChildByName("ListView_1")
	self.Text_1 = self.root:getChildByName("Text_1")

	self.text:setString(g_tr("playerTroop"))

	self:addEvent()
	self:setData()
end

function BattleHeroInfoView:setData()

	local buff = g_BuffMode.GetData()

	if buff["noob_protection"] ~= nil and buff["noob_protection"].v ~= 0 then
		self.Text_1:setString(g_tr("getOtherInfo"))
	else
		self.Text_1:setString("")
	end

	for key, value in pairs(self.data.unit) do
		if key ~= "trap" then
			if self.data.key == "npc" then
				local view = require("game.uilayer.battleHall.BattleHeroInfoItemView").new(value, "npc")
				self.ListView_1:pushBackCustomItem(view)
			else
				local view = require("game.uilayer.battleHall.BattleHeroInfoItemView").new(value, "player")
				self.ListView_1:pushBackCustomItem(view)
			end
		end
	end

	if self.data.unit.trap ~= nil then
		for i=1,#self.data.unit.trap do
			local view = require("game.uilayer.battleHall.BattleHeroInfoItemView").new(self.data.unit.trap[i], "trap")
			self.ListView_1:pushBackCustomItem(view)
		end
	end
end

function BattleHeroInfoView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.btn_close then
				self:close()
			end
		end
	end

	self.btn_close:addTouchEventListener(proClick)
end

return BattleHeroInfoView