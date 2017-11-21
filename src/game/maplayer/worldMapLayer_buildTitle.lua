local worldMapLayer_buildTitle = {}
setmetatable(worldMapLayer_buildTitle,{__index = _G})
setfenv(1,worldMapLayer_buildTitle)

local HelperMD = require "game.maplayer.worldMapLayer_helper"
local QueueHelperMD = require "game.maplayer.worldMapLayer_queueHelper"


--是否有自己联盟成员(包括自己)正在这个建筑里做queueType类型的事情
local function _isHaveSelfGuildAndSelfQueueDoing(buildServerData,queueType)
	if g_AllianceMode.getGuildId() ~= 0 then
		local bigMap = require("game.maplayer.worldMapLayer_bigMap")
		local currentQueueDatas = bigMap.getCurrentQueueDatas()
		for k , v in pairs(currentQueueDatas.Queue) do
			assert(v.to_map_id ~= 0, "error : to_map_id == 0 ")
			if buildServerData.id == v.to_map_id then
				if v.guild_id == g_AllianceMode.getGuildId() and v.type == queueType then
					return true
				end
			end
		end
	end
	return false
end


local function _create_playHome(serverData, configData, originBigTileIndex)
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
	
	local bigMap = require "game.maplayer.worldMapLayer_bigMap"
	
	local str = ""
	local color = cc.c4b(255,255,255,255)
	
	if serverData.guild_id ~= 0 then
		
		color = g_AllianceMode.getGuildId() == serverData.guild_id and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)
		
		local guildData = bigMap.getCurrentAreaDatas().Guild[tostring(serverData.guild_id)]
		if guildData then
			if guildData.short_name and guildData.short_name ~= "" then
				str = str.."("..guildData.short_name..")"
			end
			guildIcon:setVisible(true)
			guildIcon:loadTexture(g_data.sprite[g_data.alliance_flag[guildData.icon_id].res_flag].path)
		end
	end
	
	local playerData = bigMap.getCurrentAreaDatas().Player[tostring(serverData.player_id)]
	if playerData then
		if tonumber(g_PlayerMode.GetData().id) == tonumber(playerData.id) then
			color = cc.c4b(255,255,0,255)
			str = str..g_tr("worldmap_SelfHome")
			if g_PlayerHelpMode.GetHelpArmyNum() > 0 then
				str = str..g_tr("worldmap_SelfHomeHaveHelp")
			end
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
	
	local bigMap = require "game.maplayer.worldMapLayer_bigMap"
	
	local str = ""
	local color = cc.c4b(255,255,255,255)
	
	if serverData.guild_id ~= 0 then
		
		color = g_AllianceMode.getGuildId() == serverData.guild_id and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)
		
		local guildData = bigMap.getCurrentAreaDatas().Guild[tostring(serverData.guild_id)]
		if guildData then
			if guildData.short_name and guildData.short_name ~= "" then
				str = str.."("..guildData.short_name..")"
			end
			guildIcon:setVisible(true)
			guildIcon:loadTexture(g_data.sprite[g_data.alliance_flag[guildData.icon_id].res_flag].path)
		end	
		
	end
	
	str = str..g_tr(configData.name)
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort then
		--联盟堡垒才有驻防
		if serverData.guild_id ~= 0 and g_AllianceMode.getGuildId() == serverData.guild_id then
			--自己公会才看驻防信息
			if _isHaveSelfGuildAndSelfQueueDoing(serverData, QueueHelperMD.QueueTypes.TYPE_GUILDBASE_DEFEND) then
				str = str.."("..g_tr("worldmap_houses_have")..")"
			else	
				str = str.."("..g_tr("worldmap_houses_nothave")..")"
			end
			
			
			local guildData = bigMap.getCurrentAreaDatas().Guild[tostring(serverData.guild_id)]
			if guildData then
				local campId = tonumber(guildData.camp_id)
				if campId ~= 0 then
					local campInfoCfg = g_data.country_camp_list[campId]
					local iconId = campInfoCfg.camp_pic
					local campIcon = widget:getChildByName("Image_2_0")
					campIcon:loadTexture(g_resManager.getResPath(iconId))
				end
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


local function _create_camp(serverData, configData, originBigTileIndex)
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
	
	local bigMap = require "game.maplayer.worldMapLayer_bigMap"
	
	local str = ""
	local color = cc.c4b(255,255,255,255)
	
	if serverData.guild_id ~= 0 then
		--有公会占领了
		color = g_AllianceMode.getGuildId() == serverData.guild_id and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)
		
		local guildData = bigMap.getCurrentAreaDatas().Guild[tostring(serverData.guild_id)]
		if guildData then
			if guildData.short_name and guildData.short_name ~= "" then
				str = str.."("..guildData.short_name..")"
			end
			guildIcon:setVisible(true)
			guildIcon:loadTexture(g_data.sprite[g_data.alliance_flag[guildData.icon_id].res_flag].path)
		end	
		
	end
	
	str = str..g_tr(configData.name)
	
	textLabel:setTextColor(color)
	textLabel:setString(str)
	
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
	
	local bigMap = require "game.maplayer.worldMapLayer_bigMap"
	
	local str = ""
	local color = cc.c4b(255,255,255,255)
	
	if serverData.guild_id ~= 0 then
		--最高分公会
		color = g_AllianceMode.getGuildId() == serverData.guild_id and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)
		
		local guildData = bigMap.getCurrentAreaDatas().Guild[tostring(serverData.guild_id)]
		if guildData then
			if guildData.short_name and guildData.short_name ~= "" then
				str = str.."("..guildData.short_name..")"
			end
			guildIcon:setVisible(true)
			guildIcon:loadTexture(g_data.sprite[g_data.alliance_flag[guildData.icon_id].res_flag].path)
		end	
		
	end
	
	str = str..g_tr(configData.name)
	
	textLabel:setTextColor(color)
	textLabel:setString(str)
	
	return widget , textNode
end


function createTitle(serverData, configData, originBigTileIndex)
	local ret_image , ret_label_1 , ret_label_2 = nil , nil , nil

	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.player_home then
		ret_image , ret_label_1 , ret_label_2 = _create_playHome(serverData, configData, originBigTileIndex)
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
	end
	
	if ret_image then
		local position = HelperMD.bigTileIndex_2_position(originBigTileIndex)
		position.x = position.x + HelperMD.m_SingleSizeHalf.width
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