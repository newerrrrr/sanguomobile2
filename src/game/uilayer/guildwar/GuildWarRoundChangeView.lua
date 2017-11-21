local GuildWarRoundChangeView = class("GuildWarRoundChangeView", require("game.uilayer.base.BaseLayer"))

local _instance = nil

function GuildWarRoundChangeView:onEnter()
	_instance = self
end

function GuildWarRoundChangeView:onExit()
	_instance = nil
end

function GuildWarRoundChangeView.show()
	if _instance == nil then
		g_sceneManager.addNodeForTopEffect(require("game.uilayer.guildwar.GuildWarRoundChangeView").new())
	end
end

function GuildWarRoundChangeView:ctor()
	GuildWarRoundChangeView.super.ctor(self)

	self.layer = self:loadUI("guildwar_main1.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.Image_lianmtb1 = self.root:getChildByName("Image_lianmtb1")
	self.Image_lianmtb2 = self.root:getChildByName("Image_lianmtb2")

	self.Text_mc1 = self.root:getChildByName("Text_mc1")
	self.Text_mc2 = self.root:getChildByName("Text_mc2")

	self.ListView_1 = self.root:getChildByName("ListView_1")
	self.Button_1 = self.root:getChildByName("Button_1")
	self.Text_5 = self.Button_1:getChildByName("Text_5")
	self.Text_4 = self.root:getChildByName("Text_4")
	self.Text_3 = self.root:getChildByName("Text_3")
	self.Text_szzz = self.root:getChildByName("Text_szzz")
	self.Text_szzz:setString("")

	self.Text_mc1_0 = self.root:getChildByName("Text_mc1_0")
	self.Text_mc1_0_0 = self.root:getChildByName("Text_mc1_0_0")

	self.Text_mc1_0_0:setString(g_tr("killRank"))

	self.Button_1:setVisible(false)

	self:addEvent()

	self.data = g_guildWarBattleInfoData.GetData()

	self.topData = g_guildWarBattleInfoData.GetTopPlayerData()

	if self.data.status >= 5 then
		--self.Text_szzz:setString(g_tr("num2"))
		self.Text_mc2:setString(self.data.guild_1_name)
		self.Text_mc1:setString(self.data.guild_2_name)

		self.Image_lianmtb2:loadTexture(g_resManager.getResPath(g_data.alliance_flag[self.data.guild_1_avatar].res_flag))
		self.Image_lianmtb1:loadTexture(g_resManager.getResPath(g_data.alliance_flag[self.data.guild_2_avatar].res_flag))

		self.Text_mc1_0:setString(g_tr("spendTime")..g_gameTools.convertSecondToString(self.data.guild_2_time))
	else
		--self.Text_szzz:setString(g_tr("num1"))
		self.Text_mc1:setString(self.data.guild_1_name)
		self.Text_mc2:setString(self.data.guild_2_name)

		self.Image_lianmtb1:loadTexture(g_resManager.getResPath(g_data.alliance_flag[self.data.guild_1_avatar].res_flag))
		self.Image_lianmtb2:loadTexture(g_resManager.getResPath(g_data.alliance_flag[self.data.guild_2_avatar].res_flag))

		self.Text_mc1_0:setString(g_tr("spendTime")..g_gameTools.convertSecondToString(self.data.guild_1_time))
	end
	
	if self.data.status == 6 or self.data.status == 7 then
		local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuZhanChangHuiHeShengLiShiBai/Effect_KuaFuZhanChangHuiHeShengLiShiBai.ExportJson", "Effect_KuaFuZhanChangHuiHeShengLiShiBai")
    	self.root:addChild(armature)
		armature:setPosition(cc.p(self.root:getContentSize().width*0.5,self.root:getContentSize().height*0.5))
		if self.data.win == 2 then
			if g_guildWarBattleInfoData.IsAttacker() then
				animation:play("ShengLi")
			else
				animation:play("ShiBai")
			end
		else
			if g_guildWarBattleInfoData.IsAttacker() then
				animation:play("ShiBai")
			else
				animation:play("ShengLi")
			end
		end
	else
		local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuYinZhang/Effect_KuaFuYinZhang.ExportJson", "Effect_KuaFuYinZhang")
    	self.root:addChild(armature)
		armature:setPosition(cc.p(self.root:getContentSize().width*0.5,self.root:getContentSize().height*0.5))
		if self.data.guild_1_beat == 1 then
			animation:play("JiPo")
		else
			animation:play("ShiJianOver")
		end
	end

	self.Text_5:setString(g_tr("gotoNextRound"))
	self.Text_4:setString(g_tr("closed"))
	self.Text_3:setString("10")

	self:setTime()

	if self.topData ~= nil and self.topData.attack ~= nil and self.topData.defend ~= nil then
		local len = 0
		if table.nums(self.topData.attack) > table.nums(self.topData.defend) then
			len = table.nums(self.topData.attack)
		else
			len = table.nums(self.topData.defend)
		end

		for i=1, len do
			local item = require("game.uilayer.guildwar.RoundChangeItemView").new(self.topData.attack[i], self.topData.defend[i], i)
			self.ListView_1:pushBackCustomItem(item)
		end
	end
end

function GuildWarRoundChangeView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1 then
				if self.time ~= nil then
					self:unschedule(self.time)
					self.time = nil
				end

				local battleStatus = g_guildWarBattleInfoData.GetData().status
				if battleStatus == 7 then
					if g_activityData.RequestCrossBasicInfo() == true then
						require("game.maplayer.changeMapScene").changeToHome()
					end
				end

				g_groundData.RequestSycCrossData()

				self:close()
			end
		end
	end
	self.Button_1:addTouchEventListener(proClick)
end

function GuildWarRoundChangeView:setTime()
	local data = g_clock.getCurServerTime() + 10

	local function update(dt)

		local t = data - g_clock.getCurServerTime()
		if t < 0 then
			t = 0
		end

		local battleStatus = g_guildWarBattleInfoData.GetData().status
		if battleStatus == g_guildWarBattleInfoData.StatusType.STATUS_ATTACK_CLAC 
		or battleStatus == g_guildWarBattleInfoData.StatusType.STATUS_DEFEND_CLAC then
			if t == 0 then
				data = g_clock.getCurServerTime() + 10
			end
			self.Button_1:setVisible(false)
			self.Text_3:setString(g_gameTools.convertSecondToString(t))
			self.Text_4:setString(g_tr("closed"))
		else
			self.Button_1:setVisible(true)
			self.Text_3:setString("")
			self.Text_4:setString("")
		end
	end

	if self.time ~= nil then
		self:unschedule(self.time)
		self.time = nil
	end
	self.time = self:schedule(update, 1)
	update()
end

return GuildWarRoundChangeView