local AllianceManageCamp = class("AllianceManageCamp",function()
	return cc.Layer:create()
end)

--有联盟，是管理员，并且修改免费才会打开界面
function AllianceManageCamp.show()

	if g_AllianceMode.getSelfHaveAlliance() and g_AllianceMode.isAllianceManager() then
		local isCostFree = false
		isCostFree = g_AllianceMode.getAllianceCampId() <= 0
		if not isCostFree then
			local newSeasonTime = g_AllianceMode.getCampWarCurrentSeasonStatTime()
			isCostFree = g_AllianceMode.getBaseData().change_camp_time < newSeasonTime
		end
		
		if isCostFree then
			local page = require("game.uilayer.alliance.managelayer.AllianceManageCamp"):create()
		g_sceneManager.addNodeForUI(page)
		end
	
	end
	
end

function AllianceManageCamp:ctor()
	local uiLayer = g_gameTools.LoadCocosUI("CityBattle_popup02.csb",5)
	self:addChild(uiLayer)
	
	local closeBtn = uiLayer:getChildByName("scale_node"):getChildByName("close_btn")

	closeBtn:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			self:removeFromParent()
		end
	end)
	
	
--	uiLayer:getChildByName("text_1"):setString(g_tr("currentAllianceCamp"))--当前联盟阵营
--	uiLayer:getChildByName("text_2"):setString(g_tr("newAllianceCamp"))--选择新阵营
		
	local currentCampId = g_AllianceMode.getAllianceCampId()
--	if currentCampId > 0 then
--		local iconId = g_data.country_camp_list[currentCampId].camp_pic
--		uiLayer:getChildByName("pic_current"):loadTexture(g_resManager.getResPath(iconId))
--	end
	
	self._countryFlag = currentCampId
	
	uiLayer:getChildByName("scale_node"):getChildByName("Panel_xuanzzr"):getChildByName("Text_2"):setString(g_tr("allianceCampChoseText"))
	uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf"):getChildByName("Text_1_0"):setString(g_tr("allianceCampChangeCost"))
	uiLayer:getChildByName("scale_node"):getChildByName("Text_xz"):setString(g_tr("allianceCampChose"))
	
	
	do
		local costs = g_gameTools.getCostsByCostId(29,1)
		local costNum = costs[1].cost_num
		local costType =	costs[1].cost_type
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf"):getChildByName("Text_1"):setString(string.formatnumberthousands(costNum))--price
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf"):getChildByName("Image_y1"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
	end
	
	do
		local costs = g_gameTools.getCostsByCostId(30,1)
		local costNum = costs[1].cost_num
		local costType =	costs[1].cost_type
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf"):getChildByName("Text_2"):setString(string.formatnumberthousands(costNum))--price
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf"):getChildByName("Image_y1_0"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
	end
		
	local updateCost = function()
		local isCostFree = false
		isCostFree = g_AllianceMode.getAllianceCampId() <= 0
		if not isCostFree then
			local newSeasonTime = g_AllianceMode.getCampWarCurrentSeasonStatTime()
			isCostFree = g_AllianceMode.getBaseData().change_camp_time < newSeasonTime
		end
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf"):setVisible(not isCostFree)
		
		--当前拥有
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf_0"):getChildByName("Text_1_0"):setString(g_tr("citybttle_change_camp_resshow"))
		do
			local count, icon = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.Gem)
			uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf_0"):getChildByName("Text_1"):setString(string.formatnumberthousands(count))--price
			uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf_0"):getChildByName("Image_y1"):loadTexture(icon)
		end
		
		do
			local count, icon = g_gameTools.getPlayerCurrencyCount(g_Consts.AllCurrencyType.AllianceHonor)
			uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf_0"):getChildByName("Text_2"):setString(string.formatnumberthousands(count))--price
			uiLayer:getChildByName("scale_node"):getChildByName("Panel_hf_0"):getChildByName("Image_y1_0"):loadTexture(icon)
		end
		
	end
	updateCost()
	
	local flags = {}
	local function selectCountryHandler(sender)
		if sender then
			local idx = sender.idx
--			for i=1, 3 do
--		 		flags[i]:getChildByName("Image_fag"):setVisible(false)
--		 	end
--		 	flags[idx]:getChildByName("Image_fag"):setVisible(true)
		 	self._countryFlag = idx
		 	
		 	local countryName = g_tr(g_data.country_camp_list[self._countryFlag].camp_name)
		 	g_msgBox.show(g_tr("makeSureChangeCamp",{country = countryName}),nil,nil,function(event)
			if event == 0 then
					local resultHandler = function(result, msgData)
								if result then
									print("success")
									--g_AllianceMode.setBaseData(msgData)
									g_airBox.show(g_tr("changeSuccess"))
									updateCost()
									--self:updateView()
								else
									--g_airBox.show(g_tr("changeFail"))
								end
							end
							
							local data = {}
							data.camp_id = self._countryFlag
							g_AllianceMode.reqChangeCamp(data,resultHandler)
					end
			end,1)
		end
	end
	
	
	for i=1, 3 do
		local icon = uiLayer:getChildByName("scale_node"):getChildByName("Button_d"..i)
		local iconId = g_data.country_camp_list[i].camp_pic
		--icon:getChildByName("pic_current"):loadTexture(g_resManager.getResPath(iconId))
		icon:setTouchEnabled(true)
		icon.idx = i
		icon:addClickEventListener(selectCountryHandler)
		flags[i] = icon
	end
	--selectCountryHandler(flags[currentCampId])
	
	
--	local saveBtn = uiLayer:getChildByName("btn_save")
--	saveBtn:getChildByName("Text"):setString(g_tr("modification")) --修改
--	saveBtn:addTouchEventListener(function(sender,eventType)
--		if eventType == ccui.TouchEventType.ended then
--			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
--			if self._countryFlag == tonumber(currentCampId) then
--				g_airBox.show(g_tr("selectCampTip"))
--				return
--			end
--			local resultHandler = function(result, msgData)
--				if result then
--					print("success")
--					--g_AllianceMode.setBaseData(msgData)
--					g_airBox.show(g_tr("changeSuccess"))
--					updateCost()
--					--self:updateView()
--				else
--					--g_airBox.show(g_tr("changeFail"))
--				end
--			end
--			
--			local data = {}
--			data.camp_id = self._countryFlag
--			g_AllianceMode.reqChangeCamp(data,resultHandler)
--		end
--	end)
--	

		
end

return AllianceManageCamp