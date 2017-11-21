local LoginRewardView = class("LoginRewardView", function()
	return cc.Layer:create()
end)

function LoginRewardView:ctor()
	self.mode = require("game.uilayer.activity.ActivityMode").new()

	self.layer = cc.CSLoader:createNode("Cumulative_main1.csb")
	self:addChild(self.layer)

	self.ListView_1 = self.layer:getChildByName("ListView_1")

	self.Panel_1 = self.layer:getChildByName("Panel_1")
	self.Text_8 = self.Panel_1:getChildByName("Text_8")
	self.Text_8_0 = self.Panel_1:getChildByName("Text_8_0")

	self.Text_8:setString(g_tr("actEnd"))

	self:initFun()

	local function getData(data)
		self.data = data.activity
		self.login = data.login

		if self.data == nil then
			return
		end

		self:setData()
	end

	self.mode:loginCharge(getData)
end

function LoginRewardView:initFun()
	self.getReward = function(days)
		self.mode:loginReward(days, self.update)
	end

	self.update = function()
		g_airBox.show(g_tr("fetchSucess"))
		local function getData(data)
			self.data = data.activity
			self.login = data.login

			if self.data == nil then
				return
			end

			self:setData()
			end

		self.mode:loginCharge(getData)
	end
end

function LoginRewardView:setData()
	self.ListView_1:removeAllItems()

	local tem = {}
	for key, value in pairs(self.data.activity_para.reward) do
		tem[tonumber(key)] = value
	end

	for key, value in pairs(tem) do
		local tag = false
		for i=1, #self.login.flag do
			if tonumber(key) == tonumber(self.login.flag[i]) then
				tag = true
				break
			end	
		end
		local item = require("game.uilayer.activity.loginReward.LoginItemView").new(key, value.drop, 1, self.login.days, tag, self.getReward)
		self.ListView_1:pushBackCustomItem(item)
	end

	self:processTime()
end

function LoginRewardView:processTime()
    local function updateTime()
        local dt = self.data.end_time - g_clock.getCurServerTime()

        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.time)
            self.time = nil
            self.ListView_1:removeAllItems()
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

function LoginRewardView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self.layer:runAction(action)
  return action
end 

function LoginRewardView:unschedule(action)
  self.layer:stopAction(action)
end

return LoginRewardView