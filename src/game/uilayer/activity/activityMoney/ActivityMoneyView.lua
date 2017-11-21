local ActivityMoneyView = class("ActivityMoneyView", require("game.uilayer.base.BaseLayer"))

local g_dir = {
	
	["left"] = 1,
	["right"] = 2,
}

function ActivityMoneyView:onEnter()
	g_moneyData.setView(self)
end

function ActivityMoneyView:onExit()
	g_moneyData.setView(nil)
end

function ActivityMoneyView:ctor(num, aid)
	ActivityMoneyView.super.ctor(self)

	self.mode = require("game.uilayer.activity.ActivityMode").new()

	self.curStep = num or 1

	self.index = 1

	self.activityId = aid

	self.inAction = false

	self.isMove = false

	self.btnList = {}

	self.actList = {}

	self.layer = self:loadUI("AdvertisingGifts_main1.csb")

	self.root = self.layer:getChildByName("scale_node")
	self.close_btn = self.root:getChildByName("close_btn")
	self.Text_1 = self.root:getChildByName("Text_1")
	
	self.Panel_3 = self.root:getChildByName("Panel_3")
	self.Panel_1 = self.Panel_3:getChildByName("Panel_1")
	self.Panel_2 = self.Panel_3:getChildByName("Panel_2")
	self.Panel_anniudingwei = self.root:getChildByName("Panel_anniudingwei")

	self.Panel_djs = self.root:getChildByName("Panel_djs")
	self.Text_8 = self.Panel_djs:getChildByName("Text_8")
	self.Text_8_0 = self.Panel_djs:getChildByName("Text_8_0")

	self.Text_8:setString(g_tr("actEnd"))

	self.Text_normal = self.root:getChildByName("Text_normal")
	self.Text_guild = self.root:getChildByName("Text_guild")

	for i=1, 3 do
		self["Button_chakan"..i] = self.root:getChildByName("Button_chakan"..i)
		self["Button_chakan"..i.."_Text_chakan"] = self["Button_chakan"..i]:getChildByName("Text_chakan")
		self["Button_chakan"..i]:setVisible(false)
	end

	self.originPosX = 17
	self.originPosY = 62.25


	self.Image_jt1 = self.root:getChildByName("Image_jt1")
	self.Image_jt2 = self.root:getChildByName("Image_jt2")

	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_JianTouYiDongGuiWei/Effect_JianTouYiDongGuiWei.ExportJson", "Effect_JianTouYiDongGuiWei")
    self.Image_jt1:addChild(armature)
    armature:setScaleX(-1)
	armature:setPosition(cc.p(self.Image_jt1:getContentSize().width*0.5,self.Image_jt1:getContentSize().height*0.5))
	animation:play("Animation1")

	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_JianTouYiDongGuiWei/Effect_JianTouYiDongGuiWei.ExportJson", "Effect_JianTouYiDongGuiWei")
    self.Image_jt2:addChild(armature)
	armature:setPosition(cc.p(self.Image_jt2:getContentSize().width*0.5,self.Image_jt2:getContentSize().height*0.5))
	animation:play("Animation1")

	local function getData(data)
        if data == nil or data.list == nil or #data.list == 0 then
            return
        end

        self.data = self:processData(data)

        if self.activityId ~= nil then
        	for key, value in pairs(self.data) do
        		local tag = false
        		for k, v in pairs(value) do
        			if tonumber(v.aci) == tonumber(self.activityId) then
        				self.curStep = tonumber(key)
        				tag = true
        				break
        			end
        		end

        		if tag == true then
        			break
        		end
        	end
        else
        	if self.curStep > #self.data then
        		self.curStep = 1
        	end
        end
        
        self:initContent()

        self:updateTime()

        self:updateBtn(self.index)
    end

    self.mode:getGiftList(g_channelManager.GetPayWayList()[1], getData)

    self:addEvent()
end

function ActivityMoneyView:initContent()

	self.view1 = require("game.uilayer.activity.activityMoney.ActivityMoneyItemView").new(self.Panel_1)
	self.view1:showData(self.data[self.curStep], self.index)


	local gift = g_data.activity_commodity[tonumber(self.data[self.curStep][self.index].aci)]
	if tonumber(gift.guild_drop_id) > 0 then
		self.Text_normal:setString(g_tr("masterGet"))
		self.Text_guild:setString(g_tr("memberGet"))
	end

	if #self.data > 1 then
		self.view2 = require("game.uilayer.activity.activityMoney.ActivityMoneyItemView").new(self.Panel_2)
		if self.curStep >= #self.data then
		   self.view2:showData(self.data[1], self.index)
		else
		   self.view2:showData(self.data[self.curStep + 1], self.index)
		end
	end

	local size = self.Panel_anniudingwei:getContentSize()

	for i=1, #self.data do
		local btn = require("game.uilayer.activity.activityMoney.ActivityMoneyButtonView").new()
		table.insert(self.btnList, btn)
		self.Panel_anniudingwei:addChild(btn)
		if (#self.data)%2 == 1 then
			btn:setPosition(cc.p(size.width/(#self.data) * i - size.width/(#self.data)/2, 0))
		else
			btn:setPosition(cc.p(size.width/(#self.data) * i - size.width/2, 0))
		end
	end

	self:updatePoint()
end

function ActivityMoneyView:update()
	local function getData(data)
        if data == nil or data.list == nil or #data.list == 0 then
        	self.Panel_1:setVisible(false)
            return
        end

        self.data = self:processData(data)
        
        if self.data[self.curStep] == nil then
        	if len == 1 then
        		self.curStep = 1
        	else
        		self.curStep = (#self.data) - 1
        	end
        elseif self.curStep == #self.data then
        	self.curStep = (#self.data)-1
        end

        if self.view1 ~= nil then
        	self.view1:showData(self.data[self.curStep], self.index)
        end

        if self.view2 ~= nil then
        	self.view2:showData(self.data[self.curStep + 1], self.index)
        end
    end

    self.mode:getGiftList(g_channelManager.GetPayWayList()[1], getData)
end

function ActivityMoneyView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Image_jt1 then
				self:doAction(g_dir.right)
			elseif sender == self.Image_jt2 then
				self:doAction(g_dir.left)
			elseif sender == self.close_btn then
				self:close()
			elseif sender == self["Button_chakan1"] then
				if self.inAction == true then
					return
				end

				if self.index == 1 then
					return
				end

				self.index = 1
				if self.view1 ~= nil then
					self.view1:showData(self.data[self.curStep], self.index)
				end
				if self.view2 ~= nil then
					self.view2:showData(self.data[self.curStep], self.index)
				end

				self:updateBtn(self.index)
			elseif sender == self["Button_chakan2"] then
				if self.inAction == true then
					return
				end

				if self.index == 2 then
					return
				end

				self.index = 2
				if self.view1 ~= nil then
					self.view1:showData(self.data[self.curStep], self.index)
				end
				if self.view2 ~= nil then
					self.view2:showData(self.data[self.curStep], self.index)
				end
				self:updateBtn(self.index)
			elseif sender == self["Button_chakan3"] then
				if self.inAction == true then
					return
				end

				if self.index == 3 then
					return
				end

				self.index = 3
				if self.view1 ~= nil then
					self.view1:showData(self.data[self.curStep], self.index)
				end
				if self.view2 ~= nil then
					self.view2:showData(self.data[self.curStep], self.index)
				end
				self:updateBtn(self.index)
			end 
		end
	end

	local function moveClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.pos ~= nil and self.isMove == true then
				if (self.pos.x - sender:getTouchMovePosition().x) > 0 then
					self:doAction(g_dir.left)
				elseif (self.pos.x - sender:getTouchMovePosition().x) < 0 then
					self:doAction(g_dir.right)
				end
			end
			self.isMove = false
		elseif eventType == ccui.TouchEventType.moved then
			if self.isMove == false then
				self.pos = sender:getTouchMovePosition()
			end
			self.isMove = true
		elseif eventType == ccui.TouchEventType.began then
			self.pos = sender:getTouchMovePosition()
		end
	end

	self.Image_jt1:addTouchEventListener(proClick)
	self.Image_jt2:addTouchEventListener(proClick)
	self.close_btn:addTouchEventListener(proClick)
	self.Panel_1:addTouchEventListener(moveClick)
	self.Panel_2:addTouchEventListener(moveClick)
	self["Button_chakan1"]:addTouchEventListener(proClick)
	self["Button_chakan2"]:addTouchEventListener(proClick)
	self["Button_chakan3"]:addTouchEventListener(proClick)
end

function ActivityMoneyView:updateBtn(index)
	for i=1, 3 do
		self["Button_chakan"..i]:setBrightStyle(BRIGHT_NORMAL)
	end

	self["Button_chakan"..index]:setBrightStyle(BRIGHT_HIGHLIGHT)
end

function ActivityMoneyView:updateTime()
	local data = self.data[self.curStep][self.index]
	
	local function update()
		local dt = data.endTime - g_clock.getCurServerTime()

		if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.time)
            self.time = nil
            self.Text_8_0:setString(g_tr("actOver"))
        else
        	self.Text_8_0:setString(g_gameTools.convertSecondToString(dt))
        end
	end

	if self.time ~= nil then
        self:unschedule(self.time)
        self.time = nil
    end

	self.needTime = data.endTime - g_clock.getCurServerTime()

	if self.needTime > 0 then
        self.time = self:schedule(update, 1.0)
        update()
    end
end

function ActivityMoneyView:doAction(type)
	if self.view1 == nil or self.view2 == nil then
		return
	end

	if self.inAction == true then
		return
	end

	self.inAction = true

	local function callBack1()
		self.curStep = self.curStep + 1

		self.inAction = false

		self.index = 1

		self:updateTime()

		self:updatePoint()

		local gift = g_data.activity_commodity[tonumber(self.data[self.curStep][1].aci)]
		if tonumber(gift.guild_drop_id) > 0 then
			self.Text_normal:setString(g_tr("masterGet"))
			self.Text_guild:setString(g_tr("memberGet"))
		end

		self:updateBtn(self.index)
	end

	local function callBack2()

		self.curStep = self.curStep - 1

		self.inAction = false

		self.index = 1

		self:updateTime()

		self:updatePoint()

		local gift = g_data.activity_commodity[tonumber(self.data[self.curStep][1].aci)]
		if tonumber(gift.guild_drop_id) > 0 then
			self.Text_normal:setString(g_tr("masterGet"))
			self.Text_guild:setString(g_tr("memberGet"))
		end

		self:updateBtn(self.index)
	end

	local moveTo = nil
	local callFunc = nil

	for i=1, 3 do
		self["Button_chakan"..i]:setVisible(false)
	end

	if type == g_dir.left then
		self.Panel_3:setPosition(cc.p(self.originPosX, self.originPosY))
		self.view1:showData(self.data[self.curStep], self.index)
		if self.curStep == #self.data then
			self.curStep = 0
		end
		self.view2:showData(self.data[self.curStep + 1], 1)
		moveTo = cc.MoveTo:create(0.5, cc.p(-1254, self.originPosY))
		callFunc=cc.CallFunc:create(callBack1)
	else
		self.Panel_3:setPosition(cc.p(-1254, self.originPosY))
		self.view2:showData(self.data[self.curStep], self.index)
		if self.curStep == 1 then
			self.curStep = (#self.data) + 1
		end
		self.view1:showData(self.data[self.curStep - 1], 1)
		
		moveTo = cc.MoveTo:create(0.5, cc.p(self.originPosX, self.originPosY))
		callFunc=cc.CallFunc:create(callBack2)
	end

	local seq=cc.Sequence:create(moveTo, callFunc)
	self.Panel_3:runAction(seq)
end

function ActivityMoneyView:updatePoint()
	if self.curStep > #self.btnList then
		return
	end

	for key, value in pairs(self.btnList) do
		value:show(false)
	end

	self.btnList[self.curStep]:show(true)


	self.Text_normal:setString("")
	self.Text_guild:setString("")

	if #self.data[self.curStep] > 1 then

		for i=1, #self.data[self.curStep] do
			local sGift = g_data.activity_commodity[tonumber(self.data[self.curStep][i].aci)]

			if tonumber(sGift.guild_drop_id) > 0 then
				self.Text_normal:setString(g_tr("masterGet"))
				self.Text_guild:setString(g_tr("memberGet"))
			end

			for key, value in pairs(g_data.pricing) do
				if value.channel == g_channelManager.GetPayWayList()[1] and tonumber(value.gift_type) == tonumber(sGift.gift_type) then
					self["Button_chakan"..i]:setVisible(true)
					self["Button_chakan"..i.."_Text_chakan"]:setString(g_channelManager.GetMoneyType(value.type)..value.price.."")
					break
				end
			end
		end
	end
end

function ActivityMoneyView:processData(data)

		local aciList = {}
		for i=1, #data.list do
			local sGift = g_data.activity_commodity[tonumber(data.list[i].aci)]

			if sGift.act_same_index > 0 then
			local tag = false
			for k, v in pairs(aciList) do
				if #v > 0 then
					local sg = g_data.activity_commodity[tonumber(v[1].aci)]
					if sg.act_same_index == sGift.act_same_index then
						table.insert(aciList[sGift.act_same_index], data.list[i])
						tag = true
						break
					end
				end
			end

			if tag == false then
				if aciList[sGift.act_same_index] == nil then
					aciList[sGift.act_same_index] = {}
				end
				table.insert(aciList[sGift.act_same_index], data.list[i])
			end
			end
		end

		local  dataList = {}
		for k, v in pairs(aciList) do
			table.insert(dataList, v)
		end

		for i=1, #dataList do
			table.sort(dataList[i], function(a,b)
				return tonumber(a.id) < tonumber(b.id)
			end)
		end

		return dataList
end

return ActivityMoneyView