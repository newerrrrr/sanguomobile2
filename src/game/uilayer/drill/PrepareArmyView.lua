local PrepareArmyView = class("PrepareArmyView", require("game.uilayer.base.BaseLayer"))

function PrepareArmyView:ctor()
	PrepareArmyView.super.ctor(self)

	self.layer = self:loadUI("yby01.csb")

	self.root = self.layer:getChildByName("scale_node")
	self.close_btn = self.root:getChildByName("Panel_dianjiquyu")
	self.text = self.root:getChildByName("bg_goods_name"):getChildByName("text")
	self.ListView_1 = self.root:getChildByName("ListView_1")

	self.text:setString(g_tr("prepardArmy"))
	self.data = g_SoldierMode.GetData() or {}

	self:addEvent()

	self:setData()
end

function PrepareArmyView:setData()
	local showList = {}
	for key, value in pairs(self.data) do
		if value.num ~= 0 then
			table.insert(showList, value)
		end
	end

	local len = #showList
	if len%2 == 1 then
		len = math.floor(len/2) + 1
	else
		len = len/2
	end

	for i=1, len do
		local item = require("game.uilayer.drill.PrepareItemView").new()

		self.ListView_1:pushBackCustomItem(item)

		item:show(showList[i*2-1], showList[i*2])
	end
end

function PrepareArmyView:addEvent()
	local function proClick(sender , eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)
end

return PrepareArmyView