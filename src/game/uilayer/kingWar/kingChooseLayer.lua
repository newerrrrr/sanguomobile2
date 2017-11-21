--region kingChooseLayer.lua
--Author : liuyi
--Date   : 2016/3/18
local kingChooseLayer = class("kingChooseLayer", require("game.uilayer.base.BaseLayer"))
local theGuildAllPlayerData = nil

function kingChooseLayer:ctor( data )
    
    kingChooseLayer.super.ctor(self)

    self.playersData = data

    self.cData,self.nData,self.officeType,self.giftId = require("game.uilayer.kingWar.kingEnthroneLayer").getCDataAndNData()
    
    self.jobData = require("game.uilayer.kingWar.kingEnthroneLayer").getJobData().Job
    
    self:initUI()

end

function kingChooseLayer:initUI()
    self.layer = self:loadUI("KingOfWar_bestowAReward_Popup.csb")

    self.root = self.layer:getChildByName("scale_node")

    local close_btn = self.root:getChildByName("Button_x")
    self:regBtnCallback(close_btn,function ()
		self:close()
	end)

    local titleStr = ""
    if self.officeType == 1 then
        titleStr = g_tr("kwar_appoint")
    elseif self.officeType == 2 then
         titleStr = g_tr("kwar_appointDown")
    else
        titleStr = g_tr("kwar_giftgive")
    end

    self.root:getChildByName("Text_c2"):setString( g_tr("kwar_selplayer",{title = titleStr } ) )
    
    local function itemTouch(sender,eventType)
        if eventType == ccui.TouchEventType.ended then

            local nick = sender.player.nick

            if self.officeType ~= 3 then
                
                local job = sender.player.job

                local timeStep = 3600 * tonumber(g_data.starting[85].data)
                
                --当前选中玩家的官职，可能不存在
                local job1 = self.jobData[tostring(job)]
               
                --需要任命的官职的人
                local job2 = self.jobData[tostring(self.cData.id)]
                

                --print("job,self.cData.id",job,self.cData.id)

                if job == self.cData.id then
                    g_airBox.show(g_tr("kwar_asSoon"))
                    return
                end


                local function jobTimeTips(name,time)
                    g_msgBox.show(  g_tr("kwar_changeOfficErr",{ offic = name,time = time }))
                end

                if job1 then
                    local job1Time = job1.time + timeStep
                    if g_clock.getCurServerTime() < job1Time then
                        local jobName = g_tr(g_data.king_appoint[ tonumber(job1.job) ].position_name)
                        local time = g_gameTools.convertSecondToString(job1Time - g_clock.getCurServerTime())
                        jobTimeTips(jobName,time)
                        return
                    end
                end
                
                if job2 then
                    local job2Time = job2.time + timeStep
                    if g_clock.getCurServerTime() < job2Time then
                        local jobName = g_tr(g_data.king_appoint[ tonumber(job2.job) ].position_name)
                        local time = g_gameTools.convertSecondToString(job2Time - g_clock.getCurServerTime() )
                        jobTimeTips(jobName,time)
                        return
                    end
                end

                
                --if job and job > 0 then
                    --g_airBox.show(g_tr("kwar_doubleapp"),2)
                --else
                local officStr = g_tr(self.cData.position_name)

                g_msgBox.show(  g_tr("kwar_sendOfficTips",{ nickname = nick,offic = officStr }),nil,2,
                    function ( eventType )
                        --确定
                        if eventType == 0 then 
                            local function callback( result , data )
		                        if true == result then
                                    g_airBox.show(g_tr("kwar_sendOfficOK"))
                                    require("game.uilayer.kingWar.kingEnthroneLayer").updateList()
                                    require("game.uilayer.kingWar.kingSelPlayerLayer").removeLayer()
                                    self:close()
		                        end
	                        end

                            g_sgHttp.postData("King/appointment", { nick = nick , jobId = self.cData.id }, callback)

                        end
                end , 1)
                --end
            else
                --送礼包
                local playerID = sender.playerID

                --print("送礼包",playerID,self.giftId)

                g_msgBox.show( g_tr("kwar_sendGiftTips",{ nickname = nick }),nil,2,
                    function ( eventType )
                        --确定
                        if eventType == 0 then 
                            local function callback( result , data )
		                        if true == result then
                                    g_airBox.show(g_tr("kwar_sendGiftOK"))
                                    require("game.uilayer.kingWar.kingEnthroneLayer").updateList()
                                    require("game.uilayer.kingWar.kingSelPlayerLayer").removeLayer()
                                    self:close()
		                        end
	                        end
                            g_sgHttp.postData("king/kingGift",{targetPlayerId = playerID,giftType = self.giftId},callback)
                        end
                end , 1)
            end
        end
    end
    
    self.list = self.root:getChildByName("ListView_1")
    
    local row = math.ceil(#self.playersData / 2 )

    local index = 1

    --for i = 1, row do
    local function loadItem()
        
        if index <= #self.playersData then

            local listItem = cc.CSLoader:createNode("KingOfWar_bestowAReward__Popup1.csb")

            local layout = ccui.Layout:create()

            layout:setSize( cc.size( listItem:getContentSize().width * 2,listItem:getContentSize().height ))
        
            for j = 1, 2 do
            
                local player = self.playersData[index]

                if player then
                    
                    local item = listItem:clone()

                    item:setPosition( cc.p( ( j - 1 ) * item:getContentSize().width + 7,0 ) )

                    item:getChildByName("Text_z"):setString( string.formatnumberthousands(player.power) )
                
                    item:getChildByName("Text_19"):setString( tostring(player.nick) )

                    item:getChildByName("Text_18_0"):setVisible(false)

                    local iconid = g_data.res_head[player.avatar_id].head_icon

                    item:getChildByName("equip"):getChildByName("pic"):loadTexture( g_resManager.getResPath( iconid ))

                    item:getChildByName("equip"):getChildByName("level_bg"):setVisible(false)

                    item:getChildByName("equip"):getChildByName("Text_1"):setVisible(false)

                    --dump(g_data.king_appoint)

                    if player.job and player.job > 0 then
                        local jobConfig = g_data.king_appoint[tonumber(player.job)]
                        if jobConfig then
                            item:getChildByName("Text_19_0"):setString(g_tr(jobConfig.position_name))
                        end
                        --g_tr(jobConfig.position_name)
                    else
                        item:getChildByName("Text_19_0"):setVisible(false)
                    end
                
                    item.player = player

                    item.playerID = player.player_id

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
    --end

    self:scheduleUpdateWithPriorityLua( loadItem , 0)

end

function kingChooseLayer:onEnter()
    
end

function kingChooseLayer:onExit()
    
end

return kingChooseLayer