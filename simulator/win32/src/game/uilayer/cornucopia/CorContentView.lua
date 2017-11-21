local CorContentView = class("CorContentView", function() 
	return cc.Layer:create()
end)

local g_SOUNDS_ZHANXING_PATH = g_data.sounds[5300001].sounds_path --占星动画

function CorContentView:ctor(tab)
	self.curTab = tab

	self.startAnima = false

	g_corData.SetContentView(self)

	if tab == 1 then
		self.layer = cc.CSLoader:createNode("TheObservatory_list2.csb")
	else
		self.layer = cc.CSLoader:createNode("TheObservatory_list1.csb")
	end
	

	self:addChild(self.layer)

	self.Panel_dc = self.layer:getChildByName("Panel_dc")
	self.Panel_dc_Button_dc = self.Panel_dc:getChildByName("Button_dc")
	self.Panel_dc_Text_4 = self.Panel_dc:getChildByName("Text_4")
	self.Panel_dc_Text_4_0 = self.Panel_dc:getChildByName("Text_4_0")
	self.Panel_dc_Image_11 = self.Panel_dc:getChildByName("Image_11")

	self.Panel_sl = self.layer:getChildByName("Panel_sl")
	self.Panel_sl_Button_dc = self.Panel_sl:getChildByName("Button_dc")
	self.Panel_sl_Text_4 = self.Panel_sl:getChildByName("Text_4")
	self.Panel_sl_Text_4_0 = self.Panel_sl:getChildByName("Text_4_0")

	self.Panel_sl_Text_4_0:setString("")

	self.Panel_1 = self.layer:getChildByName("Panel_1")
	

	if tab == 2 then
		self.Text_6 = self.layer:getChildByName("Text_6")
		self.Text_6_0 = self.layer:getChildByName("Text_6_0")

		self.Text_g1 = self.layer:getChildByName("Text_g1")
		self.Image_w = self.layer:getChildByName("Image_w")
		self.Text_g2 = self.layer:getChildByName("Text_g2")
		self.Text_g1:setString(g_tr("corInfoBefore"))

		local data = g_data.drop[230009].drop_data
		local item = require("game.uilayer.common.DropItemView").new(data[1][1], data[1][2], data[1][3])
		self.Image_w:addChild(item)
		item:setPosition(self.Image_w:getContentSize().width/2, self.Image_w:getContentSize().height/2)
		item:setCountEnabled(false)
		
		self.Text_g2:setString(g_tr("corSummaryInfo", {num=data[1][3], item=g_tr("coT2")}))

		if self.txtRich == nil then
			self.txtRich = g_gameTools.createRichText(self.Text_6, "")
		end

		self.txtRich:setRichText(g_tr("coT2Tip"))
	else
		self.Panel_sl:setVisible(false)
	end

	self.Button_1 = self.layer:getChildByName("Button_1")
	self.txtBtn = self.Button_1:getChildByName("Text_1")
	self.txtBtn:setString(g_tr("corCheckReward"))

	if tab == 2 then
		local armature1, animation1 = g_gameTools.LoadCocosAni("anime/Effect_TianYun/Effect_TianYun.ExportJson", "Effect_TianYun")
    	armature1:setPosition(cc.p( self.Panel_1:getContentSize().width/2,self.Panel_1:getContentSize().height/2 ))
    	self.Panel_1:addChild(armature1)
    	animation1:play("Animation1")

    	local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_BaGua/Effect_BaGua.ExportJson", "Effect_BaGua")
    	armature:setPosition(cc.p( self.Panel_1:getContentSize().width/2,self.Panel_1:getContentSize().height/2 ))
    	self.Panel_1:addChild(armature)
    	animation:play("Animation1")

    	local armature2, animation2 = g_gameTools.LoadCocosAni("anime/Effect_TianYunUp/Effect_TianYunUp.ExportJson", "Effect_TianYunUp")
    	armature2:setPosition(cc.p( self.Panel_1:getContentSize().width/2,self.Panel_1:getContentSize().height/2 ))
    	self.Panel_1:addChild(armature2)
    	animation2:play("Animation1")
	else
		local armature3, animation3 = g_gameTools.LoadCocosAni("anime/Effect_XingKong/Effect_XingKong.ExportJson", "Effect_XingKong")
    	armature3:setPosition(cc.p( self.Panel_1:getContentSize().width/2,self.Panel_1:getContentSize().height/2 ))
    	self.Panel_1:addChild(armature3)
    	animation3:play("Animation1")

    	local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_BaGua/Effect_BaGua.ExportJson", "Effect_BaGua")
    	armature:setPosition(cc.p( self.Panel_1:getContentSize().width/2,self.Panel_1:getContentSize().height/2 ))
    	self.Panel_1:addChild(armature)
    	animation:play("Animation1")

    	local armature4, animation4 = g_gameTools.LoadCocosAni("anime/Effect_XingKongUp/Effect_XingKongUp.ExportJson", "Effect_XingKongUp")
    	armature4:setPosition(cc.p( self.Panel_1:getContentSize().width/2,self.Panel_1:getContentSize().height/2 ))
    	self.Panel_1:addChild(armature4)
    	animation4:play("Animation1")
	end

    if tab == 1 then
    	self.Panel_sl_Text_4:setString(g_data.cost[10003].cost_num.."")
    else
    	self.Panel_sl_Text_4:setString(g_data.cost[10005].cost_num.."")
    end

    self.freeTimes = 0

    self:initFun()

    self:addEvent()

    self:show()
end

function CorContentView:initFun()

	local function onMaskCallFunc(armature , eventType , name)
		if ccs.MovementEventType.loopComplete == eventType then
			self.layer:removeChild(armature)
		end
	end

	local function onChouKaCallFunc(armature , eventType , name)
		if ccs.MovementEventType.loopComplete == eventType then
			self.layer:removeChild(armature)
			g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CorReward").new(self.result, self.curTime, self.curTab, self.freeTimes,
				self.nextTenTime, self.nextOneTime, self.closeWin))
		end
	end

	self.closeWin = function()
		self.startAnima = false
	end

	self.showResult = function(data)
		self.startAnima = true
		self.result = data
		self:show()
		self:choukaAni(onMaskCallFunc, onChouKaCallFunc)
	end

	self.nextTenTime = function()
		self.startAnima = false
		g_corData.TreasureBowl(1, self.curTab, 1, 0, self.showResult)
	end

	self.nextOneTime = function()
		self.startAnima = false

		if self.freeTimes <= 0 then
			if self.curTab == 1 then
				if g_BagMode.findItemNumberById(52001) > 0 then
					g_corData.TreasureBowl(0, self.curTab, 0, 1, self.showResult)
				else
					g_airBox.show(g_tr("luckyNotEnough"))
				end
			else
				if g_BagMode.findItemNumberById(52002) > 0 then
					g_corData.TreasureBowl(0, self.curTab, 0, 1, self.showResult)
				else
					g_corData.TreasureBowl(0, self.curTab, 0, 0, self.showResult)
				end
			end
		else
			self.freeTimes = self.freeTimes - 1
			g_corData.TreasureBowl(0, self.curTab, 1, 0, self.showResult)
		end
	end
end

function CorContentView:choukaAni(callback1, callback2)
	g_musicManager.playEffect(g_SOUNDS_ZHANXING_PATH)

	local armature1, animatio1n = g_gameTools.LoadCocosAni("anime/Effect_ChouKaMask/Effect_ChouKaMask.ExportJson", "Effect_ChouKaMask", callback1)
	armature1:setPosition(cc.p(self.Panel_1:getContentSize().width/2,self.Panel_1:getContentSize().height/2 ))
	self.layer:addChild(armature1)


	local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_ChouKa/Effect_ChouKa.ExportJson", "Effect_ChouKa", callback2)
	armature:setPosition(cc.p(self.Panel_1:getContentSize().width/2,self.Panel_1:getContentSize().height/2 ))
	self.layer:addChild(armature)

	if self.curTime == 1 then
		animation:play("DanChou")
		animatio1n:play("DanChou")
	else
		animation:play("ShiLianChou")
		animatio1n:play("ShiLianChou")
	end
end

function CorContentView:maskAni(callback)
	local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_ChouKaMask/Effect_ChouKaMask.ExportJson", "Effect_ChouKaMask", callback)
	armature:setPosition(cc.p( self.Panel_1:getContentSize().width/2,self.Panel_1:getContentSize().height/2 ))
	self.layer:addChild(armature)

	if self.curTime == 1 then
		animation:play("DanChou")
	else
		animation:play("ShiLianChou")
	end
end

function CorContentView:show()
	local playerInfo = g_playerInfoData.GetData()
	local startingData = 0
	local tTemp = 0
	if self.curTab == 1 then
		startingData = tonumber(g_data.starting[90].data)
		tTemp = g_clock.getCurServerTime() - playerInfo.bowl_type1_last_time + 3
		if tTemp < startingData then
			self.freeTimes = 0
			self:showTime(startingData - tTemp + 3)
			local num = g_BagMode.findItemNumberById(52001)
			self.Panel_dc_Text_4:setString("x"..num)
			self.Panel_dc_Image_11:loadTexture(g_resManager.getResPath(1010123))
			self.Panel_dc_Image_11:setVisible(true)
		elseif tTemp >= startingData and tTemp < startingData * 2 then
			self.freeTimes = 1
			self.Panel_dc_Text_4:setString(g_tr("godFreeTimes", {num=1}))
			self.Panel_dc_Text_4_0:setString("")
			self.Panel_dc_Image_11:setVisible(false)
		elseif tTemp >= startingData*2 then
			self.freeTimes = tonumber(g_data.starting[91].data)
			self.Panel_dc_Text_4:setString(g_tr("godFreeTimes", {num=g_data.starting[91].data}))
			self.Panel_dc_Text_4_0:setString("")
			self.Panel_dc_Image_11:setVisible(false)
		end
	else
		startingData = tonumber(g_data.starting[92].data)
		tTemp = g_clock.getCurServerTime() - playerInfo.bowl_type2_last_time + 3
		if tTemp < startingData then
			self.freeTimes = 0
			self:showTime(startingData - tTemp + 3)
			local num = g_BagMode.findItemNumberById(52002)
			if num == 0 then
				self.Panel_dc_Text_4:setString(g_data.cost[10004].cost_num.."")
				self.Panel_dc_Image_11:loadTexture(g_resManager.getResPath(1999007))
			else
				self.Panel_dc_Text_4:setString("x"..num)
				self.Panel_dc_Image_11:loadTexture(g_resManager.getResPath(1010124))
			end
			self.Panel_dc_Image_11:setVisible(true)
		elseif tTemp >= startingData then
			self.freeTimes = tonumber(g_data.starting[93].data)
			self.Panel_dc_Text_4:setString(g_tr("godFreeTimes", {num=g_data.starting[93].data}))
			self.Panel_dc_Text_4_0:setString("")
			self.Panel_dc_Image_11:setVisible(false)
		end

		local tag = false

		for key, value in pairs(g_data.general) do
			if value.condition > 0 and value.general_quality == g_GeneralMode.godQuality then
				if g_BagMode.FindItemByID(value.piece_item_id) == nil or g_GeneralMode.getGeneralById(math.floor(key/100)) == nil then
					tag = true
					break
				end
			end
		end

		if self.richInfo == nil then
			self.richInfo = g_gameTools.createRichText(self.Text_6_0, "")
		end

		if tag == true then
			for key, value in pairs(g_data.astrology) do
				if value.drop_group == 12 and playerInfo.bowl_counter_drop_group_12 >= value.min_count and playerInfo.bowl_counter_drop_group_12 <= value.max_count then
					if value.chance <= 10 then
						self.richInfo:setRichText(g_tr("dropTip1"))
					elseif value.chance <= 100 then
						self.richInfo:setRichText(g_tr("dropTip2"))
					elseif value.chance <= 1000 then
						self.richInfo:setRichText(g_tr("dropTip3"))
					elseif value.chance <= 10000 then	
						self.richInfo:setRichText(g_tr("dropTip4"))
					end
				end
			end
		else
			self.richInfo:setRichText("")
		end
	end
end

function CorContentView:showTime(time)
	local function updateTime()
        time = time - 1

        if time <= 0 then 
            time = 0 
            self.needTime = 0 
            self:unschedule(self.time)
            self.time = nil

            self:show()
        end

        self.Panel_dc_Text_4_0:setString(g_gameTools.convertSecondToString(time)..g_tr("nextFreeTime"))      
    end

    if self.time ~= nil then
        self:unschedule(self.time)
        self.time = nil
    end

    if time > 0 then
        self.time = self:schedule(updateTime, 1.0)
        updateTime()
    end
end

function CorContentView:schedule(callback, time)
  local sequence = cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function CorContentView:unschedule(action)
  self:stopAction(action)
end

function CorContentView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.startAnima == true then
				return
			end
			if sender == self.Panel_dc_Button_dc then
			  g_guideManager.clearGuideLayer()
				self.curTime = 1
				if self.freeTimes <= 0 then

					if self.curTab == 1 then
						if g_BagMode.findItemNumberById(52001) > 0 then
							g_corData.TreasureBowl(0, self.curTab, 0, 1, self.showResult)
						else
							g_airBox.show(g_tr("luckyNotEnough"))
						end
					else
						if g_BagMode.findItemNumberById(52002) > 0 then
							g_corData.TreasureBowl(0, self.curTab, 0, 1, self.showResult)
						else
							g_corData.TreasureBowl(0, self.curTab, 0, 0, self.showResult)
						end
					end
				else
					self.freeTimes = self.freeTimes - 1
					g_corData.TreasureBowl(0, self.curTab, 1, 0, self.showResult)
				end
			elseif sender == self.Panel_sl_Button_dc then
				self.curTime = 10
				g_corData.TreasureBowl(1, self.curTab, 0, 0, self.showResult)
			elseif self.Button_1 == sender then
				g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CorShowRewardView").new(self.curTab))
			end
		end
	end
  
  g_guideManager.registComponent(9999987,self.Panel_dc_Button_dc)
  g_guideManager.execute()
  
	self.Panel_dc_Button_dc:addTouchEventListener(proClick)
	self.Panel_sl_Button_dc:addTouchEventListener(proClick)
	self.Button_1:addTouchEventListener(proClick)
end

function CorContentView:getInAni()
	return self.startAnima
end

return CorContentView