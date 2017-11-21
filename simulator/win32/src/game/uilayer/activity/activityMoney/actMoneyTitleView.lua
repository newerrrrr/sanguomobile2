local actMoneyTitleView = class("actMoneyTitleView", require("game.uilayer.base.BaseWidget"))

function actMoneyTitleView:ctor()
	self.layer = self:LoadUI("activity2_Package3.csb")

	self.Text_1 = self.layer:getChildByName("Text_1")

	self.Text_1:setString(g_tr("actMoneyTitle"))
end

function actMoneyTitleView:setContent(value)
	self.Text_1:setString(value)
end

return actMoneyTitleView