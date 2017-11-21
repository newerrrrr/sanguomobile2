local MatchRecordView = class("MatchRecordView", require("game.uilayer.base.BaseLayer"))

function MatchRecordView:ctor(data)
	MatchRecordView.super.ctor(self)

	self.layer = self:loadUI("activity3_popup2.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.close_btn = self.root:getChildByName("close_btn")
	self.text = self.root:getChildByName("bg_goods_name"):getChildByName("text")
	self.ListView_1 = self.root:getChildByName("ListView_1")

	self.text:setString(g_tr("allianceBattleReport"))
	self.data = data

	self:addEvent()
	self:init()
end

function MatchRecordView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)
end

function MatchRecordView:init()
	for i=1, #self.data do
		local item = require("game.uilayer.activity.crossServer.RecordItemView").new(self.data[i])

		self.ListView_1:pushBackCustomItem(item)
	end
end

return MatchRecordView