local GuildWarInfoView = class("GuildWarInfoView", require("game.uilayer.base.BaseLayer"))

local _instance = nil

function GuildWarInfoView:onEnter()
	_instance = self
end

function GuildWarInfoView:onExit()
	_instance = nil
end

function GuildWarInfoView.show()
	if _instance == nil then
		local layer = require("game.uilayer.guildwar.GuildWarInfoView").new()
		g_sceneManager.addNodeForUI(layer)
	end
end

function GuildWarInfoView:ctor()
	GuildWarInfoView.super.ctor(self)

	self.layer = self:loadUI("guildwar_main1_xin1.csb")

	self.root = self.layer:getChildByName("scale_node")
	self.Image_lianmtb1 = self.root:getChildByName("Image_lianmtb1")
	self.Image_lianmtb2 = self.root:getChildByName("Image_lianmtb2")

	self.Text_mc1 = self.root:getChildByName("Text_mc1")
	self.Text_mc2 = self.root:getChildByName("Text_mc2")

	self.Button_1 = self.root:getChildByName("Button_1")
	self.btnTxt = self.Button_1:getChildByName("Text_5")
	self.btnTxt:setString(g_tr("closed"))

	self.Panel_xx = self.root:getChildByName("Panel_xx")

	self.Panel_z1 = self.Panel_xx:getChildByName("Panel_z1")
	self.Panel_z1_Text_1 = self.Panel_z1:getChildByName("Text_1")
	--g
	self.Image_4 = self.Panel_z1:getChildByName("Image_4")
	--x
	self.Image_44 = self.Panel_z1:getChildByName("Image_44")
	--x
	self.Image_4_0 = self.Panel_z1:getChildByName("Image_4_0")
	--g
	self.Image_4_0_0 = self.Panel_z1:getChildByName("Image_4_0_0")
	self.Panel_z1_Text_1:setString(g_tr("poDoor"))

	self.Panel_z2 = self.Panel_xx:getChildByName("Panel_z2")
	self.Panel_z2_Text_h1 = self.Panel_z2:getChildByName("Text_h1")
	self.Panel_z2_Text_1 = self.Panel_z2:getChildByName("Text_1")
	self.Panel_z2_Text_h2 = self.Panel_z2:getChildByName("Text_h2")
	self.Panel_z2_Text_1:setString(g_tr("spTime"))
	self.Panel_z2_Image_1 = self.Panel_z2:getChildByName("Image_1")
	self.Panel_z2_Text_2 = self.Panel_z2:getChildByName("Text_2")
	self.Panel_z2_Image_1_0 = self.Panel_z2:getChildByName("Image_1_0")
	self.Panel_z2_Text_2_0 = self.Panel_z2:getChildByName("Text_2_0")
	self.Panel_z2_Text_2:setString(g_tr("lessTime"))
	self.Panel_z2_Text_2_0:setString(g_tr("lessTime"))

	self.Panel_z3 = self.Panel_xx:getChildByName("Panel_z3")
	self.Panel_z3_Text_h1 = self.Panel_z3:getChildByName("Text_h1")
	self.Panel_z3_Text_1 = self.Panel_z3:getChildByName("Text_1")
	self.Panel_z3_Text_h2 = self.Panel_z3:getChildByName("Text_h2")
	self.Panel_z3_Text_1:setString(g_tr("kiNum"))
	self.Panel_z3_Image_1 = self.Panel_z3:getChildByName("Image_1")
	self.Panel_z3_Text_2 = self.Panel_z3:getChildByName("Text_2")
	self.Panel_z3_Image_1_0 = self.Panel_z3:getChildByName("Image_1_0")
	self.Panel_z3_Text_2_0 = self.Panel_z3:getChildByName("Text_2_0")
	self.Panel_z3_Text_2:setString(g_tr("killMore"))
	self.Panel_z3_Text_2:setString(g_tr("killMore"))

	self.Panel_z4 = self.Panel_xx:getChildByName("Panel_z4")
	self.Panel_z4_Text_1 = self.Panel_z4:getChildByName("Text_1")
	--w
	self.Panel_z4_Image_11 = self.Panel_z4:getChildByName("Image_11")
	--l
	self.Panel_z4_Image_11_0_0 = self.Panel_z4:getChildByName("Image_11_0_0")
	--l
	self.Panel_z4_Image_11_0 = self.Panel_z4:getChildByName("Image_11_0")
	--w
	self.Panel_z4_Image_11_1 = self.Panel_z4:getChildByName("Image_11_1")
	self.Panel_z4_Text_1:setString(g_tr("reInfo"))

	self.data = g_guildWarBattleInfoData.GetData()
	self.topData = g_guildWarBattleInfoData.GetTopPlayerData()

	self:setData()
	self:addAnimation()
	self:addEvent()
end

function GuildWarInfoView:setData()
	self.Text_mc1:setString(self.data.guild_1_name)
	self.Text_mc2:setString(self.data.guild_2_name)

	self.Image_lianmtb1:loadTexture(g_resManager.getResPath(g_data.alliance_flag[tonumber(self.data.guild_1_avatar)].res_flag))
	self.Image_lianmtb2:loadTexture(g_resManager.getResPath(g_data.alliance_flag[tonumber(self.data.guild_2_avatar)].res_flag))

	self.Panel_z2_Text_h1:setString(g_gameTools.convertSecondToString(tonumber(self.data.guild_1_time)))
	self.Panel_z2_Text_h2:setString(g_gameTools.convertSecondToString(tonumber(self.data.guild_2_time)))


	if tonumber(self.data.guild_1_time) == tonumber(self.data.guild_2_time) then
		self.Panel_z3_Text_h1:setString(self.data.guild_1_kill.."")
		self.Panel_z3_Text_h2:setString(self.data.guild_2_kill.."")

		self.Panel_z2_Image_1:setVisible(false)
		self.Panel_z2_Text_2:setVisible(false)
		self.Panel_z2_Image_1_0:setVisible(false)
		self.Panel_z2_Text_2_0:setVisible(false)

		if tonumber(self.data.guild_1_kill) > tonumber(self.data.guild_2_kill) then
			self.Panel_z3_Image_1:setVisible(true)
			self.Panel_z3_Text_2:setVisible(true)
			self.Panel_z3_Image_1_0:setVisible(false)
			self.Panel_z3_Text_2_0:setVisible(false)
		elseif tonumber(self.data.guild_1_kill) < tonumber(self.data.guild_2_kill) then
			self.Panel_z3_Image_1:setVisible(false)
			self.Panel_z3_Text_2:setVisible(false)
			self.Panel_z3_Image_1_0:setVisible(true)
			self.Panel_z3_Text_2_0:setVisible(true)
		else
			self.Panel_z3_Image_1:setVisible(false)
			self.Panel_z3_Text_2:setVisible(false)
			self.Panel_z3_Image_1_0:setVisible(false)
			self.Panel_z3_Text_2_0:setVisible(false)
		end
	else
		self.Panel_z3_Text_h1:setString("--")
		self.Panel_z3_Text_h2:setString("--")

		self.Panel_z3_Image_1:setVisible(false)
		self.Panel_z3_Text_2:setVisible(false)
		self.Panel_z3_Image_1_0:setVisible(false)
		self.Panel_z3_Text_2_0:setVisible(false)

		if tonumber(self.data.guild_1_time) < tonumber(self.data.guild_2_time) then
			self.Panel_z2_Image_1:setVisible(true)
			self.Panel_z2_Text_2:setVisible(true)
			self.Panel_z2_Image_1_0:setVisible(false)
			self.Panel_z2_Text_2_0:setVisible(false)
		else
			self.Panel_z2_Image_1:setVisible(false)
			self.Panel_z2_Text_2:setVisible(false)
			self.Panel_z2_Image_1_0:setVisible(true)
			self.Panel_z2_Text_2_0:setVisible(true)
		end
	end
	

	if tonumber(self.data.guild_1_beat) == 1 then
		self.Image_4:setVisible(true)
		self.Image_44:setVisible(false)
	else
		self.Image_4:setVisible(false)
		self.Image_44:setVisible(true)
	end

	if tonumber(self.data.guild_2_beat) == 1 then
		self.Image_4_0_0:setVisible(true)
		self.Image_4_0:setVisible(false)
	else
		self.Image_4_0_0:setVisible(false)
		self.Image_4_0:setVisible(true)
	end

	if tonumber(self.data.win) == 1 then
		self.Panel_z4_Image_11:setVisible(true)
		self.Panel_z4_Image_11_0_0:setVisible(false)
		self.Panel_z4_Image_11_0:setVisible(true)
		self.Panel_z4_Image_11_1:setVisible(false)
	else
		self.Panel_z4_Image_11:setVisible(false)
		self.Panel_z4_Image_11_0_0:setVisible(true)
		self.Panel_z4_Image_11_0:setVisible(false)
		self.Panel_z4_Image_11_1:setVisible(true)
	end
end

function GuildWarInfoView:addAnimation()
	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuZhanChangHuiHeShengLiShiBai/Effect_KuaFuZhanChangHuiHeShengLiShiBai.ExportJson", "Effect_KuaFuZhanChangHuiHeShengLiShiBai")
	self.root:addChild(armature)
	armature:setPosition(cc.p(self.root:getContentSize().width*0.5,self.root:getContentSize().height*0.5))
	if tonumber(self.data.win) == 2 then
		if g_guildWarPlayerData.getGuildId() == self.data.guild_2_id then
			animation:play("ShengLi")
		else
			animation:play("ShiBai")
		end
	elseif tonumber(self.data.win) == 1 then
		if g_guildWarPlayerData.getGuildId() == self.data.guild_1_id then
			animation:play("ShengLi")
		else
			animation:play("ShiBai")
		end
	end
end

function GuildWarInfoView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1 then
				local battleStatus = g_guildWarBattleInfoData.GetData().status
				if battleStatus == 7 then
					if g_activityData.RequestCrossBasicInfo() == true then
						require("game.maplayer.changeMapScene").changeToHome()
					end
				end
				self:close()
			end
		end
	end
	
	self.Button_1:addTouchEventListener(proClick)
end

return GuildWarInfoView