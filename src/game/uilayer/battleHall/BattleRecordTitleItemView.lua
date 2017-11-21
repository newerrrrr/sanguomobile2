local BattleRecordTitleItemView = class("BattleRecordTitleItemView", require("game.uilayer.base.BaseWidget"))

function BattleRecordTitleItemView:ctor(v1, v2)
	self.layer = self:LoadUI("HistoryReport_ReportDetails_content_2.csb")

	self.label_attack = self.layer:getChildByName("label_attack")
	self.label_defense = self.layer:getChildByName("label_defense")

	self.label_attack:setString(v1.."")
	self.label_defense:setString(v2.."")
end

return BattleRecordTitleItemView