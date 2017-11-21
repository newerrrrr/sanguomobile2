local BattleRecordLoseView = class("BattleRecordLoseView", require("game.uilayer.base.BaseWidget"))

function BattleRecordLoseView:ctor(p1, p2)
	self.layer = self:LoadUI("HistoryReport_ReportDetails_content_8.csb")

	for i=1,8 do
		self["Text_"..i] = self.layer:getChildByName("Text_"..i)
	end

	for i=1, 4 do
		self["Image_j"..i] = self.layer:getChildByName("Image_j"..i)
	end

	self.Text_1:setString(g_tr("powerLost"))
	self.Text_3:setString(g_tr("powerLost"))
	self.Text_5:setString(g_tr("trapLost"))
	self.Text_7:setString(g_tr("trapLost"))

	self.Text_2:setString(p1.power_lost.."")
	self.Text_4:setString(p2.power_lost.."")
	self.Text_6:setString(p1.trap_lost.."")
	self.Text_8:setString(p2.trap_lost.."")

	if p1.power_lost <= 0 then
		self["Image_j1"]:setVisible(false)
	end

	if p2.power_lost <= 0 then
		self["Image_j2"]:setVisible(false)
	end

	if p1.trap_lost <= 0 then
		self["Image_j3"]:setVisible(false)
	end

	if p2.trap_lost <= 0 then
		self["Image_j4"]:setVisible(false)
	end
end

return BattleRecordLoseView