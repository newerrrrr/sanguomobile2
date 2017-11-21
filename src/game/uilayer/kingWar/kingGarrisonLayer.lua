local kingGarrisonLayer = class("kingGarrisonLayer", require("game.uilayer.base.BaseLayer"))

function kingGarrisonLayer:ctor(data,guildPlayers)
    kingGarrisonLayer.super.ctor(self)
    self.buildData = data
    self.guildPlayersData = guildPlayers
    dump(self.buildData)

    self:initUI()
end

function kingGarrisonLayer:initUI()
    
    self.layer = self:loadUI("alliance_building_defense.csb")

    self.root = self.layer:getChildByName("scale_node")

    local close_btn = self.root:getChildByName("close_btn")
    self:regBtnCallback(close_btn,function ()
		self:close()
	end)

    local config = g_data.map_element[tonumber(self.buildData.map_element_id)]

    --dump(config)

    self.root:getChildByName("Text_1"):setString(g_tr(config.name))
    self.root:getChildByName("text_2"):setString(g_tr(config.name))
    
    local showPanel = self.root:getChildByName("pic_building")
    local node = g_gameTools.getWorldMapElementDisplay(self.buildData.map_element_id)
    node:setPosition(cc.p( showPanel:getContentSize().width/2,showPanel:getContentSize().height/2 ))
    node:setScale(0.7)
    showPanel:addChild(node)
    
    self.infoPanel = self.root:getChildByName("bg_building_info")
    self.infoPanel:getChildByName("text_tips"):setVisible(false)
    
    self.infoPanel:getChildByName("text_property_name2"):setVisible(false)
    self.infoPanel:getChildByName("text_property_value2"):setVisible(false)
    self.infoPanel:getChildByName("text_property_name3"):setVisible(false)
    self.infoPanel:getChildByName("text_property_value3"):setVisible(false)
    self.root:getChildByName("Image_ditu1_0"):setVisible(false)
    self.root:getChildByName("Image_ditu1_0_0"):setVisible(false)
    self.root:getChildByName("btn_save"):setVisible(false)

    --size 912.00 , 600
    --pos 787,44

    self.list = self.root:getChildByName("ListView_1")
    self.list:setSize(cc.size(912,600))
    self.list:setPosition(cc.p(787,44))


    if self.guildPlayersData then
        self:showGuildPlayers()
    else
        self:noBodyIn()
    end
    
    self.infoPanel:getChildByName("text_property_name1"):setString(g_tr("garrisonTroops"))

end

function kingGarrisonLayer:noBodyIn()

    local listItem = cc.CSLoader:createNode("alliance_building_defense_list_1.csb")
    
    local panel = listItem:getChildByName("army_item")
    
    local backBtn = panel:getChildByName("Button_1"):setVisible(false)

    local npcid = self.buildData.KingTown.npc_id

    local npcConfig = g_data.npc[npcid]
    
    local pic = panel:getChildByName("pic")

    pic:loadTexture( g_resManager.getResPath( npcConfig.img_mail ) )

    pic:setScale(0.8)

    local name = panel:getChildByName("name")

    name:setString(g_tr( npcConfig.monster_name ))

    self.list:pushBackCustomItem(listItem)

    panel:getChildByName("label_general"):setString(g_tr("allianceBuildSoldierArmy"))
    panel:getChildByName("num_current"):setString( "1" )

    panel:getChildByName("label_soldier"):setVisible(false)

    local index = 1

    while index do
        local st = panel:getChildByName( string.format( "soldier_type_%d", index) )
        local ns = panel:getChildByName( string.format( "num_soldier_%d", index) )

        if st then
            st:setVisible(false)
        else
            break
        end

        if ns then
            ns:setVisible(false)
        else
            break
        end

        index = index + 1
    end
    
    panel:getChildByName("label_battle"):setString(g_tr("allianceBuildSoldierPower"))

    local sNum = self.buildData.KingTown and self.buildData.KingTown.npc_num or 0
    
    --计算单兵数量
    local power = npcConfig.recommand_power/npcConfig.number

    panel:getChildByName("num_battle"):setString( tostring( math.ceil(sNum * power) ) )
    
    self.infoPanel:getChildByName("text_property_value1"):setString( string.format("%d/10",1) )

end

function kingGarrisonLayer:showGuildPlayers()
    
    self.infoPanel:getChildByName("text_property_value1"):setString( string.format("%d/10",#self.guildPlayersData) )

    local bodyItem = cc.CSLoader:createNode("alliance_building_defense_list_1.csb")

    local noBodyItem = cc.CSLoader:createNode("alliance_building_defense_list_4.csb")

    dump(self.guildPlayersData)

    for i = 1, 10 do

        local guild = self.guildPlayersData[i]

        local node = nil

        if guild then
            
            node = bodyItem:clone()
            
            local panel = node:getChildByName("army_item")

            panel:getChildByName("label_soldier"):setString(g_tr("allianceBuildSoldierNum"))

            panel:getChildByName("name"):setString(guild.player_nick)

            panel:getChildByName("num_battle"):setString( tostring( guild.total_power ) )
            
            local armyData = guild.army

            panel:getChildByName("label_general"):setString(g_tr("allianceBuildSoldierArmy"))

            panel:getChildByName("num_current"):setString( tostring(#armyData) )
            
            panel:getChildByName("pic"):setScale(0.68)

            panel:getChildByName("pic"):loadTexture( g_resManager.getResPath(g_data.res_head[guild.avatar_id].head_icon) )
            
            local orginalPosList = {}

            for i = 1, 4 do
                local iconPos = panel:getChildByName("soldier_type_"..i):getPositionX()
                local labelPos = panel:getChildByName("num_soldier_"..i):getPositionX()
                orginalPosList[i] = {}
                orginalPosList[i].iconX = iconPos
                orginalPosList[i].labelX = labelPos
            end

            local soldierTypes = {}
            
            for i = 1, 4 do
    	        panel:getChildByName("soldier_type_"..i):setVisible(false)

                panel:getChildByName("num_soldier_"..i):setVisible(false)
                
                soldierTypes[i] = 0
            end

            for i = 1, #armyData do
                local army = armyData[i]
                print("soldier_id:",army.soldier_id)
                local soldierInfo = g_data.soldier[army.soldier_id]
                if soldierInfo then
                    soldierTypes[soldierInfo.soldier_type] = soldierTypes[soldierInfo.soldier_type] + army.soldier_num
    	        end
            end

            local idx = 1
            for i = 1, 4 do
                if soldierTypes[i] > 0 then
                    panel:getChildByName("soldier_type_"..i):setVisible(true)
                    panel:getChildByName("num_soldier_"..i):setVisible(true)
                    panel:getChildByName("soldier_type_"..i):loadTexture(g_resManager.getResPath(1002003 + (i-1)))
                    panel:getChildByName("num_soldier_"..i):setString(soldierTypes[i].."")
            
                    panel:getChildByName("soldier_type_"..i):setPositionX(orginalPosList[idx].iconX)
                    panel:getChildByName("num_soldier_"..i):setPositionX(orginalPosList[idx].labelX)
            
                    idx = idx + 1
                end
            end


            local army_item = panel
            army_item:getChildByName("Button_1"):setVisible(false)
            --[[army_item:getChildByName("label_soldier"):setString(g_tr("allianceBuildSoldierNum"))
    
    
            local targetPlayerRank = guild.rank
    
            if g_AllianceMode.isAllianceManager() then
                army_item:getChildByName("Button_1"):setVisible(true)
    
                local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
                local myRank = myInfo.rank
        
                if targetPlayerRank >= myRank then
                    army_item:getChildByName("Button_1"):setVisible(false)
                end
            end
    
            if army_item:getChildByName("Button_1"):isVisible() then
                army_item:getChildByName("Button_1"):addClickEventListener(function(sender)
            
                    local doDelete = function()
                
                        local resultHandler = function(result, msgData)
                          if result then
                             item:removeFromParent()
                          end
                        end
                        g_sgHttp.postData("guild/kickDefendArmyFromGuildBase",{ppq_id = guild.ppq_id},resultHandler)
            
                    end
            
                    g_msgBox.show(g_tr("guildBuildArmyFireTip"),nil,nil,function(event)
                        if event == 0 then
                            doDelete()
                        end
                    end,1)
            
                end)
            end]]
        else
            node = noBodyItem:clone()
            local panel = node:getChildByName("army_item")
            panel:getChildByName("text_tips"):setString(g_tr("kwar_touchAdd"))

            node:setTouchEnabled(true)

            node:addClickEventListener(function(sender)
            	local buildServerData = serverData
                require("game.uilayer.battleSet.battleManager").gotoGarrison({buildServerData = self.buildData})
            end)

        end
        self.list:pushBackCustomItem(node)
    end
end

return kingGarrisonLayer