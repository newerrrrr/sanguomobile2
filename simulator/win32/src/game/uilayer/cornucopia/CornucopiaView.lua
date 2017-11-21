local CornucopiaView = class("CornucopiaView", require("game.uilayer.base.BaseLayer"))

function CornucopiaView:ctor(value, callback)
	CornucopiaView.super.ctor(self)

	self.curTab = value or 1

	self.callback = callback

	self.layer = self:loadUI("TheObservatory_Panel.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.Panel_dingwei = self.root:getChildByName("Panel_dingwei")
	self.Button_1 = self.root:getChildByName("Button_1")
	self.Text_8 = self.root:getChildByName("Text_8")

	self.topRes = g_resourcesInterface.installResources(self.layer)
	self.topResEx = require("game.gametools.TopTitleRes").new(self.layer, {g_Consts.AllCurrencyType.XuanTie, g_Consts.AllCurrencyType.Gem})

	for i=1, 5 do
		self["Button_mc"..i] = self.root:getChildByName("Button_mc"..i)
		self["btn"..i.."_Text_mc"] = self["Button_mc"..i]:getChildByName("Text_mc")
		self["btn"..i.."_Text_mc"]:setString(g_tr("coT"..i))
		self["btn"..i.."_Image_3"] = self["Button_mc"..i]:getChildByName("Image_3")
		self["btn"..i.."_Image_3"]:setVisible(false)
	end

	self.Text_8:setString(g_tr("cornucopiaTitle"))

	self:setTabLight()

	self:addEvent()

	self:updateTip()

	self:show()
end

function CornucopiaView:onEnter()
	g_gameCommon.addEventHandler(g_Consts.CustomEvent.DrawCardUpdateTip,function(_,data)
		self:updateTopRes()
		self:updateTip()
	end,self)
end

function CornucopiaView:onExit()
	g_gameCommon.removeEventHandler(g_Consts.CustomEvent.DrawCardUpdateTip,self)
	g_corData.SetContentView(nil)
	g_corData.SetCombineView(nil)
end


function CornucopiaView:show()
	local function closeWin()
		self:close()
	end

	if self.view ~= nil then
		self.Panel_dingwei:removeChild(self.view)
	end

	g_corData.SetContentView(nil)
	g_corData.SetCombineView(nil)

	if self.curTab == 3 then
		self.view = require("game.uilayer.cornucopia.CorCombineView").new(closeWin)
	elseif self.curTab == 4 then
		self.view = require("game.uilayer.cornucopia.CorGodView").new()
	elseif self.curTab == 5 then	
		self.view = require("game.uilayer.cornucopia.CorDecomposeView").new(self)
	else
		self.view = require("game.uilayer.cornucopia.CorContentView").new(self.curTab)
	end
	
	self.Panel_dingwei:addChild(self.view)
end

function CornucopiaView:updateTip()
	local playerInfo = g_playerInfoData.GetData()

	local startingData = tonumber(g_data.starting[90].data)
	local tTemp = g_clock.getCurServerTime() - playerInfo.bowl_type1_last_time + 3
	if tTemp < startingData then
		self.btn1_Image_3:setVisible(false)
	else
		self.btn1_Image_3:setVisible(true)
	end

	if g_BagMode.findItemNumberById(52001) > 0 then --占星券
		self.btn1_Image_3:setVisible(true)
	end 



	startingData = tonumber(g_data.starting[92].data)
	tTemp = g_clock.getCurServerTime() - playerInfo.bowl_type2_last_time + 3
	if tTemp < startingData then
		self.btn2_Image_3:setVisible(false)
	else
		self.btn2_Image_3:setVisible(true)
	end
	if g_BagMode.findItemNumberById(52002) > 0 then --天陨券
		self.btn2_Image_3:setVisible(true)
	end 

	local itemEquip = {51001,51002,51003,51004,51005,51006}
	local tag = true
	for i=1, #itemEquip do
		if g_BagMode.findItemNumberById(itemEquip[i]) == 0 then
			tag = false
			break
		end
	end

	self.btn3_Image_3:setVisible(tag)

	local tag = false
	if g_PlayerBuildMode.getMainCityBuilding_lv() >= tonumber(g_data.starting[106].data) then
        if playerInfo.sacrifice_free_flag == 1 then
           tag = true
        else
            local num = g_BagMode.findItemNumberById(52005)
            if num > 0 then
                tag = true
            end
        end
    end
    self.btn4_Image_3:setVisible(tag)
end

function CornucopiaView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.view:getInAni() == true then
				return
			end
			
			self:updateTip()
			
			if sender == self.Button_1 then
				if self.callback ~= nil then
					self.callback()
				end
				self:close()
			elseif sender == self.Button_mc1 then
				if self.curTab ~= 1 then
					self.curTab = 1
					self:show()
				end
				--self.btn1_Image_3:setVisible(false)
				self:setTabLight()
			elseif sender == self.Button_mc2 then
				if self.curTab ~= 2 then
					self.curTab = 2
					self:show()
				end
				--self.btn2_Image_3:setVisible(false)
				self:setTabLight()
			elseif sender == self.Button_mc3 then
				if self.curTab ~= 3 then
					self.curTab = 3
					self:show()
				end
				self.btn3_Image_3:setVisible(false)
				self:setTabLight()
			elseif sender == self.Button_mc4 then
				if g_PlayerBuildMode.getMainCityBuilding_lv() < tonumber(g_data.starting[106].data) then
					g_airBox.show(g_tr("leffOfficeLevel", {level=g_data.starting[106].data}))
					return
				end
				if self.curTab ~= 4 then
					self.curTab = 4
					self:show()
				end
				--self.btn4_Image_3:setVisible(false)
				self:setTabLight()

			elseif sender == self.Button_mc5 then
				if self.curTab ~= 5 then
					self.curTab = 5
					self:show()
				end
				--self.btn5_Image_3:setVisible(false)
				self:setTabLight()
			end
		end
	end

	self.Button_1:addTouchEventListener(proClick)
	self["Button_mc1"]:addTouchEventListener(proClick)
	self["Button_mc2"]:addTouchEventListener(proClick)
	self["Button_mc3"]:addTouchEventListener(proClick)
	self["Button_mc4"]:addTouchEventListener(proClick)
	self["Button_mc5"]:addTouchEventListener(proClick)
end

function CornucopiaView:setTabLight()
	for i=1, 5 do
		self["Button_mc"..i]:setBrightStyle(BRIGHT_NORMAL)
	end

	self["Button_mc"..self.curTab]:setBrightStyle(BRIGHT_HIGHLIGHT)

	if self.topRes then 
		self.topRes:setVisible(self.curTab ~= 5)
	end 
	if self.topResEx then 
		self.topResEx:getTopRes():setVisible(self.curTab == 5)
	end 
end

function CornucopiaView:updateTopRes()
	if self.topResEx then 
		self.topResEx:update()
	end 
end 

return CornucopiaView