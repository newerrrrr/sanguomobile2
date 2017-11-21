local MoreChargeView = class("MoreChargeView", function()
	return cc.Layer:create()
end)

function MoreChargeView:ctor()
	
	self.mode = require("game.uilayer.activity.ActivityMode").new()

	self.layer = cc.CSLoader:createNode("CumulativeCharge_main1.csb")
	self:addChild(self.layer)

	self.ListView_1 = self.layer:getChildByName("ListView_1")
	self.Panel_1 = self.layer:getChildByName("Panel_1")
	self.Text_8 = self.Panel_1:getChildByName("Text_8")
	self.Text_8_0 = self.Panel_1:getChildByName("Text_8_0")

	self.Text_8:setString(g_tr("actEnd"))

	self:initFun()

	local function getData(data)
		self.data = data.activity
		self.charge = data.charge

		if self.data == nil then
			return
		end

		self:setData()
	end

	self.mode:charge(getData)
	
end

function MoreChargeView:initFun()
	self.getReward = function(gem)
		self.mode:chargeReward(gem, self.update)
	end

	self.update = function()
		g_airBox.show(g_tr("fetchSucess"))
		local function getData(data)
			self.data = data.activity
			self.charge = data.charge

			if self.data == nil then
				return
			end

			self:setData()
			end

		self.mode:charge(getData)
	end
end

function MoreChargeView:setData()
	self.ListView_1:removeAllItems()

	local re = {}
	for key, value in pairs(self.data.activity_para.reward) do
		table.insert(re, key)
	end

	table.sort(re, function(a, b)
		return tonumber(a) < tonumber(b)
	end)
	
	for i=1, #re do
		local tag = false
		for j=1, #self.charge.flag do
			if tonumber(re[i]) == tonumber(self.charge.flag[j]) then
				tag = true
				break
			end	
		end
		
		local item = require("game.uilayer.activity.loginReward.LoginItemView").new(re[i], self.data.activity_para.reward[re[i]].drop, 2, self.charge.gem, tag, self.getReward)
		self.ListView_1:pushBackCustomItem(item)
	end

	self:processTime()
end

function MoreChargeView:processTime()
    local function updateTime()
        local dt = self.data.end_time - g_clock.getCurServerTime()

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

    self.needTime = self.data.end_time - g_clock.getCurServerTime()

    if self.needTime > 0 then
        self.time = self:schedule(updateTime, 1.0)
        updateTime()
    end
end

function MoreChargeView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self.layer:runAction(action)
  return action
end 

function MoreChargeView:unschedule(action)
  self.layer:stopAction(action)
end

return MoreChargeView