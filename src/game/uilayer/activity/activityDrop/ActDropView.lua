local ActDropView = class("ActDropView", function() 
	return cc.Layer:create()
end)

function ActDropView:ctor()
	self.mode = require("game.uilayer.activity.ActivityMode").new()

	self.layer = cc.CSLoader:createNode("Strange_main1.csb")
	self:addChild(self.layer)

	self.Text_8 = self.layer:getChildByName("Panel_1"):getChildByName("Text_8")
	self.Text_8_0 = self.layer:getChildByName("Panel_1"):getChildByName("Text_8_0")

	self.Text_ew = self.layer:getChildByName("Text_ew")
	self.Text_sm = self.layer:getChildByName("Text_sm")
	self.Text_n_0 = self.layer:getChildByName("Text_n_0")
	self.Text_n = self.layer:getChildByName("Text_n")
	self.ListView_1 = self.layer:getChildByName("ListView_1")
	self.Image_40 = self.layer:getChildByName("Image_40")

	self.Text_8:setString(g_tr("actEnd"))
	self.Text_sm:setString(g_tr("MapBuildDesc"))

	local function getData(data)
		self.data = data.activity
		if self.data == nil then
			return
		end

		self:setData()
	end

	self.mode:npcDrop(getData)
end

function ActDropView:setData()
	self.Text_ew:setString(self.data.activity_para.name)
	self.Text_n_0:setString(self.data.activity_para.memo)

	local item = require("game.uilayer.common.DropItemView").new(tonumber(self.data.activity_para.npc.drop[1][1]),tonumber(self.data.activity_para.npc.drop[1][2]),tonumber(self.data.activity_para.npc.drop[1][3]))
	self.Image_40:addChild(item)
	item:setPosition(self.Image_40:getContentSize().width/2, self.Image_40:getContentSize().height/2)

	self.Text_n:setString(g_tr("actDrop", {item = item:getName()}))

	local data = g_data.item[tonumber(item:getConfigId())]
	for i=1, #data.drop do
		for j=1, #g_data.drop[tonumber(data.drop[i])].drop_data do
			local item = require("game.uilayer.activity.loginReward.RewardItemView").new(g_data.drop[tonumber(data.drop[i])].drop_data[j])
			self.ListView_1:pushBackCustomItem(item)
		end
	end

	self:processTime()
end

function ActDropView:processTime()
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

function ActDropView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self.layer:runAction(action)
  return action
end 

function ActDropView:unschedule(action)
  self.layer:stopAction(action)
end

return ActDropView