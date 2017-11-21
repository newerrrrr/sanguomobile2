local ActivityMoneyItemView = class("ActivityMoneyItemView")

function ActivityMoneyItemView:ctor(mc)
	self.layer = mc

	self.BitmapFontLabel_2 = self.layer:getChildByName("BitmapFontLabel_2")
	self.Image_huantu = self.layer:getChildByName("Image_huantu")
	self.text = self.layer:getChildByName("text")
	self.btn_anniu = self.layer:getChildByName("btn_anniu")
	self.btn_Text_2 = self.btn_anniu:getChildByName("Text_2")
	self.btn_Text_3 = self.btn_anniu:getChildByName("Text_3")
	self.Panel_texiao = self.btn_anniu:getChildByName("Panel_texiao")
	self.Image_yb = self.layer:getChildByName("Image_yb")
	self.Image_zjt = self.layer:getChildByName("Image_zjt")
	self.Text_xg = self.layer:getChildByName("Text_xg")

	self.Button_chakan = self.layer:getChildByName("Button_chakan")
	self.ListView_1 = self.layer:getChildByName("ListView_1")
	self.Panel_texiaodiwei = self.layer:getChildByName("Panel_texiaodiwei")

	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZiYuanLiBaoAnNiu/Effect_ZiYuanLiBaoAnNiu.ExportJson", "Effect_ZiYuanLiBaoAnNiu")
	self.Panel_texiao:addChild(armature)
	armature:setPosition(cc.p(self.Panel_texiao:getContentSize().width*0.5,self.Panel_texiao:getContentSize().height*0.5))
	animation:play("Animation1")

	local armature1 , animation1 = g_gameTools.LoadCocosAni("anime/Effect_ZiYuanLiBaoShuZi/Effect_ZiYuanLiBaoShuZi.ExportJson", "Effect_ZiYuanLiBaoShuZi")
	self.Panel_texiaodiwei:addChild(armature1)
	armature1:setPosition(cc.p(self.Panel_texiaodiwei:getContentSize().width*0.5,self.Panel_texiaodiwei:getContentSize().height*0.5))
	animation1:play("Animation1")

	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ChongZhiYuanBaoXunHuan/Effect_ChongZhiYuanBaoXunHuan.ExportJson", "Effect_ChongZhiYuanBaoXunHuan")
	self.Image_yb:addChild(armature)
	armature:setPosition(cc.p(self.Image_yb:getContentSize().width*0.5,self.Image_yb:getContentSize().height*0.5))
	animation:play("Animation1")

	self.pos = nil
	self.isMove = false

	--self.Text_xg:setString(g_tr("onlyOneBuy"))

	self:addEvent()
end

function ActivityMoneyItemView:showData(data, index)
	self.data = data[index]
	if self.data == nil then
		if data[1] ~= nil then
			self.data = data[1]
		else
			self.layer:setVisible(false)
		end
		
		return
	end
	self:setData()
end

function ActivityMoneyItemView:setData()

	local gift = g_data.activity_commodity[tonumber(self.data.aci)]
	local pData = g_data.pricing[tonumber(self.data.id)]

	if gift.desc2 == 1 then
		self.Text_xg:setString(g_tr("onlyOneBuy"))
	else
		self.Text_xg:setString("")
	end

	self.Image_huantu:loadTexture(g_resManager.getResPath(gift.gift_icon))
	self.btn_Text_2:setString(g_channelManager.GetMoneyType(pData.type)..gift.show_price.."")
	self.btn_Text_3:setString(g_channelManager.GetMoneyType(pData.type)..pData.price.."")
	self.BitmapFontLabel_2:setString(gift.ratio.."%")

	self.text:setString(g_tr("containPrice", {money=pData.count}))

	self.ListView_1:removeAllItems()

	self.ListView_1:jumpToTop()


	--如果没有联盟奖励就用平铺的方式
	if tonumber(gift.guild_drop_id) == 0 then
		self.Image_zjt:setVisible(false)
		local len = self:getDropLen5(gift.drop_id)
		for i=1, len do
			local item = require("game.uilayer.money.BannerItemView").new()
			self.ListView_1:pushBackCustomItem(item)
			item:show(g_data.drop[gift.drop_id].drop_data[i*5-4],g_data.drop[gift.drop_id].drop_data[i*5-3],
			g_data.drop[gift.drop_id].drop_data[i*5-2],g_data.drop[gift.drop_id].drop_data[i*5-1],g_data.drop[gift.drop_id].drop_data[i*5])
		end
	else
		--两边加载的方式
		self.Image_zjt:setVisible(true)

		local len1 = self:getDropLen(gift.drop_id)
		local len2 = self:getDropLen(gift.guild_drop_id)

		local len = 0
		if len1 > len2 then
			len = len1
		else
			len = len2
		end

		local norDrop = g_data.drop[gift.drop_id]
		local menDrop = g_data.drop[gift.guild_drop_id]

		for i=1, len do
			local item = require("game.uilayer.money.BannerItemView").new(6)
			self.ListView_1:pushBackCustomItem(item)
			item:show(norDrop.drop_data[i*3-2],norDrop.drop_data[i*3-1],norDrop.drop_data[i*3],
			menDrop.drop_data[i*3-2],menDrop.drop_data[i*3-1],menDrop.drop_data[i*3])
		end
	end

	self.ListView_1:jumpToTop()
	
end

function ActivityMoneyItemView:getDropLen5(dropId)
	local len = #g_data.drop[dropId].drop_data

	if (len%5) ~= 0 then
		len = math.ceil(len/5)
	else
		len = len/5
	end

	return len
end

function ActivityMoneyItemView:getDropLen(dropId)
	local len = #g_data.drop[dropId].drop_data

	if (len%3) ~= 0 then
		len = math.ceil(len/3)
	else
		len = len/3
	end

	return len
end

function ActivityMoneyItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.btn_anniu then
				if #g_channelManager.GetPayWayList() == 1 then
					g_moneyData.RequestData(self.data.id, self.data.aci, g_channelManager.GetPayWayList()[1])
				else
					g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyTypeView").new(self.data.id, self.data.aci))
				end
				g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			end
		end
	end

	self.btn_anniu:addTouchEventListener(proClick)
end

return ActivityMoneyItemView