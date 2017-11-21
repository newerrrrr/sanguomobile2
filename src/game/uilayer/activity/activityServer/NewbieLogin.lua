local NewbieLogin = class("NewbieLogin", function()
	return cc.Layer:create()
end)

function NewbieLogin:ctor(value)
  local function handler(event)
  	if event == "enter" then
  		g_activityData.SetActServerView(self)
		elseif event == "exit" then
			g_activityData.SetActServerView(nil)
			self:unregisterScriptHandler()
		end
  end

  self:registerScriptHandler(handler)

	self.type = value

	if self.type == 1 then
		self.layer = cc.CSLoader:createNode("EveryDay_main1.csb")
	else
		self.layer = cc.CSLoader:createNode("EveryDay_main2.csb")
	end

	self:addChild(self.layer)

	self.Text_8 = self.layer:getChildByName("Text_8")
	self.Text_8_0 = self.layer:getChildByName("Text_8_0")
	self.Text_9 = self.layer:getChildByName("Text_9")
	self.ListView_1 = self.layer:getChildByName("ListView_1")

	self.player = g_PlayerMode.GetData()
	self.playerInfo = g_playerInfoData.GetData()

	if self.type == 1 then
		self.Text_9:setString(g_tr("newbieLoginInfo"))
		self.endTime = self.player.create_time - ((self.player.create_time + 8 * 3600)%(24*3600)) + (#g_data.act_newbie_sign)*24*3600
	else

		self.Button_1 = self.layer:getChildByName("Button_1")
		self.Button_1_0 = self.layer:getChildByName("Button_1_0")
		self.btn_1_Text_1 = self.Button_1:getChildByName("Text_1")
		self.btn_1_0_Text_1 = self.Button_1_0:getChildByName("Text_1")
		self.btn_1_Text_1:setString(g_tr("priceTitle"))
		self.btn_1_0_Text_1:setString(g_tr("newbieGiftTxt"))

		local dataList = {}
		local time = math.ceil((g_clock.getCurServerTime() - self.player.create_time)/3600/24)


		local period = 0
		for i=1,#g_data.act_newbie_recharge do
			if time >= g_data.act_newbie_recharge[i].open_date and time <= g_data.act_newbie_recharge[i].close_date then
				period = g_data.act_newbie_recharge[i].period
				table.insert(dataList, g_data.act_newbie_recharge[i])
			end
		end

		local max = 0
		for i=1,#dataList do
			if max < dataList[i].close_date then
				max = dataList[i].close_date
			end
		end

		self.endTime = self.player.create_time + max * 24 * 3600
	end

	self:showTime()
	self:initList()
	self:addEvent()
end

function NewbieLogin:initList()
	self.ListView_1:removeAllItems()

	if self.type == 1 then
		local curDay = 1
		for i=1,#g_data.act_newbie_sign do
			if self.playerInfo.newbie_login[i] ~= nil then
				curDay = i
			end

			local tag = false
			for j=1, #g_activityData.GetNewbieLogin().flag do
				if tonumber(g_activityData.GetNewbieLogin().flag[j]) == i then
					tag = true
					break
				end
			end

			local item = require("game.uilayer.activity.activityServer.NewbieLoginItem").new(g_data.act_newbie_sign[i], 
				self.playerInfo.newbie_login[i], tag, curDay)

			self.ListView_1:pushBackCustomItem(item)
		end
	else
		local dataList = {}
		local time = math.ceil((g_clock.getCurServerTime() - self.player.create_time)/3600/24)


		local period = 0
		for i=1,#g_data.act_newbie_recharge do
			if time >= g_data.act_newbie_recharge[i].open_date and time <= g_data.act_newbie_recharge[i].close_date then
				period = g_data.act_newbie_recharge[i].period
				table.insert(dataList, g_data.act_newbie_recharge[i])
			end
		end
		
		g_activityData.RequestNewbieActivityCharge()
		local chargeData = g_activityData.GetNewbieCharge()

		local item = nil
		for i=1, #dataList do
			if #chargeData == 0 then
				self.Text_9:setString(g_tr(dataList[1].desc))
				item = require("game.uilayer.activity.activityServer.NewbieChargeItem").new(dataList[i], nil)
				self.ListView_1:pushBackCustomItem(item)
			else
				local tag = false
				for j=1,#chargeData do
					if period == chargeData[j].period then
						self.Text_9:setString(g_tr(dataList[i].desc))
						item = require("game.uilayer.activity.activityServer.NewbieChargeItem").new(dataList[i], chargeData[j])
						self.ListView_1:pushBackCustomItem(item)
						tag = true
						break
					end
				end

				if tag == false then
					self.Text_9:setString(g_tr(dataList[1].desc))
					item = require("game.uilayer.activity.activityServer.NewbieChargeItem").new(dataList[i], nil)
					self.ListView_1:pushBackCustomItem(item)
				end
			end
		end
	end
end

function NewbieLogin:update()
	self:initList()
end

function NewbieLogin:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1 then
				g_sceneManager.addNodeForUI(require("game.uilayer.money.MoneyView").new())
			elseif sender == self.Button_1_0 then
				local view  = require("game.uilayer.activity.activityMoney.ActivityMoneyView").new()
				g_sceneManager.addNodeForUI(view)
			end
		end
	end

	if self.type == 2 then
		self.Button_1:addTouchEventListener(proClick)
		self.Button_1_0:addTouchEventListener(proClick)
	end
end

function NewbieLogin:showTime()
	local function updateTime()

		local dt = self.endTime - g_clock.getCurServerTime()

		if dt <= 0 then 
			dt = 0 
			self.needTime = 0 
			self:unschedule(self.time)
			self.time = nil
		end

		self.Text_8_0:setString(g_gameTools.convertSecondToString(dt))	  
	end

	if self.time ~= nil then
		self:unschedule(self.time)
		self.time = nil
	end

	self.needTime = self.endTime - g_clock.getCurServerTime()

	if self.needTime > 0 then
		if self.type == 1 then
			self.Text_8:setString(g_tr("actEnd"))
		else
			self.Text_8:setString(g_tr("newbieActOver"))
		end
		
		self.time = self:schedule(updateTime, 1.0)
		updateTime()
	else
		self.Text_8:setString(g_tr("actOver"))
		self.Text_8_0:setString("")
	end
end

function NewbieLogin:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self.layer:runAction(action)
  return action
end 

function NewbieLogin:unschedule(action)
  self.layer:stopAction(action)
end

return NewbieLogin