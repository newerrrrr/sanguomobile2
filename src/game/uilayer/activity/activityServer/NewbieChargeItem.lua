local NewbieChargeItem = class("NewbieChargeItem", require("game.uilayer.base.BaseWidget"))

function NewbieChargeItem:ctor(data, chargeData)
	self.data = data
	self.chargeData = chargeData

	self.mode = require("game.uilayer.activity.ActivityMode").new()

	self.layer = self:LoadUI("EveryDay_main2_list1.csb")

	self.ListView_1 = self.layer:getChildByName("ListView_1")
	self.Text_lj1 = self.layer:getChildByName("Text_lj1")
	self.Text_lj2 = self.layer:getChildByName("Text_lj2")
	self.Text_lj3 = self.layer:getChildByName("Text_lj3")
	self.Text_lj4 = self.layer:getChildByName("Text_lj4")

	--领取
	self.Button_1 = self.layer:getChildByName("Button_1")
	self.txtBtn = self.Button_1:getChildByName("Text_6")
	self.txtBtn:setString(g_tr("commonAwardGet"))

	--已领取
	self.Image_lq1 = self.layer:getChildByName("Image_lq1")
	self.txtImage_lq1 = self.Image_lq1:getChildByName("Text_1")
	self.txtImage_lq1:setString(g_tr("commonAwardGeted"))

	--不可领取
	self.Image_lq2 = self.layer:getChildByName("Image_lq2")
	self.txtImage_lq2 = self.Image_lq2:getChildByName("Text_1")
	self.txtImage_lq2:setString(g_tr("commonAwardNo"))

	if self.chargeData == nil then
		self.Button_1:setVisible(false)
		self.Image_lq1:setVisible(false)
		self.Text_lj4:setString("0/"..self.data.recharge_price)
	else
		local tag = false
		for i=1,#self.chargeData.flag do
			if tonumber(self.chargeData.flag[i]) == self.data.recharge_price then
				tag = true
				break
			end
		end

		if tag == false then
			if self.chargeData.gem < self.data.recharge_price then
				self.Button_1:setVisible(false)
				self.Image_lq1:setVisible(false)
				self.Text_lj4:setString(self.chargeData.gem.."/"..self.data.recharge_price)
			else
				self.Image_lq1:setVisible(false)
				self.Image_lq2:setVisible(false)
				self.Text_lj4:setString(self.data.recharge_price.."/"..self.data.recharge_price)
			end
		else
			self.Button_1:setVisible(false)
			self.Image_lq2:setVisible(false)
			self.Text_lj4:setString(self.data.recharge_price.."/"..self.data.recharge_price)
		end
	end

	self:addEvent()
	self:setData()
end

function NewbieChargeItem:setData()
	self.Text_lj1:setString(g_tr("actCharge"))
	self.Text_lj2:setString(self.data.recharge_price.."")
	self.Text_lj3:setString(g_tr("fundNumExt"))

	local itemList = {}
	local canMove = 0
	for i=1,#self.data.drop do
		local dropData = g_data.drop[self.data.drop[i]]
		for j=1, #dropData.drop_data do
			local item = require("game.uilayer.activity.loginReward.RewardItemView").new(dropData.drop_data[j])
			self.ListView_1:pushBackCustomItem(item)
			canMove = canMove + 1
		end
	end

	if canMove > 5 then
       self.ListView_1:setTouchEnabled(true)
	else
		self.ListView_1:setTouchEnabled(false)
	end
end

function NewbieChargeItem:addEvent()
	local function fetchCompete(data)
		self.Button_1:setVisible(false)
		self.Image_lq1:setVisible(true)
		g_gameCommon.dispatchEvent(g_Consts.CustomEvent.NewbieShowTip)
	end

	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender ==self.Button_1 then
				self.mode:newbieChargeReward(self.data.id, fetchCompete)
			end
		end
	end

	self.Button_1:addTouchEventListener(proClick)
end

return NewbieChargeItem