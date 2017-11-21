--region kingInfoLayer.lua
--Author : liuyi
--Date   : 2016/3/9
local kingInfoLayer = class("kingInfoLayer", require("game.uilayer.base.BaseLayer"))

function kingInfoLayer:ctor()
    kingInfoLayer.super.ctor(self)
end


function kingInfoLayer:onEnter()
    
    self.kingWarData = g_kingInfo.GetData()

    if self.kingWarData.player_id and tonumber(self.kingWarData.player_id) ~= 0 then
        self:initUI()
    else
        local function callback1( result , data )
            g_busyTip.hide_1()
		    if true == result then
			    self.kingOldData = data

                if self.kingOldData then
                    table.sort( self.kingOldData ,function (a,b)
                        return a.start_time > b.start_time
                    end)
                end

                self:initUI()

                if self.scheduler == nil then
                    self.scheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update_time), 1 , false)
                end
            else
                self:close()
		    end
	    end
        g_busyTip.show_1()
        g_sgHttp.postData("King/getHistoryKing", nil, callback1,true)
    end

    
end


function kingInfoLayer:initUI()

    self.layer = self:loadUI("KingOfWar_details_main.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("Button_x")
	self:regBtnCallback(close_btn,function ()
		self:close()
	end)

    self:regBtnCallback(self.root:getChildByName("Button_wenhao"),function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		require("game.uilayer.common.HelpInfoBox"):show(19)
	end)

    local tx1 = self.root:getChildByName("Text_c3")

    --判断是否正在进行
    tx1:setString( g_kingInfo.isKingBattleStarted() and g_tr("kwar_nowTimeStr") or g_tr("kwar_nextOpenTimeStr"))
    
    --倒计时
    self.showClock = self.root:getChildByName("Text_c3_0")
    self.showClock:setPositionX( tx1:getContentSize().width/2 + tx1:getPositionX() )

    self:update_time()
    self.root:getChildByName("Text_c2"):setString(g_tr("kwar_infotitle"))
    self.root:getChildByName("Text_c4"):setString(g_tr("kwar_king"))
    
    self.showNowList = self.root:getChildByName("ListView_1")
    self.showOldList = self.root:getChildByName("ListView_2")
    
    --当前皇帝的基本信息
    if self.kingWarData.player_id and tonumber(self.kingWarData.player_id) ~= 0 then
        local nowItem = cc.CSLoader:createNode("KingOfWar_details_list2.csb")
        self.showNowList:pushBackCustomItem(nowItem)
    
        local name = nowItem:getChildByName("Panel_details2"):getChildByName("Text_6")
        name:setString(self.kingWarData.nick)

        local head = nowItem:getChildByName("Panel_details2"):getChildByName("Image_2")
        local iconid = g_data.res_head[self.kingWarData.avatar_id].head_icon
        head:loadTexture(g_resManager.getResPath( iconid ))

        local guildname = nowItem:getChildByName("Panel_details2"):getChildByName("Text_7_0")
        guildname:setString( g_tr("allianceName").. self.kingWarData.guild_name )

        local guildicon = nowItem:getChildByName("Panel_details2"):getChildByName("Image_3")

        local currentIcon = g_AllianceMode.getAllianceIconId( self.kingWarData.guild_icon_id)
        local iconInfo = g_data.alliance_flag[currentIcon]
        guildicon:loadTexture( g_resManager.getResPath(iconInfo.res_flag) )

        self:nowKingVisible(true)
    else
        self:nowKingVisible(false)
    end

    if self.kingOldData then
        for index, value in ipairs(self.kingOldData) do
            local olditem = cc.CSLoader:createNode("KingOfWar_details_list1.csb")
            local oldicon = olditem:getChildByName("Panel_details1"):getChildByName("Image_6_1")
       
            local iconid = g_data.res_head[value.avatar_id].head_icon
            oldicon:loadTexture(g_resManager.getResPath( iconid ))
        
            local oldname = olditem:getChildByName("Panel_details1"):getChildByName("Text_6")
            oldname:setString(value.nick)

            local rankindex = olditem:getChildByName("Panel_details1"):getChildByName("Text_7")
            rankindex:setString(g_tr("kwar_oldking",{rank = value.rank }))

            local oldTime = olditem:getChildByName("Panel_details1"):getChildByName("Text_7_0")
        
            local showTime = os.date("*t", value.start_time)
            oldTime:setString( string.format("%d-%d-%d",showTime.year,showTime.month,showTime.day))
            self.showOldList:pushBackCustomItem(olditem)
        end
    end
end

function kingInfoLayer:nowKingVisible(isshow)
    self.showNowList:setVisible(isshow)
    self.root:getChildByName("Image_hd"):setVisible(isshow)
    self.root:getChildByName("Text_c4"):setVisible(isshow)
    self.showOldList:setVisible(not isshow)
end

function kingInfoLayer:update_time()
    if g_kingInfo.isKingBattleStarted() then
        self.showClock:setString(g_gameTools.convertSecondToString( self.kingWarData.end_time - g_clock.getCurServerTime() ))
    else
        self.showClock:setString(g_gameTools.convertSecondToString(g_kingInfo.kingBattleSoonTime()))
    end
    --print("end_time",kingWarData.end_time)
end




function kingInfoLayer:onExit()
    if self.scheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
    end
end


return kingInfoLayer


--endregion
