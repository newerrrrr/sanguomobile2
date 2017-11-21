local CombineRewardView = class("CombineRewardView", require("game.uilayer.base.BaseLayer"))

local timeValue = 0.2
local animaValue = 0.3

function CombineRewardView:ctor(data, reCombine, data2, tip)
	self.data = (data and data.itemIds) or data2
	self.reCombine = reCombine
	self.tip = tip

	CombineRewardView.super.ctor(self)

	self.layer = self:loadUI("TheObservatory_Panel_list3.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.Panel_tx = self.root:getChildByName("Panel_tx")

	for i = 1, 3 do
		self["Panel_"..i] = self.root:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Image_22"] = self["Panel_"..i]:getChildByName("Image_22")
		self["Panel_"..i.."_name"] = self["Panel_"..i]:getChildByName("name")
		self["Panel_"..i.."_name"]:setString("")
	end

	self.Button_1 = self.root:getChildByName("Button_1")
	self.Text_1 = self.Button_1:getChildByName("Text_1")
	self.Text_1:setString(g_tr("confirm"))

	self.Button_1_0 = self.root:getChildByName("Button_1_0")
	self.Text_1_0 = self.Button_1_0:getChildByName("Text_1_0")
	if self.tip == nil then
		self.Text_1_0:setString(g_tr("continueCom"))
	else
		self.Text_1_0:setString(self.tip)
	end
	

	self.Image_ew1_0 = self.root:getChildByName("Image_ew1_0")
	self.Image_ew2_0 = self.root:getChildByName("Image_ew2_0")

	local armature1, animation1 = g_gameTools.LoadCocosAni("anime/Effect_ChouKa_HuoDeTextSaoGuang/Effect_ChouKa_HuoDeTextSaoGuang.ExportJson", "Effect_ChouKa_HuoDeTextSaoGuang")
	armature1:setPosition(cc.p(self.Panel_tx:getContentSize().width/2,self.Panel_tx:getContentSize().height/2 ))
	self.Panel_tx:addChild(armature1)
	animation1:play("Animation1")

	self.uiList = {}
	self.pos = {}

	if #self.data == 1 then
		self.Image_ew1_0:setVisible(false)
		self.Image_ew2_0:setVisible(false)
		table.insert(self.pos, self["Panel_3"])
	else
		self.Image_ew1_0:setVisible(true)
		self.Image_ew2_0:setVisible(true)
		table.insert(self.pos, self["Panel_1"])
		table.insert(self.pos, self["Panel_2"])
	end
	self.doAction = true
	self:addEvent()
	self:processTime()
end

function CombineRewardView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1 then
				self:close()
			elseif sender == self.Button_1_0 then
				if self.reCombine ~= nil then
					self.reCombine()
				end
				self:close()
			end
		end
	end

	self.Button_1:addTouchEventListener(proClick)
	self.Button_1_0:addTouchEventListener(proClick)
end

function CombineRewardView:processTime()
	local i = 1
	local function updateTime()
		if i > #self.data then 
			self.doAction = false
			self:unschedule(self.time)
			self.time = nil
			self.Button_1:setVisible(true)
			self.Button_1_0:setVisible(true)
			return
		end 

		if i == 2 and #self.data == 2 then
			self.Image_ew1_0:setVisible(true)
			self.Image_ew2_0:setVisible(true)
		end

		local icon = require("game.uilayer.common.DropItemView").new(self.data[i][1], self.data[i][2], self.data[i][3])
		icon:setScale(0.1)
		self.root:addChild(icon)
		table.insert(self.uiList, icon)
		icon:enableTip()

		icon:setPosition((self.root:getContentSize().width)/2, (self.root:getContentSize().height)/2)

		local action = cc.Spawn:create(
			cc.MoveTo:create(animaValue, cc.p(self.pos[i]:getPositionX()+icon:getContentSize().width/2, self.pos[i]:getPositionY() + icon:getContentSize().height/2)), 
		cc.ScaleTo:create(animaValue,1), 
		cc.Sequence:create(cc.RotateTo:create(animaValue/2, 180), cc.RotateTo:create(animaValue/2, 360)))

		icon:runAction(action)
		self.pos[i]:getChildByName("name"):setString(icon:getName())

		if self.data[i][1] == 2 and self.data[i][2] >= 41001 and  self.data[i][2] <= 41111 then
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
				if value.piece_item_id == self.data[i][2] then
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
		end
		i = i + 1
	end

	if self.time ~= nil then
		self:unschedule(self.time)
		self.time = nil
	end

	self.time = self:schedule(updateTime, timeValue)
end

function CombineRewardView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function CombineRewardView:unschedule(action)
  self:stopAction(action)
end

return CombineRewardView