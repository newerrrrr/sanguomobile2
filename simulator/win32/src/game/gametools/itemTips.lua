--g_itemTips
local itemTips = {}
setmetatable(itemTips,{__index = _G})
setfenv(1,itemTips)

local tipsNodeName = "__tipsNodeName__"
local m_LayerType = {
	DROP = 0,
	EQUIPMENT = 1,
	EQUIPMENT_MASTER = 2,
	STRING = 3,
	GODGENERALSKILL = 4,--神武将技能
	GENERAL_SERVER = 5,--基于服务器数据的武将
}
local holdTime = 0.3

local createTouchLayer = function(began_callback)
	local layer = cc.LayerColor:create(cc.c4b(0,0,0,0))
	local listener = cc.EventListenerTouchOneByOne:create()
	local onTouchBegan = function(touch,event)
		if began_callback then
			began_callback()
		end
		return true
	end
	
	local onTouchEnded = function(touch,event)
	end
	
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,layer)
	
	return layer
end

--创建文字提示
local function createTextTipLayer(titleText,contentText)
		local uilayer = cc.CSLoader:createNode("ItemName_01.csb")
		--g_sceneManager.addNodeForUI(itemTipLayer)
		if not titleText or type(titleText) ~= "string" then
		  titleText = g_tr("itemTipsDefaultTitle")
		end
		
		if not contentText or type(contentText) ~= "string" then
		  contentText = g_tr("itemTipsDefaultContent")
		end

		uilayer:getChildByName("Text_1"):setString(titleText)
		uilayer:getChildByName("Text_2"):setVisible(false)
		local richText = g_gameTools.createRichText(uilayer:getChildByName("Text_2"),contentText)

		local addHeight = 0
		
		local richSize = richText:getRichSize()
		if richSize.height > uilayer:getChildByName("Text_2"):getContentSize().height then
		  local bgSize = uilayer:getChildByName("Image_1"):getContentSize()
		  addHeight = richSize.height - uilayer:getChildByName("Text_2"):getContentSize().height
		  uilayer:getChildByName("Image_1"):setContentSize(cc.size(bgSize.width,bgSize.height + addHeight))
		end
		local size = uilayer:getChildByName("Image_1"):getContentSize() 
		return uilayer,addHeight,size
end

--创建武将提示
local function createGeneralTipLayer(configId,asItem,serverData) --asItem:是否武将信物描述
	local addHeight = 0
	local uilayer = cc.CSLoader:createNode("ItemName_02.csb")
	local dataInfo = g_data.general[configId]
	
	if asItem == nil then
		asItem = false
	end
	
	assert(dataInfo)
	if dataInfo then
		--武将/信物名称
		local titleName = g_tr(dataInfo.general_name)
		if asItem then
		  local orginalName = g_tr_original(dataInfo.general_name)
		  titleName = g_tr("generalItemTitle",{name = orginalName})
		end
		uilayer:getChildByName("Panel_1"):getChildByName("Text_1"):setString(titleName)
		
		--星级重置（全部隐藏）
		do
			for i = 1, 5 do
				uilayer:getChildByName("Panel_1"):getChildByName("Image_"..i):setVisible(false)
				uilayer:getChildByName("Panel_1"):getChildByName("Image_"..i.."_0"):setVisible(false)
			end
		end
		
		if not asItem then
		  --显示星级
			if dataInfo.general_quality < 6 then
				--star
				uilayer:getChildByName("Panel_1"):getChildByName("Image_1"):setVisible(true)
			else
				local currentStarLv = 1
				if serverData then
					currentStarLv = math.floor(tonumber(serverData.star_lv)/5) + 1
				end
				for i=1, 4 do
					uilayer:getChildByName("Panel_1"):getChildByName("Image_"..i.."_0"):setVisible(true)
					uilayer:getChildByName("Panel_1"):getChildByName("Image_"..i):setVisible(currentStarLv >= i)
				end
			end
		end
		
		--武将属性标题
		uilayer:getChildByName("Panel_2"):getChildByName("Text_1"):setString(g_tr("generalPropTit"))
		
		--["attr1"] = "武",
		--["attr2"] = "智",
		--["attr3"] = "统",
		--["attr4"] = "魅",
		--["attr5"] = "政",
		
		local propVals = {}
		if serverData then
			propVals = g_GeneralMode.getGeneralPropertyByServerData(serverData)
		else
			local props = {"general_force","general_intelligence","general_governing","general_charm","general_political"}
			for key, var in ipairs(props) do
				table.insert(propVals,dataInfo[var])
			end
		end
		
		--武将属性
		do
			for i = 1, 5 do
				local label = uilayer:getChildByName("Panel_2"):getChildByName("Text_"..(i + 1))
				local contentText = g_tr("attr"..i).." +"..string.formatnumberthousands(propVals[i])
				label:setString(contentText)
				--g_gameTools.createRichText(label,contentText)
			end
		end
		
		local equipmentInfo = g_data.equipment[dataInfo.general_item_id*100]
		assert(equipmentInfo)
		--武将武器技能
		do
			local showLabels = {}
			do  --找出需要显示的武将特技文字
				for key, id in ipairs(equipmentInfo.equip_skill_id) do 
					local strNum = ""
					local skill = g_data.equip_skill[id]
					if skill then 
						local buff = g_data.buff[skill.skill_buff_id[1]]
						if buff then 
							strNum = ""..skill.num
							if buff.buff_type == 1 then --万分比
								strNum = (skill.num/10000)*100 .. "%%"
							end 
						end
						table.insert(showLabels,g_tr(skill.skill_description, {num = strNum}))
					end
				 end
			end
			
			if asItem then --添加武将信物描述
				table.insert(showLabels," ")
				
				local descStr = g_tr("generalItemDesc")
				if dataInfo.general_quality == g_GeneralMode.godQuality then
					descStr = g_tr("generalGoldItemDesc")
				end
				table.insert(showLabels,descStr)
			end
		
			local itemView = uilayer:getChildByName("Panel_3"):getChildByName("Text_1")
			local addCnt = 0
			local distance = 3
			local bgWidth = uilayer:getChildByName("Image_1"):getContentSize().width
	
			do --显示文字
				 for key, str in ipairs(showLabels) do 
					local label = nil
					if key == 1 then
						label = itemView
					else
						addCnt = addCnt + 1
						label = itemView:clone()
						itemView:getParent():addChild(label)
						label:setPositionY(itemView:getPositionY() - (itemView:getContentSize().height + distance) * addCnt)
					end
					label:setString(str)
					bgWidth = math.max(bgWidth + 5,label:getContentSize().width + 28)
				 end
			end
			
			local bgSize = uilayer:getChildByName("Image_1"):getContentSize()
			if addCnt > 0 then
				addHeight = (itemView:getContentSize().height + distance) * addCnt
			end
			uilayer:getChildByName("Image_1"):setContentSize(cc.size(bgWidth,bgSize.height + addHeight))

		end
		
		local size = uilayer:getChildByName("Image_1"):getContentSize() 
		return uilayer,addHeight,size
		
	end
end

--创建装备提示
local function createEquipmentTipLayer(configId)
	local addHeight = 0
	local uilayer = cc.CSLoader:createNode("ItemName_02.csb")
	local dataInfo = g_data.equipment[configId]
	assert(dataInfo)
	if dataInfo then
		--万能装备
		if dataInfo.equip_type == 0 then
			local itemName = g_tr("equipmentItemName")
			local itemDesc = g_tr("equipmentItemDesc")
			return createTextTipLayer(itemName,itemDesc)
		else
			--装备名称
			uilayer:getChildByName("Panel_1"):getChildByName("Text_1"):setString(g_tr(dataInfo.equip_name))
			local starLv = dataInfo.star_level
			--装备星级
			do
				for i = 1, 5 do
					uilayer:getChildByName("Panel_1"):getChildByName("Image_"..i):setVisible(starLv > 0 and i <= starLv)
				end
			end
			
			--装备类型
			uilayer:getChildByName("Panel_2"):getChildByName("Text_1"):setString(g_tr("equipmentType"..dataInfo.equip_type))
			
			--["attr1"] = "武",
			--["attr2"] = "智",
			--["attr3"] = "统",
			--["attr4"] = "魅",
			--["attr5"] = "政",
			local props = {"force","intelligence","governing","charm","political"}
			--装备属性
			 do
				for i = 1, 5 do
					local label = uilayer:getChildByName("Panel_2"):getChildByName("Text_"..(i + 1))
					local contentText = g_tr("attr"..i).." +"..string.formatnumberthousands(dataInfo[props[i]])
					label:setString(contentText)
					--g_gameTools.createRichText(label,contentText)
				end
			end
			
			
			--装备技能
			do
				local itemView = uilayer:getChildByName("Panel_3"):getChildByName("Text_1")
				local addCnt = 0
				local distance = 3
				local bgWidth = uilayer:getChildByName("Image_1"):getContentSize().width
				
				for key, id in ipairs(dataInfo.equip_skill_id) do 
					local strNum = ""
					local skill = g_data.equip_skill[id]
					if skill then 
						local buff = g_data.buff[skill.skill_buff_id[1]]
						if buff then 
							strNum = ""..skill.num
							if buff.buff_type == 1 then --万分比
								strNum = (skill.num/10000)*100 .. "%%"
							end 
						end
						
						local label = nil
						if key == 1 then
							label = itemView
						else
							addCnt = addCnt + 1
							label = itemView:clone()
							itemView:getParent():addChild(label)
							label:setPositionY(itemView:getPositionY() - (itemView:getContentSize().height + distance) * addCnt)
						end
						label:setString(g_tr(skill.skill_description, {num = strNum}))
 
						bgWidth = math.max(bgWidth + 5,label:getContentSize().width + 28)
						
						local bgSize = uilayer:getChildByName("Image_1"):getContentSize()
						if addCnt > 0 then
							addHeight = (itemView:getContentSize().height + distance) * addCnt
						end
						uilayer:getChildByName("Image_1"):setContentSize(cc.size(bgWidth,bgSize.height + addHeight))
					end
				 end
				 
				 --红色装备技能属性
				 local SmithyData = require("game.uilayer.smithy.SmithyData")
				 local desc = SmithyData:instance():getRedEquipNewSkillDesc(configId)
				 if desc and desc ~= "" then
				 		addCnt = addCnt + 1
						local label = itemView:clone()
						itemView:getParent():addChild(label)
						label:setPositionY(itemView:getPositionY() - (itemView:getContentSize().height + distance) * addCnt)
						label:setString(desc)
						bgWidth = math.max(bgWidth + 5,label:getContentSize().width + 28)
						local bgSize = uilayer:getChildByName("Image_1"):getContentSize()
						if addCnt > 0 then
							addHeight = (itemView:getContentSize().height + distance) * addCnt
						end
						uilayer:getChildByName("Image_1"):setContentSize(cc.size(bgWidth,bgSize.height + addHeight))
				 end
				 
			end
		end
	end
	local size = uilayer:getChildByName("Image_1"):getContentSize() 
	return uilayer,addHeight,size
end

--创建主公装备提示
--{"id":77,"player_id":500009,"equip_master_id":4002501,"status":0,"position":-1,"create_time":1480723717,"update_time":1480723717,"equip_skill":{"500033":"2254"}}
local function createMasterEquipmentTipLayerByServerData(serverData)
	assert(serverData)
	
	local configId = serverData.equip_master_id

	local uilayer = cc.CSLoader:createNode("ItemName_03.csb")
	local dataInfo = clone(g_data.equip_master[configId])
	dataInfo.serverSkills = serverData.equip_skill
	
	local addHeight = 0
	assert(dataInfo)
	if dataInfo then
		--装备名称
		uilayer:getChildByName("Panel_1"):getChildByName("Text_1"):setString(g_tr(dataInfo.equip_name))
		
		--装备星级(主公装备暂时没有星级)
		do
			for i = 1, 5 do
				uilayer:getChildByName("Panel_1"):getChildByName("Image_"..i):setVisible(false)
				uilayer:getChildByName("Panel_1"):getChildByName("Image_"..i.."_0"):setVisible(false)
			end
		end
		
		--装备类型
		uilayer:getChildByName("Panel_2"):getChildByName("Text_1"):setString(g_tr("equipmentTypeMaster"))

		--装备技能
		do
			local itemView = uilayer:getChildByName("Panel_3"):getChildByName("Text_1")
			local addCnt = 0
			local distance = 3
			local bgWidth = uilayer:getChildByName("Image_1"):getContentSize().width
			
			local idx = 0
			for skillId, value in pairs(dataInfo.serverSkills) do 
				idx = idx + 1
				local strNum = ""
				local skill = g_data.equip_skill[tonumber(skillId)]
				if skill then 
					local buff = g_data.buff[skill.skill_buff_id[1]]
					if buff then
						if tonumber(value) < 0 then
							 strNum = "?"
							 if buff.buff_type == 1 then --万分比
								strNum =  "?%%"
							 end 
						else
							strNum = ""..value
							if buff.buff_type == 1 then --万分比
								strNum = (tonumber(value)/10000)*100 .. "%%"
							end 
						end
					end
					
					local label = nil
					if idx == 1 then
						label = itemView
					else
						addCnt = addCnt + 1
						label = itemView:clone()
						itemView:getParent():addChild(label)
						label:setPositionY(itemView:getPositionY() - (itemView:getContentSize().height + distance) * addCnt)
					end
					label:setString(g_tr(skill.skill_description, {num = strNum}))
					bgWidth = math.max(bgWidth + 10,label:getContentSize().width + 28)
					
					local bgSize = uilayer:getChildByName("Image_1"):getContentSize()
					if addCnt > 0 then
						local addCnt = addCnt - 4
						if addCnt < 0 then
							addCnt = 0
						end
						addHeight = (itemView:getContentSize().height + distance) * addCnt
					end
					uilayer:getChildByName("Image_1"):setContentSize(cc.size(bgWidth,bgSize.height + addHeight))
				end
			 end
			 
		end
	 end
	 local size = uilayer:getChildByName("Image_1"):getContentSize() 
	 return uilayer,addHeight,size
end

--创建主公装备提示
local function createMasterEquipmentTipLayer(configId)

	local dataInfo = g_data.equip_master[configId]
	local addHeight = 0
	assert(dataInfo)
	local equip_skill = {}
	if dataInfo then
		--装备技能
		do
			for key, id in ipairs(dataInfo.equip_skill_id) do 
				local strNum = ""
				local skill = g_data.equip_skill[id]
				if skill then 
					equip_skill[id] = -1 
				end
			 end
		end
	 end
	 --{"id":77,"player_id":500009,"equip_master_id":4002501,"status":0,"position":-1,"create_time":1480723717,"update_time":1480723717,"equip_skill":{"500033":"2254"}}
	 local serverData = {} --模拟serverData
	 serverData.equip_master_id = configId
	 serverData.equip_skill = equip_skill
	 
	 return createMasterEquipmentTipLayerByServerData(serverData)
end


local function createGeneralSkillLayer(config)
	
	if config == nil then return end
	local server = g_GeneralMode.getOwnedGeneralByOriginalId(config.general_original_id)
	--getGeneralById(config.general_original_id)
	local dscTb = require("game.uilayer.godGeneral.GodGeneralMode"):instance():getLevelFormula( { cdata = config,ndata = server } )
	local addHeight = 0
	local uilayer = cc.CSLoader:createNode("ItemName_04.csb")
	local title = uilayer:getChildByName("Text_1")
	title:setString( dscTb.title .. (dscTb.level > 0 and "(Lv." .. tostring(dscTb.level) .. ")" or "")  )

	--title:setString(g_tr( "godGeneralTipsTitle" ))

	uilayer:getChildByName("Text_2_1"):setString(g_tr("godGeneralCZBuffStr"))
	local dsc1 = uilayer:getChildByName("Text_2")
	if dscTb.level > 0 then
		dsc1:setString( dscTb.rdsc1)
		g_gameTools.createRichText(dsc1,dscTb.rdsc1_org)
	else
		dsc1:setString( dscTb.odesc)
	end
	
	uilayer:getChildByName("Text_2_1_0"):setString(g_tr("godGeneralWDBuffStr"))
	local dsc2 = uilayer:getChildByName("Text_2_0")

	if dscTb.level > 0 then
		dsc2:setString( dscTb.rddsc1 )
		g_gameTools.createRichText(dsc2,dscTb.rddsc1_org)
	else
		dsc2:setString( dscTb.odesc1)
	end

	local size = uilayer:getChildByName("Image_1"):getContentSize() 
	return uilayer,addHeight,size
end


--创建掉落物品提示
local function createTipLayer(mtype,configId)
	local uilayer = nil
	local addHeight = 0
	local size = nil
	if mtype == g_Consts.DropType.MasterEquipment then
		uilayer,addHeight,size = createMasterEquipmentTipLayer(configId)
	elseif mtype == g_Consts.DropType.Equipment then
		uilayer,addHeight,size = createEquipmentTipLayer(configId)
	elseif mtype == g_Consts.DropType.General then
		uilayer,addHeight,size = createGeneralTipLayer(configId)
	else
		if mtype == g_Consts.DropType.Soldier 
		or mtype == g_Consts.DropType.Trap
		then
			local item = require("game.uilayer.common.DropItemView"):create(mtype,configId,0)
			uilayer,addHeight,size = createTextTipLayer(item:getName(),item:getDesc())
		else
			local itemInfo = g_data.item[configId]
			local item 
			if itemInfo and itemInfo.item_type == 4 then--武将信物
				local generalInfo = g_PlayerPubMode.getGeneralInfoByPieceItemId(configId)
				uilayer,addHeight,size = createGeneralTipLayer(generalInfo.id,true)
			elseif itemInfo and itemInfo.item_type == 5 then--武将将魂
				local generalOrginalId = g_PlayerPubMode.getGodGeneralOriginalIdBySoulItemId(configId)
				local generalServerData = g_GeneralMode.getOwnedGeneralByOriginalId(generalOrginalId)
				item = require("game.uilayer.common.DropItemView"):create(mtype,configId,0)
				local titleStr = item:getName()
				local descStr = item:getDesc()
				
				if generalServerData then
					local currentStarLv = math.floor(tonumber(generalServerData.star_lv)/5) + 1
					descStr = descStr.."|<#\n#>| |<#\n#>|"..g_tr("generalSouleTipGeneralStar",{num = currentStarLv})
					
					local mat_s, mat_b = require("game.uilayer.godGeneral.GodGeneralMode"):instance():getStarUpConsume(generalServerData)
					if mat_b then
						local needCnt = mat_b[3]
						local haveCnt = g_BagMode.findItemNumberById(configId)
						--local cnt = math.max(0,needCnt - haveCnt)
						descStr = descStr.."|<#\n#>|"..g_tr("generalSouleTipGeneralStarNext",{num = needCnt,num1 = haveCnt})
					else --最大星级
						descStr = descStr.."|<#\n#>|"..g_tr("generalSouleTipFull")
					end
				else
					descStr = descStr.."|<#\n#>|"..g_tr("generalSouleTipEmpty")
				end
				
				uilayer,addHeight,size = createTextTipLayer(titleStr,descStr)
			else
				item = require("game.uilayer.common.DropItemView"):create(mtype,configId,0)
				uilayer,addHeight,size = createTextTipLayer(item:getName(),item:getDesc())
			end
		end
	end
	return uilayer,addHeight,size
end

local function createTip(node,layerType,...)
	--node,titleText,contentText
--	if node:getChildByName(tipsNodeName) then
--		return
--	end
	
	clearTip(node)
	
	local params = {...}
	--dump(params)
	
	local tipsNode = ccui.Widget:create()
	tipsNode:setTouchEnabled(true)
	tipsNode:setName(tipsNodeName)
	node:addChild(tipsNode)
	local size = node:getContentSize()
	tipsNode:setContentSize(size)
	tipsNode:setPosition(cc.p(size.width/2,size.height/2))

	local itemTipLayer = nil
	local remmoveItemHandler = function()
		 if itemTipLayer then
			itemTipLayer:removeFromParent()
			itemTipLayer = nil
		end
	end
	
	local showItemHandler = function()
		remmoveItemHandler()
		
		itemTipLayer = createTouchLayer(remmoveItemHandler)
		g_sceneManager.addNodeForUI(itemTipLayer)
		
		local uilayer = nil
		local addHeight = 0
		local finalSize = cc.size(100,180)
		if layerType == m_LayerType.STRING then
			uilayer,addHeight,finalSize = createTextTipLayer(params[1],params[2])
		elseif layerType == m_LayerType.DROP then
			uilayer,addHeight,finalSize = createTipLayer(params[1],params[2])
		elseif layerType == m_LayerType.EQUIPMENT_MASTER then
			uilayer,addHeight,finalSize = createMasterEquipmentTipLayerByServerData(params[1])
		elseif layerType == m_LayerType.GODGENERALSKILL then
			uilayer,addHeight,finalSize = createGeneralSkillLayer(params[1])
		elseif layerType == m_LayerType.GENERAL_SERVER then
			local serverData = params[1]
			local config = g_GeneralMode.getGeneralByOriginalId(serverData.general_id)
			local configId = config.id
			uilayer,addHeight,finalSize = createGeneralTipLayer(configId,false,serverData)
		end
		
		itemTipLayer:addChild(uilayer)
		local worldPos = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
		local size = cc.size(size.width * g_display.scale, size.height * g_display.scale)
		if worldPos.x <= g_display.cx then
			uilayer:setAnchorPoint(cc.p(0,0.5))
			uilayer:setPositionX(worldPos.x + size.width/2 + 15* g_display.scale)
		else
			uilayer:setAnchorPoint(cc.p(1,0.5))
			uilayer:setPositionX(worldPos.x - size.width/2 - 15* g_display.scale)
		end
		local posY = worldPos.y + addHeight*g_display.scale/2
		
		if posY > g_display.size.height - finalSize.height*g_display.scale/2 - 10*g_display.scale then
		  posY = g_display.size.height - finalSize.height*g_display.scale/2 - 10*g_display.scale
		elseif posY < finalSize.height*g_display.scale/2 + addHeight*g_display.scale/2 + 10*g_display.scale then
		  posY = finalSize.height*g_display.scale/2 + addHeight*g_display.scale/2 + 10*g_display.scale
		end
		uilayer:setPositionY(posY)
		uilayer:setScale(g_display.scale)
	end

	local clickHandler = function(sender)
		showItemHandler()
	end
	tipsNode:addClickEventListener(clickHandler)
	 
	local function nodeEventHandler(eventType)
		if eventType == "enter" then
		elseif eventType == "exit" then
			--remmoveItemHandler()
		end
	end
	tipsNode:registerScriptHandler(nodeEventHandler)
end

--clear tip
function clearTip(node)
	if node:getChildByName(tipsNodeName) then
		node:removeChildByName(tipsNodeName)
	end
end

--node :需要点击长按的节点
--type :道具类型 g_Consts.DropType.Resource/Props/General/Equipment
--configId :道具的配置id
function tip(node,type,configId)
	assert(node and type and configId ,"3 params expect")
	createTip(node,m_LayerType.DROP,type,configId)
end

--node :需要点击长按的节点
--titleText :描述标题
--contentText :描述文字
function tipStr(node,titleText,contentText)
	createTip(node,m_LayerType.STRING,titleText,contentText)
end

--node :需要点击长按的节点
--serverData :主公装备的服务器数据，格式如下
--{"id":77,"player_id":500009,"equip_master_id":4002501,"status":0,"position":-1,"create_time":1480723717,"update_time":1480723717,"equip_skill":{"500033":"2254"}}
function tipMasterEquipmentByServerData(node,serverData)
	createTip(node,m_LayerType.EQUIPMENT_MASTER,serverData)
end

function tipGodGeneralData(node,config)
	createTip(node,m_LayerType.GODGENERALSKILL,config)
end


--node :需要点击长按的节点
--serverData :武将服务器数据
function tipGeneralByServerData(node,serverData)
	createTip(node,m_LayerType.GENERAL_SERVER,serverData)
end

--node :需要点击长按的节点
--serverData :武将服务器数据
--idx:第几个城战技能(1-3)
function tipGeneralBattleSkill(node,serverData,idx)
	assert(idx > 0 and idx <= 3)

	local currentGeneral = {}
	currentGeneral.cdata = g_GeneralMode.getGeneralByOriginalId(serverData.general_id)
	currentGeneral.ndata = serverData
	local showData = require("game.uilayer.godGeneral.GodGeneralMode"):instance():getBattleSkillFormula(currentGeneral,idx)
	tipStr(node,showData.title,showData.skill_desc_org)
end

return itemTips