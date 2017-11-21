--region kingActivityLayer.lua
--Author : liuyi
--Date   : 2016/9/24
--此文件由[BabeLua]插件自动生成
local kingActivityLayer = class("kingActivityLayer", require("game.uilayer.base.BaseLayer"))

function kingActivityLayer:ctor(data)
    
    kingActivityLayer.super.ctor(self)

    self.isOpen = true

    self.kingBuildData = data

    self.kingInfoData = g_kingInfo.GetData()

    self.guild = g_AllianceMode.getBaseData()
    
    --国王战开启 获取排名积分
    --[[if g_kingInfo.isKingBattleStarted() then
        local function callback(result,data)
            if result == true then
                if data then
                    self.pointData = data
                    if g_AllianceMode.getSelfHaveAlliance() then --是否加入联盟
                        if self.pointData then
                            self.guildPointInfo = self.pointData and self.pointData.GuildKingPoint[ tostring(self.guild.id) ]
                        end
                    end
                end
            end
        end
        g_sgHttp.postData("King/getScore", nil, callback)
    end--]]


    --self:initUI()
end

function kingActivityLayer:onEnter()
    local function callback(result,data)
        if result == true then
            if data then
                self.pointData = data
                if g_AllianceMode.getSelfHaveAlliance() then --是否加入联盟
                    if self.pointData then
                        self.guildPointInfo = self.pointData and self.pointData.GuildKingPoint[ tostring(self.guild.id) ]
                    end
                end
                self:initUI()
            end
        else
            self:close()
        end
    end
    
    g_sgHttp.postData("King/getScore", {}, callback,true)
end


function kingActivityLayer:initUI()
    
    if self.layer == nil then
        self.layer = self:loadUI("KingOfWar_details_main2.csb")
    end

    self.root = self.layer:getChildByName("scale_node")

    local close_btn = self.root:getChildByName("Button_x")
    self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)
    
    self.root:getChildByName("Text_c2"):setString(g_tr("MasterInfo"))

    local scPanel = self.root:getChildByName("Panel_ck")
    --scPanel:setVisible(g_kingInfo.isKingBattleStarted())
    
    local showBtn = scPanel:getChildByName("Button_1")
    self:regBtnCallback(showBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        if self.pointData then
            local data = self.pointData
            g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingPointListLayer"):create(data))
        end
    end)
    

    local function jumpMap(sender,evenType)
        if evenType == ccui.TouchEventType.ended then
            local pos
            if sender:getName() == "Image_nt" then
                pos = cc.p(610,626)
            elseif sender:getName() == "Image_lianb" then
                pos = cc.p(610,610)
            elseif sender:getName() == "Image_taigu" then
                pos = cc.p(626,610)
            elseif sender:getName() == "Image_junx" then
                pos = cc.p(626,626)
            elseif sender:getName() == "Image_wangc" then
                pos = cc.p(618,618)
            end
           
            self:close()

            require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex(pos)
        end
    end

    local b1 = self.root:getChildByName("Image_nt")
    b1:addTouchEventListener(jumpMap)
    b1.name = g_tr("kwar_taigutai")
    b1:getChildByName("Text_4"):setString( "(" .. g_tr("kwar_no")..")" .. b1.name )
    -- 610 626 , 1605 太鼓台
    local b2 = self.root:getChildByName("Image_lianb")
    b2:addTouchEventListener(jumpMap)
    b2.name = g_tr("kwar_lianbingsuo")
    b2:getChildByName("Text_4"):setString( "(" .. g_tr("kwar_no")..")" .. b2.name )
    -- 610 610 ，1604 练兵所
    local b3 = self.root:getChildByName("Image_taigu")
    b3:addTouchEventListener(jumpMap)
    b3.name = g_tr("kwar_jumtunnong")
    b3:getChildByName("Text_4"):setString( "(" .. g_tr("kwar_no")..")" .. b3.name )
    -- 626 610 ，1602 军械所
    local b4 = self.root:getChildByName("Image_junx")
    b4:addTouchEventListener(jumpMap)
    b4.name = g_tr("kwar_junxiesuo")
    b4:getChildByName("Text_4"):setString( "(" .. g_tr("kwar_no")..")" .. b4.name )
    -- 626 626 , 1603 军屯农

    self.root:getChildByName("Image_wangc"):addTouchEventListener(jumpMap)
    
    local skillbuild = {b1,b2,b3,b4}

    local function loadBuildData()
        
        if self.isOpen == false or self.isOpen == nil then
            return
        end

        table.sort( self.kingBuildData , function (a,b)
            return tonumber(a.id) < tonumber(b.id)
        end )

        for index, data in ipairs(self.kingBuildData) do
            
            local build = skillbuild[index]

            local name = build.name

            --已经选完国王之后
            if self.kingInfoData.guild_id and tonumber(self.kingInfoData.guild_id) ~= 0 then
                build:getChildByName("Text_4"):setString( name )
                local color = cc.c3b(255,255,255)
                if tonumber(self.kingInfoData.guild_id) == tonumber(self.guild.id) then
                    color = cc.c3b(30,230,30)
                elseif g_AllianceMode.getSelfHaveAlliance() then
                    color = cc.c3b(230,30,30) 
                end

                build:getChildByName("Text_4"):setTextColor( color )

            else
                if data.guild_id and tonumber(data.guild_id) ~= 0 then
                    build:getChildByName("Text_4"):setString( "(" .. data.guild_short_name ..")".. name )
                    build:getChildByName("Text_4"):setTextColor( cc.c3b(230,30,30) )
             
                    if g_AllianceMode.getSelfHaveAlliance() then 
                        if tonumber(data.guild_id) == tonumber(self.guild.id) then
                             build:getChildByName("Text_4"):setTextColor( cc.c3b(30,230,30) )
                        end
                    end
                else
                    build:getChildByName("Text_4"):setString( "(" .. g_tr("kwar_no")..")" .. name )
                end
            end
        end

    end
    
    local function callback(result,data)
        g_busyTip.hide_1()
        if true == result then
            self.kingBuildData = data.kingTown
            loadBuildData()
        end

    end
    g_busyTip.show_1()
    g_sgHttp.postData("King/getTownInfo", nil,callback,true)
    
    local helpBtn = self.root:getChildByName("Button_wenhao")
    self:regBtnCallback(helpBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        require("game.uilayer.common.HelpInfoBox"):show(17)
    end)

    --官职任命按钮
    local gzBtn = self.root:getChildByName("Button_2")
    gzBtn:getChildByName("Text_3"):setString(g_tr("kwar_promotedtitle"))
    self:regBtnCallback(gzBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingEnthroneLayer"):create())
    end)

    gzBtn:setVisible( g_PlayerMode.GetData().id == self.kingInfoData.player_id)

    --kwar_promotedtitle


    --Image_nt --1
    --Image_lianb--2
    --Image_taigu --3
    --Image_junx --4

    if self.openTimeTx == nil then
        self.openTimeTx = ccui.Text:create()
        self.openTimeTx:setFontName("cocostudio_res/simhei.ttf")
        self.openTimeTx:setFontSize(35)
        self.openTimeTx:setAnchorPoint(0.5,0.5)
        self.openTimeTx:setPosition( cc.p(self.root:getContentSize().width/2,self.root:getContentSize().height/2 - 25 ) ) 
        self.root:addChild(self.openTimeTx,1000)
        self.openTimeTx:enableOutline(cc.c4b(0, 0, 0,255), 1)
    
        local action = nil

        local function openTimeUpdate()
            if g_kingInfo.isKingBattleStarted() then

                if action then
                    self.openTimeTx:stopAction(action)
                    action = nil
                end

                self.openTimeTx:setString(g_tr("kwar_Opening"))
                self.openTimeTx:setTextColor( cc.c3b(30,230,30) )
                --self:initUI()
                return
            end

            if self.kingInfoData.guild_id and tonumber(self.kingInfoData.guild_id) ~= 0 then
                local color = cc.c3b(255,255,255)

                if tonumber(self.kingInfoData.guild_id) == tonumber(self.guild.id) then
                    color = cc.c3b(30,230,30)
                elseif g_AllianceMode.getSelfHaveAlliance() then
                    color = cc.c3b(230,30,30)
                end

                self.openTimeTx:setTextColor(color)

                self.openTimeTx:setString( g_tr("kwar_allow").. self.kingInfoData.guild_name )
            else
                self.openTimeTx:setString(g_gameTools.convertSecondToString(g_kingInfo.kingBattleSoonTime()))
            end

        end
        
        openTimeUpdate()

        local delay = cc.DelayTime:create(1)
        local sequence = cc.Sequence:create(delay, cc.CallFunc:create(openTimeUpdate))
        action = cc.RepeatForever:create(sequence)
        self.openTimeTx:runAction(action)
    end


    self:showKingWar()

end


function kingActivityLayer:showKingWar()

    local panel = self.root:getChildByName("jiangli")

    local desc1 = panel:getChildByName("Text_1")
    local desc2 = panel:getChildByName("Text_2")
    local timetxt = panel:getChildByName("Text_1_0")


    if g_kingInfo.isKingBattleStarted() then
        desc1:setString(g_tr("kworld_title_1"))
        desc2:setString(g_tr("kworld_title_2"))
    else
        desc1:setVisible(false)
        desc2:setVisible(false)
    end

    --panel:getChildByName("Text_1"):setString(g_tr("kworld_title_1"))
    --zhcn 后结束
    --panel:getChildByName("Text_2"):setString(g_tr("kworld_title_2"))
    

    local function paiMing()
        
        local scPanel = self.root:getChildByName("Panel_ck")

        if self.guildPointInfo then
            scPanel:getChildByName("Text_2"):setString( self.guildPointInfo.guild_name or "" )
            scPanel:getChildByName("Text_2_0"):setString( g_tr("kworld_point",{ num = self.guildPointInfo.point or 0 }) )
        else
            local showStr = g_tr("noAllianceTip")
            if g_AllianceMode.getSelfHaveAlliance() then
                showStr = self.guild.name
            end
            scPanel:getChildByName("Text_2"):setString(showStr)
            scPanel:getChildByName("Text_2_0"):setString( g_tr("kworld_point",{ num = 0 }) )
        end


        local guildPointSortData = self:guildPointSort()

        if guildPointSortData then
            --第1名称
            local OnePointData = guildPointSortData[1]
            if OnePointData then
                panel:getChildByName("Text_4_0"):setString(OnePointData.guild_name or "")
                panel:getChildByName("Text_4_1"):setString( g_tr("kworld_point",{ num = OnePointData.point or 0 }) )
            else
                panel:getChildByName("Text_4_0"):setString( g_tr("freeStatus") )
                panel:getChildByName("Text_4_1"):setString( "" )
            end

            --第2名称
            local TwoPointData = guildPointSortData[2]

            if TwoPointData then
                panel:getChildByName("Text_5_0"):setString(TwoPointData.guild_name or "")
                panel:getChildByName("Text_5_1"):setString( g_tr("kworld_point",{ num = TwoPointData.point or 0 }) )
            else
                panel:getChildByName("Text_5_0"):setString( g_tr("freeStatus") )
                panel:getChildByName("Text_5_1"):setString( "" )
            end

            --第3名称
            local ThreePointData = guildPointSortData[3]
            if ThreePointData then
                panel:getChildByName("Text_6_0"):setString(ThreePointData.guild_name or "")
                panel:getChildByName("Text_6_1"):setString( g_tr("kworld_point",{ num = ThreePointData.point or 0 }) )
            else
                panel:getChildByName("Text_6_0"):setString( g_tr("freeStatus") )
                panel:getChildByName("Text_6_1"):setString( "" )
            end
        end
    end

    paiMing()

    local action = nil

    local nowTagTime = g_clock.getCurServerTime()

    --时间更新方法
    local function update()
        
        local end_time = g_kingInfo.GetData().end_time - g_clock.getCurServerTime()

        --nowTagTime = nowTagTime - g_clock.getCurServerTime()

        if g_clock.getCurServerTime() - nowTagTime >= 30 then
            nowTagTime = g_clock.getCurServerTime()
            
            local function callback(result,data)
                if result then
                    self.pointData = data

                    if g_AllianceMode.getSelfHaveAlliance() then --是否加入联盟
                        self.guildPointInfo = self.pointData.GuildKingPoint[ tostring(self.guild.id) ]
                    end

                    paiMing()
                end
            end


            g_sgHttp.postData("King/getScore", nil, callback,true)

        end
        
        local timetxt = panel:getChildByName("Text_1_0")
        --timetxt:setString( g_gameTools.convertSecondToString(end_time) )

        --关闭倒计时定时器
        if g_kingInfo.isKingBattleStarted() then
            timetxt:setString( g_gameTools.convertSecondToString(end_time) )
        else
            --panel:setVisible(false)
            timetxt:setString( g_tr("kwar_pointstr") .. g_tr("kwar_pointrank") )
            if action then
                panel:stopAction(action)
            end
        end
    end

    update()

    local delay = cc.DelayTime:create(1)

    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(update))

    action = cc.RepeatForever:create(sequence)

    panel:runAction(action)
    
end


function kingActivityLayer:guildPointSort()
    
    --if g_kingInfo.isKingBattleStarted() then
        
        if self.pointData == nil then
            local function callback(result,data)
                if (true == result) then
                    self.pointData = data
                    if g_AllianceMode.getSelfHaveAlliance() then --是否加入联盟
                        self.guildPointInfo = self.pointData.GuildKingPoint[ tostring(self.guild.id) ]
                    end
                end
            end
            g_sgHttp.postData("King/getScore", nil, callback)
        end

        if self.pointData == nil then
            return
        end

        local guildPointSortData = {}

        for _, var in pairs(self.pointData.GuildKingPoint) do
            table.insert( guildPointSortData,var )
        end

        table.sort( guildPointSortData,function (a,b)
            return a.point > b.point
        end )

        return guildPointSortData
    --end

    --return nil

end


function kingActivityLayer:onExit()
    self.isOpen = false
end


return kingActivityLayer

--endregion
