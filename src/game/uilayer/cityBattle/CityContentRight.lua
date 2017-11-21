local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode"):GetInstance()
local CityContentRight = class("CityContentRight",function ()
	return cc.CSLoader:createNode("citybattle_tech_contribute_content.csb")
end)

function CityContentRight:ctor()
    self.nData = g_PlayerMode.GetDonateData()
end

function CityContentRight:_InitUI()
	self.nameTx = self:getChildByName("Text_2")
    self.iconPic = self:getChildByName("tech_pic")
    self.lvTx = self:getChildByName("level"):getChildByName("Text_1")
    self.expBar = self:getChildByName("bg_LoadingBar"):getChildByName("LoadingBar")
    self.expTx = self:getChildByName("Text_time")
    self.dscTx = self:getChildByName("tech_info_text")
    if self.dscTx.rich == nil then
        self.dscTx.rich = g_gameTools.createRichText( self.dscTx )
    end
    self.expBarIcon = self:getChildByName("Image_3"):loadTexture(g_resManager.getResPath(g_data.item[12400].res_icon))
    self:getChildByName("Panel_contribute"):getChildByName("Panel_getStr"):getChildByName("text_tips_1"):setString(g_tr("city_battle_get"))
    self:getChildByName("Panel_contribute"):getChildByName("Panel_cishu"):getChildByName("text_tips_1"):setString(g_tr("city_battle_times"))


    self.resPanel1 = self:getChildByName("Panel_contribute"):getChildByName("panel_contribute_3")
    self.resPanel2 = self:getChildByName("Panel_contribute"):getChildByName("panel_contribute_2")
    self.resPanel3 = self:getChildByName("Panel_contribute"):getChildByName("panel_contribute_1")
end

function CityContentRight:Show(nData,scienceType)
    self.nData = g_PlayerMode.GetDonateData()
    self:_InitUI()
    local science_type = nData and nData.science_type or scienceType
    local science_level = nData and nData.science_level or 0
    local configList = CityBattleMode:GetFilterScienceConfig()
    local config = configList[tostring(science_type)][ tonumber(science_level)]
    if config == nil then
        config = configList[tostring(science_type)][1]
    end
    local picpath = g_resManager.getResPath(config.icon_img)
    local exp = nData and nData.science_exp or 0
    self.nameTx:setString(g_tr(config.name))
    self.iconPic:loadTexture(picpath)
    self.lvTx:setString( "Lv."..tostring( science_level ) )
    
    local function _load(_panel,_consume,_drop,_exp,_index)
        local item = require("game.uilayer.common.DropItemView").new(_consume[1],_consume[2],_consume[3])
        _panel:getChildByName("pic_cost"):loadTexture(item:getIconPath())
        _panel:getChildByName("btn_contribute"):getChildByName("text"):setString(tostring(_consume[3]))
        local drop = _drop[1]
        local item = require("game.uilayer.common.DropItemView").new(drop[1],drop[2],drop[3])
        _panel:getChildByName("pic_rewards_1"):loadTexture(item:getIconPath())
        _panel:getChildByName("text_num_1"):setString(tostring(drop[3]))
        _panel:getChildByName("text_num_2"):setString(tostring(_exp))

        local expIcon = g_resManager.getResPath(g_data.item[12400].res_icon)
        _panel:getChildByName("pic_rewards_2"):loadTexture(expIcon)
        
        local timesTx = _panel:getChildByName("Text_cs1")
        local maxTimes = g_data.country_basic_setting[_index].data
        local times = self.nData[ string.format("button%d_counter",_index) ]
        timesTx:setString(  (maxTimes - times) .. "/"..maxTimes)
        if (maxTimes - times) <= 0 then
            _panel:getChildByName("btn_contribute"):setEnabled(false)
        end
    end
    
    for i = 1, 3 do
        local consume = config[string.format("button%d_consume",i)]
        local drop = g_data.drop[tonumber(config[string.format("button%d_drop",i)][1])].drop_data
        local exp = config[string.format("button%d_exp",i)]
        _load(self["resPanel"..i],consume,drop,exp,i)
    end
    
    self:getChildByName("Panel_contribute"):setVisible(true)
    self.expTx:setVisible(true)
    self:getChildByName("Image_2"):setVisible(true)
    self:getChildByName("bg_LoadingBar"):setVisible(true)
    self.expBarIcon:setVisible(true)
    self:getChildByName("tech_title_text"):setString(g_tr("nextLevelEffect"))
    self:getChildByName("tech_title_text_0"):setVisible(false)
    local nextConfig
    if config.level == config.max_level then
        nextConfig = config
        self.expTx:setVisible(false)
        self:getChildByName("Image_2"):setVisible(false)
        self:getChildByName("bg_LoadingBar"):setVisible(false)
        self.expBarIcon:setVisible(false)
        self:getChildByName("tech_title_text"):setString(g_tr("generalSkillLevelMax"))
        self:getChildByName("Panel_contribute"):setVisible(false)
        self:getChildByName("tech_title_text_0"):setVisible(true)
        self:getChildByName("tech_title_text_0"):setString(g_tr("generalSkillLevelMax"))
    else
        nextConfig = configList[tostring(config.science_type)][science_level + 1]
        self.expBar:setPercent( exp / nextConfig.levelup_exp * 100 )
        self.expTx:setString( string.format("%.2f%%",exp / nextConfig.levelup_exp * 100) )
    end

    local value = nextConfig.num_value
    if nextConfig.num_type == 1 then
        value = value / 100
    end

   
    self.dscTx:setString( g_tr(config.description,{ num = value}) )
    self.dscTx.rich:setRichText(g_tr(config.description,{ num = value}))

    local function _send(sType,sendType)
        local function callback(result,msgData)
            g_busyTip.hide_1()
            if result == true then
                local newData = msgData.CityBattleScience
                CityBattleMode:UpdateServerData(newData)
                require("game.uilayer.cityBattle.CityTechnologyLayer").UpdateNode()
                self:Show(newData)
            end
        end
        g_busyTip.show_1()
        g_sgHttp.postData("City_Battle/scienceDonate",{ scienceType = sType,btn = sendType }, callback,true)
    end

    local btn1 = self.resPanel1:getChildByName("btn_contribute")
    btn1.sType = config.science_type
    if btn1.isTouch == nil then
        btn1:addClickEventListener(function (sender)
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            _send(sender.sType,1)
        end)
        btn1.isTouch = true
    end

    local btn2 = self.resPanel2:getChildByName("btn_contribute")
    btn2.sType = config.science_type
    if btn2.isTouch == nil then
        btn2:addClickEventListener(function (sender)
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            _send(sender.sType,2)
        end)
        btn2.isTouch = true
    end

    local btn3 = self.resPanel3:getChildByName("btn_contribute")
    btn3.sType = config.science_type
    if btn3.isTouch == nil then
        btn3:addClickEventListener(function (sender)
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            _send(sender.sType,3)
        end)
        btn3.isTouch = true
    end

end


return CityContentRight