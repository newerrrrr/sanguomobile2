local NewbieLoginItem = class("NewbieLoginItem", require("game.uilayer.base.BaseWidget"))

function NewbieLoginItem:ctor(data, days, hasGet, curDay)
	self.data = data
	self.days = days
	self.hasGet = hasGet
	self.curDay = curDay

	self.mode = require("game.uilayer.activity.ActivityMode").new()

	self.layer = self:LoadUI("EveryDay_main1_list1.csb")

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

	if self.days == nil then
		self.Button_1:setVisible(false)
		self.Image_lq1:setVisible(false)
	else
		if self.hasGet == false then
			self.Image_lq1:setVisible(false)
			self.Image_lq2:setVisible(false)
		else
			self.Button_1:setVisible(false)
			self.Image_lq2:setVisible(false)
		end
	end

	self:addEvent()
	self:setData()
end

function NewbieLoginItem:setData()
	self.Text_lj1:setString(g_tr("actLogin"))
	self.Text_lj2:setString(self.data.id.."")
	self.Text_lj3:setString(g_tr("day"))
	self.Text_lj4:setString(self.curDay.."/"..self.data.id)

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

function NewbieLoginItem:addEvent()
	local function fetchCompete(data)
		self.Button_1:setVisible(false)
		self.Image_lq1:setVisible(true)
		g_gameCommon.dispatchEvent(g_Consts.CustomEvent.NewbieShowTip)
	end

	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender ==self.Button_1 then
				self.mode:newbieLoginReward(self.data.id, fetchCompete)
			end
		end
	end

	self.Button_1:addTouchEventListener(proClick)
end

return NewbieLoginItem