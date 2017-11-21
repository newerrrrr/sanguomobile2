local BattleRecordInfoView = class("BattleRecordInfoView", require("game.uilayer.base.BaseLayer"))

local battleData = require("game.uilayer.battleHall.BattleData")

function BattleRecordInfoView:ctor(id, gotoPos)
	BattleRecordInfoView.super.ctor(self)

	self.gotoPos = gotoPos

	self:initUI()
	self:addEvent()

	self.mode = require("game.uilayer.battleHall.BattleHallMode").new()

	local function getData(result, data)
		if result == false then
			self:close()
			return
		end

		self.data = data.guildBattleLogDetail

		if self.data == nil then
			return
		end

		self:loadItem()
	end

	self.mode:getBattleLogDetail(id, getData)
end

function BattleRecordInfoView:initUI()
	self.layer = self:loadUI("HistoryReport_ReportDetails.csb")

	self.root = self.layer:getChildByName("scale_node")

	self.Text_1 = self.root:getChildByName("Text_1")
	self.close_btn = self.root:getChildByName("close_btn")
	self.Text_c2 = self.root:getChildByName("Text_c2")
	self.Text_01 = self.root:getChildByName("Text_01")
	self.Text_02 = self.root:getChildByName("Text_02")
	self.ListView_1 = self.root:getChildByName("ListView_1")
	self.img_addMenbers = self.root:getChildByName("panel_list"):getChildByName("img_addMenbers")

	self.Text_1:setString(g_tr("battleRecord"))
	self.Text_c2:setString(g_tr("allianceBattleReport"))
	self.Text_01:setString("")
	self.Text_02:setString("")
end

function BattleRecordInfoView:loadItem()
    local index = 0
    local idx_s = 1 
    local idx_e = 7
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
        	if idx_s == 1 then
        		if self:setPlayerInfo() == false then
        			self:unschedule(self.frameLoadTimer) 
                	self.frameLoadTimer = nil
        		end
        	elseif idx_s == 2 then
        		self:setResouceInfo()
        	elseif idx_s == 3 then
        		self:setGodSkill()
        	elseif idx_s == 4 then
        		self:processPlayer()
        	elseif idx_s == 6 then
        		self:setDamangeInfo()
        	elseif idx_s == 7 then
        		self:setPropertyInfo()
        	end
            idx_s = idx_s + 1 
            index = index + 1
        else

            --加载完成
            if self.frameLoadTimer then 
                self:unschedule(self.frameLoadTimer) 
                self.frameLoadTimer = nil  
            end 
        end
    end

    --分侦加载
    if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
    end 
    self.frameLoadTimer = self:schedule(loadItem, 0) 
end

function BattleRecordInfoView:setPlayerInfo()
	self.Text_01:setString(g_tr("battlePos", {X=self.data.detail.x,Y=self.data.detail.y}))
	local player = g_PlayerMode.GetData()
	if tonumber(player.id) == tonumber(self.data.attack_player_id) then
		if self.data.detail.all_dead == true then
			self.Text_02:setString(g_tr("allMyArmyKilled"))
			return false
		end
	end
	self.Text_02:setString(self.data.create_time)

	local playerItem =  require("game.uilayer.battleHall.BattleRecordInfoPlayerItemView").new()
	self.ListView_1:pushBackCustomItem(playerItem)
	if self.data.type == "10" then
		playerItem:setData(self.data.detail.player1, self.data.detail.player2, self.data.is_win, self.data.type, self.data.a_list)
	else
		playerItem:setData(self.data.detail.player1, self.data.detail.player2, self.data.is_win, self.data.type, nil)
	end

	return true
end

function BattleRecordInfoView:setResouceInfo()
	local resourceItem = require("game.uilayer.battleHall.BattleRecordResourceView").new(self.data.detail.resource)
	self.ListView_1:pushBackCustomItem(resourceItem)

	local title1 = require("game.uilayer.battleHall.BattleRecordTitleItemView").new(g_tr("powerReport"),"")
	self.ListView_1:pushBackCustomItem(title1)

	local loseview = require("game.uilayer.battleHall.BattleRecordLoseView").new(self.data.detail.player1,self.data.detail.player2)
	self.ListView_1:pushBackCustomItem(loseview)
end

function BattleRecordInfoView:processPlayer()
	local title2 = require("game.uilayer.battleHall.BattleRecordTitleItemView").new(g_tr("attack"),g_tr("defense"))
	self.ListView_1:pushBackCustomItem(title2)

	local len = 0
	if #self.data.detail.player1.players > #self.data.detail.player2.players then
		len = #self.data.detail.player1.players
	else
		len = #self.data.detail.player2.players
	end
	local u1 = {}
	local u2 = {}

	for i=1, len do
		if self.data.detail.player1.players[i] ~= nil and self.data.detail.player1.players[i].unit then
			if self.data.detail.type == 10 then
				self.data.detail.player1.players[i].key = "npc"
				self.data.detail.player1.players[i].aList = self.data.a_list
			end
			table.insert(u1, self.data.detail.player1.players[i])
		end
		
		if self.data.detail.player2.players[i] ~= nil and self.data.detail.player2.players[i].unit ~= nil then
			local tag = false
			for key, value in pairs(self.data.detail.player2.players[i].unit) do
				if key == "tower" then
					value.key = key
					table.insert(u2, value)
				elseif key == "trap" then
					
				else
					tag = true
				end
			end

			if tag == true then
				table.insert(u2, self.data.detail.player2.players[i])
			end
		end
	end

	len = 0
	if #u1 > #u2 then
		len = #u1
	else
		len = #u2
	end

	for i=1, len do
		local heroView = require("game.uilayer.battleHall.BattleRecordGeneralView").new(u1[i], u2[i])
		self.ListView_1:pushBackCustomItem(heroView)
	end
end

function BattleRecordInfoView:setDamangeInfo()
	local title3 = require("game.uilayer.battleHall.BattleRecordDamageTitle").new()
	self.ListView_1:pushBackCustomItem(title3)

	local u1, max1 = battleData:getInstance():getDamage(self.data.detail.player1)
	local u2, max2 = battleData:getInstance():getDamage(self.data.detail.player2)

	local len = #self.data.detail.player1.players
	if #self.data.detail.player1.players < #self.data.detail.player2.players then
		len = #self.data.detail.player2.players
	end

	for i=1, len do
		local damageView = require("game.uilayer.battleHall.BattleRecordDamageView").new()
		local p1 = nil
		local p2 = nil
		if self.data.detail.player1.players[i] ~= nil then
			p1 = u1[self.data.detail.player1.players[i].player_id]
		end
		if self.data.detail.player2.players[i] ~= nil then
			p2 = u2[self.data.detail.player2.players[i].player_id]
		end
		damageView:show(self.data.detail.player1.players[i], 
			self.data.detail.player2.players[i],
			p1, p2, max1, max2)
		self.ListView_1:pushBackCustomItem(damageView)
	end
end

function BattleRecordInfoView:setPropertyInfo()
	local propertyView = require("game.uilayer.battleHall.BattleRecordProperty").new(self.data.detail.player1.buff,self.data.detail.player2.buff)
	self.ListView_1:pushBackCustomItem(propertyView)
end

function BattleRecordInfoView:setGodSkill()
	local godSkill1 = battleData:getInstance():getGodSkill(self.data.detail.player1)
	local godSkill2 = battleData:getInstance():getGodSkill(self.data.detail.player2)

	local len = 0
	if #godSkill1 > #godSkill2 then
		len = #godSkill1
	else
		len = #godSkill2
	end

	if len > 0 then
		local title1 = require("game.uilayer.battleHall.BattleRecordTitleItemView").new(g_tr("godGenSkill"),"")
		self.ListView_1:pushBackCustomItem(title1)

		for i=1, len do
			local item = require("game.uilayer.battleHall.BattleGodSkillView").new(godSkill1[i], godSkill2[i], self.data.detail.player1, self.data.detail.player2)
			self.ListView_1:pushBackCustomItem(item)
		end
	end
end

function BattleRecordInfoView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			elseif sender == self.img_addMenbers then 
				local MailHelper = require("game.uilayer.mail.MailHelper"):instance() 
				if MailHelper:canMailShared(self.data.id) then 
					require("game.uilayer.chat.ChatMode").shareMailToGuild(self.data, true, function()
						MailHelper:setMailSharedTime(self.data.id, g_clock.getCurServerTime())
						end) 					
				end 
			elseif sender == self.Text_01 then
				if self.gotoPos ~= nil then
					self.gotoPos(self.data.detail.x, self.data.detail.y)
				end
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)
	self.img_addMenbers:addTouchEventListener(proClick)
	self.Text_01:addTouchEventListener(proClick)
end

return BattleRecordInfoView