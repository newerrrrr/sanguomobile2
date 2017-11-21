local CityBattleFinish = class("CityBattleFinish",require("game.uilayer.base.BaseLayer"))
local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode"):GetInstance()

local m_Root = nil
function CityBattleFinish.Show()
    if m_Root == nil then
        local view = require("game.uilayer.cityBattle.CityBattleFinish"):create()
        g_sceneManager.addNodeForUI(view)
    else
        local nData = g_cityBattleInfoData.GetData()
        if nData then
            m_Root.nData = nData
            m_Root:_InitUI()
        end
    end
end

function CityBattleFinish:ctor()
    CityBattleFinish.super.ctor(self)
end

function CityBattleFinish:onEnter()
    self.nData = g_cityBattleInfoData.GetData()
    if self.nData then
        self:_InitUI()
    else
        self:close()
    end
end

function CityBattleFinish:_InitUI()
    self.layer = self:loadUI("guildwar1_main1_xin1.csb")
    self.root = self.layer:getChildByName("scale_node")
    
    local jfPanel = self.root:getChildByName("Panel_xx"):getChildByName("Panel_z1")
    jfPanel:getChildByName("Text_1"):setString(g_tr("kwar_pointstr"))
    
    local sdPanel = self.root:getChildByName("Panel_xx"):getChildByName("Panel_z3")
    sdPanel:getChildByName("Text_1"):setString(g_tr("kiNum"))

    local camp1 = self.nData.attack_camp
    jfPanel:getChildByName("Text_h1"):setString("0")--积分
    sdPanel:getChildByName("Text_h1"):setString("0")
    if camp1 and camp1 ~= 0 then
        local config = g_data.country_camp_list[camp1]
        self.root:getChildByName("Image_lianmtb1"):loadTexture(g_resManager.getResPath(config.camp_pic))
        jfPanel:getChildByName("Text_h1"):setString(tostring( math.floor( self.nData.attack_score) ))--积分
        sdPanel:getChildByName("Text_h1"):setString(tostring( math.floor( self.nData[string.format( "camp_%d_kill",camp1 )]) ))
    end

    local camp2 = self.nData.defend_camp
    jfPanel:getChildByName("Text_h2"):setString("0") --积分
    sdPanel:getChildByName("Text_h2"):setString("0")
    if camp2 and camp2 ~= 0 then
        local config = g_data.country_camp_list[camp2]
        self.root:getChildByName("Image_lianmtb2"):loadTexture(g_resManager.getResPath(config.camp_pic))
        jfPanel:getChildByName("Text_h2"):setString(tostring( math.floor( self.nData.defend_score) )) --积分
        sdPanel:getChildByName("Text_h2"):setString(tostring( math.floor( self.nData[string.format( "camp_%d_kill",camp2 )]) ))
    end
    
    local btn = self.root:getChildByName("Button_1")
    btn:addClickEventListener( function (sender)
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
        require("game.maplayer.changeMapScene").changeToHome()
    end )

    local winPanel = self.root:getChildByName("Panel_xx"):getChildByName("Panel_z4")
    winPanel:getChildByName("Text_1"):setString(g_tr("reInfo"))

    if self.nData.win_camp and self.nData.win_camp > 0 then
        if self.nData.win_camp == tonumber(camp1) then
            winPanel:getChildByName("Image_11"):setVisible(true)
            winPanel:getChildByName("Image_11_0_0"):setVisible(false)

            winPanel:getChildByName("Image_11_0"):setVisible(true)
            winPanel:getChildByName("Image_11_1"):setVisible(false)
        end

        if self.nData.win_camp == tonumber(camp2) then
            winPanel:getChildByName("Image_11"):setVisible(false)
            winPanel:getChildByName("Image_11_0_0"):setVisible(true)

            winPanel:getChildByName("Image_11_0"):setVisible(false)
            winPanel:getChildByName("Image_11_1"):setVisible(true)
        end
    end
    
    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuZhanChangHuiHeShengLiShiBai/Effect_KuaFuZhanChangHuiHeShengLiShiBai.ExportJson", "Effect_KuaFuZhanChangHuiHeShengLiShiBai")
	self.root:addChild(armature)
	armature:setPosition(cc.p(self.root:getContentSize().width*0.5,self.root:getContentSize().height*0.5))
    if self.nData.win_camp == g_PlayerMode.GetData().camp_id then
        animation:play("ShengLi")
	else
		animation:play("ShiBai")
    end

end

function CityBattleFinish:onExit()
    m_Root = nil
    CityBattleMode:AsyncGetRoundData()
end



return CityBattleFinish