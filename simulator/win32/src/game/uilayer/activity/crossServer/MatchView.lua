local MatchView = class("MatchView", function() 
	return cc.Layer:create()
end)

function MatchView:ctor(closeWin)
	self.closeWin = closeWin

	g_activityData.SetInActivity(true)
	
	self.mode = require("game.uilayer.activity.crossServer.CrossMode").new()

	self.layer = cc.CSLoader:createNode("CrossService_main1.csb")

	self:addChild(self.layer)

	self.Text_sz = self.layer:getChildByName("Text_sz")
	self.Button_wenh = self.layer:getChildByName("Button_wenh")
	self.Text_6 = self.layer:getChildByName("Text_6")
	self.Text_6_0 = self.layer:getChildByName("Text_6_0")
	self.Button_ls = self.layer:getChildByName("Button_ls")
	self.btn_ls_Text_21 = self.Button_ls:getChildByName("Text_21")
	self.Button_ls1 = self.layer:getChildByName("Button_ls1")
	self.btn_ls1_Text_21 = self.Button_ls1:getChildByName("Text_21")
	self.Button_wenh = self.layer:getChildByName("Button_wenh")
	self.Image_dt = self.layer:getChildByName("Image_dt")
	self.Image_dt_Text_2 = self.Image_dt:getChildByName("Text_2")
	self.Image_wj = self.layer:getChildByName("Image_wj")
	self.Image_wj_Text_2 = self.Image_wj:getChildByName("Text_2")
	self.Image_phb = self.layer:getChildByName("Image_phb")
	self.Image_phb_Text_2 = self.Image_phb:getChildByName("Text_2")

	self.Text_ts = self.layer:getChildByName("Text_ts")
	self.Text_ts:setString("")

	for i=1, 3 do
		self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Image_6"] = self["Panel_"..i]:getChildByName("Image_6")
		self["Panel_"..i.."_Text_10"] = self["Panel_"..i]:getChildByName("Text_10")
		self["Panel_"..i.."_Text_w1"] = self["Panel_"..i]:getChildByName("Text_w1")
	end

	for i=1, 5 do
		if i== 1 or i == 3 or i == 4 then
			self["Text_"..i] = self.layer:getChildByName("Text_"..i)
			self["Text_"..i.."_0"] = self.layer:getChildByName("Text_"..i.."_0")

			self["Text_"..i.."_0"]:setString("--")
		end
	end

	for i=1, 5 do
		self["Button_"..i] = self.layer:getChildByName("Button_"..i)
		self["Button_"..i.."_Text_5"] = self["Button_"..i]:getChildByName("Text_5")
		self["Button_"..i]:setVisible(false)
	end

	self["Text_1"]:setString(g_tr("groupName"))
	--self["Text_2"]:setString(g_tr("enterRound"))
	self["Text_3"]:setString(g_tr("enterRound"))
	self["Text_4"]:setString(g_tr("winNum"))
	--self["Text_5"]:setString(g_tr("winNum"))
	self["Button_1_Text_5"]:setString(g_tr("signUpMatch"))
	self["Button_2_Text_5"]:setString(g_tr("memberSelect"))
	self["Button_3_Text_5"]:setString(g_tr("matchOpponet"))
	self["Button_4_Text_5"]:setString(g_tr("application"))
	self["Button_5_Text_5"]:setString(g_tr("enterWarfield"))
	--self.Text_6:setString(g_tr("endSignUp"))
	self.btn_ls_Text_21:setString(g_tr("historyReport"))
	self.btn_ls1_Text_21:setString(g_tr("zhuanpanCk"))
	self.Image_dt_Text_2:setString(g_tr("crossSmallMap"))
	self.Image_wj_Text_2:setString(g_tr("armyFomation"))
	self.Image_phb_Text_2:setString(g_tr("rankTitleStr"))
	--[[
	self:setGuildInfo("Panel_1", nil)
	self:setGuildInfo("Panel_2", nil)
	self:setGuildInfo("Panel_3", nil)
	self.Text_6_0:setString("")
	]]

	self.layer:setVisible(false)
	self:addEvent()

	local function callback(data)
		if data == nil  then
			return
		end

		self.player = g_PlayerMode.GetData()
		self.data = data

		g_activityData.SetCrossBasicInfo(data)

		self.layer:setVisible(true)
		self:init()
		self:initFun()
	end

	self.mode:basicInfo(callback)
end

function MatchView:init()
	dump(self.data)

--	self:setGuildInfo("Panel_1", self.data.top_info[2])
--	self:setGuildInfo("Panel_2", self.data.top_info[1])
--	self:setGuildInfo("Panel_3", self.data.top_info[3])

	if self.data.current_guild_info == nil or self.data.first_king_status == 0 then
		self.Text_sz:setString("--")
		self["Text_1_0"]:setString("--")
		self["Text_3_0"]:setString("--")
		self["Text_4_0"]:setString("--")
		self["Button_1"]:setVisible(false)
		self["Button_2"]:setVisible(false)
		self["Button_3"]:setVisible(false)
		self["Button_4"]:setVisible(false)
		self["Button_5"]:setVisible(false)
		self.Button_ls:setVisible(false)
		self.Button_ls1:setVisible(false)
		self.Image_wj:setVisible(false)

		self.Text_6:setString(g_tr("noAllianceNoBattle"))
		self.Text_6_0:setString("")

		self["Panel_1_Text_w1"]:setString("")
		self["Panel_2_Text_w1"]:setString("")
		self["Panel_3_Text_w1"]:setString("")
		return
	end

	if g_AllianceMode.getBaseData() and g_AllianceMode.getBaseData().id  > 0 then
		if self.data.current_guild_info.current_round_id == nil then
			self.Text_sz:setString("1")
		else
			if self.data.current_guild_info.current_round_id == 0 then
				self.Text_sz:setString("1")
			else
				self.Text_sz:setString(self.data.current_guild_info.current_round_id.."")
			end
		end

		if self.data.current_guild_info.current_round_id == nil or self.data.current_guild_info.current_round_id == 1 then
			self["Panel_1_Text_w1"]:setString("")
			self["Panel_2_Text_w1"]:setString("")
			self["Panel_3_Text_w1"]:setString("")
		else
			self["Panel_1_Text_w1"]:setString(g_tr("secondCross"))
			self["Panel_2_Text_w1"]:setString(g_tr("firstCross"))
			self["Panel_3_Text_w1"]:setString(g_tr("thirdCross"))
		end
		
		self["Text_1_0"]:setString(self.data.current_guild_info.guild_name.."")
		self["Text_3_0"]:setString(self.data.current_guild_info.joined_round.."")
		self["Text_4_0"]:setString(self.data.current_guild_info.win_times.."")
		self:setStatus(self.data.current_guild_info.round_status, self.data.current_guild_info.guild_status)
		self:updateTime(self.data.current_guild_info.round_status)
	else
		self.Text_sz:setString("--")
		self["Text_1_0"]:setString("--")
		self["Text_3_0"]:setString("--")
		self["Text_4_0"]:setString("--")
		self["Button_1"]:setVisible(false)
		self["Button_2"]:setVisible(false)
		self["Button_3"]:setVisible(false)
		self["Button_4"]:setVisible(false)
		self["Button_5"]:setVisible(false)
	end
end

function MatchView:initFun()
	self.joinBattle = function(data)
		g_airBox.show(g_tr("signSucc"))
		self.data = data
		self:setStatus(self.data.current_guild_info.round_status, self.data.current_guild_info.guild_status)
		self:updateTime(self.data.current_guild_info.round_status)
		self.Image_wj:setVisible(true)
	end

	self.applySuc = function()
		self["Button_1"]:setVisible(false)
		self["Button_3"]:setVisible(false)
		self["Button_5"]:setVisible(false)
		self["Button_4"]:setVisible(false)
		self["Button_2"]:setVisible(true)
		self.Image_wj:setVisible(true)
	end

	self.updateMemData = function(data)
		self.data.members = data.members
		if data.joinedNumber ~= nil then
			self.data.joined_number = data.joinedNumber
		end
	end
end

function MatchView:setTime(data)
	local time = tonumber(data)

	local function update(t)
		local dt = time - g_clock.getCurServerTime()

		if dt <= 0 then
			self:unschedule(self.time)
			self.time = nil
			self.Text_6:setString(g_tr("waitAMoment"))
			self.Text_6_0:setString("")

			self:getServerData()
			return
		end

		self.Text_6_0:setString(g_gameTools.convertSecondToString(dt))
	end

	if self.time ~= nil then
		self:unschedule(self.time)
		self.time = nil
	end

	if time - g_clock.getCurServerTime() <= 0 then
		self.Text_6:setString(g_tr("waitAMoment"))
		self.Text_6_0:setString("")

		self:getServerData()
	else
		self.time = self:schedule(update, 1)
		update(1)
	end
end

function MatchView:getServerData()
	g_activityData.RequestSycCrossBasicInfo()

	if tonumber(self.data.current_guild_info.round_status) ~= tonumber(g_activityData.GetCrossBasicInfo().current_guild_info.round_status) then
		self.data = g_activityData.GetCrossBasicInfo()
		self:init()
		return
	end

	local function update(dt)
		if tonumber(self.data.current_guild_info.round_status) ~= tonumber(g_activityData.GetCrossBasicInfo().current_guild_info.round_status) then
			self:unschedule(self.sendMessage)
			self.sendMessage = nil

			self.data = g_activityData.GetCrossBasicInfo()
			self:init()
		else
			g_activityData.RequestSycCrossBasicInfo()
		end
	end

	if self.sendMessage ~= nil then
		self:unschedule(self.sendMessage)
		self.sendMessage = nil
	end

	self.sendMessage = self:schedule(update, 2)
	update(2)
end

function MatchView:setGuildInfo(ui, data)
	--dump(data)
	if data == nil  then
		self[ui.."_Image_6"]:setVisible(false)
		self[ui.."_Text_10"]:setString("")
	else
		self[ui.."_Image_6"]:setVisible(true)
		if g_AllianceMode.getGuildId() == 0 then
			self[ui.."_Text_10"]:setString("")
		else
			self[ui.."_Text_10"]:setString(data.guild_name)
		end
		
		self[ui.."_Image_6"]:loadTexture(g_data.sprite[g_data.alliance_flag[data.icon_id].res_flag].path)
	end
end

function MatchView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_ls  then
				g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.MatchRecordView").new(self.data.history))
			elseif sender == self.Button_ls1  then
				g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.MatchRewardView").new())
			elseif sender == self["Button_1"]  then
				self.mode:joinBattle(self.joinBattle)
			elseif sender == self["Button_2"]  then
				local function callback(data)
					if data == nil  then
						return
					end

					self.data = data

					g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.MemberView").new(self.data.members, self.data.joined_number, self.updateMemData))
				end

				self.mode:basicInfo(callback)
			elseif sender == self["Button_4"]  then
				self.mode:applyToJoinBattle(self.applySuc)
			elseif sender == self["Button_5"]  then
				if self.data.current_guild_info.luck_round == 1 then
					g_airBox.show(g_tr("luckyWin"))
					return
				end

				local function enterCallback()
					if self.closeWin ~= nil then
						self.closeWin()
					end

					if g_guildWarPlayerData.RequestAllCrossData() then
						require("game.mapguildwar.changeMapScene").changeToWorld()
					end
				end

				if self.data.current_guild_info.cross_joined_flag == 1 and self.data.current_guild_info.guild_status == 1 and g_guildWarPlayerData.RequestData() then
					local p = g_guildWarPlayerData.GetData()
					if p.status == 0 then
						local mode = require("game.uilayer.drill.DrillMode").new()
						mode:crossEnterBattlefield(enterCallback)
					else
						enterCallback()
					end
				end
			elseif sender == self.Button_wenh then
				require("game.uilayer.common.HelpInfoBox"):show(25)
			elseif sender == self.Image_dt then
				g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.MapInfoView").new())
			elseif sender == self.Image_wj then
				g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.FormationView").new(0))
			elseif sender == self.Image_phb then
				if self.data.current_guild_info == nil then
					return
				end
				if self.data.current_guild_info.round_status >= 3 then
					g_airBox.show(g_tr("notSeeRank"))
					return
				end
				g_sceneManager.addNodeForUI(require("game.uilayer.rank.RankCrossView").new())
			end
		end
	end

	self.Button_ls:addTouchEventListener(proClick)
	self.Button_ls1:addTouchEventListener(proClick)
	self["Button_1"]:addTouchEventListener(proClick)
	self["Button_2"]:addTouchEventListener(proClick)
	self["Button_4"]:addTouchEventListener(proClick)
	self["Button_5"]:addTouchEventListener(proClick)
	self.Button_wenh:addTouchEventListener(proClick)
	self.Image_dt:addTouchEventListener(proClick)
	self.Image_wj:addTouchEventListener(proClick)
	self.Image_phb:addTouchEventListener(proClick)
end

function MatchView:setStatus(status, guild)
	--1.参赛报名
	--2.参赛名单
	--4。申请
	--5。进入战场
	if tonumber(status) == -1 then
		self["Button_1"]:setVisible(false)
		self["Button_2"]:setVisible(false)
		self["Button_3"]:setVisible(false)
		self["Button_4"]:setVisible(false)
		self["Button_5"]:setVisible(false)
		self.Image_wj:setVisible(false)
	elseif tonumber(status) == 0 then
		if guild == 1 then
			self["Button_1"]:setVisible(false)
			if g_AllianceMode.isAllianceManager() then
				self["Button_2"]:setVisible(true)
				self["Button_4"]:setVisible(false)
			else
				local tag = false
				for key, value in pairs(self.data.members) do
					if tonumber(self.player.id) == tonumber(value.player_id) and tonumber(value.application_flag) == 1 then
						tag = true
						break
					end
				end

				if tag == true then
					self["Button_2"]:setVisible(true)
					self["Button_4"]:setVisible(false)
					self.Image_wj:setVisible(true)
				else
					self["Button_2"]:setVisible(false)
					self["Button_4"]:setVisible(true)
					self.Image_wj:setVisible(false)
				end
			end
		else
			if g_AllianceMode.isAllianceManager() then
				self["Button_1"]:setVisible(true)
			else
				self["Button_1"]:setVisible(false)
				self.Text_ts:setString(g_tr("noSign"))
			end
			self["Button_2"]:setVisible(false)
			self["Button_4"]:setVisible(false)
			self.Image_wj:setVisible(false)
		end
		
		
		self["Button_3"]:setVisible(false)
		self["Button_5"]:setVisible(false)
	elseif tonumber(status) == 1 then
		self["Button_1"]:setVisible(false)
		self["Button_3"]:setVisible(false)
		self["Button_5"]:setVisible(false)
		self.Image_wj:setVisible(true)

		if g_AllianceMode.isAllianceManager() then
			self["Button_2"]:setVisible(true)
			self["Button_4"]:setVisible(false)
		else
			local tag = false
			for key, value in pairs(self.data.members) do
				if tonumber(self.player.id) == tonumber(value.player_id) and tonumber(value.application_flag) == 1 then
					tag = true
					break
				end
			end

			if tag == true then
				self["Button_2"]:setVisible(true)
				self["Button_4"]:setVisible(false)
			else
				self["Button_2"]:setVisible(false)
				self["Button_4"]:setVisible(true)
			end
		end
	elseif tonumber(status) == 2 then
		self["Button_1"]:setVisible(false)
		self["Button_3"]:setVisible(false)
		self["Button_4"]:setVisible(false)
		self["Button_5"]:setVisible(false)
		
		if guild == 1 then
			self["Button_2"]:setVisible(true)
			self.Image_wj:setVisible(true)
		else
			self["Button_2"]:setVisible(false)
			self.Image_wj:setVisible(false)
		end
	elseif tonumber(status) == 3 then
		self["Button_1"]:setVisible(false)
		self["Button_2"]:setVisible(false)
		self["Button_3"]:setVisible(false)
		self["Button_4"]:setVisible(false)
		self["Button_5"]:setVisible(false)
		self.Image_wj:setVisible(false)

		if self.data.current_guild_info.cross_joined_flag == 1 and self.data.current_guild_info.guild_status == 1 then
			self["Button_5"]:setVisible(true)
		end
	elseif tonumber(status) == 4 or tonumber(status) == 5 then
		self["Button_1"]:setVisible(false)
		self["Button_2"]:setVisible(false)
		self["Button_3"]:setVisible(false)
		self["Button_4"]:setVisible(false)
		self["Button_5"]:setVisible(false)
		self.Image_wj:setVisible(false)
	end
end

function MatchView:updateTime(status)
	if tonumber(status) == -1 then
		self.Text_6:setString(g_tr("startActivity"))
		self:setTime(self.data.current_guild_info.wf_enroll_start_finish_time)
	elseif tonumber(status) == 0 then
		self.Text_6:setString(g_tr("endSignUp"))
		self:setTime(self.data.current_guild_info.wf_match_start_finish_time)
	elseif tonumber(status) == 1 then
		self.Text_6:setString(g_tr("endMatch"))
		self:setTime(self.data.current_guild_info.open_time)
	elseif tonumber(status) == 2 then
		self.Text_6:setString(g_tr("endMatch"))
		self:setTime(self.data.current_guild_info.open_time)
	elseif tonumber(status) == 3 then
		self.Text_6:setString(g_tr("endMatchEnd"))
		self:setTime(self.data.current_guild_info.wf_award_start_finish_time)
	elseif tonumber(status) == 4 or  tonumber(status) == 5 then
		self.Text_6:setString(g_tr("endActivityEnd"))
		self:setTime(self.data.current_guild_info.wf_close_time)
	end
end

function MatchView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function MatchView:unschedule(action)
  self:stopAction(action)
end


return MatchView