local BattleRecordResourceView = class("BattleRecordResourceView", require("game.uilayer.base.BaseWidget"))

function BattleRecordResourceView:ctor(data)
	self.data = data

	self.layer = self:LoadUI("HistoryReport_ReportDetails_content_1.csb")

	self.root = self.layer:getChildByName("rewards")
	self.text_01 = self.root:getChildByName("text_01")
	self.text_01_0 = self.root:getChildByName("text_01_0")
	for i=1, 5 do
		self["num_"..i] = self.root:getChildByName("num_"..i)
	end

	self.text_01:setString(g_tr("Resources"))
	self.text_01_0:setString((self.data.gold + self.data.food + self.data.wood + self.data.stone + self.data.iron).."")
	self.num_1:setString(self.data.gold.."")
	self.num_2:setString(self.data.food.."")
	self.num_3:setString(self.data.wood.."")
	self.num_4:setString(self.data.stone.."")
	self.num_5:setString(self.data.iron.."")
end

return BattleRecordResourceView