local FightPreview = class("FightPreview",function()
	return cc.Layer:create()
end)

function FightPreview:ctor(selfPlaystates,targetPlaystates,pkId,playbackData)
	
	self._playbackData = playbackData
	
	local listener = cc.EventListenerTouchOneByOne:create()
	local onTouchBegan = function(touch,event)
		return true
	end
	
	local onTouchEnded = function(touch,event)
		 
	end
	
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
	
	local endAnima = function(startAnim)
		local onMovementEventCallFunc = function(armature , eventType , name)
			 print("armature , eventType , name:",armature , eventType , name)
			 if 0 == eventType then --start
				startAnim:getBone("Layer13"):getDisplayRenderNode():setVisible(false)
			 elseif 1 == eventType then --end
				self:removeFromParent()
			 end
		end
		
		local projName = "Effect_LeiTaiGuoChang_JieWei"
		local animPath = "anime/"..projName.."/"..projName..".ExportJson"
		
		local onFrameCallFunc = function(bone , frameEventName , originFrameIndex , currentFrameIndex)
			print("bone , frameEventName , originFrameIndex , currentFrameIndex:",bone , frameEventName , originFrameIndex , currentFrameIndex)
			if startAnim then
				startAnim:removeFromParent()
--				g_autoCallback.addCocosList(function () 
--					ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath) 
--				end , 0.01 )
			end
		end
		 
		local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,onMovementEventCallFunc,onFrameCallFunc)
		self:addChild(armature)
		armature:setScale(g_display.scale)
		armature:setPositionX(g_display.cx)
		armature:setPositionY(g_display.cy)
		animation:play("JieWei")
	end
	
	local function getEquipAttrs(generalServerData)
		local weaponId = generalServerData.weapon_id
		local armorId = generalServerData.armor_id
		local horseId = generalServerData.horse_id
		local zuojiId = generalServerData.zuoji_id
		
		local equipmentIds = {weaponId,armorId,horseId,zuojiId}
		local equipAttrs = {0,0,0,0,0} --武，智，统，魅，政
		for key, equipmentId in ipairs(equipmentIds) do
			local equipmentInfo = g_data.equipment[equipmentId]
			if equipmentInfo then
				equipAttrs[1] = equipAttrs[1] + equipmentInfo.force
				equipAttrs[2] = equipAttrs[2] + equipmentInfo.intelligence
				equipAttrs[3] = equipAttrs[3] + equipmentInfo.governing
				equipAttrs[4] = equipAttrs[4] + equipmentInfo.charm
				equipAttrs[5] = equipAttrs[5] + equipmentInfo.political
			end
		end
		return equipAttrs
	end
	
	local function getCfgByGeneralData(generalServerData,buffs)
		
		if generalServerData == nil then
			return nil
		end
		
		if buffs == nil then
			buffs = {}
		end
		
		--武，智，统，魅，政
		--顺序不可以换
		local buffsKey = {
			"general_force_inc",
			"general_intelligence_inc",
			"general_governing_inc",
			"general_charm_inc",
			"general_political_inc",
		}
		
		local equipAttrs = getEquipAttrs(generalServerData)
		local propertyList = g_GeneralMode.getGeneralPropertyByServerData(generalServerData,false)
		local finalPropertyList = {0,0,0,0,0}
		for i=1, 5 do
			 local buffKey = buffsKey[i]
			 local buffConfig = g_BuffMode.getBuffConfigByKeyName(buffKey)
			 local buffValue = buffs[buffKey] or 0
			 local buffType = buffConfig.buff_type
			 local orginalValue = propertyList[i]
			 local finalValue = orginalValue
			 if buffType == 1 then --万分比
				finalValue = math.ceil(orginalValue * (10000 + buffValue)/10000)
			 elseif buffType == 2 then --固定值
				finalValue = orginalValue + buffValue
			 end
			 finalValue = finalValue + equipAttrs[i]
			 finalPropertyList[i] = finalValue
		end
		

		local general = g_GeneralMode.getGeneralByOriginalId(generalServerData.general_id)
		local cfg = {}
		cfg.hero_lv = generalServerData.lv
		--cfg.skill_lv = generalServerData.skill_lv
		cfg.skill_lv = g_GeneralMode.getGenSkillLv(generalServerData) 
		cfg.hero_configId = general.id
		cfg.general_id = generalServerData.general_id --原型Id，战斗结算需要发送
		cfg.hero_wu = finalPropertyList[1]
		cfg.hero_zhi = finalPropertyList[2]
		cfg.hero_tong = finalPropertyList[3]
		cfg.hero_mei = finalPropertyList[4]
		cfg.hero_zheng = finalPropertyList[5]
		return cfg
	end
	
	
	local onMovementEventCallFunc = function(armature , eventType , name)
		 if 0 == eventType then --start
		 elseif 1 == eventType then --end
			if self._playbackData ~= nil then --进入回放
				local backPlayInfo = self._playbackData
				require("game.uilayer.tournament.tournament_backplay").show(backPlayInfo)
			else --进入战斗
				local pkInfo = {
				 ["pk_id"] = pkId,
				 ["A"] = {
					["player_name"] = "S"..selfPlaystates.server_id.." "..selfPlaystates.nick,
					["player_id"] = selfPlaystates.player_id,
					["duel_rank_id"] = selfPlaystates.duel_rank_id,
					["1"] = getCfgByGeneralData(selfPlaystates.general_1,selfPlaystates.buff),
					["2"] = getCfgByGeneralData(selfPlaystates.general_2,selfPlaystates.buff),
					["3"] = getCfgByGeneralData(selfPlaystates.general_3,selfPlaystates.buff),
				 },
				 ["B"] = {
					["player_name"] = "S"..targetPlaystates.server_id.." "..targetPlaystates.nick,
					["player_id"] = targetPlaystates.player_id,
					["duel_rank_id"] = targetPlaystates.duel_rank_id,
					["1"] = getCfgByGeneralData(targetPlaystates.general_1,targetPlaystates.buff),
					["2"] = getCfgByGeneralData(targetPlaystates.general_2,targetPlaystates.buff),
					["3"] = getCfgByGeneralData(targetPlaystates.general_3,targetPlaystates.buff),
				 },
				 ["selfGroup"] = "A",
				}
				
				--进入武斗战斗
				require("game.uilayer.tournament.tournament").show(pkInfo)
				
				--for test
--				local resultInfo = {
--				--0: 平 1：A胜 2：B胜
--				["result"] = {
--					["1"] = 0,
--					["2"] = 1,
--					["3"] = 1,
--					["backplay"] = ""
--				},
--				["info"] = pkInfo
--				}
--				require("game.uilayer.fightperipheral.FightResult").show(resultInfo)
				--for test end
				
			end
			endAnima(armature)
		
		 end
	end
	 
	local onFrameCallFunc = function()
		print("start frame")
	end
		
	local projName = "Effect_LeiTaiGuoChang_KaiChang"
	local animPath = "anime/"..projName.."/"..projName..".ExportJson"
	local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,onMovementEventCallFunc,onFrameCallFunc)
	self:addChild(armature)
	armature:setScale(g_display.scale)
	armature:setPositionX(g_display.cx)
	armature:setPositionY(g_display.cy)
	
	local playerInfoCon = cc.Node:create()
	local uiLayer = cc.CSLoader:createNode("Arena_panel5.csb")
	local size = uiLayer:getChildByName("scale_node"):getContentSize()
	playerInfoCon:addChild(uiLayer)
	uiLayer:setPosition(cc.p(-size.width/2,-size.height/2))
	
	--target
	uiLayer:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Text_mz1"):setString("S"..targetPlaystates.server_id.." "..targetPlaystates.nick)
	uiLayer:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Text_jif1"):setString(g_tr("peripheral_score_title"))
	uiLayer:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Text_jif2"):setString(targetPlaystates.score.."")
	
	local rankConfig = g_data.duel_rank[targetPlaystates.duel_rank_id]
	if rankConfig then
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Image_21"):loadTexture(g_resManager.getResPath(rankConfig.rank_pic))
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Image_21_0"):loadTexture(g_resManager.getResPath(rankConfig.rank_number))
	end
	
	--self
	uiLayer:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Text_mz1"):setString("S"..selfPlaystates.server_id.." "..selfPlaystates.nick)
	uiLayer:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Text_jif1"):setString(g_tr("peripheral_score_title"))
	uiLayer:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Text_jif2"):setString(selfPlaystates.score.."")
	
	local rankConfig = g_data.duel_rank[selfPlaystates.duel_rank_id]
	if rankConfig then
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Image_21"):loadTexture(g_resManager.getResPath(rankConfig.rank_pic))
		uiLayer:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Image_21_0"):loadTexture(g_resManager.getResPath(rankConfig.rank_number))
	end

	armature:getBone("DuiZhenTiao01"):addDisplay(playerInfoCon,0)

	--left
	armature:getBone("Layer7"):addDisplay(self:createPortrait(false,g_GeneralMode.getGeneralByOriginalId(selfPlaystates.general_3.general_id).id,3),0)
	armature:getBone("Layer6"):addDisplay(self:createPortrait(false,g_GeneralMode.getGeneralByOriginalId(selfPlaystates.general_2.general_id).id,2),0)
	armature:getBone("Layer5"):addDisplay(self:createPortrait(false,g_GeneralMode.getGeneralByOriginalId(selfPlaystates.general_1.general_id).id,1),0)
	
	--right
	armature:getBone("Layer8"):addDisplay(self:createPortrait(true,g_GeneralMode.getGeneralByOriginalId(targetPlaystates.general_1.general_id).id,1),0)
	armature:getBone("Layer9"):addDisplay(self:createPortrait(true,g_GeneralMode.getGeneralByOriginalId(targetPlaystates.general_2.general_id).id,2),0)
	armature:getBone("Layer10"):addDisplay(self:createPortrait(true,g_GeneralMode.getGeneralByOriginalId(targetPlaystates.general_3.general_id).id,3),0)
	
	animation:play("KaiChang")
end

function FightPreview:createPortrait(isBlue,generalId,position)

	local gId = generalId
	
	local node = cc.Node:create()
	local scaleX = 1.0
	local bgPath = "freeImage/wudouzhunbeibj2.png"
	local stencil = cc.Sprite:create("freeImage/wudouzhunbeibj.png")
	local alphaBoaderPath = "freeImage/wudouzhunbeibj3.png"
	local uiPath = "Arena_panel3.csb"
	if isBlue == true then
		bgPath = "freeImage/wudouzhunbeibj4.png"
		alphaBoaderPath = "freeImage/wudouzhunbeibj5.png"
		uiPath = "Arena_panel4.csb"
		scaleX = -1.0
	end
	
	stencil:setScaleX(scaleX)
	
	local bg = cc.Sprite:create(bgPath)
	node:addChild(bg)
	local clipper = cc.ClippingNode:create()
	clipper:setStencil(stencil)
	clipper:setInverted(true)
	clipper:setAlphaThreshold(0)
	local general = g_data.general[gId]
	local icon = cc.Sprite:create(g_resManager.getResPath(general.general_big_icon))
	if general.portrait_xy and #general.portrait_xy >= 2 then
			if isBlue then
				icon:setPosition(cc.p(-general.portrait_xy[1],general.portrait_xy[2]))
			else
				icon:setPosition(cc.p(general.portrait_xy[1],general.portrait_xy[2]))
			end
		
	end
	icon:setScaleX(scaleX)
	clipper:addChild(icon)
	
	local boader = cc.Sprite:create(alphaBoaderPath)
	clipper:addChild(boader)
	node:addChild(clipper)
	
	local uiLayer = cc.CSLoader:createNode(uiPath)
	node:addChild(uiLayer)
	local size = uiLayer:getContentSize()
	uiLayer:setPosition(cc.p(-size.width/2,-size.height/2))
	uiLayer:getChildByName("scale_node"):getChildByName("Text_mz1"):setString(g_tr(general.general_name))
	
	for i=1, 3 do
		uiLayer:getChildByName("scale_node"):getChildByName("Image_n1_"..(i -1)):setVisible(false)
	end
	uiLayer:getChildByName("scale_node"):getChildByName("Image_n1_"..(position -1)):setVisible(true)
	return node
end


return FightPreview