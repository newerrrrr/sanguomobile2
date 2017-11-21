local BattleRecordDamageTitle = class("BattleRecordDamageTitle", require("game.uilayer.base.BaseWidget"))

function BattleRecordDamageTitle:ctor()
	self.layer = self:LoadUI("HistoryReport_ReportDetails_content_10.csb")

	for i=1, 6 do
		self["text_0"..i] = self.layer:getChildByName("text_0"..i)
	end

	self.text_01:setString(g_tr("attack"))
	self.text_02:setString(g_tr("makeDamage"))
	self.text_03:setString(g_tr("sufferDamage"))
	self.text_04:setString(g_tr("defense"))
	self.text_05:setString(g_tr("makeDamage"))
	self.text_06:setString(g_tr("sufferDamage"))
end

return BattleRecordDamageTitle