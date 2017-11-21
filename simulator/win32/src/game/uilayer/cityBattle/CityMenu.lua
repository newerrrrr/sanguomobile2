local CityMenu = class("CityMenu", require("game.uilayer.base.BaseLayer"))

local m_Root = nil

 function CityMenu:ctor()
    CityMenu.super.ctor(self)
    m_Root = self
    self:_InitUI()
 end


 function CityMenu:_InitUI()
    self.layer = g_gameTools.LoadCocosUI("CityBattle_02.csb",9)
    self:addChild(self.layer)
    self.root = self.layer:getChildByName("scale_node")
    
    local closeBtn = self.root:getChildByName("Button_dituanniu1")
    closeBtn:getChildByName("Text_16"):setString(g_tr("city_battle_shop_goback"))
    closeBtn:addClickEventListener( handler(self,self._MapClose) )
    
    local countyTechnologyBtn = self.root:getChildByName("Button_1")
    countyTechnologyBtn:getChildByName("Text_17"):setString(g_tr("city_battle_map_menu1"))
    countyTechnologyBtn:addClickEventListener( handler(self,self._TouchTechnology) )
    --红点
    countyTechnologyBtn:getChildByName("Image_4"):setVisible(false)
    self.tBtn = countyTechnologyBtn

    local countyTaskBtn = self.root:getChildByName("Button_2")
    countyTaskBtn:getChildByName("Text_17"):setString(g_tr("city_battle_map_menu2"))
    countyTaskBtn:addClickEventListener( handler(self,self._TouchTask) )

    self.root:getChildByName("Button_3"):addClickEventListener( handler(self,self._TouchTest) )

    self.root:getChildByName("Button_3"):setVisible(false)
    self.root:getChildByName("Button_4"):setVisible(false)



    local function _ShowRedP()
        local donateData = g_PlayerMode.GetDonateData()
        if donateData.button1_counter <= 0 and donateData.button2_counter <= 0 and donateData.button3_counter <= 0 then 
            countyTechnologyBtn:getChildByName("Image_4"):setVisible(true)
        else
            countyTechnologyBtn:getChildByName("Image_4"):setVisible(true)
        end
        --dump(donateData)        
    end

    g_PlayerMode.RequestDonateData_Async()

 end

 --科技
 function CityMenu:_TouchTechnology(sender)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local view = require("game.uilayer.cityBattle.CityTechnologyLayer"):create()
    g_sceneManager.addNodeForUI(view)
 end

 --任务
 function CityMenu:_TouchTask(sender)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

    if not g_AllianceMode.getSelfHaveAlliance() then
        g_airBox.show(g_tr("battleHallNoAlliance"))
        return
    end  
    local view = require("game.uilayer.task.TaskWeekBattle"):create() 
    g_sceneManager.addNodeForUI(view)
 end

 function CityMenu:_TouchTest(sender)
    --local view = require("game.uilayer.cityBattle.CityBattleFinish").Show()
    require("game.uilayer.cityBattle.CityDoorReport").Show()
    require("game.uilayer.cityBattle.CityDoorReport").Show()
    require("game.uilayer.cityBattle.CityDoorReport").Show()
    require("game.uilayer.cityBattle.CityDoorReport").Show()
    require("game.uilayer.cityBattle.CityDoorReport").Show()
    require("game.uilayer.cityBattle.CityDoorReport").Show()
    
    --require("game.uilayer.cityBattle.CityShop"):create() 
    --g_sceneManager.addNodeForUI(view)
 end

 function CityMenu:_MapClose()
     require("game.uilayer.cityBattle.CityMap").Remove()
 end


 function CityMenu:_UpdateRP()
    local donateData = g_PlayerMode.GetDonateData()
    if donateData.button1_counter <= 0 and donateData.button2_counter <= 0 and donateData.button3_counter <= 0 then 
        self.tBtn:getChildByName("Image_4"):setVisible(true)
    else
        self.tBtn:getChildByName("Image_4"):setVisible(false)
    end
 end

function CityMenu.UpdateRP()
    if m_Root then
        m_Root:_UpdateRP()
    end
 end

 function CityMenu:onExit()
    m_Root = nil
 end


return CityMenu