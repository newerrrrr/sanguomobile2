local ActivityBanner = class("ActivityBanner", require("game.uilayer.base.BaseLayer"))

function ActivityBanner:onExit()
	g_gameCommon.removeEventHandler(g_Consts.CustomEvent.GiudeTrigged,self)
end

function ActivityBanner:ctor(activityId)
	ActivityBanner.super.ctor(self)

	self.curAct = activityId

	self.layer = self:loadUI("AdvertisingGifts_main2.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.Image_huantu = self.root:getChildByName("Image_huantu")
	self.Text_jrhd = self.root:getChildByName("Text_jrhd")
	self.Text_sm1 = self.root:getChildByName("ListView_1"):getChildByName("Text_sm1")
	self.Text_sm2 = self.root:getChildByName("ListView_1"):getChildByName("Text_sm2")

	self.Button_chakan = self.root:getChildByName("Button_chakan")
	self.Text_chakan = self.Button_chakan:getChildByName("Text_chakan")
	self.close_btn = self.root:getChildByName("close_btn")

	self.Text_chakan:setString(g_tr("seeDetail"))
	self.Text_jrhd:setString(g_tr("actToday"))
	self.Text_sm1:setString(g_tr("actInfoTitle"))

	self:addEvent()

	self:setData(self.curAct)
end

function ActivityBanner:setData(activityId)
	if activityId == 1002 then
		--限时比赛
		local data = require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").GetCustomMatchInfo()
		for key, value in pairs(g_data.time_limit_match) do
			if value.match_type[1] == data.match_type then
				self.data = value
				break
			end
		end

	elseif activityId == 1003 then
		--联盟任务
		local MissionMode = require("game.uilayer.activity.allianceMission.AllianceMissionMode") 
		local isOpen, missionType = MissionMode:hasMissionOpen()
		print(isOpen, missionType, "@@@@@@@")
		if isOpen == false then
			return
		end

		for key, value in pairs(g_data.alliance_match) do
			if value.match_type[1] == missionType then
				self.data = value
				break
			end
		end
	end

	self.Image_huantu:loadTexture(g_resManager.getResPath(self.data.match_show))

	local txtRich = g_gameTools.createRichText(self.Text_sm2, "")
	txtRich:setRichText(g_tr(self.data.help_desc))
end

function ActivityBanner:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender  == self.Button_chakan then
				require("game.uilayer.activity.ActivityMainLayer").show(self.curAct)
				self:close()
			elseif sender == self.close_btn then
				self:close()
			end
		end
	end

	self.Button_chakan:addTouchEventListener(proClick)
	self.close_btn:addTouchEventListener(proClick)

	local function update()
		self:close()
	end

	g_gameCommon.addEventHandler(g_Consts.CustomEvent.GiudeTrigged, update, self)
end

return ActivityBanner