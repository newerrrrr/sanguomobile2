local worldMapLayer_buildTitle = {}
setmetatable(worldMapLayer_buildTitle,{__index = _G})
setfenv(1,worldMapLayer_buildTitle)

local HelperMD = require "game.mapcitybattle.worldMapLayer_helper"
local QueueHelperMD = require "game.mapcitybattle.worldMapLayer_queueHelper"


--是否有自己联盟成员(包括自己)正在这个建筑里做queueType类型的事情
local function _isHaveSelfGuildAndSelfQueueDoing(buildServerData,queueType)
	if g_cityBattlePlayerData.getCampId() ~= 0 then
		local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
		local currentQueueDatas = bigMap.getCurrentQueueDatas()
		for k , v in pairs(currentQueueDatas.Queue) do
			assert(v.to_map_id ~= 0, "error : to_map_id == 0 ")
			if buildServerData.id == v.to_map_id then
				if v.camp_id == g_cityBattlePlayerData.getCampId() and v.type == queueType then
					return true
				end
			end
		end
	end
	return false
end


local function _create_playHome(serverData, configData, originBigTileIndex,showDurability)
	local widget = cc.CSLoader:createNode("worldmap_Upgrade.csb")
	local guildIcon = widget:getChildByName("Image_2")
	
	if showDurability == nil then
			showDurability = false
	end
	
	local loadingBar = widget:getChildByName("LoadingBar_1")
	loadingBar:setVisible(false)
	
	if showDurability == true then
		
		loadingBar:setVisible(true)
		loadingBar:setPercent(0)
		local currentAreaDatas = require "game.mapcitybattle.worldMapLayer_bigMap".getCurrentAreaDatas()
		local playerData = currentAreaDatas.Player[tostring(serverData.player_id)]
		if playerData then
			local percent = playerData.wall_durability/playerData.wall_durability_max*100
			loadingBar:setPercent(percent)
		end
		
		
	end
	
	local loadingBarBg = widget:getChildByName("Image_3")
	loadingBarBg:setVisible(loadingBar:isVisible())
	
	local textNode = cc.Node:create()
	textNode:setContentSize(widget:getContentSize())
	
	local textLabel = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
	textLabel:setAnchorPoint(cc.p(0.5, 0.5))
	textLabel:setPosition(cc.p(173.0, 31.0))
	textNode:addChild(textLabel)
	
	guildIcon:setVisible(false)
	
	local bigMap = require "game.mapcitybattle.worldMapLayer_bigMap"
	
	local str = ""
	local color = cc.c4b(255,255,255,255)
	
	if serverData.camp_id ~= 0 then
		
		color = g_cityBattlePlayerData.getCampId() == serverData.camp_id and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)
		--dump(bigMap.getCurrentAreaDatas())
--		local guildData = bigMap.getCurrentAreaDatas().Camp[tostring(serverData.camp_id)]
--		if guildData then
--			if guildData.short_name and guildData.short_name ~= "" then
--				str = str.."("..guildData.short_name..")"
--			end
--			guildIcon:setVisible(true)
--			local iconId = g_data.country_camp_list[tonumber(serverData.camp_id)].camp_pic
--			guildIcon:loadTexture(g_resManager.getResPath(iconId))
--		end
		
		guildIcon:setVisible(true)
		local campInfoCfg = g_data.country_camp_list[tonumber(serverData.camp_id)]
		local iconId = campInfoCfg.camp_pic
		guildIcon:loadTexture(g_resManager.getResPath(iconId))
		
		--str = str.."("..g_tr(campInfoCfg.camp_name)..")"
		
	end
	
	local playerData = bigMap.getCurrentAreaDatas().Player[tostring(serverData.player_id)]
	if playerData then
		str = require("game.mapcitybattle.worldMapLayer_uiLayer").getServerPreName(serverData.player_id)
		if tonumber(g_cityBattlePlayerData.GetData().player_id) == tonumber(serverData.player_id) then
			color = cc.c4b(255,255,0,255)
			str = str..g_tr("worldmap_SelfHome")
		else
			str = str..playerData.nick
		end
		
		
		if playerData.rank_title and tonumber(playerData.rank_title) > 0 then
			--御林军等称号
			local playerTitle = widget:getChildByName("Image_5")
			
			local resPath = nil
			if tonumber(playerData.rank_title) == 2 then
				resPath = g_resManager.getResPath(1083001)
			else
				resPath = g_resManager.getResPath(1083002)
			end
			if resPath then
				playerTitle:loadTexture(resPath)
			end
		end
		
	end
	
	textLabel:setTextColor(color)
	textLabel:setString(str)
	
	return widget , textNode
end


local function _create_guild(serverData, configData, originBigTileIndex)
	local widget = cc.CSLoader:createNode("worldmap_Upgrade.csb")
	local guildIcon = widget:getChildByName("Image_2")
	
	local loadingBar = widget:getChildByName("LoadingBar_1")
	loadingBar:setVisible(false)
	
	local loadingBarBg = widget:getChildByName("Image_3")
	loadingBarBg:setVisible(loadingBar:isVisible())
	
	local textNode = cc.Node:create()
	textNode:setContentSize(widget:getContentSize())
	
	local textLabel = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
	textLabel:setAnchorPoint(cc.p(0.5, 0.5))
	textLabel:setPosition(cc.p(173.0, 31.0))
	textNode:addChild(textLabel)
	
	guildIcon:setVisible(false)
	
	local bigMap = require "game.mapcitybattle.worldMapLayer_bigMap"
	
	local str = ""
	local color = cc.c4b(255,255,255,255)
	
	if serverData.camp_id ~= 0 then
		
		color = g_cityBattlePlayerData.getCampId() == serverData.camp_id and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)
		
--		local guildData = bigMap.getCurrentAreaDatas().Camp[tostring(serverData.camp_id)]
--		if guildData then
--			if guildData.short_name and guildData.short_name ~= "" then
--				str = str.."("..guildData.short_name..")"
--			end
--			guildIcon:setVisible(true)
--			local iconId = g_data.country_camp_list[tonumber(serverData.camp_id)].camp_pic
--			guildIcon:loadTexture(g_resManager.getResPath(iconId))
--			--guildIcon:loadTexture(g_data.sprite[g_data.alliance_flag[guildData.icon_id].res_flag].path)
--		end	

		guildIcon:setVisible(true)
		local campInfoCfg = g_data.country_camp_list[tonumber(serverData.camp_id)]
		local iconId = campInfoCfg.camp_pic
		guildIcon:loadTexture(g_resManager.getResPath(iconId))
		
		--str = str.."("..g_tr(campInfoCfg.camp_name)..")"
		
		
	end
	
	str = str..g_tr(configData.name)
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort then
		--联盟堡垒才有驻防
		if serverData.camp_id ~= 0 and g_cityBattlePlayerData.getCampId() == serverData.camp_id then
			--自己公会才看驻防信息
			if _isHaveSelfGuildAndSelfQueueDoing(serverData, QueueHelperMD.QueueTypes.TYPE_GUILDBASE_DEFEND) then
				str = str.."("..g_tr("worldmap_houses_have")..")"
			else	
				str = str.."("..g_tr("worldmap_houses_nothave")..")"
			end
		end
	end
	
	textLabel:setTextColor(color)
	textLabel:setString(str)
	
	return widget , textNode
end


local function _create_monster(serverData, configData, originBigTileIndex)
	local widget = cc.CSLoader:createNode("monster_Grade1.csb")
	widget:getChildByName("Image_2"):loadTexture(g_data.sprite[configData.image_lv_back].path, ccui.TextureResType.plistType)
	
	local textNode_1 = cc.Node:create()
	textNode_1:setContentSize(widget:getContentSize())
	
	local nameText = cc.Label:createWithTTF(g_tr(configData.name), "cocostudio_res/simhei.ttf", 21, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
	nameText:setAnchorPoint(cc.p(0.5, 0.5))
	nameText:setPosition(cc.p(119.0, 30.0))
	textNode_1:addChild(nameText)
	
	local textNode_2 = cc.Node:create()
	textNode_2:setContentSize(widget:getContentSize())
	
	local lvText = cc.Label:createWithCharMap("worldmap/notPlist/lv_number.png", 10, 18, 48)
	lvText:setString(tostring(configData.level))
	lvText:setAnchorPoint(cc.p(0.5, 0.5))
	lvText:setPosition(cc.p(25.0, 31.0))
	lvText:setScale(1.2)
	textNode_2:addChild(lvText)
	
	return widget , textNode_1 , textNode_2
end


local function _create_camp(serverData, configData, originBigTileIndex,showDurability)
	local widget = cc.CSLoader:createNode("worldmap_Upgrade.csb")
	local guildIcon = widget:getChildByName("Image_2")
	
	if showDurability == nil then
			showDurability = false
	end
	
	local loadingBarHp = widget:getChildByName("LoadingBar_1")
	loadingBarHp:setVisible(false)
	
	if showDurability == true then
		loadingBarHp:setVisible(true)
		local percent = serverData.durability/serverData.max_durability*100
		loadingBarHp:setPercent(percent)
	end
	
	local loadingBarBg = widget:getChildByName("Image_3")
	loadingBarBg:setVisible(loadingBarHp:isVisible())
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_yunti 
	then
		local isAttacker = g_cityBattleInfoData.IsAttacker()
		widget:getChildByName("Panel_player_num"):setVisible(isAttacker) --驻守人数
		if isAttacker then
			local playerNumStr = serverData.player_num.."/10"
			local txtCon = widget:getChildByName("Panel_player_num"):getChildByName("Panel_1")
			local textLabel = cc.Label:createWithTTF(playerNumStr, "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
			textLabel:setAnchorPoint(cc.p(0.5, 0.5))
			txtCon:addChild(textLabel)
		end
	
		widget:getChildByName("Panel_6"):setVisible(isAttacker)
		
		local cdTime = tonumber(g_data.country_basic_setting[45].data)
		local nextRecoveTime = serverData.recover_time 

		local bg =  cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_yt_bottom.png") --占领背景
		local bg1 =  cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_xiufu_bottom.png") --修复背景
		bg:setVisible(false)
		bg1:setVisible(false)

		local textProgressNode = cc.Node:create()
		--textProgressNode:setContentSize(widget:getContentSize())
		
		local textProgressLabel = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
		textProgressLabel:setAnchorPoint(cc.p(0.5, 0.5))
		textProgressLabel:setPosition(cc.p(0.0, 40.5))
		textProgressNode:addChild(textProgressLabel)
		
 		local node = cc.Node:create()
 		node:addChild(bg)
 		node:addChild(bg1)
 		
 		--for test
-- 		bg:setCascadeOpacityEnabled(true)
--		bg:setOpacity(100)
 		
 		local imgPath = "worldmap_image_guildwar_yt_mid.png"  --云梯占领进度
 		local cd = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(imgPath))
    cd:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    node:addChild(cd)
   	function cd:setPercent(percent)
			self:setPercentage(checkint(percent))
		end
		cd:setPercent(0)
		cd:setVisible(false)
    
    imgPath = "worldmap_image_guildwar_xiufu_mid.png" --云梯修复进度
    local cd1 = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(imgPath))
    cd1:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    node:addChild(cd1)
    function cd1:setPercent(percent)
			self:setPercentage(checkint(percent))
		end
		cd1:setPercent(0)
		cd1:setVisible(false)
    
    widget:getChildByName("Panel_6"):addChild(node)
    
		local iconGetedLight = cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_yt_top.png") --云梯占领亮
		local iconRepairLight = cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_xiufu_top.png") --云梯修复亮
    iconRepairLight:setVisible(false)
    iconGetedLight:setVisible(false)
    node:addChild(iconRepairLight)
    node:addChild(iconGetedLight)
    node:addChild(textProgressNode)
		
		
		widget:getChildByName("Panel_6"):getChildByName("LoadingBar_2"):setVisible(false)
		widget:getChildByName("Panel_6"):getChildByName("Image_4"):setVisible(false)
		
		local loadingBar = nil

   	local maxValue = tonumber(g_data.country_basic_setting[42].data)
   	if serverData.resource >= maxValue then
   		cd:setVisible(true) 
   		loadingBar = cd
   		loadingBar:setPercent(100)
   		--TODO:显示云梯占领图标亮
   		iconGetedLight:setVisible(true)
   		textProgressLabel:setString(g_tr("guild_war_geted_yunti"))
   		
   		loadingBarHp:setVisible(false)
   		local loadingBarBg = widget:getChildByName("Image_3")
			loadingBarBg:setVisible(loadingBarHp:isVisible())
   	else
   		
   		cd:setVisible(true)
   		bg:setVisible(true)
   		loadingBar = cd
   		local per = serverData.resource/maxValue*100
   		loadingBar:setPercent(per)
   		textProgressLabel:setString(per.."%")
   		
   		
   		local showNormalStatus = function()
   			widget:getChildByName("Panel_6"):setVisible(g_cityBattleInfoData.IsAttacker())
   			cd:setVisible(true)
   			cd1:setVisible(false)
   			bg:setVisible(true)
   			bg1:setVisible(false)
   			loadingBar = cd
   			local per = serverData.resource/maxValue*100
   			loadingBar:setPercent(per)
   			textProgressLabel:setString(per.."%")
   		
   			if serverData.durability <= 0 then
					loadingBarHp:setPercent(100)
				end
			
				local finishTime = require ("game.mapcitybattle.worldMapLayer_queueHelper").getYunTiProgressTime(tonumber(serverData.x), tonumber(serverData.y), serverData.map_element_origin_id)
				if finishTime then
				  local needTime = tonumber(finishTime) - serverData.build_time
					if needTime <= 0 or serverData.resource >= maxValue then
						loadingBar:setPercent(100)
						--TODO:显示云梯占领图标亮
						iconGetedLight:setVisible(true)
						textProgressLabel:setString(g_tr("guild_war_geted_yunti"))
						loadingBarHp:setVisible(false)
			   		local loadingBarBg = widget:getChildByName("Image_3")
						loadingBarBg:setVisible(loadingBarHp:isVisible())
					else
						local secondStep = (maxValue - serverData.resource )/needTime
					
						local currentResource = serverData.resource + (g_clock.getCurServerTime() - serverData.build_time)*secondStep
						
						local updateShow = function()
						  currentResource = currentResource + secondStep
						  print("currentResource:",currentResource)
						  if currentResource >= maxValue then
							  currentResource = maxValue
							  widget:getChildByName("Panel_6"):stopAllActions()
							  --TODO:显示云梯占领图标亮
							  textProgressLabel:setString(g_tr("guild_war_geted_yunti"))
							  iconGetedLight:setVisible(true)
						  end
						  
						  local percent = math.floor(currentResource)/maxValue*100
						  loadingBar:setPercent(percent)
						  
						  if nextRecoveTime > g_clock.getCurServerTime() then --如果正在
						  	local timeLeft =  serverData.recover_time - g_clock.getCurServerTime()
						  	if timeLeft < 0 then
						  		timeLeft = 0
						  		textProgressLabel:setString("")
						  	else
						  		textProgressLabel:setString( timeLeft..g_tr("second"))
						  	end
	 						else
	 							textProgressLabel:setString(percent.."%")
				   		end
						end
						local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateShow))
						local action = cc.RepeatForever:create(seq)
						widget:getChildByName("Panel_6"):runAction(action)
						updateShow()
					end
				end
   		end
   		
   		if nextRecoveTime > g_clock.getCurServerTime() then
   			widget:getChildByName("Panel_6"):setVisible(true)
   			cd:setVisible(false)
   			cd1:setVisible(true)
   			bg:setVisible(false)
   			bg1:setVisible(true)
   			loadingBar = cd1
   			local finishTime  = nextRecoveTime
				local updateShow = function()
					local per = 100
					local leftTime = finishTime - g_clock.getCurServerTime()
				  if finishTime > g_clock.getCurServerTime() then --如果正在
				  	per = 100 - (finishTime - g_clock.getCurServerTime())/cdTime * 100
				  	if leftTime < 0 then
				  		leftTime = 0
				  	end
				  	
						textProgressLabel:setString(leftTime..g_tr("second"))
						loadingBarHp:setPercent(per)
					else
						textProgressLabel:setString("")
						per = 100
						widget:getChildByName("Panel_6"):stopAllActions()
						loadingBarHp:setPercent(per)
						showNormalStatus()
		   		end
		   		loadingBar:setPercent(per)
				end
				local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateShow))
				local action = cc.RepeatForever:create(seq)
				widget:getChildByName("Panel_6"):runAction(action)
				updateShow()
			else
				showNormalStatus()
   		end
   		
   		
   	end
  elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_chuangnu 
  then
  	
  	--禁止进入图标
		--[[local noEnterCon = widget:getChildByName("Panel_6"):clone()
  	local currentBuildIdx = g_cityBattleMapSpBuildData.getLocalSpBuildDataBy_xy(serverData.x,serverData.y).build_num
  	
		local updateNoEnterStatus = function()
			if g_cityBattleInfoData.IsAttacker() then
				--noEnterCon:setVisible(true)
			else
				
				if currentBuildIdx == 1 or currentBuildIdx == 2 then
					--城门A
					local gate_1_InitData = g_data.cross_map_config[2]
					local gate_1_ServerData = g_cityBattleMapSpBuildData.getSpBuildDataBy_xy(gate_1_InitData.x,gate_1_InitData.y)
					local gate_1_IsBroken = tonumber(gate_1_ServerData.durability) == 0 --A门是否被击破
					if gate_1_IsBroken then
						noEnterCon:setVisible(true)
					end
				elseif currentBuildIdx == 3 or currentBuildIdx == 4 then
					--云梯
					local yuntiInitData = g_data.cross_map_config[5]
					local yunTiServerData = g_cityBattleMapSpBuildData.getSpBuildDataBy_xy(yuntiInitData.x,yuntiInitData.y)
					local wf_ladder_max_progress = tonumber(g_data.country_basic_setting[42].data) 
					local yunti_IsHold =  tonumber(yunTiServerData.resource) >= wf_ladder_max_progress --云梯是否被占领
					if yunti_IsHold then
						noEnterCon:setVisible(true)
					end
				end
			end
		end
		
		local function rootLayerEventHandler(eventType)
			if eventType == "enter" then
				g_gameCommon.addEventHandler(g_Consts.CustomEvent.CityBattleMapEvent, function(_,data)
					if data.Data.type == "ladderDone" then
						updateNoEnterStatus()
						if currentBuildIdx == 3 or currentBuildIdx == 4 then
							noEnterCon:setVisible(true)
						end
					end
					
					if data.Data.type == "doorBroken" then
						local gate_1_InitData = g_data.cross_map_config[2]
						local targetX = tonumber(data.Data.x)
						local targetY = tonumber(data.Data.y)
						if gate_1_InitData.x == targetX and gate_1_InitData.y == targetY then
							updateNoEnterStatus()
							if currentBuildIdx == 1 or currentBuildIdx == 2 then
								noEnterCon:setVisible(true)
							end
						end
					end
					
				end,noEnterCon)
			elseif eventType == "exit" then
				g_gameCommon.removeEventHandler(g_Consts.CustomEvent.CityBattleMapEvent,noEnterCon)
	    end
	  end
	  noEnterCon:registerScriptHandler(rootLayerEventHandler)
		noEnterCon:removeAllChildren()
		widget:getChildByName("Panel_6"):getParent():addChild(noEnterCon)
		local noEnter =  cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_no_bottom.png") --禁止图标
		noEnterCon:addChild(noEnter)
		noEnterCon:setVisible(false)
		]]
		
  	if not g_cityBattleInfoData.IsAttacker() 
  	and serverData.player_id ~= 0 then
			widget:getChildByName("Panel_6"):setVisible(true)
	
			local imgPath = "worldmap_image_guildwar_cn_mid.png"  --床弩攻击进度
			local bg =  cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_cn_bottom.png") --背景
	
			local textProgressNode = cc.Node:create()
			--textProgressNode:setContentSize(widget:getContentSize())
			local textProgressLabel = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
			textProgressLabel:setAnchorPoint(cc.p(0.5, 0.5))
			textProgressLabel:setPosition(cc.p(0.0, 40.5))
			textProgressNode:addChild(textProgressLabel)
			
	 		local node = cc.Node:create()
	 		node:addChild(bg)
	 		
	 		--for test
	-- 		bg:setCascadeOpacityEnabled(true)
	--		bg:setOpacity(100)
	 		
	 		local cd = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(imgPath))
	    cd:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    node:addChild(cd)
	    widget:getChildByName("Panel_6"):addChild(node)
	    
			local iconGetedLight = cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_cn_top.png") --亮
	    node:addChild(iconGetedLight)
	    node:addChild(textProgressNode)
	    iconGetedLight:setVisible(false)
			
			
			widget:getChildByName("Panel_6"):getChildByName("LoadingBar_2"):setVisible(false)
			widget:getChildByName("Panel_6"):getChildByName("Image_4"):setVisible(false)
			
			--local loadingBar = widget:getChildByName("Panel_6"):getChildByName("LoadingBar_2")
			local loadingBar = cd
	--		loadingBar:setPosition(pos)
	--		bg:setPosition(pos)
			
			function loadingBar:setPercent(percent)
				self:setPercentage(checkint(percent))
			end
	   	loadingBar:setPercent(0)

	   	--cd改为从服务器获取
	   	local cdTime = serverData.attack_cd
	   	local finishTime = serverData.attack_time + cdTime
	   	if g_clock.getCurServerTime() > finishTime then
	   		loadingBar:setPercent(100)
	   		iconGetedLight:setVisible(true)
	   		textProgressLabel:setString("")
	   	else
				local updateShow = function()
						local per = 100
						local leftTime = finishTime - g_clock.getCurServerTime()
					  if finishTime > g_clock.getCurServerTime() then --如果正在
					  	per = 100 - (finishTime - g_clock.getCurServerTime())/cdTime * 100
					  	if leftTime < 0 then
					  		leftTime = 0
					  	end
							textProgressLabel:setString(leftTime..g_tr("second"))
						else
							textProgressLabel:setString("")
							per = 100
							widget:getChildByName("Panel_6"):stopAllActions()
							iconGetedLight:setVisible(true)
			   		end
			   		loadingBar:setPercent(per)
				end
				local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateShow))
				local action = cc.RepeatForever:create(seq)
				widget:getChildByName("Panel_6"):runAction(action)
				updateShow()
	   	end
	  else
	  	--updateNoEnterStatus()
	  end
  elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche
  and serverData.player_id ~= 0
  then
  	local playerData = require "game.mapcitybattle.worldMapLayer_bigMap".getCurrentAreaDatas().Player[tostring(serverData.player_id)]
  	if playerData and tonumber(serverData.camp_id) == tonumber(g_cityBattlePlayerData.getCampId()) then
  		widget:getChildByName("Panel_6"):setVisible(true)
			local imgPath = "worldmap_image_guildwar_tsc_mid.png"  --床弩攻击进度
			local bg =  cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_tsc_bottom.png") --背景
	
			local textProgressNode = cc.Node:create()
			--textProgressNode:setContentSize(widget:getContentSize())
			local textProgressLabel = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
			textProgressLabel:setAnchorPoint(cc.p(0.5, 0.5))
			textProgressLabel:setPosition(cc.p(0.0, 40.5))
			textProgressNode:addChild(textProgressLabel)
			
	 		local node = cc.Node:create()
	 		node:addChild(bg)
	 		
	 		--for test
	-- 		bg:setCascadeOpacityEnabled(true)
	--		bg:setOpacity(100)
	 		
	 		local cd = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(imgPath))
	    cd:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    node:addChild(cd)
	    widget:getChildByName("Panel_6"):addChild(node)
	    
			local iconGetedLight = cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_tsc_top.png") --亮
	    node:addChild(iconGetedLight)
	    node:addChild(textProgressNode)
	    iconGetedLight:setVisible(false)
			
			
			widget:getChildByName("Panel_6"):getChildByName("LoadingBar_2"):setVisible(false)
			widget:getChildByName("Panel_6"):getChildByName("Image_4"):setVisible(false)
			
			--local loadingBar = widget:getChildByName("Panel_6"):getChildByName("LoadingBar_2")
			local loadingBar = cd
	--		loadingBar:setPosition(pos)
	--		bg:setPosition(pos)
			
			function loadingBar:setPercent(percent)
				self:setPercentage(checkint(percent))
			end
	   	loadingBar:setPercent(0)
	   	local cdTime = tonumber(g_data.country_basic_setting[35].data)
	   	local finishTime = serverData.attack_time + cdTime
	   	if g_clock.getCurServerTime() > finishTime then
	   		loadingBar:setPercent(100)
	   		iconGetedLight:setVisible(true)
	   		textProgressLabel:setString("")
	   	else
				local updateShow = function()
						local per = 100
						local leftTime = finishTime - g_clock.getCurServerTime()
					  if finishTime > g_clock.getCurServerTime() then --如果正在
					  	per = 100 - (finishTime - g_clock.getCurServerTime())/cdTime * 100
					  	if leftTime < 0 then
					  		leftTime = 0
					  	end
							textProgressLabel:setString(leftTime..g_tr("second"))
						else
							textProgressLabel:setString("")
							per = 100
							widget:getChildByName("Panel_6"):stopAllActions()
							iconGetedLight:setVisible(true)
			   		end
			   		loadingBar:setPercent(per)
				end
				local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateShow))
				local action = cc.RepeatForever:create(seq)
				widget:getChildByName("Panel_6"):runAction(action)
				updateShow()
	   	end
	  end
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gongchengchui 
	then
	
		--禁止进入图标
		local noEnterCon = widget:getChildByName("Panel_6"):clone()
		noEnterCon:removeAllChildren()
		
		widget:getChildByName("Panel_6"):getParent():addChild(noEnterCon)
		local noEnter =  cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_no_bottom.png") --禁止图标
		noEnterCon:addChild(noEnter)
		noEnterCon:setVisible(false)
	
		--[[local gate_1_InitData = g_data.cross_map_config[2]
		print("gate_1 x,y:",gate_1_InitData.x,gate_1_InitData.y)
		local gate_1_ServerData = g_cityBattleMapSpBuildData.getSpBuildDataBy_xy(gate_1_InitData.x,gate_1_InitData.y)
		local gate_1_IsBroken = tonumber(gate_1_ServerData.durability) == 0 --A门是否被击破
		if gate_1_IsBroken then
			loadingBarHp:setVisible(false)
   		local loadingBarBg = widget:getChildByName("Image_3")
			loadingBarBg:setVisible(loadingBarHp:isVisible())
		end]]
		
		local isAttacker = g_cityBattleInfoData.IsAttacker()
		widget:getChildByName("Panel_player_num"):setVisible(isAttacker) --驻守人数
		if isAttacker then
			local playerNumStr = serverData.player_num.."/10"
			local txtCon = widget:getChildByName("Panel_player_num"):getChildByName("Panel_1")
			local textLabel = cc.Label:createWithTTF(playerNumStr, "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
			textLabel:setAnchorPoint(cc.p(0.5, 0.5))
			txtCon:addChild(textLabel)
			
--			if gate_1_IsBroken then
--				noEnterCon:setVisible(true)
--			end
		else
			--noEnterCon:setVisible(true)
		end
		
		widget:getChildByName("Panel_6"):setVisible(isAttacker)

		local cdTime = tonumber(g_data.country_basic_setting[57].data) --复活cd
		local nextRecoveTime = serverData.recover_time 
		
		local bg =  cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_gcc_bottom.png") --攻击背景
		local bg1 =  cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_xiufu_bottom.png") --修复背景

		
		local textProgressNode = cc.Node:create()
		--textProgressNode:setContentSize(widget:getContentSize())
		
		local textProgressLabel = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
		textProgressLabel:setAnchorPoint(cc.p(0.5, 0.5))
		textProgressLabel:setPosition(cc.p(0.0, 40.5))
		textProgressNode:addChild(textProgressLabel)
		
 		local node = cc.Node:create()
 		widget:getChildByName("Panel_6"):addChild(node)
 		
 		node:addChild(bg)
 		node:addChild(bg1)
 		bg:setVisible(false)
 		bg1:setVisible(false)
 		
 		--for test
-- 		bg:setCascadeOpacityEnabled(true)
--		bg:setOpacity(100)
 		local imgPath = "worldmap_image_guildwar_gcc_mid.png"  --攻城锤攻击进度
 		local cd = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(imgPath))
    cd:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    node:addChild(cd)
    
    function cd:setPercent(percent)
			self:setPercentage(checkint(percent))
		end
   	cd:setPercent(0)
    
    imgPath = "worldmap_image_guildwar_xiufu_mid.png" --修复进度
    local cd1 = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(imgPath))
    cd1:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    node:addChild(cd1)

    function cd1:setPercent(percent)
			self:setPercentage(checkint(percent))
		end
   	cd1:setPercent(0)
    
    local iconRepairLight = cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_xiufu_top.png") --攻城锤修复亮
		local iconGetedLight = cc.Sprite:createWithSpriteFrameName("worldmap_image_guildwar_gcc_top.png") --攻城锤攻击亮
    iconRepairLight:setVisible(false)
    iconGetedLight:setVisible(false)
    node:addChild(iconRepairLight)
    node:addChild(iconGetedLight)
    node:addChild(textProgressNode)
		
		widget:getChildByName("Panel_6"):getChildByName("LoadingBar_2"):setVisible(false)
		widget:getChildByName("Panel_6"):getChildByName("Image_4"):setVisible(false)

		local loadingBar = cd
		
		local showNormalStatus = function()
			widget:getChildByName("Panel_6"):setVisible(g_cityBattleInfoData.IsAttacker() and serverData.camp_id ~= 0)
 			cd:setVisible(true)
 			cd1:setVisible(false)
 			bg:setVisible(true)
 			bg1:setVisible(false)
 			loadingBar = cd
			loadingBar:setPercent(0)
			
	   	--cd改为从服务器获取
	   	local cdTime = serverData.attack_cd
	   	local finishTime = serverData.attack_time + cdTime
	   	
	   	if g_clock.getCurServerTime() > finishTime then
	   		loadingBar:setPercent(100)
	   		iconGetedLight:setVisible(true)
	   		textProgressLabel:setString("")
	   	else
				local updateShow = function()
						local per = 100
						local leftTime = finishTime - g_clock.getCurServerTime()
					  if finishTime > g_clock.getCurServerTime() then --如果正在
					  	per = 100 - (finishTime - g_clock.getCurServerTime())/cdTime * 100
					  	if leftTime < 0 then
					  		leftTime = 0
					  	end
							textProgressLabel:setString(leftTime..g_tr("second"))
						else
							textProgressLabel:setString("")
							per = 100
							widget:getChildByName("Panel_6"):stopAllActions()
							iconGetedLight:setVisible(true)
			   		end
			   		loadingBar:setPercent(per)
				end
				local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateShow))
				local action = cc.RepeatForever:create(seq)
				widget:getChildByName("Panel_6"):runAction(action)
				updateShow()
	   	end
		end

 		if nextRecoveTime > g_clock.getCurServerTime() then --如果正在修复
 		
 			widget:getChildByName("Panel_6"):setVisible(true)
 			cd:setVisible(false)
 			cd1:setVisible(true)
 			bg:setVisible(false)
 			bg1:setVisible(true)
 			loadingBar = cd1
 		
 			local finishTime  = nextRecoveTime
			local updateShow = function()
				local per = 100
				local leftTime = finishTime - g_clock.getCurServerTime()
			  if finishTime > g_clock.getCurServerTime() then --如果正在
			  	per = 100 - (finishTime - g_clock.getCurServerTime())/cdTime * 100
			  	if leftTime < 0 then
			  		leftTime = 0
			  	end
			  	
					textProgressLabel:setString(leftTime..g_tr("second"))
					loadingBarHp:setPercent(per)
				else
					textProgressLabel:setString("")
					per = 100
					widget:getChildByName("Panel_6"):stopAllActions()
					loadingBarHp:setPercent(per)
					showNormalStatus()
	   		end
	   		loadingBar:setPercent(per)
			end
			local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateShow))
			local action = cc.RepeatForever:create(seq)
			widget:getChildByName("Panel_6"):runAction(action)
			updateShow()
		else
			showNormalStatus()
 		end

	end
	
	local textNode = cc.Node:create()
	textNode:setContentSize(widget:getContentSize())
	
	local textLabel = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
	textLabel:setAnchorPoint(cc.p(0.5, 0.5))
	textLabel:setPosition(cc.p(173.0, 31.0))
	textNode:addChild(textLabel)
	
	guildIcon:setVisible(false)
	
	local bigMap = require "game.mapcitybattle.worldMapLayer_bigMap"
	
	local str = ""
	local color = cc.c4b(255,255,255,255)
	
	if serverData.camp_id ~= 0 then
		--有公会占领了
		color = g_cityBattlePlayerData.getCampId() == serverData.camp_id and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)
--		
--		local guildData = bigMap.getCurrentAreaDatas().Camp[tostring(serverData.camp_id)]
--		if guildData then
--			if guildData.short_name and guildData.short_name ~= "" then
--				str = str.."("..guildData.short_name..")"
--			end
--			guildIcon:setVisible(true)
--			local iconId = g_data.country_camp_list[tonumber(serverData.camp_id)].camp_pic
--			guildIcon:loadTexture(g_resManager.getResPath(iconId))
--			--guildIcon:loadTexture(g_data.sprite[g_data.alliance_flag[guildData.icon_id].res_flag].path)
--		end	

		guildIcon:setVisible(true)
		local campInfoCfg = g_data.country_camp_list[tonumber(serverData.camp_id)]
		local iconId = campInfoCfg.camp_pic
		guildIcon:loadTexture(g_resManager.getResPath(iconId))
		
		--str = str.."("..g_tr(campInfoCfg.camp_name)..")"
		
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche
  and serverData.player_id == 0 then
  
  	local updateTitleShow = function()
	  	--投石车空闲时需要显示攻或者守
	  	if g_cityBattleInfoData.IsAttacker() then
	  		if g_cityBattleInfoData.IsSelfOccupationArea(serverData.area) then
	  			str = "("..g_tr("guild_war_attack_group")..")"
	  		else
	  			str = "("..g_tr("guild_war_defense_group")..")"
	  		end
	  	else
	  		if g_cityBattleInfoData.IsSelfOccupationArea(serverData.area) then
	  			str = "("..g_tr("guild_war_defense_group")..")"
	  		else
	  			str = "("..g_tr("guild_war_attack_group")..")"
	  		end
	  	end
	  	
	  	if not g_cityBattleInfoData.IsDoorMap() then
	  		str = "("..g_tr("guild_war_any_group")..")"
	  	end
	  	
	  	str = str..g_tr(configData.name)
	  	
	  	textLabel:setTextColor(color)
	  	textLabel:setString(str)
  	end
  	
  	
  	local seq = cc.Sequence:create(cc.DelayTime:create(6.18),cc.CallFunc:create(updateTitleShow))
		local action = cc.RepeatForever:create(seq)
		widget:runAction(action)
		updateTitleShow()
	else
		str = str..g_tr(configData.name)
	
		textLabel:setTextColor(color)
		textLabel:setString(str)
  end
	
	
	return widget , textNode
end


local function _create_kingCity(serverData, configData, originBigTileIndex)
	local widget = cc.CSLoader:createNode("worldmap_Upgrade.csb")
	local guildIcon = widget:getChildByName("Image_2")
	
	local loadingBar = widget:getChildByName("LoadingBar_1")
	loadingBar:setVisible(false)
	
	local loadingBarBg = widget:getChildByName("Image_3")
	loadingBarBg:setVisible(loadingBar:isVisible())
	
	local textNode = cc.Node:create()
	textNode:setContentSize(widget:getContentSize())
	
	local textLabel = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER)
	textLabel:setAnchorPoint(cc.p(0.5, 0.5))
	textLabel:setPosition(cc.p(173.0, 31.0))
	textNode:addChild(textLabel)
	
	guildIcon:setVisible(false)
	
	local bigMap = require "game.mapcitybattle.worldMapLayer_bigMap"
	
	local str = ""
	local color = cc.c4b(255,255,255,255)
	
	if serverData.camp_id ~= 0 then
		--最高分公会
		color = g_cityBattlePlayerData.getCampId() == serverData.camp_id and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)
		
--		local guildData = bigMap.getCurrentAreaDatas().Camp[tostring(serverData.camp_id)]
--		if guildData then
--			if guildData.short_name and guildData.short_name ~= "" then
--				str = str.."("..guildData.short_name..")"
--			end
--			guildIcon:setVisible(true)
--			local iconId = g_data.country_camp_list[tonumber(serverData.camp_id)].camp_pic
--			guildIcon:loadTexture(g_resManager.getResPath(iconId))
--			--guildIcon:loadTexture(g_data.sprite[g_data.alliance_flag[guildData.icon_id].res_flag].path)
--		end	

		guildIcon:setVisible(true)
		local campInfoCfg = g_data.country_camp_list[tonumber(serverData.camp_id)]
		local iconId = campInfoCfg.camp_pic
		guildIcon:loadTexture(g_resManager.getResPath(iconId))
		
		--str = str.."("..g_tr(campInfoCfg.camp_name)..")"
		
	end
	
	str = str..g_tr(configData.name)
	
	textLabel:setTextColor(color)
	textLabel:setString(str)
	
	return widget , textNode
end


function createTitle(serverData, configData, originBigTileIndex)
	local ret_image , ret_label_1 , ret_label_2 = nil , nil , nil

	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.player_home then
		ret_image , ret_label_1 , ret_label_2 = _create_playHome(serverData, configData, originBigTileIndex,true)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort then
		ret_image , ret_label_1 , ret_label_2 = _create_guild(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_tower then
		ret_image , ret_label_1 , ret_label_2 = _create_guild(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_gold then
		ret_image , ret_label_1 , ret_label_2 = _create_guild(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_food then
		ret_image , ret_label_1 , ret_label_2 = _create_guild(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_wood then
		ret_image , ret_label_1 , ret_label_2 = _create_guild(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_stone then
		ret_image , ret_label_1 , ret_label_2 = _create_guild(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_iron then
		ret_image , ret_label_1 , ret_label_2 = _create_guild(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_cache then
		ret_image , ret_label_1 , ret_label_2 = _create_guild(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.monster_small then
		ret_image , ret_label_1 , ret_label_2 = _create_monster(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.monster_boss then
		ret_image , ret_label_1 , ret_label_2 = _create_monster(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.king_castle	then
		ret_image , ret_label_1 , ret_label_2 = _create_kingCity(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.camp_middle	then
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.camp_low then
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gongchengchui then--------------------------------------------------------------攻城锤
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex,true)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gate then--------------------------------------------------------------城门
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex,true)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_chuangnu then--------------------------------------------------------------床弩
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_yunti then--------------------------------------------------------------云梯
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex,true)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche then--------------------------------------------------------------投石车
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_base_camp then--------------------------------------------------------------大本营
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex,true)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_wall then--------------------------------------------------------------城墙
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex,true)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_fuhuodian then--------------------------------------------------------------复活点
		ret_image , ret_label_1 , ret_label_2 = _create_camp(serverData, configData, originBigTileIndex)
	end
	
	if ret_image then
		local position = HelperMD.bigTileIndex_2_position(originBigTileIndex)
		position.x = position.x + HelperMD.m_SingleSizeHalf.width
		if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_chuangnu then 
			position.x = position.x + 50
		end
		position.y = position.y + 25.0
		ret_image:setAnchorPoint(cc.p(0.5, 0.5))
		ret_image:setPosition(position)
		ret_label_1:setAnchorPoint(cc.p(0.5, 0.5))
		ret_label_1:setPosition(position)
		if ret_label_2 then
			ret_label_2:setAnchorPoint(cc.p(0.5, 0.5))
			ret_label_2:setPosition(position)
		end
	end
	
	return ret_image , ret_label_1 , ret_label_2
end


function createLV(serverData, configData, originBigTileIndex)
	local ret_panel , ret_lable = nil , nil
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.player_home 
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_gold
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_food
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_wood
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_stone
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_iron
			then
		if serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_gold 
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_food 
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_wood 
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_stone 
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_iron 
				then
			local image_path = nil
			local resTab = string.split(configData.element_lv_show, ",")
			local count = (#resTab) / 3
			for i = 1 , count , 1 do
				local index = (i - 1) * 3 + 1
				local min = resTab[index]
				local max = resTab[index + 1]
				local imgId = resTab[index + 2]
				if tonumber(min) <= serverData.resource and serverData.resource <= tonumber(max) then
					image_path = g_data.sprite[tonumber(imgId)].path
					break
				end
			end
			if image_path then
				ret_panel = cc.Sprite:createWithSpriteFrameName(image_path)
			else
				ret_panel = cc.Sprite:createWithSpriteFrameName(g_data.sprite[configData.image_lv_back].path)
			end
		else
			ret_panel = cc.Sprite:createWithSpriteFrameName(g_data.sprite[configData.image_lv_back].path)
		end
		ret_lable = cc.Label:createWithCharMap("worldmap/notPlist/lv_number.png", 10, 18, 48)
		ret_lable:setString(tostring(configData.level))
		ret_lable:setSkewY(21.0)
	end
	
	if ret_panel then
		local position = HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData)
		position.x = position.x + configData.lv_xy[1]
		position.y = position.y + configData.lv_xy[2]
		ret_panel:setAnchorPoint(cc.p(0.5, 0.5))
		ret_panel:setPosition(position)
		ret_lable:setAnchorPoint(cc.p(0.5, 0.5))
		ret_lable:setPosition(position)
	end
	
	return ret_panel , ret_lable
end


function createBossMatch(serverData, configData, originBigTileIndex)
	local widget = cc.CSLoader:createNode("worldMap_blood.csb")
	widget:setAnchorPoint(cc.p(0.5, 0.5))
	local position = HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData)
	position.y = position.y + 128.0
	widget:setPosition(position)
	if serverData.max_durability <= 0 then
		widget:getChildByName("LoadingBar_1"):setPercent(0)
	else
		widget:getChildByName("LoadingBar_1"):setPercent(math.clampf((serverData.durability / serverData.max_durability) * 100, 0, 100))
	end
	widget:getChildByName("Image_2"):loadTexture(g_data.sprite[configData.img_boss_head].path)
	return widget
end



return worldMapLayer_buildTitle