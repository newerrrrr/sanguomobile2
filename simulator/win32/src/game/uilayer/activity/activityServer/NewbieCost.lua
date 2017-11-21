local NewbieCost = class("NewbieCost", function() 
	return cc.Layer:create()
end)

function NewbieCost:ctor()

	self.mode = require("game.uilayer.activity.ActivityMode").new()

	self.layer = cc.CSLoader:createNode("Consumption_main1.csb")

	self:addChild(self.layer)

	self.Text_8 = self.layer:getChildByName("Text_8")
	self.Text_8_0 = self.layer:getChildByName("Text_8_0")
	self.Text_9 = self.layer:getChildByName("Text_9")
	self.Text_sz = self.layer:getChildByName("Text_sz")

	self.ListView_1 = self.layer:getChildByName("ListView_1")
	self.LoadingBar_1 = self.layer:getChildByName("LoadingBar_1")
	self.Text_sz1 = self.layer:getChildByName("Text_sz1")
	
	self.Button_1 = self.layer:getChildByName("Button_1")
	self.Text_5 = self.Button_1:getChildByName("Text_5")

	self.Text_8:setString(g_tr("actEnd"))
	self.Text_9:setString("")
	self.Text_5:setString(g_tr("taskGetReceive"))

	self.player = g_PlayerMode.GetData()
	self.data = g_activityData.GetNewbieConsume()

	local max = 0
	for i=1, #g_data.act_newbie_cost do
		if g_data.act_newbie_cost[i].close_date > max then
			max = g_data.act_newbie_cost[i].close_date
		end
	end

	self.endTime = self.player.create_time + max*24*3600

	self:initFun()
	self:showTime()
	self:setData()
	self:addEvent()
end

function NewbieCost:initFun()
	self.update = function()
		self.data = g_activityData.GetNewbieConsume()
		self.ListView_1:removeAllItems()
		self:setData()
	end
end

function NewbieCost:setData()
	self.id = 1
	if #self.data == 0 then
		self.Text_sz1:setString("0/"..g_data.act_newbie_cost[1].cost_price)
		self.LoadingBar_1:setPercent(0)
	else
		local dataList = {}
		local time = math.ceil((g_clock.getCurServerTime() - self.player.create_time)/3600/24)

		local period = 0
		for i=1,#g_data.act_newbie_cost do
			if time >= g_data.act_newbie_cost[i].open_date and time <= g_data.act_newbie_cost[i].close_date then
				table.insert(dataList, g_data.act_newbie_cost[i])
				period = g_data.act_newbie_cost[i].period
			end
		end

		local curData = nil
		local gem = 0

		for i=1, #self.data do
			if self.data[i].period == period then
				local tag = false
				gem = self.data[i].gem
				for j=1, #dataList do
					if self.data[i].flag[dataList[j].id..""] == nil then
						tag = true
						curData = dataList[j]
						break
					end
				end

				for key, value in pairs(self.data[i].flag) do
					local s = g_data.act_newbie_cost[tonumber(key)]
					gem = gem - s.cost_price * value
				end

				if tag == true then
					break
				else
					curData = g_data.act_newbie_cost[(#g_data.act_newbie_cost)]
				end
			end
		end

		if curData == nil and gem == 0 then
			curData = g_data.act_newbie_cost[1]
		else
			if curData == nil then
				curData = g_data.act_newbie_cost[(#g_data.act_newbie_cost)]
			end
		end
		
		local idx = math.floor(gem*100/g_data.act_newbie_cost[curData.id].cost_price)
		self.LoadingBar_1:setPercent(idx)

		self.id = curData.id
		self.Text_sz1:setString(gem.."/"..g_data.act_newbie_cost[self.id].cost_price)
	end

	self.Text_sz:setString(g_data.act_newbie_cost[self.id].cost_price.."")
	

	local canMove = 0
	for i=1,#g_data.act_newbie_cost[self.id].drop do
		local dropData = g_data.drop[g_data.act_newbie_cost[self.id].drop[i]]
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

function NewbieCost:update()
	self.update()
end

function NewbieCost:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1 then
				self.mode:newbieConsumeReward(self.id, self.update)
			end
		end
	end

	self.Button_1:addTouchEventListener(proClick)
end

function NewbieCost:showTime()
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
    	self.Text_8:setString(g_tr("actEnd"))
        self.time = self:schedule(updateTime, 1.0)
        updateTime()
    else
    	self.Text_8:setString(g_tr("actOver"))
    	self.Text_8_0:setString("")
    end
end

function NewbieCost:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self.layer:runAction(action)
  return action
end 

function NewbieCost:unschedule(action)
  self.layer:stopAction(action)
end

return NewbieCost