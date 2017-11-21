local PanicItemView = class("PanicItemView", require("game.uilayer.base.BaseWidget"))

function PanicItemView:ctor(data, startTime)
	self.data = data

	self.startTime = startTime

	self.layer = self:LoadUI("activity4_mian2_list1.csb")

	self.root = self.layer:getChildByName("Panel_bj1")

	self.Text_1 = self.root:getChildByName("Text_1")
	self.Image_k1 = self.root:getChildByName("Image_k1")
	self.Text_s1 = self.root:getChildByName("Text_s1")
	self.Text_s2_0 = self.root:getChildByName("Text_s2_0")
	self.Button_1 = self.root:getChildByName("Button_1")
	self.Button_1:getChildByName("Text_5"):setString(g_tr("panicQuick"))
	self.Text_15 = self.root:getChildByName("Text_15")
	self.Text_15:setString(g_tr("noSale"))

	local item = require("game.uilayer.common.DropItemView").new(self.data.drop[1][1], self.data.drop[1][2], self.data.drop[1][3])
	self.Image_k1:addChild(item)
	item:setPosition(cc.p(self.Image_k1:getContentSize().width/2, self.Image_k1:getContentSize().height/2))
	item:enableTip()

	self.Text_1:setString(item:getName())
	self.Text_s1:setString(self.data.price.."")
	--当前购买了多少次
	self.Text_s2_0:setString(g_tr("panicNum", {cur = self.data.limit - self.data.num, tol = self.data.limit}))

	if g_clock.getCurServerTime() < self.startTime then
		self.Button_1:setVisible(false)
		self.Text_15:setVisible(false)
	else
		if self.data.num >= self.data.limit then
			self.Button_1:setVisible(false)
			self.Text_15:setVisible(true)
		else
			self.Button_1:setVisible(true)
			self.Text_15:setVisible(false)
		end
	end
	self:addEvent()
end

function PanicItemView:update(data)
	self.data.num = tonumber(data.panicNum)

	self.Text_s2_0:setString(g_tr("panicNum", {cur = self.data.limit - self.data.num, tol = self.data.limit}))

	if self.data.num >= self.data.limit then
		self.Button_1:setVisible(false)
		self.Text_15:setVisible(true)
	else
		self.Button_1:setVisible(true)
		self.Text_15:setVisible(false)
	end
end

function PanicItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1 then
				g_activityData.doPanic(self.data.id, handler(self, self.update))
			end
		end
	end
	self.Button_1:addTouchEventListener(proClick)
end

return PanicItemView