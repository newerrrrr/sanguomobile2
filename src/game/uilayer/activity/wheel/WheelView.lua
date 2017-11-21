local WheelView = class("WheelView", function()
	return cc.Layer:create()
end)

function WheelView:ctor()
	self.mode = require("game.uilayer.activity.ActivityMode").new()

	self.inAction = false

	self.layer = cc.CSLoader:createNode("LargeTurntable_main1.csb")
	self:addChild(self.layer)

	self.Panel_zhuanptx = self.layer:getChildByName("Panel_zhuanptx")

	self.Panel_1 = self.layer:getChildByName("Panel_1")
	self.Panel_1_Text_8 = self.Panel_1:getChildByName("Text_8")
	self.Panel_1_Text_8_0 = self.Panel_1:getChildByName("Text_8_0")
	self.Panel_1_Text_mc = self.Panel_1:getChildByName("Text_mc")
	self.Panel_1_Text_mc1 = self.Panel_1:getChildByName("Text_mc1")

	self.Panel_z1 = self.layer:getChildByName("Panel_z1")
	self.Panel_z1_Image_2 = self.Panel_z1:getChildByName("Image_2")
	self.Panel_z1_Panel_zhuanptx = self.Panel_z1:getChildByName("Panel_zhuanptx")

	self.armature1, self.animation1 = g_gameTools.LoadCocosAni("anime/Effect_NewDaZhuanPan_XuanZhuan/Effect_NewDaZhuanPan_XuanZhuan.ExportJson", "Effect_NewDaZhuanPan_XuanZhuan")
    self.armature1:setPosition(cc.p(self.Panel_z1_Panel_zhuanptx:getContentSize().width/2,self.Panel_z1_Panel_zhuanptx:getContentSize().height/2 ))
    self.Panel_z1_Panel_zhuanptx:addChild(self.armature1)
    self.animation1:play("Man")

	for i=1, 10 do
		self["Panel_w"..i] = self.Panel_z1:getChildByName("Panel_w"..i)
		self["Panel_w"..i.."_Image_22"] = self["Panel_w"..i]:getChildByName("Image_22")
	end

	self.Button_yic1 = self.layer:getChildByName("Button_yic1")

	for i=1, 2 do
		self["Panel_yic"..i] = self.layer:getChildByName("Panel_yic"..i)
		self["Panel_yic"..i.."_Button_yc1"] = self["Panel_yic"..i]:getChildByName("Button_yc1")
		self["Panel_yic"..i.."_Image_10"] = self["Panel_yic"..i]:getChildByName("Image_10")
		self["Panel_yic"..i.."_Text_6"] = self["Panel_yic"..i]:getChildByName("Text_6")
		self["Panel_yic"..i.."_Text_6"]:setString("0")
	end
	
	self.Button_3 = self.layer:getChildByName("Button_3")
	self.Button_3_Panel_zhuanptx = self.Button_3:getChildByName("Panel_zhuanptx_0")

	local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_NewDaZhuanPanXunHuan/Effect_NewDaZhuanPanXunHuan.ExportJson", "Effect_NewDaZhuanPanXunHuan")
    armature:setPosition(cc.p(self.Button_3_Panel_zhuanptx:getContentSize().width/2,self.Button_3_Panel_zhuanptx:getContentSize().height/2 ))
    self.Button_3_Panel_zhuanptx:addChild(armature)
    animation:play("Animation1")

	self.LoadingBar_1 = self.layer:getChildByName("LoadingBar_1")

	for i=1, 3 do
		self["Panel_jj"..i] = self.layer:getChildByName("Panel_jj"..i)
		--可以开启宝箱
		self["Panel_jj"..i.."_Image_1"] = self["Panel_jj"..i]:getChildByName("Image_1")
		--已经被打开
		self["Panel_jj"..i.."_Image_1_0"] = self["Panel_jj"..i]:getChildByName("Image_1_0")
		--灰色状态
		self["Panel_jj"..i.."_Image_1_hui"] = self["Panel_jj"..i]:getChildByName("Image_1_hui")

		self["Panel_jj"..i.."_Text_s1"] = self["Panel_jj"..i]:getChildByName("Text_s1")
		self["Panel_jj"..i.."_Text_s1"]:setString("")
	end

	self:addEvent()
	self:initFun()

	local function callback(data)
		self.data = data.activity
		self.charge = data.charge
		if self.data == nil then
			return
		end

		self:setData()
		self:updateBar()
	end

	self.mode:wheel(callback)
end

function WheelView:initFun()
	self.reReward = function()
		self.inAction = true
		self.mode:wheelPlay(self.wheelTimes, self.doAction)
	end

	self.doAction = function(data)
		if data == nil then
			self.inAction = false
			return
		end
		self.animation1:play("Kuai")

		local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_NewDaZhuanPan_Mask/Effect_NewDaZhuanPan_Mask.ExportJson", "Effect_NewDaZhuanPan_Mask")
		armature:setPosition(cc.p(self.Panel_zhuanptx:getContentSize().width/2,self.Panel_zhuanptx:getContentSize().height/2 ))
		self.Panel_zhuanptx:addChild(armature)
		animation:play("Animation1")

		self.inAction = true
		self.updateFun()

		local result = data
		local step = 1
		local tem = 1
		local maxT = 0.3
		local minT = 0.1
		local t = 0.4
		local dir = 1
		local isPlay = false

		local function update()
			self.Panel_z1_Image_2:setRotation((step*36)%360)
			step = step + 1

			if dir == 1 then
				if step%1 == 0 then
					self:unschedule(self.action)
					t = t - minT
					self.action = self:schedule(update, t)
					if t <= minT then
						dir = 2
					end
				end
			else
				if tem < 15 then
					tem = tem + 1
				else
					if step%1 == 0 then
						self:unschedule(self.action)
						if self.wheelTimes == 1 then
							if t >= maxT then
								if isPlay == false then
									self.animation1:play("HuoJian")
									isPlay = true
								end
							
								if self.Panel_z1_Image_2:getRotation()/36 == result.key[1] then
									local function showReward()
										self:unschedule(self.action)
										self.action = nil

										self.inAction = false
										isPlay = false
										self.animation1:play("Man")
										self.Panel_zhuanptx:removeAllChildren()

										self.Panel_z1_Image_2:setRotation(0)

										local result1 = {}
										for i=1, #result.drop do
											table.insert(result1,result.drop[i][1])
										end

										g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CorReward").new(result1, self.wheelTimes, 3, 0, self.reReward, self.reReward, nil, self.data.activity_para.gem))
									end

									self.action = self:schedule(showReward, 1.0)
								else
									self.action = self:schedule(update, t)
								end
							else
								t = t + minT
								self.action = self:schedule(update, t)
							end
						elseif self.wheelTimes == 10 then
							self.action = nil

							self.inAction = false
							isPlay = false
							self.animation1:play("Man")
							self.Panel_zhuanptx:removeAllChildren()

							self.Panel_z1_Image_2:setRotation(0)

							local result1 = {}
							for i=1, #result.drop do
								table.insert(result1,result.drop[i][1])
							end

							g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CorReward").new(result1, self.wheelTimes, 3, 0, self.reReward, self.reReward, nil, self.data.activity_para.gem))
						end
					end
				end
			end
			
		end

		self.action = self:schedule(update, t)
	end

	self.updateFun = function(value)
		if value ~= nil then
			local drop = {}
			for i=1, #value.drop do
				table.insert(drop, {value.drop[i].type,value.drop[i].id,value.drop[i].num})
			end
			local view = require("game.uilayer.task.TaskAwardAlertLayer").new(drop)
        	g_sceneManager.addNodeForUI(view)
		end

		local function callback(data)
			self.data = data.activity
			self.charge = data.charge
			if data == nil then
				return
			end

			self:updateBar()
		end

		self.mode:wheel(callback)
	end
end

function WheelView:setData()
	self.Panel_1_Text_8:setString(g_tr("actEnd"))
	self:showTime()

	self.Panel_1_Text_mc:setString(g_tr("actInfoTitle"))
	self.Panel_1_Text_mc1:setString(self.data.activity_para.memo)

	local result = {}
	self.rewardList = {}
	for key in pairs(self.data.activity_para.reward) do
		table.insert(result, tonumber(key))
		table.insert(self.rewardList, tonumber(key))
	end
	table.sort(result)
	table.sort(self.rewardList)

	for i=1, #self.data.activity_para.wheel do
		local item = require("game.uilayer.common.DropItemView").new(tonumber(self.data.activity_para.wheel[i][1][1]), tonumber(self.data.activity_para.wheel[i][1][2]), tonumber(self.data.activity_para.wheel[i][1][3]))
		self["Panel_w"..i.."_Image_22"]:addChild(item)
		item:setPosition(cc.p(self["Panel_w"..i.."_Image_22"]:getContentSize().width/2, self["Panel_w"..i.."_Image_22"]:getContentSize().height/2))
		item:enableTip()
	end
end

function WheelView:updateBar()

	local percent = 0
	if math.floor(tonumber(self.charge.counter)/self.rewardList[#self.rewardList]*100) > 100 then
		percent = 100
	else
		percent = math.floor(tonumber(self.charge.counter)/self.rewardList[#self.rewardList]*100)
	end

	for i=1, #self.rewardList do
		self["Panel_jj"..i.."_Text_s1"]:setString(self.charge.counter.."/"..self.rewardList[i])
	end

	self.LoadingBar_1:setPercent(percent)

	for i=1, #self.rewardList do
		if tonumber(self.charge.counter) >= self.rewardList[i] then
			local tag = false
				
			for j=1, #self.charge.flag do
				if self.rewardList[i] == tonumber(self.charge.flag[j]) then
					tag = true
					break
				end
			end

			if tag == false then
				self["Panel_jj"..i.."_Image_1"]:setVisible(true)
				self["Panel_jj"..i.."_Image_1_0"]:setVisible(false)
			else
				self["Panel_jj"..i.."_Image_1"]:setVisible(false)
				self["Panel_jj"..i.."_Image_1_0"]:setVisible(true)
			end
			self["Panel_jj"..i.."_Image_1_hui"]:setVisible(false)
		else
			self["Panel_jj"..i.."_Image_1"]:setVisible(false)
			self["Panel_jj"..i.."_Image_1_0"]:setVisible(false)
			self["Panel_jj"..i.."_Image_1_hui"]:setVisible(true)
		end
	end

	--中间的价格和奖券显示
	local num = g_BagMode.findItemNumberById(52003)
	if num > 0 then
		self["Panel_yic1_Image_10"]:loadTexture(g_resManager.getResPath(1999988))
		self["Panel_yic1_Text_6"]:setString("x"..num)
	else
		self["Panel_yic1_Image_10"]:loadTexture(g_resManager.getResPath(1999007))
		self["Panel_yic1_Text_6"]:setString(self.data.activity_para.gem.."")
	end
	self["Panel_yic2_Text_6"]:setString((self.data.activity_para.gem*10).."")
end

function WheelView:showTime()
	local function updateTime()
		local dt = self.data.end_time - g_clock.getCurServerTime()

		if dt <= 0 then
			self:unschedule(self.timeAction)
			self.timeAction = nil
			self.Panel_1_Text_8_0:setString(g_tr("actOver"))
		end

		self.Panel_1_Text_8_0:setString(g_gameTools.convertSecondToString(dt))
	end

	if self.timeAction ~= nil then
		self:unschedule(self.timeAction)
		self.timeAction = nil
	end

	if self.data.end_time - g_clock.getCurServerTime() > 0 then
		self.timeAction = self:schedule(updateTime, 1)
		updateTime()
	else
		self.Panel_1_Text_8_0:setString(g_tr("actOver"))
	end
end

function WheelView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self["Panel_yic1_Button_yc1"] then
				if self.inAction == true then
					return
				end

				self.wheelTimes = 1
				self.mode:wheelPlay(self.wheelTimes, self.doAction)
			elseif sender == self["Panel_yic2_Button_yc1"] then
				if self.inAction == true then
					return
				end

				self.wheelTimes = 10
				self.mode:wheelPlay(self.wheelTimes, self.doAction)
			elseif sender == self["Panel_jj1_Image_1"] then
				self.mode:wheelReward(self.rewardList[1], self.updateFun)
			elseif sender == self["Panel_jj2_Image_1"] then
				self.mode:wheelReward(self.rewardList[2], self.updateFun)
			elseif sender == self["Panel_jj3_Image_1"] then
				self.mode:wheelReward(self.rewardList[3], self.updateFun)
			elseif sender == self["Panel_jj1_Image_1_hui"] then
				local drop = {}
				local tem = self.data.activity_para.reward[self.rewardList[1]..""].drop
				for i=1, #tem do
					table.insert(drop, {tonumber(tem[i][1]),tonumber(tem[i][2]),tonumber(tem[i][3])})
				end
				local view = require("game.uilayer.task.TaskAwardAlertLayer").new(drop)
        		g_sceneManager.addNodeForUI(view)
			elseif sender == self["Panel_jj2_Image_1_hui"] then
				local drop = {}
				local tem = self.data.activity_para.reward[self.rewardList[2]..""].drop
				for i=1, #tem do
					table.insert(drop, {tonumber(tem[i][1]),tonumber(tem[i][2]),tonumber(tem[i][3])})
				end
				local view = require("game.uilayer.task.TaskAwardAlertLayer").new(drop)
        		g_sceneManager.addNodeForUI(view)
			elseif sender == self["Panel_jj3_Image_1_hui"] then
				local drop = {}
				local tem = self.data.activity_para.reward[self.rewardList[3]..""].drop
				for i=1, #tem do
					table.insert(drop, {tonumber(tem[i][1]),tonumber(tem[i][2]),tonumber(tem[i][3])})
				end
				local view = require("game.uilayer.task.TaskAwardAlertLayer").new(drop)
        		g_sceneManager.addNodeForUI(view)
        	elseif sender == self.Button_yic1 then
        		g_sceneManager.addNodeForUI(require("game.uilayer.activity.wheel.WheelHelpView").new(self.data.activity_para.memo))
			end
		end
	end

	self["Panel_yic1_Button_yc1"]:addTouchEventListener(proClick)
	self["Panel_yic2_Button_yc1"]:addTouchEventListener(proClick)
	self["Panel_jj1_Image_1"]:addTouchEventListener(proClick)
	self["Panel_jj2_Image_1"]:addTouchEventListener(proClick)
	self["Panel_jj3_Image_1"]:addTouchEventListener(proClick)
	self["Panel_jj1_Image_1_hui"]:addTouchEventListener(proClick)
	self["Panel_jj2_Image_1_hui"]:addTouchEventListener(proClick)
	self["Panel_jj3_Image_1_hui"]:addTouchEventListener(proClick)
	self.Button_yic1:addTouchEventListener(proClick)
end

function WheelView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function WheelView:unschedule(action)
  self:stopAction(action)
end

return WheelView