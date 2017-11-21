local BannerView = class("BannerView", require("game.uilayer.base.BaseLayer"))

function BannerView:onEnter()
	g_moneyData.setBannerView(self)
end

function BannerView:onExit()
	g_gameCommon.removeEventHandler(g_Consts.CustomEvent.GiudeTrigged,self)
	g_moneyData.setBannerView(nil)
end

local index = 0

function BannerView:ctor()
	BannerView.super.ctor(self)

	index = 1

	self.mode = require("game.uilayer.money.MoneyMode").new()

	self.layer = self:loadUI("AdvertisingGifts_main.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.text = self.root:getChildByName("text")
	self.close_btn = self.root:getChildByName("close_btn")
	self.btn_anniu = self.root:getChildByName("btn_anniu")
	self.Image_huantu = self.root:getChildByName("Image_huantu")
	self.Image_yb = self.root:getChildByName("Image_yb")
	self.BitmapFontLabel_2 = self.root:getChildByName("BitmapFontLabel_2")
	self.Button_chakan = self.root:getChildByName("Button_chakan")
	self.Text_chakan = self.root:getChildByName("Text_chakan")
	self.Panel_texiaodiwei = self.root:getChildByName("Panel_texiaodiwei")
	self.ListView_1 = self.root:getChildByName("ListView_1")

	for i=1, 3 do
		self["Button_chakan"..i] = self.root:getChildByName("Button_chakan"..i)
		self["Button_chakan"..i.."_Text_chakan"] = self["Button_chakan"..i]:getChildByName("Text_chakan")
		self["Button_chakan"..i.."_Text_chakan"]:setString(g_tr("seeDetail"))
		self["Button_chakan"..i]:setVisible(false)
	end

	self.btn_Text_2 = self.btn_anniu:getChildByName("Text_2")
	self.btn_Text_3 = self.btn_anniu:getChildByName("Text_3")
	self.Panel_texiao = self.btn_anniu:getChildByName("Panel_texiao")

	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZiYuanLiBaoAnNiu/Effect_ZiYuanLiBaoAnNiu.ExportJson", "Effect_ZiYuanLiBaoAnNiu")
    self.Panel_texiao:addChild(armature)
	armature:setPosition(cc.p(self.Panel_texiao:getContentSize().width*0.5,self.Panel_texiao:getContentSize().height*0.5))
	animation:play("Animation1")

	local armature1 , animation1 = g_gameTools.LoadCocosAni("anime/Effect_ZiYuanLiBaoShuZi/Effect_ZiYuanLiBaoShuZi.ExportJson", "Effect_ZiYuanLiBaoShuZi")
    self.Panel_texiaodiwei:addChild(armature1)
	armature1:setPosition(cc.p(self.Panel_texiaodiwei:getContentSize().width*0.5,self.Panel_texiaodiwei:getContentSize().height*0.5))
	animation1:play("Animation1")

	local armature1 , animation1 = g_gameTools.LoadCocosAni("anime/Effect_ChongZhiYuanBaoXunHuan/Effect_ChongZhiYuanBaoXunHuan.ExportJson", "Effect_ChongZhiYuanBaoXunHuan")
    self.Image_yb:addChild(armature1)
	armature1:setPosition(cc.p(self.Image_yb:getContentSize().width*0.5,self.Image_yb:getContentSize().height*0.5))
	animation1:play("Animation1")

	self.data = g_activityData.GetGiftData()
	
	self:processData()

	self:addEvent()

	self:setData()
end

function BannerView:processData()
	local aciList = {}
	for i=1, #self.data.list do
		local sGift = g_data.activity_commodity[tonumber(self.data.list[i].aci)]
		if sGift.act_same_index > 0 then
			local tag = false
			for k, v in pairs(aciList) do
				if #v > 0 then
					local sg = g_data.activity_commodity[tonumber(v[1].aci)]
					if sg.act_same_index > 0 then
						if sg.act_same_index == sGift.act_same_index then
							table.insert(aciList[sGift.act_same_index], self.data.list[i])
							tag = true
							break
						end
					end
				end
			end

			if tag == false then
				if aciList[sGift.act_same_index] == nil then
					aciList[sGift.act_same_index] = {}
				end
				table.insert(aciList[sGift.act_same_index], self.data.list[i])
			end
		end
	end

	self.curData = nil

	local result = {}
	local min = 10000

	for key, value in pairs(aciList) do
		local sGift = g_data.activity_commodity[tonumber(value[1].aci)]
		if sGift ~= nil then
			if min > sGift.priority  then
				min = sGift.priority
			end
		end
	end

	for key, value in pairs(aciList) do
		local sGift = g_data.activity_commodity[tonumber(value[1].aci)]
		if sGift ~= nil then
			if min == sGift.priority  then
				table.insert(result, value)
			end
		end
	end

	if #result > 0 then
		local tem = math.random((#result))
		self.curData = result[tem]
	end
end

function BannerView:setData()
	if self.curData == nil or self.curData[index] == nil then
		self:close()
		return
	end

	self.ListView_1:removeAllItems()

	if #self.curData > 1 then
		for i=1, #self.curData do
			--self["Button_chakan"..i]:setVisible(true)
		end
	end
	

	local gift = g_data.activity_commodity[tonumber(self.curData[index].aci)]
	local pData = g_data.pricing[tonumber(self.curData[index].id)]

	self.Image_huantu:loadTexture(g_resManager.getResPath(gift.gift_banner))
	self.btn_Text_2:setString(g_channelManager.GetMoneyType(pData.type)..gift.show_price.."")
	self.btn_Text_3:setString(g_channelManager.GetMoneyType(pData.type)..pData.price.."")
	self.BitmapFontLabel_2:setString(gift.ratio.."%")
	self.Text_chakan:setString(g_tr("seeMore"))
	self.text:setString(g_tr("containPrice", {money=pData.count}))

	local len = #g_data.drop[gift.drop_id].drop_data

	if (len%5) ~= 0 then
		len = math.ceil(len/5)
	else
		len = len/5
	end

	for i=1, len do
		local item = require("game.uilayer.money.BannerItemView").new()
		self.ListView_1:pushBackCustomItem(item)
		item:show(g_data.drop[gift.drop_id].drop_data[i*5-4],g_data.drop[gift.drop_id].drop_data[i*5-3],
			g_data.drop[gift.drop_id].drop_data[i*5-2],g_data.drop[gift.drop_id].drop_data[i*5-1],g_data.drop[gift.drop_id].drop_data[i*5])
	end

	if gift.guild_drop_id ~= 0 then
		local title = require("game.uilayer.activity.activityMoney.actMoneyTitleView").new()
		self.ListView_1:pushBackCustomItem(title)

		local len = #g_data.drop[gift.guild_drop_id].drop_data

		if (len%5) ~= 0 then
			len = math.ceil(len/5)
		else
			len = len/5
		end

		for i=1, len do
			local item = require("game.uilayer.money.BannerItemView").new()
			self.ListView_1:pushBackCustomItem(item)
			item:show(g_data.drop[gift.guild_drop_id].drop_data[i*5-4],g_data.drop[gift.guild_drop_id].drop_data[i*5-3],
				g_data.drop[gift.guild_drop_id].drop_data[i*5-2],g_data.drop[gift.guild_drop_id].drop_data[i*5-1],
				g_data.drop[gift.guild_drop_id].drop_data[i*5])
		end
	end

	self.ListView_1:jumpToTop()
end

function BannerView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			elseif sender == self.btn_anniu then
				if #g_channelManager.GetPayWayList() == 1 then
                    g_moneyData.RequestData(self.curData[index].id, self.curData[index].aci, g_channelManager.GetPayWayList()[1])
                else
                    g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyTypeView").new(self.curData[index].id, self.curData[index].aci))
                end
            elseif self.Button_chakan == sender then
            	local view  = require("game.uilayer.activity.activityMoney.ActivityMoneyView").new(nil, self.curData[index].aci)
				g_sceneManager.addNodeForUI(view)
				self:close()
			elseif self["Button_chakan1"] == sender then
				if index == 1 then
					return
				end
				index = 1

				self:setHightLight()
				self:setData()
			elseif self["Button_chakan2"] == sender then
				if index == 2 then
					return
				end
				index = 2

				self:setHightLight()
				self:setData()
			elseif self["Button_chakan3"] == sender then
				if index == 3 then
					return
				end
				index = 3

				self:setHightLight()
				self:setData()
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)
	self.btn_anniu:addTouchEventListener(proClick)
	self.Button_chakan:addTouchEventListener(proClick)
	self["Button_chakan1"]:addTouchEventListener(proClick)
	self["Button_chakan2"]:addTouchEventListener(proClick)
	self["Button_chakan3"]:addTouchEventListener(proClick)

	local function update()
		self:close()
	end

	g_gameCommon.addEventHandler(g_Consts.CustomEvent.GiudeTrigged, update, self)
end

function BannerView:setHightLight()
	--[[
	for i=1, 3 do
		self["Button_chakan"..i]:setBrightStyle(BRIGHT_NORMAL)
	end

	self["Button_chakan"..index]:setBrightStyle(BRIGHT_HIGHLIGHT)
	]]
end

return BannerView