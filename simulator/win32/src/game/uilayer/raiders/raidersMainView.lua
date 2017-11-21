local RaidersMainView = class("RaidersMainView", require("game.uilayer.base.BaseLayer"))

function RaidersMainView:ctor()
    RaidersMainView.super.ctor(self)
end

function RaidersMainView:onEnter()
    
    local playerData = g_PlayerMode.GetData()
    local plevel = playerData.level
    local playerInfoData = g_playerInfoData.GetData()
    local secretaryStatus = playerInfoData.secretary_status or 3

    if secretaryStatus == 0 then
        self:initUI()
    elseif secretaryStatus == 1 then
        self:selMilitary()
    elseif secretaryStatus == 2 then
        self:selInternal()
    end
end

function RaidersMainView:initUI()
    
    self.layer = self:loadUI("Raiders_main.csb")

    self.root = self.layer:getChildByName("scale_node")
    
    --需要帮助
    self.requiredHelpBtn = self.root:getChildByName("Button_1")
    --不需要帮助
    self.noRequiredHelpBtn = self.root:getChildByName("Button_2")
    --军事按钮
    self.militaryBtn = self.root:getChildByName("Button_3")
    self.militaryBtn:setVisible(false)
    --内政按钮
    self.internalBtn = self.root:getChildByName("Button_4")
    self.internalBtn:setVisible(false)

    self.titleTx = self.root:getChildByName("Text_2")
    self.titleTx:setString(g_tr("raiders_title_str1"))


    self.root:getChildByName("Image_5"):loadTexture(g_resManager.getResPath(1030061))

    self:regBtnCallback(self.requiredHelpBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        self:nextHelp()
	end)

    self:regBtnCallback(self.noRequiredHelpBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        self:noRequiredHelp()
	end)


    --g_itemTips.tipStr(self.militaryBtn,"说明","优：三项进度均超过70%　良：三项进度均超过50%　中：任意一项未超过50%")
    
    self:regBtnCallback(self.militaryBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_msgBox.show( g_tr("raiders_jsqr_str"),nil,nil,
        function ( eventtype )
            --确定
            if eventtype == 0 then 
                local function callback(result,msgData)
                    if (result == true) then
                        self:selMilitary()
                    end
                end
                g_sgHttp.postData("player_info/changeSecretaryStatus", { status = 1 }, callback)
            end
        end , 1)
	end)
    
    self:regBtnCallback(self.internalBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_msgBox.show( g_tr("raiders_nzqr_str"),nil,nil,
        function ( eventtype )
            --确定
            if eventtype == 0 then 
                local function callback(result,msgData)
                    if (result == true) then
                        self:selInternal()
                    end
                end
                g_sgHttp.postData("player_info/changeSecretaryStatus", { status = 2 }, callback)
            end
        end , 1)
	end)
end

function RaidersMainView:noRequiredHelp()
    RaidersMainView.trunOffThis( function (eventType)
        print("===========================",eventType)
        if eventType == 1 then
            self:close()
        end
    end )
end

function RaidersMainView:nextHelp()
    self.requiredHelpBtn:setVisible(false)
    self.noRequiredHelpBtn:setVisible(false)
    self.militaryBtn:setVisible(true)
    self.internalBtn:setVisible(true)
    self.titleTx:setString(g_tr("raiders_title_str2"))
end

--选择军事
function RaidersMainView:selMilitary()
    local view = require("game.uilayer.raiders.RaidersView"):create(1)
    g_sceneManager.addNodeForUI(view)

    self:close()
end

--选择内政
function RaidersMainView:selInternal()
    local view = require("game.uilayer.raiders.RaidersView"):create(2)
    g_sceneManager.addNodeForUI(view)

    self:close()
end

function RaidersMainView.trunOffThis(_callback)
    local layer = g_gameTools.LoadCocosUI("Raiders_integral_main.csb", 5)
    --self:loadUI("Raiders_integral_main")
    local root = layer:getChildByName("scale_node")
    local closeMask = layer:getChildByName("mask")
    closeMask:addTouchEventListener( function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            layer:removeFromParent()
        end
    end )
    
    local closeTx = root:getChildByName("Text_2_0")
    closeTx:setString(g_tr("clickhereclose"))

    local titleTx = root:getChildByName("Text_c2")
    titleTx:setString(g_tr("msgBox_system"))

    local btn1 = root:getChildByName("Button_1")
    btn1:getChildByName( "Text_4" ):setString(g_tr("msgBox_ok"))
    local btn2 = root:getChildByName("Button_2")
    btn2:getChildByName( "Text_4" ):setString(g_tr("msgBox_cancle"))
    --["msgBox_ok"] = "确认",
    --["msgBox_cancle"] = "取消",
    root:getChildByName("Text_1"):setString(g_tr("raiders_close_str1"))
    local modeTx = root:getChildByName("Text_1_0")
    g_gameTools.createRichText(modeTx,g_tr("raiders_close_str2"))

    btn1:addTouchEventListener( function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            
            local function callback(result,msgData)
                if (result == true) then
                    if _callback then
                        _callback(1)
                    end
                    require("game.uilayer.mainSurface.mainSurfaceChat").viewChangeShow()
                end
            end

            g_sgHttp.postData("player_info/changeSecretaryStatus", { status = 3 }, callback)

            --require("game.uilayer.mainSurface.mainSurfaceChat")

            layer:removeFromParent()
        end
    end)

    btn2:addTouchEventListener( function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            layer:removeFromParent()
        end
    end)
    
    g_sceneManager.addNodeForUI(layer)

end


return RaidersMainView