local CityDoorReport = class("CityDoorReport",require("game.uilayer.base.BaseLayer"))
local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode"):GetInstance()
local m_Root = nil

function CityDoorReport.Show()
    if m_Root == nil then
        local view = require("game.uilayer.cityBattle.CityDoorReport"):create()
        g_sceneManager.addNodeForUI(view)
    else
        --g_cityBattleInfoData.GetData().status = g_cityBattleInfoData.StatusType.STATUS_FINISH
        local nData = g_cityBattleInfoData.GetData()
        local topPlayrs = g_cityBattleInfoData.GetTopPlayerData()
        if nData and topPlayrs then
            m_Root.nData = nData
            m_Root.topPlayrs = topPlayrs
            m_Root:_InitUI()
        end
    end
end


function CityDoorReport:ctor()
    CityDoorReport.super.ctor(self)
    self.campId = g_PlayerMode.GetData().camp_id
    self.nData = nil
    self.topPlayrs = nil
    self.closeTime = 10
    self.aminStr = ""
    self.isShowAmin = false
    m_Root = self
end

function CityDoorReport:onEnter()
    
    self.nData = g_cityBattleInfoData.GetData()
    self.topPlayrs = g_cityBattleInfoData.GetTopPlayerData()
    if self.nData and self.topPlayrs then
        --dump(self.nData)
        --dump(self.topPlayrs)
        self:_InitUI()
    else
        self:close()
    end
    
end

function CityDoorReport:_InitUI()
    if self.nData.attack_camp ~= self.campId and self.nData.defend_camp ~= self.campId then
        self:_OneWiner()
    else
        self:_TwoWiner()
    end
end
--城门战最后一名
function CityDoorReport:_OneWiner()
    if self.layer == nil then
        self.layer = self:loadUI("guildwar1_main1_xin2.csb")
        self.root = self.layer:getChildByName("scale_node")
        self.backBtn = self.root:getChildByName("Button_1")
        self.backBtn:getChildByName("Text_5"):setString(g_tr("closed"))
        self.backBtn:addClickEventListener( function ( sender )
            self:close()
            require("game.maplayer.changeMapScene").changeToHome()
        end)
    end
    
    self.aminStr = "ShiJianOver"
    local battleStatus = g_cityBattleInfoData.GetData().status
    if battleStatus == g_cityBattleInfoData.StatusType.STATUS_CLAC_SEIGE or battleStatus == g_cityBattleInfoData.StatusType.STATUS_CLAC_MELEE then
        self.backBtn:setVisible(false)
    else
        self.backBtn:setVisible(true)
        self.isShowAmin = true
        local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuYinZhang/Effect_KuaFuYinZhang.ExportJson", "Effect_KuaFuYinZhang")
        self.root:addChild(armature)
	    armature:setPosition(cc.p(self.root:getContentSize().width*0.5,self.root:getContentSize().height * 0.5))
        animation:play(self.aminStr)
    end

    if self.campId and self.campId ~= 0 then
        local config = g_data.country_camp_list[self.campId]
        self.root:getChildByName("Image_lianmtb1"):loadTexture(g_resManager.getResPath(config.camp_pic))
    end

    local list = self.root:getChildByName("Panel_xx"):getChildByName("ListView_1")
    list:removeAllChildren()
    local mode = cc.CSLoader:createNode("guildwar1_main1_xin2_list2.csb")
    if self.topPlayrs then
        local players = self.topPlayrs[tostring(self.campId)] or {} 

        for key, var in ipairs(players) do
            local node = mode:clone()
            node:getChildByName("Image_5_0"):loadTexture( g_resManager.getResPath(g_data.res_head[ tonumber(var.avatar_id)].head_icon) )
            node:getChildByName("Text_name"):setString( var.nick )
            node:getChildByName("Text_3"):setString(var.score)
            node:getChildByName("Text_sz"):setString(tostring(key))
            list:pushBackCustomItem(node)
        end
    end

    local closeTx = self.root:getChildByName("Text_3")
    closeTx:setString( g_tr("city_battle_close_time",{ num = self.closeTime}))
    if self.rich == nil then
        self.rich = g_gameTools.createRichText( closeTx )
    end
    self.rich:setRichText(g_tr("city_battle_close_time",{ num = self.closeTime}))

    if self.timer then
        self:unschedule(self.timer)
        self.timer = nil
    end

    if self.timer == nil then
        self.timer = self:schedule(handler(self,self._UpdateCloseTime),1)
    end

    
    --[[
        local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuYinZhang/Effect_KuaFuYinZhang.ExportJson", "Effect_KuaFuYinZhang")
        self.root:addChild(armature)
	    armature:setPosition(cc.p(self.root:getContentSize().width*0.5,self.root:getContentSize().height * 0.5))
        animation:play("ShiJianOver")
    ]]
end

--城门战前两名（或者攻守防）
function CityDoorReport:_TwoWiner()
    if self.layer == nil then
        self.layer = self:loadUI("guildwar1_main1.csb")
        self.root = self.layer:getChildByName("scale_node")
        self.backBtn = self.root:getChildByName("Button_1")
        self.backBtn:getChildByName("Text_5"):setString(g_tr("closed"))
        self.backBtn:addClickEventListener( function ( sender )
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:close()
            local battleStatus = g_cityBattleInfoData.GetData().status
	        if battleStatus == g_cityBattleInfoData.StatusType.STATUS_FINISH then
		        require("game.maplayer.changeMapScene").changeToHome()
            else
                require("game.mapcitybattle.changeMapScene").reloadMap()
	        end
        end)
    end
    
    self.aminStr = "JiPo"
    local battleStatus = g_cityBattleInfoData.GetData().status
    if battleStatus == g_cityBattleInfoData.StatusType.STATUS_CLAC_SEIGE or battleStatus == g_cityBattleInfoData.StatusType.STATUS_CLAC_MELEE then
        self.backBtn:setVisible(false)
    else
        self.backBtn:setVisible(true)
        self.isShowAmin = true
        local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuYinZhang/Effect_KuaFuYinZhang.ExportJson", "Effect_KuaFuYinZhang")
        self.root:addChild(armature)
	    armature:setPosition(cc.p(self.root:getContentSize().width*0.5,self.root:getContentSize().height * 0.5))
        animation:play(self.aminStr)
    end
    
    self.root:getChildByName("Text_mc1_0"):setString(g_tr("city_battle_paihang")..g_tr("kwar_pointrank") )
    self.root:getChildByName("Text_mc1_0_0"):setString(g_tr("city_battle_paihang")..g_tr("kwar_pointrank") )

    local attackPlayes = {}
    if self.nData.attack_camp and self.nData.attack_camp ~= 0 then
        local config = g_data.country_camp_list[self.nData.attack_camp]
        self.root:getChildByName("Image_lianmtb1"):loadTexture(g_resManager.getResPath(config.camp_pic))
        self.root:getChildByName("Text_mc1"):setString(g_tr(config.camp_name))
        if self.topPlayrs then
            attackPlayes = self.topPlayrs[tostring(self.nData.attack_camp)] or {}
        end
    else
        self.root:getChildByName("Text_mc1"):setString("null")
    end
    
    local defendPlayes = {}
    if self.nData.defend_camp and self.nData.defend_camp ~= 0 then
        local config = g_data.country_camp_list[self.nData.defend_camp]
        self.root:getChildByName("Image_lianmtb2"):loadTexture(g_resManager.getResPath(config.camp_pic))
        self.root:getChildByName("Text_mc2"):setString(g_tr(config.camp_name))
        if self.topPlayrs then
            defendPlayes = self.topPlayrs[tostring(self.nData.defend_camp)] or {}
        end
    else
        self.root:getChildByName("Text_mc2"):setString("null")
    end
    
    local closeTx = self.root:getChildByName("Text_3")
    closeTx:setString( g_tr("city_battle_close_time",{ num = self.closeTime}))
    if self.rich == nil then
        self.rich = g_gameTools.createRichText( closeTx )
    end
    self.rich:setRichText(g_tr("city_battle_close_time",{ num = self.closeTime}))

    if self.timer then
        self:unschedule(self.timer)
        self.timer = nil
    end

    if self.timer == nil then
        self.timer = self:schedule(handler(self,self._UpdateCloseTime),1)
    end
    
    local list1 = self.root:getChildByName("ListView_1")
    list1:removeAllChildren()
    local mode1 = cc.CSLoader:createNode("guildwar1_main1_list1.csb")
    local list2 = self.root:getChildByName("ListView_2")
    list2:removeAllChildren()
    local mode2 = cc.CSLoader:createNode("guildwar1_main1_list2.csb")

    for key, var in ipairs(attackPlayes) do
        local node = mode1:clone()
        local panel = node:getChildByName("Panel_1")
        panel:getChildByName("Image_5_0"):loadTexture( g_resManager.getResPath(g_data.res_head[ tonumber(var.avatar_id)].head_icon) )
        panel:getChildByName("Text_name"):setString( var.nick )
        panel:getChildByName("Text_3"):setString(var.kill_soldier)
        panel:getChildByName("Text_sz"):setString(tostring(key))
        list1:pushBackCustomItem(node)
         
    end

    for key, var in ipairs(defendPlayes) do
        local node = mode2:clone()
        local panel = node:getChildByName("Panel_1")
        panel:getChildByName("Image_5_0"):loadTexture( g_resManager.getResPath(g_data.res_head[ tonumber(var.avatar_id)].head_icon) )
        panel:getChildByName("Text_name"):setString( var.nick )
        panel:getChildByName("Text_3"):setString(var.kill_soldier)
        panel:getChildByName("Text_sz"):setString(tostring(key))
        list2:pushBackCustomItem(node)
    end

    

    --[[
        local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuYinZhang/Effect_KuaFuYinZhang.ExportJson", "Effect_KuaFuYinZhang")
        self.root:addChild(armature)
	    armature:setPosition(cc.p(self.root:getContentSize().width*0.5,self.root:getContentSize().height * 0.5))
        animation:play("ShiJianOver")
    ]]
end

function CityDoorReport:_UpdateCloseTime()
    
    self.closeTime = self.closeTime - 1
    if self.closeTime <= 0 then
        local battleStatus = g_cityBattleInfoData.GetData().status
        if battleStatus == g_cityBattleInfoData.StatusType.STATUS_CLAC_SEIGE or battleStatus == g_cityBattleInfoData.StatusType.STATUS_CLAC_MELEE then
            self.backBtn:setVisible(false)
            self.closeTime = 10
        else
            if not self.backBtn:isVisible() then
                self.backBtn:setVisible(true)
                self.rich:setVisible(false)
            end
            self.closeTime = 0
            
            if not self.isShowAmin then
                local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuYinZhang/Effect_KuaFuYinZhang.ExportJson", "Effect_KuaFuYinZhang")
                self.root:addChild(armature)
	            armature:setPosition(cc.p(self.root:getContentSize().width*0.5,self.root:getContentSize().height * 0.5))
                animation:play(self.aminStr)
            end

            if self.timer then
                self:unschedule(self.timer)
                self.timer = nil
            end

	    end
    end
    self.rich:setRichText(g_tr("city_battle_close_time",{ num = self.closeTime}))
end


function CityDoorReport:onExit()
    m_Root = nil
    CityBattleMode:AsyncGetRoundData()
end




return CityDoorReport