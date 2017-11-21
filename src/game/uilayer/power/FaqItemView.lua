local FaqItemView = class("FaqItemView", require("game.uilayer.base.BaseWidget"))

function FaqItemView:ctor()
	self.layer = self:LoadUI("power2.csb")

	self.Text_1 = self.layer:getChildByName("Text_1")

	if self.showTxt == nil then
		self.showTxt = g_gameTools.createRichText(self.Text_1,nil)
	end
end

function FaqItemView:show(value)
	self.showTxt:setRichText(g_tr(value))
end

return FaqItemView