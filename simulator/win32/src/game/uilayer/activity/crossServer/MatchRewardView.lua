local MatchRewardView = class("MatchRewardView", require("game.uilayer.base.BaseLayer"))

function MatchRewardView:ctor()
	self.curReward = 1

	MatchRewardView.super.ctor(self)

	self.layer = self:loadUI("activity3_popup1.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.close_btn = self.root:getChildByName("close_btn")
	self.bg_text = self.root:getChildByName("bg_goods_name"):getChildByName("text")

	self.ListView_1 = self.root:getChildByName("Panel_1"):getChildByName("ListView_1")
	self.ListView_1_0 = self.root:getChildByName("Panel_1"):getChildByName("ListView_1_0")

	self.Button_1 = self.root:getChildByName("Button_1")
	self.Button_2 = self.root:getChildByName("Button_2")
	self.txtBtn_1 = self.Button_1:getChildByName("Text_1")
	self.txtBtn_2 = self.Button_2:getChildByName("Text_1")
	self.txtBtn_1:setString(g_tr("enterReward"))
	self.txtBtn_2:setString(g_tr("allAllianceReward"))

	self:setHightLight(self.Button_1)

	self.data1 = g_data.drop[tonumber(g_data.warfare_service_config[32].data)]
	self.data2 = g_data.drop[tonumber(g_data.warfare_service_config[33].data)]
	self.winData = g_data.drop[tonumber(g_data.warfare_service_config[34].data)]
	self.loseData = g_data.drop[tonumber(g_data.warfare_service_config[46].data)]
	self.bg_text:setString(g_tr("zhuanpanCk"))

	self:addEvent()

	self:init()
end

function MatchRewardView:init()
	self.ListView_1:removeAllItems()
	self.ListView_1_0:removeAllItems()

	if self.curReward == 1 then
		for i=1, #self.data1.drop_data do
			local item = require("game.uilayer.activity.crossServer.RewardItemView").new(self.data1.drop_data[i], "")

			self.ListView_1:pushBackCustomItem(item)
		end

		for i=1, #self.data2.drop_data do
			local item = require("game.uilayer.activity.crossServer.RewardItemView").new(self.data2.drop_data[i], "")

			self.ListView_1_0:pushBackCustomItem(item)
		end
	else
		for i=1, #self.winData.drop_data do
			local item = require("game.uilayer.activity.crossServer.RewardItemView").new(self.winData.drop_data[i], "")

			self.ListView_1:pushBackCustomItem(item)
		end

		for i=1, #self.loseData.drop_data do
			local item = require("game.uilayer.activity.crossServer.RewardItemView").new(self.loseData.drop_data[i], "")

			self.ListView_1_0:pushBackCustomItem(item)
		end
	end
end

function MatchRewardView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			elseif sender == self.Button_1 then
				if self.curReward == 1 then
					return
				end
				self.curReward = 1
				self:setHightLight(self.Button_1)
				self:init()
			elseif sender == self.Button_2 then
				if self.curReward == 2 then
					return
				end
				self.curReward = 2
				self:setHightLight(self.Button_2)
				self:init()
			end
		end
	end
	self.close_btn:addTouchEventListener(proClick)
	self.Button_1:addTouchEventListener(proClick)
	self.Button_2:addTouchEventListener(proClick)
end

function MatchRewardView:setHightLight(btn)
	self.Button_1:setBrightStyle(BRIGHT_NORMAL)
	self.Button_2:setBrightStyle(BRIGHT_NORMAL)

	btn:setBrightStyle(BRIGHT_HIGHLIGHT)
end

return MatchRewardView