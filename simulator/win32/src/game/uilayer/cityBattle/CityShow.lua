local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode"):GetInstance()
local CityShow = class("CityShow", require("game.uilayer.base.BaseLayer"))
local m_Root = nil
function CityShow:ctor(cityId)
    CityShow.super.ctor(self)
    m_Root = nil
    self.cityId = cityId
    self.mCampId = g_PlayerMode.GetData().camp_id
    self.belongCampID = CityBattleMode:GetCityCamp(self.cityId)
    self.config = g_data.country_city_map[self.cityId]
    self.canBattleCity = CityBattleMode:GetCanSignCity(self.cityId)
    self.prepareData = CityBattleMode:GetPrepareInfo()
    self.scienceData = nil
    self.upTime = 0
    self.nowStatus = self.prepareData.status
    m_Root = self
end

function CityShow:onEnter()

    if self.mCampId ~= self.belongCampID then
        self:_InitUI()
    else
        CityBattleMode:Req( true , function ()
            self.scienceData = CityBattleMode:GetServerData()
            self:_InitUI()
        end  ) 
    end
end

function CityShow:_InitUI()

    
    --dump(self.scienceData)

    self.layer = self:loadUI("CityBattle_panel_01.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.root:getChildByName("Text_1"):setString(g_tr(self.config.ctiy_name))
    
    local close_btn = self.root:getChildByName("close_btn")
    close_btn:addClickEventListener( function ( sender )
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
    end)

    self.root:getChildByName("Image_wenh"):addClickEventListener(function ()
        require("game.uilayer.common.HelpInfoBox"):show( 57 )
    end)


    local buffBtn = self.root:getChildByName("Button_3")
    local capital = self.config.capital
    if capital > 0 then
        local countryName = g_tr( g_data.country_camp_list[capital].camp_name )
        buffBtn:getChildByName("Text_6"):setString( countryName .. g_tr( "goodsType3" ) )
        g_itemTips.tipStr( buffBtn , countryName .. g_tr( "goodsType3" ), g_tr( "city_battle_buff_desc",{ country = countryName } ) )
    else
        buffBtn:setVisible( false )
    end

    local bg = self.root:getChildByName("Panel_bj1"):getChildByName("Image_2")
    bg:loadTexture( g_resManager.getResPath(self.config.city_bg_pic) )
    local shop = bg:getChildByName("Shop")
    shop:getChildByName("Image_3"):getChildByName("Text_4"):setString(g_tr(self.config.ctiy_name) .. g_tr("city_battle_shop_str"))
    shop:addClickEventListener(function ()
        local view = require("game.uilayer.cityBattle.CityShop"):create(self.cityId)
        g_sceneManager.addNodeForUI(view)
    end)
    local shopx = tonumber(self.config.shop_position[1])
    local shopy = tonumber(self.config.shop_position[2])
    shop:setPosition( cc.p(shopx,shopy))

    local shop1 = self.root:getChildByName("Button_jr_0")
    shop1:addClickEventListener(function ()
        local view = require("game.uilayer.cityBattle.CityShop"):create(self.cityId)
        g_sceneManager.addNodeForUI(view)
    end)
    shop1:getChildByName("Text_2"):setString(g_tr("city_battle_shop_tosee"))

    local signBtn = self.root:getChildByName("Button_jr")

    if self.mCampId == self.belongCampID then
        shop1:setVisible(false)
        signBtn:getChildByName("Text_2"):setString(g_tr("city_battle_city_def"))
        self:_Show1()
    else
        shop:setVisible(false)
        signBtn:getChildByName("Text_2"):setString(g_tr("city_battle_city_atk"))
        self:_Show2()
    end
    
    if self.prepareData.status == g_Consts.CityBattleStatus.DOING then
        local signData = CityBattleMode:GetSignData()
        dump(signData)
        if signData ~= nil and signData ~= false then
            signBtn:setEnabled( tonumber(signData.city_id) == tonumber(self.cityId) )
        else
            signBtn:setEnabled(false)
        end
        signBtn:getChildByName("Text_2"):setString(g_tr("enterWarfield"))
    end

    signBtn:addClickEventListener(function (sender)
        

        if self.mCampId ~= self.belongCampID then 
            local canBattle = CityBattleMode:GetCanSignCity(self.cityId)
            if not canBattle then
                local str = CityBattleMode:GetCanSignCityCondition(self.cityId)
                g_msgBox.show( g_tr("city_sign_condition",{ citys = str }) )
                return
            end
        end

        if self.prepareData then
            if self.prepareData.status == g_Consts.CityBattleStatus.DOING then
                CityBattleMode:GoToBattleWorld()
                return
            end

            if self.prepareData.status == g_Consts.CityBattleStatus.NOT_START or self.prepareData.status == g_Consts.CityBattleStatus.FINISH then
                --报名未开始
                g_airBox.show(g_tr("city_battle_sign") .. g_tr("city_battle_sign_noopen"))
                return
            end

            if self.prepareData.status ~= g_Consts.CityBattleStatus.SIGN_FIRST and self.prepareData.status ~= g_Consts.CityBattleStatus.SIGN_NORMAL then
                --报名结束
                g_airBox.show(g_tr("city_battle_sign") .. g_tr("zhuanpanOver"))
                return
            end
          
        end
        
        if self.time - g_clock.getCurServerTime() <= 0 then
            print("状态过度中，请稍后")
        else
            local view = require("game.uilayer.cityBattle.CitySign"):create(self.cityId)
            g_sceneManager.addNodeForUI(view)
        end

    end)

    self.timeTx = self.root:getChildByName("Text_djs2")

    if self.mCampId == 0 or self.mCampId == nil then
        signBtn:setVisible(false)
    end


    self:_UpdateTimeTx()
    self:_UpdateOverTime()
    self:schedule(handler(self,self._UpdateOverTime),1)
    
end

function CityShow:_UpdateTimeTx()
    self.startTime,self.endTime = CityBattleMode:GetSignOverTime()
    self.time = nil
    
    --下一次报名时间
    if self.endTime == nil then
        local zhuhouStartTime = self.startTime - ( tonumber(g_data.country_basic_setting[8].data) * 3600 )
        --诸侯报名倒计时
        if g_clock.getCurServerTime() > zhuhouStartTime then
            self.root:getChildByName("Text_djs1"):setString(g_tr("city_battle_zhuhou_sign"))
            self.time = self.startTime
        else
            self.root:getChildByName("Text_djs1"):setString(g_tr("city_battle_zhuhou_signtime"))
            self.time = zhuhouStartTime
        end
        
    --报名未结束
    elseif self.startTime == nil then
        self.root:getChildByName("Text_djs1"):setString(g_tr("city_battle_city_over_time"))
        self.time = self.endTime
    end
end

function CityShow:_GetCamp()
    local str = ""
    if self.belongCampID == 1 then  str = g_tr("city_battle_camp1") end
    if self.belongCampID == 2 then  str = g_tr("city_battle_camp2") end
    if self.belongCampID == 3 then  str = g_tr("city_battle_camp3") end
    if self.belongCampID == nil then  str = g_tr("city_battle_city_nobelong") end
    return str
end

--我方城池l
function CityShow:_Show1()
    self.root:getChildByName("Panel_nr"):setVisible(false)
    local panel = self.root:getChildByName("Panel_m")
    panel:setVisible(true)
    panel:getChildByName("Text_1"):setString( g_tr("city_battle_city_title") )
    panel:getChildByName("Text_1_0"):setString( self:_GetCamp() )
    panel:getChildByName("Text_zl"):setString( g_tr("city_battle_city_reward") )
    local list = panel:getChildByName("ListView_1")
    local dropId = self.config.drop
    local drop = g_data.drop[dropId]
    if drop and drop.drop_data then
        for key, var in ipairs(drop.drop_data) do
            local t = var[1]
            local id = var[2]
            local num = var[3]

            if tonumber(id) == 12300 then
                num = self:_GetJunZiBuffNum(num)
            end

            local icon = require("game.uilayer.common.DropItemView").new(t,id,num)
            icon:setScale(0.6)
            icon:enableTip()
            list:pushBackCustomItem(icon)
        end
    end

    local camp_config = g_data.country_camp_list[self.belongCampID]
    if camp_config then
        local camp_path = g_resManager.getResPath(camp_config.camp_pic)
        panel:getChildByName("Image_2"):loadTexture(camp_path)
    end

    local getBtn = panel:getChildByName("Button_1")
    local btnTx = getBtn:getChildByName("Text_2")
    btnTx:setString(g_tr("commonAwardGeted"))
    local giftData = require("game.uilayer.cityBattle.CityMap").GetGiftData()[tostring(self.cityId)]
    getBtn:setEnabled(false)

    if giftData then
        if g_clock.isSameDay( giftData , g_clock.getCurServerTime() ) then
            getBtn:setEnabled(false)
            btnTx:setString(g_tr("commonAwardGeted"))
        else
            getBtn:setEnabled(true) 
            btnTx:setString(g_tr("commonAwardGet"))
        end
        --getBtn:setEnabled( not g_clock.isSameDay( giftData , g_clock.getCurServerTime() ))
    end

    getBtn:addClickEventListener(function (sender)
        local function onRecv(result,msgData)
            g_busyTip.hide_1()
            if result == true then
                g_airBox.show(g_tr("fetchSucess"))
                btnTx:setString(g_tr("commonAwardGeted"))
                getBtn:setEnabled(false)
                require("game.uilayer.cityBattle.CityMap").GetGiftData()[tostring(self.cityId)] = nil
                require("game.uilayer.cityBattle.CityMap").UpdateGift()
            end
        end
        g_busyTip.show_1()
        g_sgHttp.postData("city_battle/output", { city_id = self.cityId }, onRecv, true)
    end)

    

end
--别方城池
function CityShow:_Show2()
    self.root:getChildByName("Panel_m"):setVisible(false)
    local panel = self.root:getChildByName("Panel_nr")
    panel:setVisible(true)
    panel:getChildByName("Text_g1"):setString( self:_GetCamp() )
    panel:getChildByName("Text_zl"):setString( g_tr("city_battle_city_reward") )
    panel:getChildByName("Text_3"):setString(g_tr("city_battle_city_title"))

    local dropId = self.config.drop
    local drop = g_data.drop[dropId]
    local list = panel:getChildByName("ListView_2")
    if drop and drop.drop_data then
        for key, var in ipairs(drop.drop_data) do
            local t = var[1]
            local id = var[2]
            local num = var[3]
            local icon = require("game.uilayer.common.DropItemView").new(t,id,num)
            icon:enableTip()
            list:pushBackCustomItem(icon)
        end
    end

    if self.belongCampID then
        local camp_config = g_data.country_camp_list[self.belongCampID]
        if camp_config then
            local camp_path = g_resManager.getResPath(camp_config.camp_pic)
            panel:getChildByName("Image_qizi"):loadTexture(camp_path)
        end
    end

end

function CityShow:_UpdateOverTime()
    
    local time = self.time - g_clock.getCurServerTime()
    if time <= 0 then
        time = 0
        if os.time() > ( self.upTime + 10 ) then
            self.upTime = os.time()
            CityBattleMode:GetRoundData()
            local newPrepare = CityBattleMode:GetPrepareInfo()
            if tonumber(self.nowStatus) ~= tonumber(newPrepare.status) then
                self.nowStatus = newPrepare.status
                self:_UpdateTimeTx()
            end
        end
    end

    self.timeTx:setString(g_gameTools.convertSecondToString(time))

    local statusStr = 
    {
        [g_Consts.CityBattleStatus.SELECT_PLAYER] = g_tr("city_battle_status4"),
        [g_Consts.CityBattleStatus.SELECT_PLAYER_FINISH] = g_tr("city_battle_status5"),
        [g_Consts.CityBattleStatus.DOING] = g_tr("city_battle_status6"),
    }
    local _p = CityBattleMode:GetPrepareInfo()
    if _p then
        local str = statusStr[tonumber( _p.status )] 
        if str then 
            self.root:getChildByName("Text_djs1"):setString(g_tr("city_battle_status_str1"))
            self.timeTx:setString(str)
        end
    end

end

function CityShow.UpdateTimeTx()
    if m_Root then
        CityBattleMode:GetRoundData()
        m_Root:_UpdateTimeTx()
        --print("1111111")
    end
end

--获取军资BUFF加成后的军资数量
function CityShow:_GetJunZiBuffNum(num)
    local _num = num
    local scienceType = 20
    local science = self.scienceData[tostring(scienceType)]
    if science then
        local lv = science.science_level
        if lv <= 0 then
            return _num
        else
            local config = CityBattleMode:GetFilterScienceConfig()
            local buff = config[tostring(scienceType)][tonumber(lv)].num_value
            buff = buff / 10000
            _num = _num * ( 1 +  buff )
            return _num
        end
    end
    return _num
end


function CityShow:onExit()
    m_Root = nil
end

return CityShow

--endregion
