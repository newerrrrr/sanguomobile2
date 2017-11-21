
--祭天抽奖结果展示弹框

local CorReward = class("CorReward", require("game.uilayer.base.BaseLayer"))

local timeValue = 0.2
local animaValue = 0.3

local g_SOUNDS_SHILIAN_PATH = g_data.sounds[5300002].sounds_path --十连抽

function CorReward:ctor(data, times, tab, freeTimes, nextTen, nextOne, closeWin, gem,itemId,itemNum)
	CorReward.super.ctor(self)

	self.doAction = false
	self.data = data
	self.times = times
	self.curTab = tab
	self.freeTimes = freeTimes
	self.nextTen = nextTen
	self.nextOne = nextOne
	self.closeWin = closeWin
	self.gem = gem
    self.itemId = itemId    --道具ID
    self.itemNum = itemNum  --一次需要的道具数量
	self.uiList = {}


	self.layer = self:loadUI("TheObservatory_Panel_list.csb")
	self.root = self.layer:getChildByName("scale_node")

	for i = 1, 11 do
		self["Panel_"..i] = self.root:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Image_22"] = self["Panel_"..i]:getChildByName("Image_22")
		self["Panel_"..i.."_name"] = self["Panel_"..i]:getChildByName("name")
		self["Panel_"..i.."_name"]:setString("")
	end

	self.Button_1 = self.root:getChildByName("Button_1")
	
	self.Text_1 = self.Button_1:getChildByName("Text_1")
	self.Text_1:setString(g_tr("confirm"))

	self.Text_6 = self.root:getChildByName("Text_6")

	local drop = nil
	local icon = nil
	if self.curTab == 1 then
		drop = g_data.drop[230008].drop_data
		icon = require("game.uilayer.common.DropItemView").new(drop[1][1], drop[1][2], drop[1][3])
		self.Text_6:setString("")
	elseif self.curTab == 2 then
		drop = g_data.drop[230009].drop_data
		icon = require("game.uilayer.common.DropItemView").new(drop[1][1], drop[1][2], drop[1][3])
		self.Text_6:setString(g_tr("corSucTitle", {item= (drop[1][3]*self.times)..icon:getName(), type=g_tr("coT2")}))
	else
		self.Text_6:setString("")
	end
	
	
	self.Button_1_0 = self.root:getChildByName("Button_1_0")
	self.Text_1_0 = self.Button_1_0:getChildByName("Text_1_0")
	self.Text_4 = self.Button_1_0:getChildByName("Text_4")
	self.Image_11 = self.Button_1_0:getChildByName("Image_11")
	if self.times == 10 then
		self.Text_1_0:setString(g_tr("corMoreTenTimes"))
	else
		self.Text_1_0:setString(g_tr("corMoreOneTimes"))
	end

	if tab == 1 then
		if self.times == 1 then --单抽
			if self.freeTimes <= 0 then
				local num = g_BagMode.findItemNumberById(52001)
				self.Text_4:setString("x"..num)
				self.Image_11:loadTexture(g_resManager.getResPath(1010123))

				if num == 0 then
					self.Button_1_0:setEnabled(false)
				end
			else
				self.Text_4:setString(g_tr("queue_free"))
				self.Image_11:setVisible(false)
			end
			
		else
			self.Text_4:setString(g_data.cost[10003].cost_num.."")
		end
    	
    elseif tab == 2 then
    	if self.times == 1 then
			if self.freeTimes <= 0 then
				local num = g_BagMode.findItemNumberById(52002)
				if num > 0 then
					self.Text_4:setString("x"..num)
					self.Image_11:loadTexture(g_resManager.getResPath(1010124))
				else
					self.Text_4:setString(g_data.cost[10004].cost_num.."")
					self.Image_11:loadTexture(g_resManager.getResPath(1999007))
				end
			else
				self.Text_4:setString(g_tr("queue_free"))
				self.Image_11:setVisible(false)
			end
		else
			self.Text_4:setString(g_data.cost[10005].cost_num.."")
		end
	elseif tab == 3 then
		if self.times == 10 then
			self.Text_4:setString((self.gem * self.times).."")
		else
			--中间的价格和奖券显示
			local num = g_BagMode.findItemNumberById(52003)
			if num > 0 then
				self.Image_11:loadTexture(g_resManager.getResPath(1999988))
				self.Text_4:setString("x"..num)
			else
				self.Image_11:loadTexture(g_resManager.getResPath(1999007))
				self.Text_4:setString((self.gem * self.times).."")
			end
		end
	elseif tab == 4 then --祭天抽卡
		if self.times == 10 then
			self.Text_4:setString(self.gem.."")
		else
			--中间的价格和奖券显示
			local num = g_BagMode.findItemNumberById(52005)
			if num > 0 then
				self.Image_11:loadTexture(g_resManager.getResPath(g_data.item[52005].res_icon)) --祭天券
				self.Text_4:setString("x"..num)
			else
				self.Image_11:loadTexture(g_resManager.getResPath(1999007))
				self.Text_4:setString(self.gem.."")
			end
		end
    else
        if self.times == 10 then
            self.Image_11:loadTexture(g_resManager.getResPath(1999007))
            self.Text_4:setString(self.gem.."")
        else
            if self.itemId then
                local num = g_BagMode.findItemNumberById(self.itemId)
                if num >= self.itemNum then
                    self.Image_11:loadTexture( g_resManager.getResPath(g_data.item[self.itemId].res_icon) )
                    self.Text_4:setString( self.itemNum .. "(" .. num .. ")" )
                else
                    self.Image_11:loadTexture(g_resManager.getResPath(1999007))
                    self.Text_4:setString(self.gem.."")
                end
            else
                self.Image_11:loadTexture(g_resManager.getResPath(1999007))
                self.Text_4:setString(self.gem.."")
            end
        end
    end

	self.Image_ew1 = self.root:getChildByName("Image_ew1")
	self.Image_ew2 = self.root:getChildByName("Image_ew2")
	self.Image_ew1_0 = self.root:getChildByName("Image_ew1_0")
	self.Image_ew2_0 = self.root:getChildByName("Image_ew2_0")
	self.Panel_tx = self.root:getChildByName("Panel_tx")

	local armature1, animation1 = g_gameTools.LoadCocosAni("anime/Effect_ChouKa_HuoDeTextSaoGuang/Effect_ChouKa_HuoDeTextSaoGuang.ExportJson", "Effect_ChouKa_HuoDeTextSaoGuang")
	armature1:setPosition(cc.p(self.Panel_tx:getContentSize().width/2,self.Panel_tx:getContentSize().height/2 ))
	self.Panel_tx:addChild(armature1)
	animation1:play("Animation1")

	self.Button_1:setVisible(false)
	self.Button_1_0:setVisible(false)
	self.Image_ew1:setVisible(false)
	self.Image_ew2:setVisible(false)
	self.Image_ew1_0:setVisible(false)
	self.Image_ew2_0:setVisible(false)

	self:addEvent()
	self:showIcon()
end

--可能需要根据品质修改背景的发光

--获取一个dropView，从中心位置移动到某个panel

function CorReward:showIcon()
	self.pos = {}
	if #self.data == 1 then
		self.pos = {self["Panel_3"]}
	elseif #self.data == 2 then
		self.pos = {self["Panel_2"], self["Panel_4"]}
	elseif #self.data == 10 then
		self.pos = {self["Panel_1"], self["Panel_2"], self["Panel_3"], self["Panel_4"], self["Panel_5"], 
		self["Panel_6"], self["Panel_7"], self["Panel_8"], self["Panel_9"], self["Panel_10"]}
	elseif #self.data == 11 then
		self.pos = {self["Panel_1"], self["Panel_2"], self["Panel_3"], self["Panel_4"], self["Panel_5"], 
		self["Panel_6"], self["Panel_7"], self["Panel_8"], self["Panel_9"], self["Panel_10"], self["Panel_11"]}
	end

	self.doAction = true
	self:processTime()
end

function CorReward:processTime()
	local i = 1
	local function updateTime()
		if i > #self.data then 
    		self.doAction = false
      		self:unschedule(self.time)
      		self.time = nil
      		self.Button_1:setVisible(true)
      		self.Button_1_0:setVisible(true)
      		g_gameCommon.dispatchEvent(g_Consts.CustomEvent.DrawCardUpdateTip,{})
      		g_guideManager.registComponent(9999985,self.Button_1) --抽奖结果界面 确定按钮
      		g_guideManager.execute()
      		return
    	end 

    
    	if i == 11 then
			self.Image_ew1:setVisible(true)
			self.Image_ew2:setVisible(true)
		end

		if i == 2 and #self.data == 2 then
			self.Image_ew1_0:setVisible(true)
			self.Image_ew2_0:setVisible(true)
		end



    	local icon = require("game.uilayer.common.DropItemView").new(self.data[i].type, self.data[i].id, self.data[i].num)
		icon:setScale(0.1)
		self.root:addChild(icon)
		table.insert(self.uiList, icon)

		icon:enableTip()

		icon:setPosition((self.root:getContentSize().width)/2, (self.root:getContentSize().height)/2)

		local action = cc.Spawn:create(
		cc.MoveTo:create(animaValue, cc.p(self.pos[i]:getPositionX()+icon:getContentSize().width/2, self.pos[i]:getPositionY() + icon:getContentSize().height/2)), 
		cc.ScaleTo:create(animaValue,1), 
		cc.Sequence:create(cc.RotateTo:create(animaValue/2, 180), 
		cc.RotateTo:create(animaValue/2, 360)),
		cc.CallFunc:create(function() 
			g_musicManager.playEffect(g_SOUNDS_SHILIAN_PATH)
		end))

		icon:runAction(action)
		self.pos[i]:getChildByName("name"):setString(icon:getName())

		if self.data[i].type == 2 and self.data[i].id >= 41001 and  self.data[i].id <= 41111 then
			--暂停后续播放
			self:unschedule(self.time)

			local function animeCallback(armature , eventType , name)
				if ccs.MovementEventType.start == eventType then
				elseif ccs.MovementEventType.complete == eventType then
					armature:removeFromParent()
				elseif ccs.MovementEventType.loopComplete == eventType then
					armature:removeFromParent()
				end
			end

			local armature1, animation1 = g_gameTools.LoadCocosAni("anime/Effect_ChouKaShenWuJianChuXian/Effect_ChouKaShenWuJianChuXian.ExportJson", "Effect_ChouKaShenWuJianChuXian", animeCallback)
			armature1:setPosition(cc.p(self.pos[i]:getContentSize().width/2,self.pos[i]:getContentSize().height/2 ))
			self.pos[i]:addChild(armature1)
			animation1:play("Effect_JiuGuanZhaoMuYinXiongRight")

			local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_ChouKaKaPai/Effect_ChouKaKaPai.ExportJson", "Effect_ChouKaKaPai")
			armature:setPosition(cc.p(self.pos[i]:getContentSize().width/2,self.pos[i]:getContentSize().height/2 ))
			self.pos[i]:addChild(armature)
			animation:play("Animation1")

			local curPos = self.pos[i]

			local id = 0
			for key, value in pairs(g_data.general) do
				if value.piece_item_id == self.data[i].id then
					id = value.general_big_icon
					break
				end
			end

			local pic = cc.Sprite:create(g_resManager.getResPath(id))
			self.root:addChild(pic)
			pic:setPosition(cc.p(self.root:getContentSize().width/2, self.root:getContentSize().height/2))

			local function endTime()
				if self.ti ~= nil then
					self:unschedule(self.ti)
        			self.ti = nil
				end

				local function scaleCallback()
					self:schedule(updateTime, timeValue)
				end

				local action1 = cc.Sequence:create(cc.Spawn:create(
				cc.MoveTo:create(0.3, cc.p(curPos:getPositionX()+icon:getContentSize().width/2, curPos:getPositionY() + icon:getContentSize().height/2)), 
				cc.ScaleTo:create(0.3,0)), cc.CallFunc:create(scaleCallback))
				pic:runAction(action1)
			end

			if self.ti ~= nil then
				self:unschedule(self.ti)
        		self.ti = nil
			end
			self.ti = self:schedule(endTime, 2)
		elseif self.data[i].id >= 51001 and  self.data[i].id <= 51006 then
			local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_WuJianBeiHouGuang/Effect_WuJianBeiHouGuang.ExportJson", "Effect_WuJianBeiHouGuang")
			armature:setPosition(cc.p(self.pos[i]:getContentSize().width/2,self.pos[i]:getContentSize().height/2 ))
			self.pos[i]:addChild(armature)
			animation:play("Animation1")
		end
		i = i + 1
    end

	if self.time ~= nil then
        self:unschedule(self.time)
        self.time = nil
    end

    self.time = self:schedule(updateTime, timeValue)
	updateTime()
end

function CorReward:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function CorReward:unschedule(action)
  self:stopAction(action)
end

function CorReward:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1 then
			  g_guideManager.execute()
			  	if self.closeWin ~= nil then
			  		self.closeWin()
			  	end
				self:close()
			elseif sender == self.Button_1_0 then
				if self.times == 10 then
					if self.nextTen ~= nil then
						self.nextTen()
					end
				else
					if self.nextOne ~= nil then
						self.nextOne()
					end
				end
				
				self:close()
			end
		end
	end

	self.root:addTouchEventListener(proClick)
	self.Button_1:addTouchEventListener(proClick)
	self.Button_1_0:addTouchEventListener(proClick)
end

return CorReward