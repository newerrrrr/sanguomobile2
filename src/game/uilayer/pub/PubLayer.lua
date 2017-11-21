local PubLayer = class("PubLayer",function()
	return cc.Layer:create()
end)

--require("game.uilayer.pub.PubLayer").openPubAndPositonGeneral(generalId)
function PubLayer.openPubAndPositonGeneral(generalId)
	g_sceneManager.addNodeForUI(require("game.uilayer.pub.PubLayer"):create(generalId))
end

local actionTag = 44556677
function PubLayer:ctor(generalId)
	local pubBuildServerData =  g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.bar) 
	self._generalId = generalId

	local uiLayer =  g_gameTools.LoadCocosUI("Pub_new_Panel.csb",5)
	self:addChild(uiLayer)
	local baseNode = uiLayer:getChildByName("scale_node")
	self._baseNode = baseNode
	
	g_guideManager.registComponent(1000201,self._baseNode:getChildByName("Button_zm"))
	
	self:registerScriptHandler(function(eventType)
	  if eventType == "enter" then
		  g_guideManager.execute()
		  
		  --新手引导的关系，在enter 里调用
		  self:updateStarCount()
		  self:updateView()
	  elseif eventType == "exit" then
		  
	  end 
	end )
	
	local closeBtn = baseNode:getChildByName("Button_1")
	closeBtn:setTouchEnabled(true)
	closeBtn:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			self:removeFromParent()
		end
	end)
	
	self._baseNode:getChildByName("Panel_a1"):getChildByName("Button_3"):getChildByName("Text_10_0"):setString(g_tr("generalStarRewardBtn"))
	
	self._countryType = 0
	-- 0 全部 1吴 2蜀 3魏 4群
	--国家标签
	for i = 1, 5 do
		local btn = baseNode:getChildByName("Panel_a1"):getChildByName("Panel_aa"..i):getChildByName("Image_3")
		baseNode:getChildByName("Panel_a1"):getChildByName("Panel_aa"..i):getChildByName("Text_3"):setString(g_tr("short_country"..(i-1)))
		if i ~= 1 then
			baseNode:getChildByName("Panel_a1"):getChildByName("Panel_aa"..i):getChildByName("Image_4"):setVisible(false)
		end
		
		btn:setTouchEnabled(true)
		btn:addClickEventListener(function()
			for j = 1, 5 do
				baseNode:getChildByName("Panel_a1"):getChildByName("Panel_aa"..j):getChildByName("Image_4"):setVisible(false)
			end
			baseNode:getChildByName("Panel_a1"):getChildByName("Panel_aa"..i):getChildByName("Image_4"):setVisible(true)
		
			local targetType = i - 1
			if targetType ~= self._countryType then
				self._countryType = targetType
				self:updateView()
			end
		end)
	end
	
	local btnStarReward = baseNode:getChildByName("Panel_a1"):getChildByName("Button_3")
	btnStarReward:addClickEventListener(function()
		local layer = require("game.uilayer.pub.PubCollectionReward"):create()
		layer:registerScriptHandler(function(eventType)
		  if eventType == "enter" then
		  elseif eventType == "exit" then
		  	self:updateStarCount()
		  end 
		end )
		g_sceneManager.addNodeForUI(layer)
	end)
	
	
	baseNode:getChildByName("Text_8"):setString(g_tr("tavern"))
	self._baseNode:getChildByName("Text_5_0_0"):enableShadow(cc.c4b(0, 0, 0,255),cc.size(1,1),2)
	
	self._orgGetWayRichLabelPosX = self._baseNode:getChildByName("getWayDesc"):getPositionX()
	self._orgGetWayRichLabelWidth = self._baseNode:getChildByName("getWayDesc"):getContentSize().width
	self._getWayRichLabel = g_gameTools.createRichText(self._baseNode:getChildByName("getWayDesc"),"")
	
	local btnHelp = baseNode:getChildByName("Button_help")
	btnHelp:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			require("game.uilayer.common.HelpInfoBox"):show(23) 
		end
	end)
	
	local btnUnRecuit = baseNode:getChildByName("Panel_2"):getChildByName("Button_mc")
	baseNode:getChildByName("Panel_2"):getChildByName("Text_mc"):setString(g_tr("generalUnRecruite"))
	baseNode:getChildByName("Panel_2"):getChildByName("Image_mc"):setVisible(false)
	
	btnUnRecuit:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			self._currentTab = 1
			self:changeTab(self._currentTab)
		end
	end)
	
	local btnRecuited = baseNode:getChildByName("Panel_3"):getChildByName("Button_mc")
	baseNode:getChildByName("Panel_3"):getChildByName("Text_mc"):setString(g_tr("generalRecruited"))
	baseNode:getChildByName("Panel_3"):getChildByName("Image_mc"):setVisible(false)
	btnRecuited:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			self._currentTab = 2
			self:changeTab(self._currentTab)
		end
	end)
	
	self._listView = self._baseNode:getChildByName("ListView_2")
	self._listView:setVisible(false)
	self._listView:setScrollBarEnabled(false)
	
	self._serverData = pubBuildServerData
	
	self._currentTab = 1
	self._currentSelectedIdx = 1
	self._refreshDirty = true
	
	local recuitHandler = function()
		local generalData = self._generalDatas[self._currentSelectedIdx]
		self:recuitHandler(generalData)
	end
	self._baseNode:getChildByName("Button_zm"):addClickEventListener(recuitHandler)
	
	local lv = g_data.starting[83].data
	self._baseNode:getChildByName("Button_dj"):getChildByName("Text_1"):setString(g_tr("generalDuijiuVipLv",{lv = lv}))
	
	local duijiuHandler = function()
	   local generalData = self._generalDatas[self._currentSelectedIdx]
	   if generalData.num and generalData.num <= 0 then
		   g_airBox.show(g_tr("generalDuijiuCondition"))
		   return
	   end
	
	   if self:checkDuijiuVipCondition() then
		  local itemData = require("game.gamedata.ShopItemData").new()
		  itemData:setType(g_Consts.DropType.Props)
		  itemData:setItemConfigId(generalData.config.piece_item_id)
		  itemData:setShopType(g_Consts.ShopType.PUB)
		  local costNum = generalData.config.sell_price
		  local costType = g_Consts.AllCurrencyType.Gem
		  itemData:setPrice(costNum)
		  itemData:setCostType(costType)
		  itemData:setCount(1)
		  
		  local alertLayer = require("game.uilayer.shop.ShopBuyAlertLayer"):create(itemData)
		  alertLayer:setDelegate(self)
		  g_sceneManager.addNodeForUI(alertLayer)
	   else
		  self._vipLeftTime = require("game.uilayer.vip.VIPMode").getVipLeftTime()
		  local needVipLv = tonumber(g_data.starting[83].data)
		  local playerData = g_PlayerMode.GetData()
		  local vipLv = playerData.vip_level
		  if vipLv >= needVipLv then
			  if self._vipLeftTime > 0 then
			  else
				  local text = g_tr("generalDuijiuVipTip1")
				  local callback = function(type)
					  if type == 0 then
						  require("game.uilayer.vip.VIPActiveExpUp"):showActivePop(function()
							  self._refreshDirty = true
							  self:changeGeneral(self._currentSelectedIdx)
						  end)
					  end
				  end
				  g_msgBox.show(text, title, ctp, callback, 1, {["0"] = g_tr("vipActive")})
			  end
		  else
			  local text = g_tr("generalDuijiuVipTip2")
			  local callback = function(type)
				  if type == 0 then
					  local vipLayer = require("game.uilayer.vip.VIPMainLayer").new()
					  g_sceneManager.addNodeForUI(vipLayer)
					  vipLayer:playLevelupTips()
				  end
			  end
			  g_msgBox.show(text, title, ctp, callback, 1, {["0"] = g_tr("vipBuy")})
		  end
	   
--		  local lv = g_data.starting[83].data
--		  g_airBox.show(g_tr("generalDuijiuVipLv",{lv = lv}))
	   end 
	end
	self._baseNode:getChildByName("Button_dj"):addClickEventListener(duijiuHandler)
	self._baseNode:getChildByName("Button_dj"):getChildByName("Text_2"):setString(g_tr("generalDuijiuTxt"))
	
end

function PubLayer:changeTab(idx)
	
	self._vipLeftTime = require("game.uilayer.vip.VIPMode").getVipLeftTime()

	self._baseNode:getChildByName("Panel_2"):getChildByName("Button_mc"):setEnabled(true)
	self._baseNode:getChildByName("Panel_3"):getChildByName("Button_mc"):setEnabled(true)
	local playerPubData = require("game.gamedata.PlayerPub")
	local max = playerPubData.getMaxGeneralToRecruit()
	local ownGenerals = g_GeneralMode.GetData()
	local owenCount = #ownGenerals or 0
		
	self._baseNode:getChildByName("Text_zd1"):setString(g_tr("generalHasRecruit"))
	self._baseNode:getChildByName("Text_zd2"):setString(owenCount.."/"..max)
		
	if idx == 1 then
		self._baseNode:getChildByName("Panel_2"):getChildByName("Button_mc"):setEnabled(false)
		self._getWayRichLabel:setVisible(true)

	--	local ownGenerals = g_GeneralMode.GetData()
	--	local owenCount = #ownGenerals or 0
	--	
		--self._baseNode:getChildByName("Text_zd1"):setString(g_tr("generalMaxToRecruit"))
		--self._baseNode:getChildByName("Text_zd2"):setString(max.."")
	
	elseif idx == 2 then
		self._baseNode:getChildByName("Panel_3"):getChildByName("Button_mc"):setEnabled(false)
		self._getWayRichLabel:setVisible(false)
		self._baseNode:getChildByName("Button_dj"):setVisible(false)

--		local ownGenerals = g_GeneralMode.GetData()
--		local owenCount = #ownGenerals or 0
--		
--		self._baseNode:getChildByName("Text_zd1"):setString(g_tr("generalHasRecruit"))
--		self._baseNode:getChildByName("Text_zd2"):setString(owenCount.."/"..max)
	end
	
	self._currentTab = idx 
	self._currentSelectedIdx = 1
	self._refreshDirty = true
	self._lastItem = nil
	self:rebuildList()
	self:changeGeneral(self._currentSelectedIdx)
end

function PubLayer:recuitHandler(generalData)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local resultHandler = function(result, msgData)
		  if result then
			  print("buy general success")
			  require("game.uilayer.pub.pubGeneralAnimation").playRecruitAnimation(generalData.config,2,self)
			  self:updateStarCount()
			  self:updateView()
		  end
	end
			
	g_sgHttp.postData("Pub/buyPrisoner",{generalId = generalData.config.general_original_id,steps = g_guideManager.getToSaveStepId()},resultHandler)
end

function PubLayer:updateStarCount()
	local btnStarReward = self._baseNode:getChildByName("Panel_a1"):getChildByName("Button_3")
	local haveReward = g_PlayerPubMode.isHaveStarReward()
	local currentStar = g_PlayerPubMode.getCurrentTotalStar()
	btnStarReward:getChildByName("Image_13"):setVisible(haveReward)
	self._baseNode:getChildByName("Panel_a1"):getChildByName("Text_10"):setString(currentStar.."")
end

function PubLayer:changeGeneral(idx)
	
	if idx == self._currentSelectedIdx and not self._refreshDirty then
		return
	end
	
	self._currentSelectedIdx = idx 
	
	if self._lastItem then
		self._lastItem:getChildByName("scale_node"):getChildByName("Image_2"):setVisible(false)
	end
	
	self._lastItem = self._lastListView:getItem(self._currentSelectedIdx - 1)
	if self._lastItem then
		self._lastItem:getChildByName("scale_node"):getChildByName("Image_2"):setVisible(true)
	end
	
	self._baseNode:getChildByName("Button_zm"):setVisible(false) 
	self._baseNode:getChildByName("Button_dj"):setVisible(false)
	
	if #self._generalDatas == 0 then
		self._baseNode:getChildByName("Panel_xx"):setVisible(false)
		self._baseNode:getChildByName("Image_renw"):setVisible(false)
		self._baseNode:getChildByName("Panel_1ss"):setVisible(false)
		self._baseNode:getChildByName("Image_8"):setVisible(false)
		self._baseNode:getChildByName("Button_2"):setVisible(false)
		
		self._baseNode:getChildByName("Text_5_0_0"):setString("")
		self._baseNode:getChildByName("Text_5_0"):setString("")
		self._baseNode:getChildByName("Text_5"):setString("")
		
		local emptyStr = g_tr("pubFinshed")
		if self._currentTab == 2 then
			emptyStr = g_tr("pubNoOne")
		end
		self._baseNode:getChildByName("Text_listEmpty"):setString(emptyStr)
		
		if self._getWayRichLabel then
			self._getWayRichLabel:setRichText("")
		end
		
		return
	end
	
	self._baseNode:getChildByName("Panel_xx"):setVisible(true)
	self._baseNode:getChildByName("Image_renw"):setVisible(true)
	self._baseNode:getChildByName("Panel_1ss"):setVisible(true)
	self._baseNode:getChildByName("Image_8"):setVisible(true)
	self._baseNode:getChildByName("Button_2"):setVisible(true)
	
	self._baseNode:getChildByName("Text_listEmpty"):setString("")
	
	local generalData = self._generalDatas[idx]
	self._baseNode:getChildByName("Image_renw"):loadTexture(g_resManager.getResPath(generalData.config.general_big_icon))
	self._baseNode:getChildByName("Text_5_0"):setString(g_tr("betterArmy"))
	self._baseNode:getChildByName("Text_5"):setString(g_tr(generalData.config.general_name))
	
	do --显示星级
		if generalData.config.general_quality < 6 then
			--star
			for i=1, 4 do
				self._baseNode:getChildByName("Panel_xx"):getChildByName("Button_x"..i):setVisible(false)
			end
			self._baseNode:getChildByName("Panel_xx"):getChildByName("Button_x1"):setVisible(true)
		else
			local currentStarLv = math.floor(tonumber(generalData.serverData.star_lv)/5) + 1
			for i=1, 4 do
				self._baseNode:getChildByName("Panel_xx"):getChildByName("Button_x"..i):setVisible(true)
				self._baseNode:getChildByName("Panel_xx"):getChildByName("Button_x"..i):setEnabled(currentStarLv >= i)
			end
		end
	end

	g_custom_loadFunc("CalculateTalent", "(star)", " return "..generalData.config.general_talent_value_client)
	
	local starLv = 0
	if generalData.serverData then
		starLv = tonumber(generalData.serverData.star_lv)
	end
  local talentVal = externFunctionCalculateTalent(starLv) 
  
	--显示天赋
	local talentStr = g_tr(generalData.config.general_talent_description,{num = talentVal})
	
	if self._richTalent == nil then
		local rich = g_gameTools.createRichText(self._baseNode:getChildByName("Panel_1ss"):getChildByName("Text_12"),talentStr)
		self._richTalent = rich
	else
		self._richTalent:setRichText(talentStr)
	end
	local parentSize = self._baseNode:getChildByName("Panel_1ss"):getContentSize()
	local size = self._richTalent:getRealSize()
	self._richTalent:setPositionX(parentSize.width - size.width/2)
	
	local btnPreview = self._baseNode:getChildByName("Button_2")
	if generalData.serverData then
		g_itemTips.tipGeneralByServerData(btnPreview,generalData.serverData)
	else
		g_itemTips.tip(btnPreview,g_Consts.DropType.General,generalData.config.id)
	end
	
	local equipInfo = g_data.equipment[generalData.config.general_item_id*100]
	local str = ""
	for i=1, #equipInfo.equip_skill_id do
		local skillInfo =  g_data.equip_skill[equipInfo.equip_skill_id[i]]
		local troopType = skillInfo.equip_arm_type
		local troopStr = ""
		if troopType == 1 then
			troopStr = g_tr("infantry")
		elseif troopType == 2 then
			troopStr = g_tr("cavalry")
		elseif troopType == 3 then
			troopStr = g_tr("archer")
		elseif troopType == 4 then
			troopStr = g_tr("vehicles")
		end
		str = str..troopStr.." "
	end
	self._baseNode:getChildByName("Text_5_0_0"):setString(str)

	local getWayStr = ""
	
	local dropshowGroups = generalData.config.drop_show
	if #dropshowGroups > 0 then
		for key, group in ipairs(dropshowGroups) do
			if group[1] == 1 then --野怪获得
			   local npcInfo = g_data.npc[group[2]]
			   assert(npcInfo,"cannot found npc "..group[2])
			   getWayStr = getWayStr..g_tr("generalGetWayDesc1",{lv = "Lv"..npcInfo.monster_lv,npc_name = g_tr_original(npcInfo.monster_name),general_name = g_tr_original(generalData.config.general_name)}).."  "
			elseif group[1] == 2 then --联盟商店
			   getWayStr = g_tr("getPathAllianceStore",{general_name = g_tr_original(generalData.config.general_name)})
			elseif group[1] == 3 then --锦囊商店
			   getWayStr = g_tr("getPathJinnangStore",{general_name = g_tr_original(generalData.config.general_name)})
			elseif group[1] == 4 then --联盟商店
			   local activityName = g_tr_original(g_data.activity[group[2]].activity_name)
			   getWayStr = g_tr("getPathActivity",{general_name = g_tr_original(generalData.config.general_name),activity_name = activityName})
			end
		end
	end
	self._getWayRichLabel:setRichText(getWayStr)
	
	local size = self._getWayRichLabel:getRealSize()
	self._getWayRichLabel:setPositionX(self._orgGetWayRichLabelPosX + self._orgGetWayRichLabelWidth/2 - size.width/2)
	--self._orgGetWayRichLabelWidth
	--self._orgGetWayRichLabelPosX
	

	self._baseNode:getChildByName("Button_zm"):setEnabled(not generalData.isDone and generalData.num >= generalData.config.piece_required)
	self._baseNode:getChildByName("Button_zm"):setVisible(not generalData.isDone) 

	if self._baseNode:getChildByName("Button_zm"):isEnabled() then
		if self._zhaoMuBtnAnim == nil then
			local size = self._baseNode:getChildByName("Button_zm"):getContentSize()
			
			 --按钮动画加载
			local projName = "Effect_JiuGuangZhaoMuAnNiu"
			local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName)
			self._baseNode:getChildByName("Button_zm"):addChild(armature)
			armature:setPosition(cc.p(size.width/2,size.height/2))
			self._zhaoMuBtnAnim = armature
			animation:play("Animation1")
		end
		
		--背景动画去掉
		--[[if self._generalAnim == nil then
			local size = self._baseNode:getChildByName("Image_7"):getContentSize()
			--背景动画加载
			local projName = "Effect_JiuGuangHeroTongYongBeiJing"
			local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName)
			self._baseNode:getChildByName("Image_7"):addChild(armature)
			armature:setPosition(cc.p(size.width/2,size.height/2))
			self._generalAnim = armature
			animation:play("Animation1")
			
		end]]
		
	end
	
	if self._zhaoMuBtnAnim then
		self._zhaoMuBtnAnim:setVisible(self._baseNode:getChildByName("Button_zm"):isEnabled() and self._baseNode:getChildByName("Button_zm"):isVisible())
	end
	
	if self._generalAnim then
		self._generalAnim:setVisible(self._baseNode:getChildByName("Button_zm"):isEnabled())
	end
	
	if generalData.isDone or generalData.num >= generalData.config.piece_required then
		self._baseNode:getChildByName("Image_renw"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )
	else
		self._baseNode:getChildByName("Image_renw"):getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
		
		--对酒按钮
		if generalData.config.sell_price > 0 then
			self._baseNode:getChildByName("Button_dj"):setVisible(true)
			self._baseNode:getChildByName("Button_dj"):getChildByName("Text_1"):setVisible(not self:checkDuijiuVipCondition())
			self._baseNode:getChildByName("Button_zm"):setVisible(false)
		end
	end
	
end

function PubLayer:checkDuijiuVipCondition()
	self._vipLeftTime = require("game.uilayer.vip.VIPMode").getVipLeftTime()
	local needVipLv = tonumber(g_data.starting[83].data)
	local playerData = g_PlayerMode.GetData()
	local vipLv = playerData.vip_level
	local vipActived = false
	if vipLv >= needVipLv and self._vipLeftTime > 0 then
		vipActived = true 
	end
	return vipActived
end

function PubLayer:updateView()
	self:changeTab(self._currentTab)
end
function PubLayer:listLoadCompleteHandler()

end


function PubLayer:rebuildList()
	if self._lastListView then
		self._lastListView:removeFromParent()
		self._lastListView = nil
	end

	local listView = self._listView:clone()
	self._listView:getParent():addChild(listView)
	listView:setVisible(true)
	listView:removeAllChildren()
	self._lastListView = listView
	
	local function listViewEvent(sender, eventType)
		if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
			g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			self:changeGeneral(sender:getCurSelectedIndex() + 1)
		end
	end
	listView:addEventListener(listViewEvent)
	
	--local generalDatas = {} --所有要显示的武将列表
 
	local colectingDatas = {} --碎片不够招募的武将列表
	
	local fullDatas = {} --碎片可合成的武将列表
	local doneDatas = {} --已经完成招募的武将列表
	
--	local ownGenerals = g_GeneralMode.GetData()
--	local keyOwnGenerals = {}
--	
--	--local generalRootId = g_data.general[self._generalConfigId].general_original_id
--	for key, generalInfo in pairs(ownGenerals) do
--		keyOwnGenerals[generalInfo.general_id] = generalInfo --服务器发送的generalInfo.general_id 为general_original_id
--	end
	
	local keyOwnGenerals = g_GeneralMode.getOwnedGenerals()
	
	for key, generalInfo in pairs(g_data.general) do
		if self._countryType == 0 or self._countryType == generalInfo.general_country then
			local haveNum = 0
			local bagData = g_BagMode.FindItemByID(generalInfo.piece_item_id)
			if bagData and bagData.num then
			   haveNum = bagData.num
			end
			
			--新手相关 将指定的街招募武将显示为不可招募
			local step = g_guideManager.getLastShowStep()
			if step then
				for key, skipGeneralId in ipairs(step:getConfig().params) do
					if skipGeneralId  == generalInfo.id then
					   haveNum = 0
					end
				end
			end
			
			local generalData = {}
			generalData.num = haveNum
			generalData.config = generalInfo
			generalData.isDone = false
			
			if keyOwnGenerals[generalInfo.general_original_id] then --已经招募
				generalData.isDone = true
				generalData.serverData = keyOwnGenerals[generalInfo.general_original_id]
				table.insert(doneDatas,generalData)
			else --未招募
				--是否已经化神
				
				if generalInfo.avaiable_level > 0 and self._serverData.build_level >= generalInfo.avaiable_level then
				
					local hasGod = false
					local godGeneralConfig = g_GeneralMode.getGodGeneralConfigByRootId(generalInfo.root_id)
					if godGeneralConfig then
						if keyOwnGenerals[godGeneralConfig.general_original_id] then
						   hasGod = true
						end
					end
					
					if not hasGod then
					  if haveNum < generalInfo.piece_required then
						  table.insert(colectingDatas,generalData)
					  else
						  table.insert(fullDatas,generalData)
					  end
					end
				end
			end
		end
	end
	
	local sortFunc = function(a,b)
		return a.config.priority > b.config.priority
	end
	
	local sortColectingFunc = function(a,b)
		if a.num == b.num then
		   return a.config.priority > b.config.priority
		end
		return a.num/a.config.piece_required > b.num/b.config.piece_required
	end
	
	table.sort(doneDatas,sortFunc)
	table.sort(fullDatas,sortFunc)
	table.sort(colectingDatas,sortColectingFunc)

--	do
--		for key, var in ipairs(doneDatas) do
--			table.insert(generalDatas,var)
--		end
--	end
--	
--	do
--		for key, var in ipairs(fullDatas) do
--			table.insert(generalDatas,var)
--		end
--	end
--	
--	do
--		for key, var in ipairs(colectingDatas) do
--			table.insert(generalDatas,var)
--		end
--	end
	
	if self._currentTab == 1 then --待招募
		local unRecuitDatas = {}
		do
			for key, var in ipairs(fullDatas) do
				table.insert(unRecuitDatas,var)
			end
		end
		
		do
			for key, var in ipairs(colectingDatas) do
				table.insert(unRecuitDatas,var)
			end
		end
	
		self._generalDatas = unRecuitDatas
	elseif self._currentTab == 2 then --已招募
		self._generalDatas = doneDatas
	end
	
	local generalGetWayFunc = function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			--g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

			local callback = function()
				self:removeFromParent()
			end
			
			local generalData = sender.data
			local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.General, generalData.config.id, callback)
			g_sceneManager.addNodeForUI(view)
		end
	end
	
	self:stopActionByTag(actionTag)
	
	if #self._generalDatas > 0 then
		--local itemModel = cc.CSLoader:createNode("Pub_new_wujiang.csb")
		
		local startIdx = 5
		
		local defaultSelectIdx = 1
		if self._generalId then
			for key, generalData in ipairs(self._generalDatas) do
				if generalData.config.id == self._generalId then
					startIdx = math.max(startIdx,key)
					defaultSelectIdx = key
					break
				end
			end
		end
		
		
		
		local idx = 1
		
		local needPosition = false
		local createItem = function(generalData)
		
			--local item = itemModel:clone()
			local item = cc.CSLoader:createNode("Pub_new_wujiang.csb")
			local getBtn = item:getChildByName("scale_node"):getChildByName("Button_1")
			if not generalData.isDone then
				getBtn.data = generalData
				getBtn:getChildByName("Text_11"):setString(g_tr("getfragment"))
				getBtn:addTouchEventListener(generalGetWayFunc)
			else
				getBtn:getChildByName("Text_11"):setString(g_tr("viewGeneral"))
				getBtn:addTouchEventListener(function(sender,eventType)
					if eventType == ccui.TouchEventType.ended then
						--g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
						local view = require("game.uilayer.office.OfficeLayer").new(generalData.config.id)
						g_sceneManager.addNodeForUI(view)
					end
				end)
			end
			
			self:updateListItem(item,generalData)
			
			listView:pushBackCustomItem(item)
			
		end
		
--		for key, generalData in ipairs(self._generalDatas) do
--			createItem(generalData)
--		end
		
	   
		for key, generalData in ipairs(self._generalDatas) do
			if key > startIdx then
				if defaultSelectIdx > 1 then
					self:changeGeneral(defaultSelectIdx)
					local sequence = cc.Sequence:create(cc.DelayTime:create(0.001), cc.CallFunc:create(function()
						listView:jumpToBottom()
					end))
					listView:runAction(sequence)
				end
				break
			else
				createItem(generalData)
				idx = idx + 1
			end
		end
		
		local callback = function()
			local generalData = self._generalDatas[idx]
			createItem(generalData)
			idx = idx + 1
			if idx > #self._generalDatas then
				self:stopActionByTag(actionTag)
				self:listLoadCompleteHandler()
			end
		end
		
		if #self._generalDatas > startIdx then
			local sequence = cc.Sequence:create(cc.DelayTime:create(0.001), cc.CallFunc:create(callback))
			local action = cc.RepeatForever:create(sequence)
			action:setTag(actionTag)
			self:runAction(action)
		else
			self:listLoadCompleteHandler()
		end
	end
end

function PubLayer:onAfterBuyGeneralPiece()
	
	local curGeneralData = self._generalDatas[self._currentSelectedIdx]
--	local ownGenerals = g_GeneralMode.GetData()
--	local keyOwnGenerals = {}
--	
--	--local generalRootId = g_data.general[self._generalConfigId].general_original_id
--	for key, generalInfo in pairs(ownGenerals) do
--		keyOwnGenerals[generalInfo.general_id] = generalInfo --服务器发送的generalInfo.general_id 为general_original_id
--	end
	local keyOwnGenerals = g_GeneralMode.getOwnedGenerals()
	
	local generalInfo = curGeneralData.config
	local haveNum = 0
	local bagData = g_BagMode.FindItemByID(generalInfo.piece_item_id)
	if bagData and bagData.num then
	   haveNum = bagData.num
	end
	
	--新手相关 将指定的街招募武将显示为不可招募
	local step = g_guideManager.getLastShowStep()
	if step then
		for key, skipGeneralId in ipairs(step:getConfig().params) do
			if skipGeneralId  == generalInfo.id then
			   haveNum = 0
			end
		end
	end
	
	local generalData = {}
	generalData.num = haveNum
	generalData.config = generalInfo
	generalData.isDone = false
	
	if keyOwnGenerals[generalInfo.general_original_id] then --已经招募
		generalData.isDone = true
		generalData.serverData = keyOwnGenerals[generalInfo.general_original_id]
	end
	
	self._generalDatas[self._currentSelectedIdx] = generalData
	if self._lastItem then
		self:updateListItem(self._lastItem,generalData)
		
		self._refreshDirty = true
		self:changeGeneral(self._currentSelectedIdx)
	end
end

function PubLayer:updateListItem(item,generalData)
	local needNum = generalData.config.piece_required
	local haveNum = generalData.num
	
	if haveNum > needNum then
		haveNum = needNum 
	end
	
	local getBtn = item:getChildByName("scale_node"):getChildByName("Button_1")
	getBtn:setVisible(true)
	if haveNum >= needNum and not generalData.isDone then
	   item:getChildByName("scale_node"):getChildByName("Text_1"):setTextColor(g_Consts.ColorType.Green)
	   getBtn:setVisible(false)
	else
	   item:getChildByName("scale_node"):getChildByName("Text_1"):setTextColor(g_Consts.ColorType.Red)
	end
	item:getChildByName("scale_node"):getChildByName("Text_1"):setString(haveNum.."/"..needNum)
	
	item:getChildByName("scale_node"):getChildByName("Image_3"):setVisible(generalData.isDone)
	item:getChildByName("scale_node"):getChildByName("Image_sp"):setVisible(not generalData.isDone)
	item:getChildByName("scale_node"):getChildByName("Text_1"):setVisible(not generalData.isDone)
	
	item:getChildByName("scale_node"):getChildByName("Text_mingzi"):setString(g_tr(generalData.config.general_name))
	
	item:getChildByName("scale_node"):getChildByName("Image_2"):setVisible(false)
	item:getChildByName("scale_node"):getChildByName("icon"):setVisible(false)
	local headContainer = item:getChildByName("scale_node"):getChildByName("Image_1")
	headContainer:removeAllChildren()
	local size = headContainer:getContentSize()
	local headView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.General,generalData.config.id,0)
	if generalData.serverData then
		headView:showGeneralServerStarLv(generalData.serverData.star_lv)
	end
	headView:setCountEnabled(false)
	headContainer:addChild(headView)
	headView:setPosition(cc.p(size.width/2,size.height/2))
	
	if not generalData.isDone and haveNum >= needNum then
		local projName = "Effect_JiuGuangRenWuKuang"
		local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName)
		headContainer:addChild(armature)
		armature:setPosition(cc.p(size.width/2,size.height/2))
		
		animation:play("Animation1")
		
		getBtn:setVisible(false)
	end
	
--	if  generalData.isDone then
--		--getBtn:setVisible(false)
--		getBtn:getChildByName("Text_11"):setString(g_tr("viewGeneral"))
--	end
	
end

return PubLayer