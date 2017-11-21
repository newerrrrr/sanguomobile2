--region actMoneyInfoView.lua
--Author : luqingqing
--Date   : 2016/4/21
--此文件由[BabeLua]插件自动生成

local actMoneyInfoView = class("actMoneyInfoView", require("game.uilayer.base.BaseLayer"))

function actMoneyInfoView:ctor(data)
	actMoneyInfoView.super.ctor(self)

	self.data = data
	self.content = g_data.activity_commodity[tonumber(self.data.aci)]
	self.price = g_data.pricing[tonumber(self.data.id)]

	self.layer = self:loadUI("activity2_Package.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.BitmapFontLabel_1 = self.root:getChildByName("BitmapFontLabel_1")
	self.ListView_1 = self.root:getChildByName("ListView_1")
	self.close_btn = self.root:getChildByName("close_btn")
	self.Button_1 = self.root:getChildByName("Button_1")
	self.Text_14 = self.root:getChildByName("Text_14")
	self.Text_15 = self.root:getChildByName("Text_15")
	self.Text_15_0 = self.root:getChildByName("Text_15_0")
	self.Text_bt11 = self.root:getChildByName("Text_bt11")
	
	self.Text_14:setString(g_tr("getMore"))
	self.Text_bt11:setString(g_tr("infoTitle"))

	self:show()
	self:addEvent()
end

function actMoneyInfoView:show()
	self.BitmapFontLabel_1:setString(g_tr(self.price.desc))

	self.Text_15:setString(g_channelManager.GetMoneyType(self.price.type)..self.content.show_price)
	self.Text_15_0:setString(g_channelManager.GetMoneyType(self.price.type)..self.price.price)

	local data = g_data.drop[self.content.drop_id].drop_data

	local len = 0
	if ((#data)%2 == 1) then
		len = (#data)/2 + 1
	else
		len = (#data)/2
	end
	
	for i=1, len do
		local item = require("game.uilayer.activity.activityMoney.actMoneyDropView").new()
		self.ListView_1:pushBackCustomItem(item)
		item:show(data[i*2-1], data[i*2])
	end

	if self.content.guild_drop_id ~= 0 then
		local title = require("game.uilayer.activity.activityMoney.actMoneyTitleView").new()
		self.ListView_1:pushBackCustomItem(title)

		local tem = g_data.drop[self.content.guild_drop_id].drop_data

		local len = 0
		if ((#tem)%2 == 1) then
			len = (#tem)/2 + 1
		else
			len = (#tem)/2
		end
	
		for i=1, len do
			local item = require("game.uilayer.activity.activityMoney.actMoneyDropView").new()
			self.ListView_1:pushBackCustomItem(item)
			item:show(tem[i*2-1], tem[i*2])
		end
	end
end

function actMoneyInfoView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1 then
				if #g_channelManager.GetPayWayList() == 1 then
					g_moneyData.RequestData(self.data.id, self.data.aci, g_channelManager.GetPayWayList()[1])
				else
					g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyTypeView").new(self.data.id, self.data.aci))
				end
				
				g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
				self:close()
			elseif sender == self.close_btn then
				g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
				self:close()
			end
		end
	end

	self.Button_1:addTouchEventListener(proClick)
	self.close_btn:addTouchEventListener(proClick)
end

return actMoneyInfoView
--endregion
