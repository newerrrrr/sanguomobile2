local RankCrossView = class("RankCrossView", require("game.uilayer.base.BaseLayer"))

function RankCrossView:ctor()
	self.curTab = 1

	self.canChange = true

	RankCrossView.super.ctor(self)

	self.layer = self:loadUI("ranking_panel_check_popup.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.close_btn = self.root:getChildByName("close_btn")
	self.Button_1 = self.root:getChildByName("Button_1")
	self.Button_2 = self.root:getChildByName("Button_2")
	self.Button_1:getChildByName("Text_1"):setString(g_tr("killerCross"))
	self.Button_2:getChildByName("Text_1"):setString(g_tr("allianceCross"))

	self.Text_ph = self.root:getChildByName("Text_ph")
	self.Text_lm = self.root:getChildByName("Text_lm")
	self.Text_wj = self.root:getChildByName("Text_wj")
	self.Text_sds = self.root:getChildByName("Text_sds")
	self.ListView_1 = self.root:getChildByName("ListView_1")

	self:addEvent()

	self.mode = require("game.uilayer.rank.RankMode").new()

	self:setHightLight(self.Button_1)

	self:showData()
end

function RankCrossView:showData()
	self.ListView_1:removeAllItems()

	if self.curTab == 1 then
		self.Text_ph:setString(g_tr("rank"))
		self.Text_lm:setString(g_tr("rankAllience"))
		self.Text_wj:setString(g_tr("playerNickName"))
		self.Text_sds:setString(g_tr("killNum"))

		local function callback1(data)
			self.data = data.rank_list
			if self.data == nil or #(self.data) == 0 then
				return
			end
			self:setKillRankData()
		end

		self.mode:rankList(callback1)
	else
		self.Text_ph:setString("")
		self.Text_lm:setString("")
		self.Text_wj:setString("")
		self.Text_sds:setString("")

		local function callback2(data)
			self.groupData = data.result_list
			if self.groupData == nil or #(self.groupData) == 0 then
				return
			end
			self:setGroupData()
		end

		self.mode:resultList(callback2)
	end
end

function RankCrossView:setKillRankData()
    local idx_s = 1 
    local idx_e = (#self.data)
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
            item = require("game.uilayer.rank.RankCrossItemView").new(self.data[idx_s])
            self.ListView_1:pushBackCustomItem(item)
            
            idx_s = idx_s + 1 

        else
        	self.canChange = true
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
    self.canChange = false
end

function RankCrossView:setGroupData()
	local len = 0
	if (#self.groupData)%2 == 1 then
		len = ((#self.groupData) + 1)/2
	else
		len = (#self.groupData)/2
	end

	local idx_s = 1 
    local idx_e = len
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
            item = require("game.uilayer.rank.RankGroupItemView").new(self.groupData[idx_s*2-1], self.groupData[idx_s*2])
            self.ListView_1:pushBackCustomItem(item)
            
            idx_s = idx_s + 1 

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

function RankCrossView:setHightLight(btn)
	self.Button_1:setBrightStyle(BRIGHT_NORMAL)
	self.Button_2:setBrightStyle(BRIGHT_NORMAL)

	btn:setBrightStyle(BRIGHT_HIGHLIGHT)
end

function RankCrossView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			elseif sender == self.Button_1 then
				if self.curTab == 1 or self.canChange == false then
					return
				end
				self:setHightLight(self.Button_1)
				self.curTab = 1
				self:showData()
			elseif sender == self.Button_2 then
				if self.curTab == 2 or self.canChange == false then
					return
				end
				self:setHightLight(self.Button_2)
				self.curTab = 2
				self:showData()
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)
	self.Button_1:addTouchEventListener(proClick)
	self.Button_2:addTouchEventListener(proClick)
end

return RankCrossView