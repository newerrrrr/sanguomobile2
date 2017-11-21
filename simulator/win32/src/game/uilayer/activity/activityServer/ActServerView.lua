local ActServerView = class("ActServerView", require("game.uilayer.base.BaseLayer"))

local actList = {2001, 2002, 2003}

function ActServerView:onEnter()
	g_activityData.SetActServerView(self)
end

function ActServerView:onExit()
	g_activityData.SetActServerView(nil)
end

function ActServerView:ctor(idx)
	self.curTab = idx or 1

	ActServerView.super.ctor(self)

	self.layer = self:loadUI("activity3_main.csb")

	self.root = self.layer:getChildByName("scale_node")
	self.Text_49 = self.root:getChildByName("Text_49")
	self.container = self.root:getChildByName("container")
	self.ListView_2 = self.root:getChildByName("ListView_2")
	self.Button_x = self.root:getChildByName("Button_x")
	self.Text_49:setString(g_tr("activityTitleStr"))

	self.player = g_PlayerMode.GetData()

	self.uiList = {}

	self:initFun()

	self:addEvent()

	self:initList()

	self:showContent()

	self:showTip()
end

function ActServerView:initFun()
	self.partSelect = function(idx)
		self.uiList[self.curTab]:isSelected(false)
		if idx == 2001 then	
			self.curTab = 1
			self.uiList[self.curTab]:isSelected(true)
		elseif idx == 2002 then
			self.curTab = 2
			self.uiList[self.curTab]:isSelected(true)
		elseif idx == 2003 then
			self.curTab = 3
			self.uiList[self.curTab]:isSelected(true)
		end

		self:showContent()

		self:showTip()
	end
end

function ActServerView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_x then
				self:close()
			end
		end
	end

	self.Button_x:addTouchEventListener(proClick)

	g_gameCommon.addEventHandler(g_Consts.CustomEvent.NewbieShowTip, function(_,data)
		g_activityData.UpdateServerViewTip()
    end)
end

function ActServerView:updateShowTip()
	self:showTip()
end

function ActServerView:initList()
	for i=1, #actList do
		local part = require("game.uilayer.activity.activityServer.ActServerPartView").new(actList[i], self.partSelect)
		if i == self.curTab then
			part:isSelected(true)
		end

		table.insert(self.uiList, part)
		self.ListView_2:pushBackCustomItem(part)
	end
end

function ActServerView:showContent()
	self.container:removeAllChildren()
	self.content = nil

	if self.curTab == 1 then
		self.content = require("game.uilayer.activity.activityServer.NewbieLogin").new(1)
		self.container:addChild(self.content)
	elseif self.curTab == 2 then
		self.content = require("game.uilayer.activity.activityServer.NewbieLogin").new(2)
		self.container:addChild(self.content)
	elseif self.curTab == 3 then
		self.content = require("game.uilayer.activity.activityServer.NewbieCost").new()
		self.container:addChild(self.content)
	end
end

function ActServerView:updateContent()
	self:showContent()

	self:showTip()

	g_activityData.ShowEffect()
end

function ActServerView:showTip()
	local playerInfo = g_playerInfoData.GetData()
	local loginInfo = g_activityData.GetNewbieLogin()

	local tag = false
	for i=1,#playerInfo.newbie_login do
		if loginInfo.flag[i] == nil then
			tag = true
			break
		end
	end

	if tag == true then
		self.uiList[1]:showTip(true)
	else
		self.uiList[1]:showTip(false)
	end

	local chargeInfo = g_activityData.GetNewbieCharge()
	if (#chargeInfo) > 0 then
		local dataList = {}
		local time = math.ceil((g_clock.getCurServerTime() - self.player.create_time)/3600/24)

		for i=1,#g_data.act_newbie_recharge do
			if time >= g_data.act_newbie_recharge[i].open_date and time <= g_data.act_newbie_recharge[i].close_date then
				table.insert(dataList, g_data.act_newbie_recharge[i])
			end
		end

		if (#dataList) > 0 then
			for i=1,#chargeInfo do
				local t = false
				if chargeInfo[i].period == dataList[1].period then
					if #chargeInfo[i].flag <= 0 then
						self.uiList[2]:showTip(false)
						break
					end

					for j=1, #dataList do
						local tag = false
						for k=1, #chargeInfo[i].flag do
							if tonumber(chargeInfo[i].flag[k]) == dataList[j].recharge_price then
								tag = true
								break
							end
						end

						if tag == false then
							self.uiList[2]:showTip(true)
							t = true
							break
						else
							self.uiList[2]:showTip(false)
						end
					end
				end

				if t == true then
					break
				end
			end
		end
	end

	local costInfo = g_activityData.GetNewbieConsume()
	if(#costInfo) > 0 then
		local dataList = {}
		local time = math.ceil((g_clock.getCurServerTime() - self.player.create_time)/3600/24)

		local period = 0
		for i=1,#g_data.act_newbie_cost do
			if time >= g_data.act_newbie_cost[i].open_date and time <= g_data.act_newbie_cost[i].close_date then
				table.insert(dataList, g_data.act_newbie_cost[i])
				period = g_data.act_newbie_cost[i].period
			end
		end

		if #dataList > 0 then
			
			local curData = nil
			local gem = 0

			for i=1, #costInfo do
				local tag = false
				if costInfo[i].period == period then
					gem = costInfo[i].gem
					for j=1, #dataList do
						if costInfo[i].flag[j..""] then
							tag = true
							gem = gem - dataList[j].cost_price
						else
							tag = false
							curData = dataList[j]
							break
						end
					end

					if tag == false then
						if curData.cost_price <= gem then
							self.uiList[3]:showTip(true)
						end
						break
					end
				end
			end
		end
	end
end

return ActServerView