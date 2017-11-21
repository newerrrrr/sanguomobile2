local kingSelKingLayer = class("kingSelKingLayer", require("game.uilayer.base.BaseLayer"))


function kingSelKingLayer:ctor( callback )
    kingSelKingLayer.super.ctor(self)

    self.AlliancePlayerData = g_AllianceMode.getGuildPlayers()
    self.AllianceData = g_AllianceMode.getBaseData()
    self.callback = callback

    table.sort(self.AlliancePlayerData,function (a,b)
        
        local powerA = ( tonumber(self.AllianceData.leader_player_id) ==  tonumber(a.Player.id) ) and  b.Player.power + 1 or a.Player.power

        local powerB = b.Player.power

        return powerA > powerB

    end  )

    self:initUI()
end


function kingSelKingLayer:initUI()
    
    self.layer = self:loadUI("KingOfWar_bestowAReward_Popup.csb")

    self.root = self.layer:getChildByName("scale_node")

    local close_btn = self.root:getChildByName("Button_x")

    self:regBtnCallback(close_btn,function ()
		self:close()
	end)

    self.list = self.root:getChildByName("ListView_1")

    self.root:getChildByName("Text_c2"):setString(g_tr("kwar_selKingTitle"))
    
    local row = math.ceil( #self.AlliancePlayerData / 2 )

    local index = 1
    local loadIndex = 1
    local function itemTouch(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("ididididid",sender.playerID)

            dump(sender.player)

            g_msgBox.show( g_tr("kwar_selKingTure",{ nick = sender.player.nick }),nil,2,
                function ( eventtype )
                    --È·¶¨
                    if eventtype == 0 then 
                        g_sgHttp.postData("King/appointKing", { target_player_id = sender.playerID }, callback)
                        
                        if self.callback and g_kingInfo.RequestData() then
                            self.callback()
                        end

                        self:close()
                    end
                end , 1)


            --g_sgHttp.postData("King/appointKing", { target_player_id =  }, callback)
        end
    end



    --[[
    for i = 1, row do
        
        local layout = ccui.Layout:create()

        layout:setSize( cc.size( listItem:getContentSize().width * 2,listItem:getContentSize().height ))
        
        for j = 1, 2 do
            
            local guildPlayerData = self.AlliancePlayerData[index]

            if guildPlayerData then
                
                local player = guildPlayerData.Player

                local item = listItem:clone()

                item:setPosition( cc.p( ( j - 1 ) * item:getContentSize().width + 7,0 ) )

                item:getChildByName("Text_z"):setString( string.formatnumberthousands(player.power) )
                
                item:getChildByName("Text_19"):setString( tostring(player.nick) )

                item:getChildByName("Text_18_0"):setVisible(false)

                local iconid = g_data.res_head[player.avatar_id].head_icon

                item:getChildByName("equip"):getChildByName("pic"):loadTexture( g_resManager.getResPath( iconid ))

                item:getChildByName("equip"):getChildByName("level_bg"):setVisible(false)

                item:getChildByName("equip"):getChildByName("Text_1"):setVisible(false)

                if player.job and player.job > 0 then

                    local jobConfig = g_data.king_appoint[tonumber(player.job)]

                    if jobConfig then
                        item:getChildByName("Text_19_0"):setString(g_tr(jobConfig.position_name))
                    end

                else
                    item:getChildByName("Text_19_0"):setVisible(false)
                end
                
                item.player = player

                item.playerID = guildPlayerData.player_id

                item:setTouchEnabled(true)

                item:addTouchEventListener(itemTouch)

                layout:addChild(item)
                
                index = index + 1
            end
        end
        self.list:pushBackCustomItem(layout)
    end
    ]]



    local function loadItem()
        
        if index <= #self.AlliancePlayerData then
            
            local listItem = cc.CSLoader:createNode("KingOfWar_bestowAReward__Popup1.csb")

            local layout = ccui.Layout:create()
            
            layout:setSize( cc.size( listItem:getContentSize().width * 2,listItem:getContentSize().height ))
        
            for j = 1, 2 do
            
                local guildPlayerData = self.AlliancePlayerData[index]

                if guildPlayerData then
                
                    local player = guildPlayerData.Player

                    local item = listItem:clone()

                    item:setPosition( cc.p( ( j - 1 ) * item:getContentSize().width + 7,0 ) )

                    item:getChildByName("Text_z"):setString( string.formatnumberthousands(player.power) )
                
                    item:getChildByName("Text_19"):setString( tostring(player.nick) )

                    item:getChildByName("Text_18_0"):setVisible(false)

                    local iconid = g_data.res_head[player.avatar_id].head_icon

                    item:getChildByName("equip"):getChildByName("pic"):loadTexture( g_resManager.getResPath( iconid ))

                    item:getChildByName("equip"):getChildByName("level_bg"):setVisible(false)

                    item:getChildByName("equip"):getChildByName("Text_1"):setVisible(false)

                    --[[if player.job and player.job > 0 then

                        local jobConfig = g_data.king_appoint[tonumber(player.job)]

                        if jobConfig then
                            item:getChildByName("Text_19_0"):setString(g_tr(jobConfig.position_name))
                        end

                    else
                        item:getChildByName("Text_19_0"):setVisible(false)
                    end]]

                    item:getChildByName("Text_19_0"):setVisible(false)

                    if guildPlayerData.player_id == self.AllianceData.leader_player_id then
                        item:getChildByName("Text_19_0"):setVisible(true)
                        item:getChildByName("Text_19_0"):setString(g_tr("SmallMapTowerKing"))
                    end
                
                    item.player = player

                    item.playerID = guildPlayerData.player_id

                    item:setTouchEnabled(true)

                    item:addTouchEventListener(itemTouch)

                    layout:addChild(item)
                
                    index = index + 1
                end
            end

            self.list:pushBackCustomItem(layout)

        else
            self:unscheduleUpdate()
        end
    end




    self:scheduleUpdateWithPriorityLua( loadItem , 0)

end


return kingSelKingLayer



