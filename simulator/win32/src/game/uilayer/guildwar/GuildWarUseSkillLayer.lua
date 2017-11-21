local GuildWarUseSkillLayer = class("GuildWarUseSkillLayer",function()
	return cc.Layer:create()
end)

local changeMapScene = require("game.maplayer.changeMapScene")

function GuildWarUseSkillLayer:ctor(serverData,targetArea,activeSkillTargetConfig)
	local uiLayer =  g_gameTools.LoadCocosUI("guild_war_message_xintanc2.csb",5)
	self:addChild(uiLayer)
	
	local baseNode = uiLayer:getChildByName("scale_node")
	self._baseNode = baseNode
	
	self._baseNode:getChildByName("Text_nr_0"):setString(g_tr("generalBattleSkillActiviteUseTip",{times = serverData.rest_times}))
	
	local skillConfig = g_data.battle_skill[tonumber(serverData.skill_id)]
	
	self._baseNode:getChildByName("Image_t2"):loadTexture(g_resManager.getResPath(skillConfig.skill_res))
	
	self._baseNode:getChildByName("bg_title"):getChildByName("Text_2"):setString(g_tr(skillConfig.skill_name))
	
	local closeBtn = self._baseNode:getChildByName("close_btn")
		closeBtn:setTouchEnabled(true)
		closeBtn:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
			self:removeFromParent()
		end
	end)
	
	local tipStrConfig = require("game.mapguildwar.worldMapLayer_uiLayer").tipStrConfig
	
	local okBtn = self._baseNode:getChildByName("Button_1")
	okBtn:getChildByName("Text_4"):setString(g_tr("confirm"))
	okBtn:addClickEventListener(function()
		local function onRecv(result, data)
        if(result==true)then
        	
        	local msgData = data.notice
        	
        	local skillType = "skill_"..serverData.skill_id
        	local str = ""
        	local strNotice = ""
        	
        	local tipList = {}
        	
        	if skillType == "skill_10110" then --技能：五雷轰顶
						local fromNick = msgData.fromNick
						str = g_tr(tipStrConfig[skillType].info_desc,{fromNick = fromNick,second = msgData.second})
						if tipStrConfig[skillType].info_type == 1 or tipStrConfig[skillType].info_type == 2 then
							strNotice = g_tr(tipStrConfig[skillType].info_desc1,{fromNick = fromNick,second = msgData.second})
						end
						table.insert(tipList,strNotice)
					elseif skillType == "skill_10098" then --技能：业火冲天
						local targetList = msgData.target or {}
						for key, var in pairs(targetList) do
							local msgData = var
							local targetX = tonumber(msgData.to_x)
							local targetY = tonumber(msgData.to_y)
	--						local targetSpBuildData = g_guildWarMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
	--						local mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
							local targetSpBuildData = g_cityBattle_cross_ui_dataHelper.requireMapSpBuildData().getLocalSpBuildDataBy_xy(targetX,targetY)
							local buildName = ""
							if targetSpBuildData then
								local mapStatus = changeMapScene.getCurrentMapStatus()
								local mapConfigData = nil
								if mapStatus == changeMapScene.m_MapEnum.guildwar then
									mapConfigData = g_data.map_element[targetSpBuildData.cross_map_element_id]
								else
									mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
								end
								buildName = g_tr(mapConfigData.name)
							else
								buildName = msgData.toNick or ""
							end
						
							str = g_tr(tipStrConfig[skillType].info_desc,{nick = msgData.fromNick,map_id = buildName,reduce = msgData.reduce,rest = msgData.rest})
							if tipStrConfig[skillType].info_type == 1 or tipStrConfig[skillType].info_type == 2 then
								strNotice = g_tr(tipStrConfig[skillType].info_desc1,{nick = msgData.fromNick,map_id = buildName,reduce = msgData.reduce,rest = msgData.rest})
							end
							table.insert(tipList,strNotice)
						end
					
					elseif skillType == "skill_10105" then --技能：破胆怒吼
						local targetList = msgData.target or {}
						for key, var in pairs(targetList) do
							local msgData = var
							local fromNick = msgData.fromNick
							str = g_tr(tipStrConfig[skillType].info_desc,{fromNick = fromNick,toArea = msgData.toArea})
							if tipStrConfig[skillType].info_type == 1 or tipStrConfig[skillType].info_type == 2 then
								strNotice = g_tr(tipStrConfig[skillType].info_desc1,{fromNick = fromNick,toArea = msgData.toArea})
							end
							table.insert(tipList,strNotice)
						end
					else
						if tipStrConfig[skillType] then
							str = g_tr(tipStrConfig[skillType].info_desc)
							if tipStrConfig[skillType].info_type == 1 or tipStrConfig[skillType].info_type == 2 then
								strNotice = g_tr(tipStrConfig[skillType].info_desc1)
							end
							table.insert(tipList,strNotice)
						else
							local skillConfig = g_data.battle_skill[tonumber(serverData.skill_id)]
							local skillName = g_tr_original(skillConfig.skill_name)
							str = g_tr("guild_war_use_skill",{name = skillName})
							require("game.mapguildwar.worldMapLayer_uiLayer").tipMsg(str)
						end
						
					end
					
					local configData = tipStrConfig[skillType]
					if configData and configData.info_type == 2 then
						for key, var in pairs(tipList) do
							if var ~= "" then
								--上浮消息
								require("game.mapguildwar.worldMapLayer_uiLayer").tipMsg(var)
							end
						end
					end
        end
        self:removeFromParent()
    end
    
    local mapStatus = changeMapScene.getCurrentMapStatus()
		if mapStatus == changeMapScene.m_MapEnum.guildwar then
			g_sgHttp.postData("Cross/useSkill",{skillId = serverData.skill_id,generalId = serverData.general_id},onRecv)
		else
			g_sgHttp.postData("City_Battle/useSkill",{skillId = serverData.skill_id,generalId = serverData.general_id},onRecv)
		end
						
    
	end)
	
	local cancleBtn = self._baseNode:getChildByName("Button_1_0")
	cancleBtn:getChildByName("Text_4"):setString(g_tr("cancel"))
	cancleBtn:addClickEventListener(function()
		g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:removeFromParent()
	end)
	
	local numStr = serverData.v1
	if skillConfig.num_type == 1 then
		numStr = string.format("%.2f",serverData.v1 * 100)
	end
	
	local buffStr = serverData.v2
	if skillConfig.num_type == 1 then
		buffStr = string.format("%.2f",serverData.v2 * 100)
	end
	
	local desc = g_tr( skillConfig.skill_description,{ num = numStr, numnext = "",buff = buffStr,buffnext = ""} )
	
	if activeSkillTargetConfig then
		local skillId = skillConfig.id
		local areaStr = ""
		if skillId == 10098 then --业火冲天
			if targetArea > 0 then
				areaStr = g_tr("guild_war_use_skill_target_area",{num = targetArea})
			end
			desc = g_tr(activeSkillTargetConfig.client_description,{value = areaStr,num = numStr, numnext = "",buff = buffStr,buffnext = ""})
		elseif skillId == 10105 then --破胆怒吼
			if targetArea > 0 then
				areaStr = g_tr("guild_war_use_skill_target_area",{num = targetArea})
			end
			desc = g_tr(activeSkillTargetConfig.client_description,{value = areaStr,num = numStr, numnext = "",buff = buffStr,buffnext = ""})
		end
	end
	
--	if skillConfig.active_skill_area_desc > 0 then
--		local skillId = skillConfig.id
--		local areaStr = ""
--		local targetName = ""
--
--		if targetArea > 0 then
--			areaStr = g_tr("guild_war_use_skill_target_area",{num = targetArea})
--		end
--		
--		if activeSkillTargetConfig then
--			local mapConfigData = g_data.map_element[targetBuildServerData.map_element_id]
--			targetName = g_tr(mapConfigData.name)
--		end
--		desc = g_tr(skillConfig.active_skill_area_desc,{value = areaStr,build_name = targetName,num = numStr, numnext = "",buff = buffStr,buffnext = ""})
--	end
	
	local rich = g_gameTools.createRichText(self._baseNode:getChildByName("Text_nr"),desc)
	
end

return GuildWarUseSkillLayer