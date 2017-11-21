--region activity_signAward.lua
--Author : luqingqing
--Date   : 2016/3/28
--此文件由[BabeLua]插件自动生成

local activity_signAward = class("activity_signAward", require("game.uilayer.base.BaseLayer"))

function activity_signAward:ctor()
	activity_signAward.super.ctor(self)
	
	self.data = {}

	--self.confirmData = false

	self.layout = self:loadUI("SignIn_panel.csb")
	self.root = self.layout:getChildByName("scale_node")
	self.Text_qdrq = self.root:getChildByName("Text_qdrq")

	for i=1, 7 do
		self["Panel_"..i] = self.root:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Text_1"] = self["Panel_"..i]:getChildByName("Text_1")
		self["Panel_"..i.."_Text_3"] = self["Panel_"..i]:getChildByName("Text_3")
		self["Panel_"..i.."_Image_wup"] = self["Panel_"..i]:getChildByName("Image_wup")
		self["Panel_"..i.."_Text_1"]:setString(g_tr("day"..i))
		self["Panel_"..i.."_Image_5"] = self["Panel_"..i]:getChildByName("Image_5")
		self["Panel_"..i.."_Image_2hei"] = self["Panel_"..i]:getChildByName("Image_2hei")
		self["Panel_"..i.."_Image_5"]:setVisible(false)
		self["Panel_"..i.."_Image_2hei"]:setVisible(false)
		self["Panel_"..i.."_Text_3"]:setString("")
	end

	self.Button_x = self.root:getChildByName("Button_x")

	local function callback(data)
		g_busyTip.hide_1()
		self.data = data

		if self.data == nil then
			self:close()
			return
		end

		self:initFun()
		self:initUI()
		self:setState()
	end

	self:addEvent()

	self.mode = require("game.uilayer.activity.ActivityMode").new()
	g_busyTip.show_1()
	self.mode:PlayerSignAward(callback)

	self.player = g_PlayerMode.GetData()
	self.vip = g_data.vip_exp_daily
	
	--连续签到天数
	local day = 1
	if g_clock.isSameDay(g_clock.getCurServerTime(), self.player.sign_date) then
		day = self.player.sign_times
	else
		day = self.player.sign_times + 1
	end
	
	if day > 7 then
		day = 7
	end
	
	--连续签到获得不同经验值
	local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffKeyName("vip_active")
	for key, value in pairs(self.vip) do
		if value.vip_level == self.player.vip_level and buffValue == value.if_vip_actived and day == value.continue_sign_days then
			self.Text_qdrq:setString(g_tr("hasSigned", {exp=value.vipexp}))
			break
		end
	end
	
end

function activity_signAward:initFun()
	
end

function activity_signAward:initUI()

	for i=1, #self.data do
		local data = nil
		local dtype = tonumber(self.data[i].award_item[1][1])
		local item = require("game.uilayer.common.DropItemView").new(dtype, tonumber(self.data[i].award_item[1][2]), tonumber(self.data[i].award_item[1][3]))
		self["Panel_"..i.."_Image_wup"]:addChild(item)
		item:setPosition(self["Panel_"..i.."_Image_wup"]:getContentSize().width/2, self["Panel_"..i.."_Image_wup"]:getContentSize().height/2)
		self["Panel_"..i.."_Text_3"]:setString(item:getName())

		if self.data[i].status == 1 then
			self["Panel_"..i.."_Image_5"]:setVisible(true)
			self["Panel_"..i.."_Image_2hei"]:setVisible(true)
		end
	end
end

function activity_signAward:setState()
	

	for i=1, #self.data do
		if self.data[i].status == 0 then
			local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_QianDaoBianKuang/Effect_QianDaoBianKuang.ExportJson", "Effect_QianDaoBianKuang")
			animation:play("Animation1")
			
			self.todayData = self.data[i]
			self.day = i
			self["Panel_"..i]:addChild(armature)
			armature:setPosition(cc.p(self["Panel_"..i]:getContentSize().width / 2, self["Panel_"..i]:getContentSize().height * 0.5))
			self._armature = armature
			break
		elseif self.data[i].status == 1 then
--			local tt = os.date("*t", self.data[i].get_award_time)
--			local cr = os.date("*t", g_clock.getCurServerTime())
--			self.addAnimation = false
--			if tt.year == cr.year and tt.month == cr.month and tt.day == cr.day then
--				self.day = i
--				break
--			end
			if g_clock.isSameDay(g_clock.getCurServerTime(), self.data[i].get_award_time) then
				self.day = i
				break
			end
		end
	end
end

function activity_signAward:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Panel_1 or sender == self.Panel_2 or sender == self.Panel_3 or sender == self.Panel_4 or sender == self.Panel_5 or sender == self.Panel_6 or sender == self.Panel_7  then
				g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
				
				
				local retHandler = function(result)
					
					g_busyTip.hide_1()
					
					if result == true then
						require("game.uilayer.mainSurface.mainSurfacePlayer").hideSign()
						if self.todayData ~= nil then
							self["Panel_"..self.day.."_Image_5"]:setVisible(true)
							self["Panel_"..self.day.."_Image_2hei"]:setVisible(true)
							
							if self._armature then
									self._armature:removeFromParent()
							end
							
							--self.confirmData = true
							
							local dropGroups = {}
							for key, dropDroup in pairs(self.todayData.award_item) do
								local group = {tonumber(dropDroup[1]),tonumber(dropDroup[2]),tonumber(dropDroup[3])}
								table.insert(dropGroups,group)
							end
							
							local iconContainer = self["Panel_"..self.day.."_Image_wup"]
							local size = iconContainer:getContentSize()
							local startPos = iconContainer:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
							require("game.uilayer.common.dropFlyEffect").show(dropGroups,startPos,true)
						end
					end
				end
				
				g_busyTip.show_1()
				self.mode:doGetSignAward(retHandler)
				
--				if self.confirmData == true then
--					g_airBox.show(g_tr("sighed"))
--					require("game.uilayer.mainSurface.mainSurfacePlayer").hideSign()
--					return
--				end
--				if armature ~= nil then
--					if self.addAnimation == true then
--						armature:removeFromParent()
--						armature = nil
--						animation = nil
--					end
--				end
--				local send = true
--				for i=1, #self.data do
--					if self.data[i].status == 1 then
--						local tt = os.date("*t", self.data[i].get_award_time)
--						local cr = os.date("*t", g_clock.getCurServerTime())
--						self.addAnimation = false
--						if tt.year == cr.year and tt.month == cr.month and tt.day == cr.day then
--							send = false
--							break
--						end
--					end
--				end
--
--				if send then
--					self.mode:doGetSignAward(self.confirm)
--				else
--					g_airBox.show(g_tr("sighed"))
--				end
			elseif sender == self.Button_x then
				g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
--				if armature ~= nil then
--					if self.addAnimation == true then
--						armature:removeFromParent()
--						armature = nil
--						animation = nil
--					end
--					armature = nil
--					animation = nil
--				end
				self:close()
			end
		end
	end

	for i=1, 7 do
		self["Panel_"..i]:addTouchEventListener(proClick)
	end

	self.Button_x:addTouchEventListener(proClick)
end

function activity_signAward:doAction(type, id, num)

	local item = require("game.uilayer.common.DropItemView").new(tonumber(type), tonumber(id), tonumber(num))
	item:setPosition(cc.p((self.root:getContentSize().width - item:getContentSize().width)/2,(self.root:getContentSize().height - item:getContentSize().height)/2))
	self.root:addChild(item)

	local function callBack()
		self.root:removeChild(item)
	end

	local function complete()
		self:unschedule(self.time)

		local epos = require("game.uilayer.mainSurface.mainSurfaceMenu").getBagBtnPos()
		epos = self.root:convertToNodeSpace(epos)
		local move = cc.MoveTo:create(0.8, epos)
		local scale = cc.ScaleTo:create(0.8, 0.1)
		local callFunc=cc.CallFunc:create(callBack)
		local seq=cc.Sequence:create(cc.Spawn:create(move, scale),callFunc)
		item:runAction(seq)
	end

	self.time = self:schedule(complete, 1)
end

return activity_signAward

--endregion
