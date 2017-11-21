local ActBannerView = class("ActBannerView", require("game.uilayer.base.BaseLayer"))

function ActBannerView:onExit()
	g_gameCommon.removeEventHandler(g_Consts.CustomEvent.GiudeTrigged,self)
end

function ActBannerView:ctor()
	ActBannerView.super.ctor(self)

	self.layer = self:loadUI("MoonCake_popup.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.close_btn = self.root:getChildByName("close_btn")
	self.ListView_1 = self.root:getChildByName("ListView_1")

	self.data = g_activityData.GetData()

	self:setData()
	self:addEvent()
end

function ActBannerView:setData()
	if self.data == nil then
		self:close()
		return
	end

	local item = nil
	for i=1, #self.data do
		if self.data[i].activity_id == 1017 or self.data[i].activity_id == 1018 or 
			self.data[i].activity_id == 1019 or self.data[i].activity_id  == 1022 or self.data[i].activity_id  == 1023 
			or self.data[i].activity_id  == 1026 or self.data[i].activity_id  == 1027 
			or self.data[i].activity_id  == 1031 or self.data[i].activity_id  == 1032 then
			item = require("game.uilayer.activity.activityBanner.ActBannerItemView").new()
			item:show(self.data[i].activity_id)
			self.ListView_1:pushBackCustomItem(item)
		end
	end

	local giftList = g_activityData.GetGiftData()
	local tag = false
	local tag1 = false

	for key, value in pairs(giftList.list) do
		local data = g_data.activity_commodity[tonumber(value.aci)]
		if data.activity_id == 1017 then
			item = require("game.uilayer.activity.activityBanner.ActBannerItemView").new()
			item:show(1017)
			self.ListView_1:pushBackCustomItem(item)
		elseif data.activity_id == 1018 then
			item = require("game.uilayer.activity.activityBanner.ActBannerItemView").new()
			item:show(1018)
			self.ListView_1:pushBackCustomItem(item)
		elseif data.activity_id == 1019 then
			item = require("game.uilayer.activity.activityBanner.ActBannerItemView").new()
			item:show(1019)
			self.ListView_1:pushBackCustomItem(item)
		elseif data.activity_id == 1020 then
			tag = true
		elseif data.activity_id == 1006 then
			--1.25
			tag1 = true
		elseif data.activity_id == 1022 then
			item = require("game.uilayer.activity.activityBanner.ActBannerItemView").new()
			item:show(1022)
			self.ListView_1:pushBackCustomItem(item)
		end
	end

	if tag == true then
		item = require("game.uilayer.activity.activityBanner.ActBannerItemView").new()
		item:show(1020)
		self.ListView_1:pushBackCustomItem(item)
	end

	if tag1 == true then
		item = require("game.uilayer.activity.activityBanner.ActBannerItemView").new()
		item:show(1006)
		self.ListView_1:pushBackCustomItem(item)
	end
end

function ActBannerView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)

	local function update()
		self:close()
	end

	g_gameCommon.addEventHandler(g_Consts.CustomEvent.GiudeTrigged, update, self)
end

return ActBannerView