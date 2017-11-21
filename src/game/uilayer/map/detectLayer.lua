local detectLayer = class("detectLayer", require("game.uilayer.base.BaseLayer"))

function detectLayer:createLayer(buildServerData,playerData,guildData,configData)
    --服务器数据
    self.server_data = buildServerData
    --玩家数据
    self.player_data = playerData
    --花费时间
    self.goto_time = 0
    --公会信息
    self.guild_data = guildData
    --配置信息
    self.config_data = configData

    if self.server_data and self.config_data then
        g_sceneManager.addNodeForUI( detectLayer:create())
    end
    
end

function detectLayer:ctor()
    detectLayer.super.ctor(self)
end

function detectLayer:onEnter()
    
    local layout = self:loadUI("Detect_main.csb")
    self.root = layout:getChildByName("scale_node")
    local close_btn = layout:getChildByName("mask")
	self:regBtnCallback(close_btn,function ()   
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    --zhcn
    self.root:getChildByName("Text_c2"):setString(g_tr("detect_title"))
    self.root:getChildByName("Text_2"):setString( g_tr("detect_title") )
    self.root:getChildByName("Text_3"):setString( g_tr("detect_time") )
    self.root:getChildByName("Text_2_0"):setString(g_tr( "clickhereclose" ))
    
    self:InitUI()

    local function callback( result , data )
        g_busyTip.hide_1()
        if result == true then
            for key, time in pairs(data.time) do
                self.goto_time = time
                break
            end
            local time_str = self.root:getChildByName("Text_3_0")
            time_str:setString( string.format( "%02d:%02d:%02d",g_clock.formatTimeHMS(self.goto_time) ) )
        else
            self:close()
        end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("map/getGotoTime", { x = self.server_data.x,y = self.server_data.y,type = g_Consts.FightType.Detect }, callback,true)
end

function detectLayer:InitUI()
    


    local name_str = self.root:getChildByName("Text_1")
    --有公会信息
    if self.guild_data then
        if self.player_data then
            name_str:setString( string.format("(%s)%s",self.guild_data.short_name,self.player_data.nick) )
        else

            dump(self.config_data)
            name_str:setString( string.format("(%s)%s",self.guild_data.short_name,g_tr(self.config_data.name)) )
        end
    else
        if self.player_data then
            name_str:setString( self.player_data.nick )
        else
            name_str:setString( g_tr("detect_pos") )
        end
    end


    local pos_str = self.root:getChildByName("Text_1_0")
    pos_str:setString( string.format("X:%d  Y:%d",self.server_data.x,self.server_data.y) )

    

    local line = self.root:getChildByName("line")
    line:setContentSize( cc.size( pos_str:getContentSize().width,line:getContentSize().height ) )
    
    --local power_str = root:getChildByName("Text_4_0")
    --power_str:setString(tostring( g_data.starting[41].data ))

    local goto_btn = self.root:getChildByName("Button_1")


    local town_pic = self.root:getChildByName("Image_tx1")
    town_pic:loadTexture( g_resManager.getResPath(self.config_data.img_mail) )
    
    --侦查消息发送
    self:regBtnCallback(goto_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local function sendBattle()
		    local function onRecv(result, msgData)
			    if(result==true)then
                    self:close()
				    require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual(true)
			    end
		    end
		    g_sgHttp.postData("player/spy",{ to_x = self.server_data.x , to_y = self.server_data.y },onRecv)
        end
        --判断是否有保护
        require("game.uilayer.battleSet.battleManager").battleHasAvoidMsgShow(sendBattle)
	end)

end

return detectLayer