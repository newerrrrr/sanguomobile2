local CorCombineView = class("CorCombineView", function()
	return cc.Layer:create()
end)

local itemEquip = {51001,51002,51003,51004,51005,51006}

function CorCombineView:ctor(closeWin)
	self.closeParent = closeWin

	self.click = false

    g_corData.SetCombineView(self)

	self.layer = cc.CSLoader:createNode("GodGenerals_Smithrecast_Synthesis.csb")

	self:addChild(self.layer)

	self.root = self.layer:getChildByName("scale_node")
	self.Panel_hecheng01 = self.root:getChildByName("Panel_hecheng01")
	self.Button_1_0_0 = self.Panel_hecheng01:getChildByName("Button_1_0_0")
	self.Text_3_0_0 = self.Panel_hecheng01:getChildByName("Text_3_0_0")
	self.Image_23 = self.Panel_hecheng01:getChildByName("Panel_tx")

	local armature1, animation1 = g_gameTools.LoadCocosAni("anime/Effect_ShenKuiJiaHeChengXunHuan/Effect_ShenKuiJiaHeChengXunHuan.ExportJson", "Effect_ShenKuiJiaHeChengXunHuan", animeCallback)
	armature1:setPosition(cc.p(self.Image_23:getContentSize().width/2,self.Image_23:getContentSize().height/2 ))
	self.Image_23:addChild(armature1)
	animation1:play("Animation1")

	for i=1, 6 do
		self["Image_kuang0"..i] = self.Panel_hecheng01:getChildByName("Image_kuang0"..i)
	end

	self.Panel_hecheng02 = self.root:getChildByName("Panel_hecheng02")
	self.ListView_1 = self.Panel_hecheng02:getChildByName("ListView_1")
	self.Text_5 = self.Panel_hecheng02:getChildByName("Text_5")

	self.Text_3_0_0:setString(g_tr("coT3"))
	self.Text_5:setString(g_tr("transformGeneral"))

	self:addEvent()

	self.data = {}
	self.uiList = {}
	self:initGeneral()
	self:initUI()
end


function CorCombineView:show(data)

	self.resultData = data
	self.data = {}
	self:initGeneral()
	self:initUI()

	local id = 0
	for key, value in pairs(g_data.general) do
		if value.piece_item_id == tonumber(self.resultData.itemIds[1]) then
			id = value.general_big_icon
			break
		end
	end

	local function animeCallback(armature , eventType , name)
		if ccs.MovementEventType.start == eventType then
		elseif ccs.MovementEventType.complete == eventType then
			armature:removeFromParent()
		elseif ccs.MovementEventType.loopComplete == eventType then
			armature:removeFromParent()
		end
	end

	local armature1, animation1 = g_gameTools.LoadCocosAni("anime/Effect_ShenKuiJiaHeChengMask/Effect_ShenKuiJiaHeChengMask.ExportJson", "Effect_ShenKuiJiaHeChengMask", animeCallback)
	armature1:setPosition(cc.p(self.root:getContentSize().width/2,self.root:getContentSize().height/2 ))
	self.root:addChild(armature1)
	animation1:play("Animation1")

	local armature2, animation2 = g_gameTools.LoadCocosAni("anime/Effect_ShenKuiJiaHeCheng/Effect_ShenKuiJiaHeCheng.ExportJson", "Effect_ShenKuiJiaHeCheng", animeCallback)
	armature2:setPosition(cc.p(self.root:getContentSize().width/2,self.root:getContentSize().height/2 ))
	self.root:addChild(armature2)
	animation2:play("Animation1")
	

	local function endTime()
		if self.ti ~= nil then
			self:unschedule(self.ti)
        	self.ti = nil
        	
        	g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CombineRewardView").new(self.resultData, handler(self, self.reCombine)))
		end
	end

	if self.ti ~= nil then
		self:unschedule(self.ti)
		self.ti = nil
	end

	self.ti = self:schedule(endTime, 1)
end

function CorCombineView:reCombine()
	local val = nil
	for key, value in pairs(g_data.general) do
		if value.piece_item_id == self.resultData.itemIds[1][2] then
			val = value.general_original_id
			break
		end
		
	end
	local GodGeneralEnhance = require("game.uilayer.godGeneral.GodGeneralEnhance"):create(val)
    g_sceneManager.addNodeForUI(GodGeneralEnhance)

    if self.closeParent ~= nil then
    	self.closeParent()
    end
end

function CorCombineView:initGeneral()
	--[[
	for key, value in pairs(g_data.general) do
		if value.condition > 0 and value.general_quality == g_GeneralMode.godQuality then
			if g_BagMode.FindItemByID(value.piece_item_id) == nil and g_GeneralMode.getGeneralById(math.floor(key/100)) == nil then
				table.insert(self.data, value)
			end
		end
	end
	]]

	local data = g_data.drop[230006]
	local generalList = g_GeneralMode.GetData()

	for i=1, #data.drop_data do
		for key, value in pairs(g_data.general) do
			if value.piece_item_id == data.drop_data[i][2] then
				if g_BagMode.FindItemByID(value.piece_item_id) == nil and g_GeneralMode.getGeneralById(math.floor(key/100)) == nil then
					table.insert(self.data, value)
				end
			end
		end
	end
end

function CorCombineView:initUI()
	local len = 0
	if (#self.data)%3 ~= 0 then
		len = math.ceil((#self.data)/3)
	else
		len = (#self.data)/3
	end

	local tem = 0
	if len > 3 then
		tem = 3
	else
		tem = len
	end

	local item = nil
	for i=1, tem do
		if self.uiList[i] == nil then
			item = require("game.uilayer.cornucopia.CorCombineItemView").new(self.closeParent)
			self.uiList[i] = item
			self.ListView_1:pushBackCustomItem(item)
		else
			item = self.uiList[i]
		end
		
		item:show(self.data[i*3-2], self.data[i*3-1], self.data[i*3])
	end

	if len > 3 then
		self:loadItem(len)
	else
		if len < #self.uiList then
			for i=len+1, #self.uiList do
				self.ListView_1:removeItem(self.ListView_1:getIndex(self.uiList[i]))
				self.uiList[i] = nil
			end
		end
	end

	for i=1, 6 do
		self["Image_kuang0"..i]:removeAllChildren()
		local num = g_BagMode.findItemNumberById(itemEquip[i])
		local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, itemEquip[i], num)
    	self["Image_kuang0"..i]:addChild(icon)
    	icon:setPosition(self["Image_kuang0"..i]:getContentSize().width/2, self["Image_kuang0"..i]:getContentSize().height/2)
    	icon:setCountEnabled(true)
	end
end

function CorCombineView:loadItem(len)
    local index = 4
    local idx_s = 4 
    local idx_e = len
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
        	if self.uiList[idx_s] == nil then
                item = require("game.uilayer.cornucopia.CorCombineItemView").new(self.closeParent)
            	self.ListView_1:pushBackCustomItem(item)
                self.uiList[idx_s] = item
            else
                item = self.uiList[idx_s]
            end
            item:show(self.data[index*3-2], self.data[index*3-1], self.data[index*3])
            idx_s = idx_s + 1 
            index = index + 1
        else
        	if index < #self.uiList then
                for i=index+1, #self.uiList do
                    self.ListView_1:removeItem(self.ListView_1:getIndex(self.uiList[i]))
                    self.uiList[i] = nil
                end
            end

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

function CorCombineView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_1_0_0 then
				if #self.data <= 0 then
					g_airBox.show(g_tr("allGodGeneralGeted"))
					return
				end

				if self.click == true then
					return
				end

				if g_BagMode.findItemNumberById(itemEquip[1]) == 0 then
					local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[1], self.closeWin)
                	g_sceneManager.addNodeForUI(view)

					return
				elseif g_BagMode.findItemNumberById(itemEquip[2]) == 0 then
					local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[2], self.closeWin)
                	g_sceneManager.addNodeForUI(view)

					return
				elseif g_BagMode.findItemNumberById(itemEquip[3]) == 0 then
					local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[3], self.closeWin)
                	g_sceneManager.addNodeForUI(view)

					return
				elseif g_BagMode.findItemNumberById(itemEquip[4]) == 0 then
					local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[4], self.closeWin)
                	g_sceneManager.addNodeForUI(view)

					return
				elseif g_BagMode.findItemNumberById(itemEquip[5]) == 0 then
					local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[5], self.closeWin)
                	g_sceneManager.addNodeForUI(view)

					return
				elseif g_BagMode.findItemNumberById(itemEquip[6]) == 0 then
					local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[6], self.closeWin)
                	g_sceneManager.addNodeForUI(view)

					return
				end

				local function callback()
					g_busyTip.hide_1()
				end

				local function limitCallback()
					self.click = false
					if self.limitClick ~= nil then
						self:unschedule(self.limitClick)
						self.limitClick = nil
					end
				end

				self.click = true
				g_busyTip.show_1()
				g_corData.CombineGodArmor(callback)
				if self.limitClick ~= nil then
					self:unschedule(self.limitClick)
					self.limitClick = nil
				end
				self.limitClick = self:schedule(limitCallback, 1)
			elseif sender == self["Image_kuang01"] then
				local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[1], self.closeWin)
                g_sceneManager.addNodeForUI(view)
                return
			elseif sender == self["Image_kuang02"] then
				local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[2], self.closeWin)
                g_sceneManager.addNodeForUI(view)
                return
			elseif sender == self["Image_kuang03"] then
				local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[3], self.closeWin)
                g_sceneManager.addNodeForUI(view)
                return
			elseif sender == self["Image_kuang04"] then
				local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[4], self.closeWin)
                g_sceneManager.addNodeForUI(view)
                return
			elseif sender == self["Image_kuang05"] then
				local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[5], self.closeWin)
                g_sceneManager.addNodeForUI(view)
                return
			elseif sender == self["Image_kuang06"] then
				local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, itemEquip[6], self.closeWin)
                g_sceneManager.addNodeForUI(view)
                return
			end
		end
	end

	self.closeWin = function()
		if self.closeParent~= nil then
			g_corData.SetCombineView(nil)
			self.closeParent()
		end
	end

	self.Button_1_0_0:addTouchEventListener(proClick)
	self["Image_kuang01"]:addTouchEventListener(proClick)
	self["Image_kuang02"]:addTouchEventListener(proClick)
	self["Image_kuang03"]:addTouchEventListener(proClick)
	self["Image_kuang04"]:addTouchEventListener(proClick)
	self["Image_kuang05"]:addTouchEventListener(proClick)
	self["Image_kuang06"]:addTouchEventListener(proClick)
end

function CorCombineView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function CorCombineView:unschedule(action)
  self:stopAction(action)
end

function CorCombineView:getInAni()
	return self.click
end

return CorCombineView