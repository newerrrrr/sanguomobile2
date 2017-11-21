local MoneyTypeView = class("MoneyTypeView", require("game.uilayer.base.BaseLayer"))

function MoneyTypeView:ctor(pid, aci)
	MoneyTypeView.super.ctor(self)

	self.data = g_data.pricing[tonumber(pid)]

	if aci == nil then
		self.aci = 0
	else
		self.aci = aci
	end

	self.layer = self:loadUI("Recharge_main1.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.Text_c2 = self.root:getChildByName("Text_c2")
	self.Text_2_0 = self.root:getChildByName("Text_2_0")
	self.Text_zflx = self.root:getChildByName("Text_zflx")

	for i=1, 6 do
		self["Image_quan"..i] = self.root:getChildByName("Image_quan"..i)
	end

	self.Text_sz1 = self.root:getChildByName("Text_sz1")
	self.Text_sz2 = self.root:getChildByName("Text_sz2")
	self.Text_sz4 = self.root:getChildByName("Text_sz4")
	self.Text_sz5 = self.root:getChildByName("Text_sz5")

	self.Button_3 = self.root:getChildByName("Button_3")
	self.Text_2 = self.Button_3:getChildByName("Text_2")

	--关闭mycard支付
	--self.Image_quan5 = self.root:getChildByName("Image_quan5")
	--self.Image_quan5:setVisible(false)
	--关闭mycard支付

	self.Panel_1 = self.root:getChildByName("Panel_1")
	self.Image_gg1 = self.Panel_1:getChildByName("Image_gg1")
	self.Image_gg2 = self.Panel_1:getChildByName("Image_gg2")
	self.Image_gg3 = self.Panel_1:getChildByName("Image_gg3")
	--self.Image_gg3:setVisible(false)

	self.Panel_2 = self.root:getChildByName("Panel_2")
	self.Image_gg4 = self.Panel_2:getChildByName("Image_gg4")
	self.Image_gg5 = self.Panel_2:getChildByName("Image_gg5")
	self.Image_gg6 = self.Panel_2:getChildByName("Image_gg6")
	--self.Image_gg6:setVisible(false)

	self.channelList = {}
	self.channelList = g_channelManager.GetPayWayList()
	for key, payway in pairs(self.channelList) do
		if payway == g_channelManager.payWay.googleplay or payway == g_channelManager.payWay.googlestore then
			self.Panel_1:setVisible(true)
			self.Panel_2:setVisible(false)
		elseif payway == g_channelManager.payWay.alipay or payway == g_channelManager.payWay.alipay_cn then
			self.Panel_1:setVisible(false)
			self.Panel_2:setVisible(true)
		end
	end

	self.Text_c2:setString(g_tr("priceType"))
	self.Text_zflx:setString(g_tr("selectPriceType"))
	self.Text_sz1:setString(g_tr("priceName"))
	self.Text_sz4:setString(g_tr("priceSale"))
	self.Text_2:setString(g_tr("priceTitle"))
	self.Text_2_0:setString(g_tr("clickhereclose"))

	self:addEvent()
	self:setData()
end

function MoneyTypeView:setData()
	self.selectPay = 1
	self.Image_quan2:setVisible(true)
	self.Image_quan4:setVisible(false)
	self.Image_quan6:setVisible(false)
	self.curPlatform = self.channelList[self.selectPay]

	self:updateContent()
end

function MoneyTypeView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Image_gg1 or sender == self.Image_quan1 or self.Image_gg4 == sender then
				if self.selectPay ~= 1 then
					self.selectPay = 1
					self.curPlatform = self.channelList[self.selectPay]
					self.Image_quan2:setVisible(true)
					self.Image_quan4:setVisible(false)
					self.Image_quan6:setVisible(false)
					self:updateContent()
				end
			elseif sender == self.Image_gg2 or sender == self.Image_quan3 or self.Image_gg5 == sender then
				if self.selectPay ~= 2 then
					self.selectPay = 2
					self.curPlatform = self.channelList[self.selectPay]
					self.Image_quan4:setVisible(true)
					self.Image_quan2:setVisible(false)
					self.Image_quan6:setVisible(false)
					self:updateContent()
				end
			elseif	sender == self.Image_gg3 or sender == self.Image_quan5 or self.Image_gg6 == sender then
				if self.selectPay ~= 3 then
					self.selectPay = 3
					self.curPlatform = self.channelList[self.selectPay]
					self.Image_quan6:setVisible(true)
					self.Image_quan4:setVisible(false)
					self.Image_quan2:setVisible(false)
					self:updateContent()
				end
			elseif sender == self.root then
				self:close()
			elseif sender == self.Button_3 then
				g_moneyData.RequestData(self.data.id, self.aci, self.curPlatform)
			end
		end
	end

	self.Image_gg1:addTouchEventListener(proClick)
	self.Image_gg2:addTouchEventListener(proClick)
	self.Image_gg3:addTouchEventListener(proClick)
	self.Image_gg4:addTouchEventListener(proClick)
	self.Image_gg5:addTouchEventListener(proClick)
	self.Image_gg6:addTouchEventListener(proClick)
	self.Image_quan1:addTouchEventListener(proClick)
	self.Image_quan3:addTouchEventListener(proClick)
	self.Image_quan5:addTouchEventListener(proClick)
	self.root:addTouchEventListener(proClick)
	self.Button_3:addTouchEventListener(proClick)
end

function MoneyTypeView:updateContent()
	--gift_type
	if self.selectPay == 1 then
		self:getData(self.channelList[1])
	elseif self.selectPay == 2 then
		self:getData(self.channelList[2])
	elseif self.selectPay == 3 then
		self:getData(self.channelList[3])
	end

	self.Text_sz2:setString(g_tr(self.data.desc))
	if self.selectPay == 3 then
		self.Text_sz5:setString(g_tr(self.data.price)..g_channelManager.GetMoneyType(self.data.type))
	else
		self.Text_sz5:setString(g_channelManager.GetMoneyType(self.data.type)..g_tr(self.data.price))
	end
end

function MoneyTypeView:getData(platform)
	for key, value in pairs(g_data.pricing) do
		local isMonthCard = (value.goods_type == 3)
		if value.channel == platform and value.gift_type == self.data.gift_type then
			if isMonthCard then
				if value.isshow == 1 then
					self.data = value
					break
				end
			else
				self.data = value
				break
			end
		end
	end
end

return MoneyTypeView