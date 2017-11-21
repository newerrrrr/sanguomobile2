local GuildWarSpBuildList = class("GuildWarSpBuildList",function()
	return cc.Layer:create()
end)

function GuildWarSpBuildList:ctor(areaId,orginal_id)
	local uiLayer =  g_gameTools.LoadCocosUI("guildwar_fuhuodian02.csb",5)
	self:addChild(uiLayer)
	
	local baseNode = uiLayer:getChildByName("scale_node")
	self._baseNode = baseNode
	
	self._baseNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("guild_war_cn_target_list"))
	
	local closeBtn = self._baseNode:getChildByName("close_btn")
		closeBtn:setTouchEnabled(true)
		closeBtn:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			self:removeFromParent()
		end
	end)
	
	self._areaId = areaId
	self._orginal_id = orginal_id
	
	self:updateView()
end

function GuildWarSpBuildList:updateView()
	local listView = self._baseNode:getChildByName("ListView_1")
	listView:removeAllChildren()
	local spBuildDatas = g_cityBattleMapSpBuildData.getSpBuildMapDatas()
	local spBuildPlayerDatas = g_cityBattleMapSpBuildData.getSpBuildPlayerDatas()
	for key, var in pairs(spBuildDatas) do
		if var.area == self._areaId and var.map_element_origin_id == self._orginal_id then
			local item = cc.CSLoader:createNode("guildwar_fuhuodian02_list1.csb")
			local config = g_data.map_element[tonumber(var.map_element_id)]
			item:getChildByName("Text_1"):setString(g_tr(config.name))
			item:getChildByName("Text_3_0"):setString("")
			item:getChildByName("Image_ss_0"):loadTexture(g_resManager.getResPath(config.img_mail))
			
			local currentBigTileIndex = cc.p(var.x,var.y)
			
			local homeBigTileIndex = g_cityBattlePlayerData.GetPosition()
			local distanceVec = cc.p( homeBigTileIndex.x - currentBigTileIndex.x , homeBigTileIndex.y - currentBigTileIndex.y )
			local distance = math.floor( math.sqrt( distanceVec.x * distanceVec.x + distanceVec.y * distanceVec.y ))
			item:getChildByName("Text_3"):setString(distance..g_tr("worldmap_KM"))
			
			local btn = item:getChildByName("Button_1")
			btn:getChildByName("Text_3_0"):setString(g_tr("guild_war_get_build"))
			btn:addClickEventListener(function()
				require("game.mapcitybattle.changeMapScene").gotoWorldAndOpenInterface_BigTileIndex(cc.p(tonumber(var.x),tonumber(var.y)),function()
					local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
					local originBigTileIndex = cc.p(tonumber(var.x),tonumber(var.y))
					local serverData = g_cityBattleMapSpBuildData.getSpBuildDataBy_xy(originBigTileIndex.x,originBigTileIndex.y)
					local configData = g_data.map_element[tonumber(serverData.map_element_id)]
					bigMap.play_arrow(serverData, configData, originBigTileIndex)
				end)
				self:removeFromParent()
			end)
			if var.player_id == 0 then
				item:getChildByName("Text_2"):setString(g_tr("guild_war_get_nothing"))
				btn:setEnabled(true)
			else
				local playerData = spBuildPlayerDatas[tostring(var.player_id)]
				if playerData then
					local countryName = ""
					if var.camp_id and tonumber(var.camp_id) > 0 then
						countryName = "("..g_tr(g_data.country_camp_list[tonumber(var.camp_id)].short_name)..")"
					end
					item:getChildByName("Text_2"):setString(countryName..playerData.nick)
					--btn:setEnabled(false)
				end
			end
			listView:pushBackCustomItem(item)
			
		end
	end
end

return GuildWarSpBuildList