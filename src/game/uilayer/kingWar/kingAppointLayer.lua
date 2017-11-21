--region kingAppointLayer.lua
--Author : liuyi
--Date   : 2016/3/9
local kingAppointLayer = class("kingAppointLayer", require("game.uilayer.base.BaseLayer"))

local FOUR_H = 3600 * tonumber(g_data.starting[85].data)

function kingAppointLayer:ctor(cData,nData)
    kingAppointLayer.super.ctor(self)

    self.kingWarData = g_kingInfo.GetData()
    self.playerData = g_PlayerMode.GetData()

    self.cData = cData
    self.nData = nData
    self.nextAppTime = 0  --下一次选举时间

    self:initUI()
end

function kingAppointLayer:initUI()
    self.layer = self:loadUI("KingOfWar_Office.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("close_btn")
	self:regBtnCallback(close_btn,function ()
		self:close()
	end)
    
    self.root:getChildByName("Text_1"):setString(self.cData.type == 1 and g_tr("kwar_officerbuff") or g_tr("kwar_officerdebuff"))
    self.root:getChildByName("text"):setString( g_tr(self.cData.position_name) )

    self.list = self.root:getChildByName("ListView_3")
    self.list:setItemsMargin(8)
    --任命按钮
    local appoint_btn = self.root:getChildByName("Button_1")
    local appoint_str = self.root:getChildByName("Text_2")
    appoint_str:setString( self.cData.type == 1 and  g_tr("kwar_appoint") or g_tr("kwar_appointDown") )
    --官员详情
    local officerview_btn = self.root:getChildByName("Button_2")
    local officerview_str = self.root:getChildByName("Text_3")
    officerview_str:setString(g_tr("kwar_officerinfo"))
    
    --local mail_btn = self.root:getChildByName("Button_3")
    --local mail_str = self.root:getChildByName("Text_4")
    --mail_str:setString(g_tr("mail"))

    --local bg = self.root:getChildByName("Image_1_0_0")
    --local show = self.root:getChildByName("Image_1_0")
    --local border = self.root:getChildByName("Image_1")

    --背景Image_1_0_0
    --展示图Image_1_0
    --边框Image_1

    --如果不是国王关闭隐藏任命按钮
    if self.playerData.id ~= self.kingWarData.player_id then
        appoint_btn:setEnabled(false)
        --appoint_btn:setVisible(false)
        --self.root:getChildByName("Text_2"):setVisible(false)
        --officerview_btn:setPosition( appoint_btn:getPosition() )
        --officerview_str:setPosition( appoint_str:getPosition() )
    else

        self:update_time()
        --获取下一次选举倒计时
        if self.nextAppTime > 0 then
            --打开定时器 开始倒计时
            appoint_btn:setEnabled(false)
            self.scheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update_time), 1 , false)
        end
    end


    local showPanel = self.root:getChildByName("Panel_8")
    local iconid
    local show = ccui.ImageView:create()
    show:setPosition( cc.p(showPanel:getContentSize().width/2,showPanel:getContentSize().height/2) )
    showPanel:addChild(show)

    if self.nData == nil then
        officerview_btn:setEnabled(false)
        iconid = self.cData.img_normal --self.cData.self.cData.
        
        self.root:getChildByName("text_xuni"):setString(g_tr("kworld_empty"))


        --[[self.openTimeTx = ccui.Text:create()
        self.openTimeTx:setFontName("cocostudio_res/simhei.ttf")
        self.openTimeTx:setFontSize(35)
        self.openTimeTx:setAnchorPoint(0.5,0.5)
        self.openTimeTx:setPosition( cc.p(self.root:getContentSize().width/2,self.root:getContentSize().height/2 - 25 ) ) 
        self.root:addChild(self.openTimeTx,1000)
        self.openTimeTx:enableOutline(cc.c4b(0, 0, 0,255), 1)]]
    else
        self.root:getChildByName("text_xuni"):setVisible(false)
        iconid = g_data.res_head[ tonumber(self.nData.avatar_id) ].bust_icon
        show:setScale(0.6)
    end

    show:loadTexture(g_resManager.getResPath(iconid))
    
    appoint_btn:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.nextAppTime and self.nextAppTime <= 0 then
                g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingSelPlayerLayer"):create(self.cData.type))
                self:close()
            else
                print("任命CD冷却。。。。。。")
            end
        end
    end)

    --皇帝不能换
    if self.cData.id == 1 then
        appoint_btn:setEnabled(false)
    end
    
    self:regBtnCallback(officerview_btn,function ()
        if self.nData then
            local playerInfoLayer = require("game.uilayer.map.mapPlayerInfoView")
            g_sceneManager.addNodeForUI(require("game.uilayer.map.mapPlayerInfoView"):create( tonumber(self.nData.id) ))
            --self:close()
        end
	end)

    --[[self:regBtnCallback(mail_btn,function()
        if self.nData then
            local pop = require("game.uilayer.mail.MailContentWritePop").new(false, self.nData.nick) 
            g_sceneManager.addNodeForMsgBox(pop)  
        end
    end)]]

    self:showList()
end

function kingAppointLayer:showList()

    local itemMode = cc.CSLoader:createNode("KingOfWar_Office_List.csb")
    
    local drop_ConfigData = g_data.drop[self.cData.add_buff]
    
    dump(self.cData)

    dump(drop_ConfigData)


    for _, buff in ipairs(self.cData.add_buff) do
        
        local dropConfig = g_data.drop[buff]

        

        local buffTempConfig = g_data.buff_temp[dropConfig.drop_data[1][2]]

        local buffId = buffTempConfig.buff_id

        local buffValue = buffTempConfig.buff_num

        local buffConfig = g_data.buff[buffId]
        
        print("buff",buff,buffId)
        
        local item = itemMode:clone()

        item:getChildByName("Text_1"):setString(g_tr(buffTempConfig.buff_desc))

        local str = ( buffConfig.buff_type == 1) and  string.format( "+%.2f%%",buffValue / 100 ) or "+" .. buffValue
        
        item:getChildByName("Text_2"):setString(str)

        self.list:pushBackCustomItem(item)

        --dump(buffConfig)

    end
    


    --[[if drop_ConfigData then
        for key, var in ipairs(drop_ConfigData.drop_data) do
            local buff_Config = g_data.buff_temp[ tonumber(var[2])]
            local item = itemMode:clone()
            local buffId = var[2]
            local buffConfig = g_data.buff_temp[buffId]
            --dump(buffConfig)

            item:getChildByName("Text_1"):setString(g_tr(buffConfig.buff_desc))
            item:getChildByName("Text_2"):setString("+" .. ( buffConfig.buff_num / 100 ) .. "%")
        

            self.list:pushBackCustomItem(item)
        end
    end]]


end


function kingAppointLayer:update_time()
    
    if self.nData == nil then
        return
    end

    self.nextAppTime = (  tonumber(self.nData.time) + FOUR_H ) - g_clock.getCurServerTime()
    self.root:getChildByName("Text_2"):setString( g_gameTools.convertSecondToString( self.nextAppTime ) )
    if self.nextAppTime <= 0 then
        if self.scheduler ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
            self.scheduler = nil
        end
        self.root:getChildByName("Button_1"):setEnabled(true)
        self.root:getChildByName("Text_2"):setString(self.cData.type == 1 and  g_tr("kwar_appoint") or g_tr("kwar_appointDown"))
    else
        self.root:getChildByName("Button_1"):setEnabled(false)
    end
end

function kingAppointLayer:onEnter()
    
end

function kingAppointLayer:onExit()
    if self.scheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler)
    end
end



return kingAppointLayer



