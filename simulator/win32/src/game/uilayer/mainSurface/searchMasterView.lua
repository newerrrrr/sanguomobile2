--region NewFile_1.lua
--Author : luqingqing
--Date   : 2016/3/18
--此文件由[BabeLua]插件自动生成

local searchMasterView = class("searchMasterView", require("game.uilayer.base.BaseLayer"))

function searchMasterView:ctor()
    searchMasterView.super.ctor(self)

    self.layer = self:loadUI("monster_resources_main.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.Text_c2 = self.root:getChildByName("Text_c2")
    self.ListView_1 = self.root:getChildByName("ListView_1")
    self.Text_dj = self.root:getChildByName("Text_dj")
    self.Text_hd = self.root:getChildByName("Text_hd")
    self.Image_jh = self.root:getChildByName("Image_jh")
    self.Slider_1 = self.root:getChildByName("Slider_1")
    self.Image_jh_0 = self.root:getChildByName("Image_jh_0")
    self.Text_sz1 = self.root:getChildByName("Text_sz1")
    self.Text_sz2 = self.root:getChildByName("Text_sz2")
    self.Button_1 =self.root:getChildByName("Button_1")
    self.Text_1 = self.root:getChildByName("Text_1")

    self.Button_2 = self.root:getChildByName("Button_2")
    self.Text_1_0_2 = self.Button_2:getChildByName("Text_1_0")
    self.Button_3 = self.root:getChildByName("Button_3")
    self.Text_1_0_3 = self.Button_3:getChildByName("Text_1_0")
    self.Text_1_0_2:setString(g_tr("searchMon"))
    self.Text_1_0_3:setString(g_tr("searchBoss"))

    self.Panel_cc1 = self.root:getChildByName("Panel_cc1")
    self.Button_cc = self.Panel_cc1:getChildByName("Button_cc")
    self.Panel_cc1:setVisible(false)

    self.Button_sous = self.root:getChildByName("Button_sous")
    self.Text_1_0_5 = self.Button_sous:getChildByName("Text_1_0")
    self.Image_2 = self.Button_sous:getChildByName("Image_2")
    self.Text_1_0_0 = self.Button_sous:getChildByName("Text_1_0_0")
    self.Text_1_0_0:setString(g_data.starting[84].data)
    self.Text_1_0_5:setString(g_tr("changeContent"))
    self.Button_sous:setVisible(false)

    self.Text_1:setString(g_tr("changeContent"))
    self.root:getChildByName("Text_ss"):setString(g_tr("searchMonsterList"))
    self.TextNoMonster = self.root:getChildByName("Text_noMonster")
    self.TextNoMonster:setString(g_tr("noEnemyFinded"))
    local btnClose = self.root:getChildByName("Button_x")
    btnClose:addClickEventListener(handler(self, self.close))

    --滑动条
    self.root:getChildByName("Text_dj"):setString(g_tr("level"))
    self.root:getChildByName("Text_hd"):setString(g_tr("slideToSelectMonsterLv"))

    self.slider = self.root:getChildByName("Slider_1")
    self.maxLevel = g_PlayerMode.GetData().monster_lv + 1
    self.root:getChildByName("Text_sz2"):setString("/"..self.maxLevel)

    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local count = math.floor(self.maxLevel*sender:getPercent()/100)
            count = math.max(1, count)
            if self.lbInputNum then 
                self.lbInputNum:setString(""..count)
            end 
            if self.curTab == 1 then
                g_MapCollectMode.SetMonsterSearchLevel(count)
            else
                g_MapCollectMode.SetBossLevel(count)
            end
        end 
    end 
    self.slider:addEventListener(sliderEvent)
    

    --输入框
    local function textFieldEvent(eventType)
        if eventType == "customEnd" then
            local editnum = tonumber( self.lbInputNum:getString()) or 1 
            if nil == editnum then 
                self.lbInputNum:setString("")
            else 
                if editnum >= self.maxLevel then
                    editnum = self.maxLevel
                end
                if editnum < 1 then
                    editnum = 1
                end
                self.lbInputNum:setString(""..editnum)
                
                self.slider:setPercent(100*editnum/self.maxLevel)
                if self.curTab == 1 then
                    g_MapCollectMode.SetMonsterSearchLevel(editnum)
                else
                    g_MapCollectMode.SetBossLevel(editnum)
                end
            end 
        end
    end

    if self.maxLevel > 26 then
        self.maxLevel = 26
    end

    local selectedLevel = 0
    if g_MapCollectMode.GetMonsterSearchLevel() == nil then
        selectedLevel = self.maxLevel
    else
         selectedLevel = g_MapCollectMode.GetMonsterSearchLevel()
    end

    g_MapCollectMode.SetMonsterSearchLevel(selectedLevel)

    local textField = self.root:getChildByName("TextField_1")
    self.lbInputNum = g_gameTools.convertTextFieldToEditBox(textField)
    self.lbInputNum:setPlaceHolder("")
    -- self.lbInputNum:setMaxLength(4)
    self.lbInputNum:registerScriptEditBoxHandler(textFieldEvent) 
    self.lbInputNum:setString(""..selectedLevel)
    self.slider:setPercent(100*selectedLevel/self.maxLevel)

    local function onDecrease()
        local editnum = tonumber( self.lbInputNum:getString())
        if nil == editnum then return end 

        if editnum > 1 then 
            self.lbInputNum:setString(""..editnum-1)
            self.slider:setPercent(100*(editnum-1)/self.maxLevel)
            if self.curTab == 1 then
                g_MapCollectMode.SetMonsterSearchLevel(editnum-1)
            else
                g_MapCollectMode.SetBossLevel(editnum - 1)
            end
            
        end 
    end 

    local function onIncrease()
        local editnum = tonumber( self.lbInputNum:getString())
        if nil == editnum then return end 

        if editnum < self.maxLevel then 
            self.lbInputNum:setString(""..editnum+1)
            self.slider:setPercent(100*(editnum+1)/self.maxLevel)
            if self.curTab == 1 then
                g_MapCollectMode.SetMonsterSearchLevel(editnum+1)
            else
                g_MapCollectMode.SetBossLevel(editnum+1)
            end
        end 
    end     
    self.root:getChildByName("Image_jh"):addClickEventListener(onDecrease)
    self.root:getChildByName("Image_jh_0"):addClickEventListener(onIncrease)



    self.manger = false
    self.curTab = 1
    self:setBrightTab(self.curTab)

    self:initFun()
    self:addEvent()

    local function getData(data)
        self.data = data
        self:showUI()
    end

    self:findNpc(getData)
end

function searchMasterView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                local function getData(data)
                    self.data = data
                    self:showUI()
                end

                self:findNpc(getData)
            elseif sender == self.Button_2 then
                if self.curTab ~= 1 then
                    self.curTab = 1
                    self:setBrightTab(self.curTab)
                    self.Panel_cc1:setVisible(false)
                    self.ListView_1:setVisible(true)
                    self.Button_sous:setVisible(false)
                    if #self.data.npc == 0 then
                        self.TextNoMonster:setVisible(true)
                    else
                        self.TextNoMonster:setVisible(false)
                    end
                    
                    self.maxLevel = g_PlayerMode.GetData().monster_lv+1

                    if self.maxLevel > 26 then
                        self.maxLevel = 26
                    end

                    local selectedLevel = 0
                    if g_MapCollectMode.GetMonsterSearchLevel() == nil then
                        selectedLevel = self.maxLevel
                    else
                        selectedLevel = g_MapCollectMode.GetMonsterSearchLevel()
                    end

                    
                    self.root:getChildByName("Text_sz2"):setString("/"..self.maxLevel)
                    self.lbInputNum:setString(""..selectedLevel)
                    self.slider:setPercent(100*selectedLevel/self.maxLevel)
                end
            elseif sender == self.Button_3 then
                if self.curTab ~= 2 then
                    self.curTab = 2
                    self:setBrightTab(self.curTab)
                    self.Panel_cc1:setVisible(true)
                    self.ListView_1:setVisible(false)
                    self.Button_sous:setVisible(true)
                    self.TextNoMonster:setVisible(false)
                    if self.bossView == nil then
                        self.bossView = require("game.uilayer.mainSurface.SearchBossView").new(self.Panel_cc1, self.gotoPosition)
                    end

                    self.bossView:show(nil)

                    self.maxLevel = g_PlayerMode.GetData().monster_lv

                    local selectedLevel = 0
                    if g_MapCollectMode.GetBossLevel() == nil then
                        selectedLevel = self.maxLevel
                    else
                        selectedLevel = g_MapCollectMode.GetBossLevel()
                    end
                    
                    self.root:getChildByName("Text_sz2"):setString("/"..self.maxLevel)
                    self.lbInputNum:setString(""..selectedLevel)
                    self.slider:setPercent(100*selectedLevel/self.maxLevel)
                end
            elseif sender == self.Button_sous then
                self:findBoss()
            elseif sender == self.Button_cc then
                g_MapCollectMode.SetBossData(nil)
                self.bossView:show(nil)
            end
        end
    end
    self.Button_1:addTouchEventListener(proClick)
    self.Button_2:addTouchEventListener(proClick)
    self.Button_3:addTouchEventListener(proClick)
    self.Button_sous:addTouchEventListener(proClick)
    self.Button_cc:addTouchEventListener(proClick)
end

function searchMasterView:initFun()
    self.gotoPosition = function(data)
        local BigMap = require("game.maplayer.worldMapLayer_bigMap")        
        BigMap.closeSmallMenu()
        BigMap.closeInputMenu()
        BigMap.changeBigTileIndex_Manual(cc.p(tonumber(data.x), tonumber(data.y)),true)

        self:close()
    end
end

function searchMasterView:showUI()
     self.ListView_1:removeAllItems()

    local item
    local len = #self.data.npc
    for i=1, len do
        item = require("game.uilayer.mainSurface.searchItemView").new(i)
        item:show(self.data.npc[i], self.gotoPosition)
        self.ListView_1:pushBackCustomItem(item)
    end

    if self.manger == false then
        self.manger = true
        g_guideManager.execute()
    end
    
    self.TextNoMonster:setVisible(len == 0)
end

function searchMasterView:setBrightTab(type)
    self.Button_2:setBrightStyle(BRIGHT_NORMAL)
    self.Button_3:setBrightStyle(BRIGHT_NORMAL)
    if type == 1 then
        self.Button_2:setBrightStyle(BRIGHT_HIGHLIGHT)
    else
        self.Button_3:setBrightStyle(BRIGHT_HIGHLIGHT)
    end
end

function searchMasterView:findNpc(fun)
    if require("game.maplayer.worldMapLayer_bigMap").getCurrentShowCenterAreaID() == nil then
        self:close()
        return
    end

    local tbl = 
    {
        ["blockId"] = require("game.maplayer.worldMapLayer_bigMap").getCurrentShowCenterAreaID(),
    }


    local selectedLevel = g_MapCollectMode.GetMonsterSearchLevel()
    if selectedLevel and type(selectedLevel) == "number" then 
        tbl.level = selectedLevel
    end 

    local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun(data)
            end
        end
    end

    g_netCommand.send("Map/findNpc", tbl, callback)
end

function searchMasterView:findBoss()
    if require("game.maplayer.worldMapLayer_bigMap").getCurrentShowCenterAreaID() == nil then
        self:close()
        return
    end

    local selectedLevel = g_MapCollectMode.GetBossLevel()

    if selectedLevel ~= nil and g_MapCollectMode.GetBossData() ~= nil then
        local data = g_MapCollectMode.GetBossData()
        local mapData = g_data.map_element[tonumber(data.element_id)]
        
        print(selectedLevel==mapData.level, "@@@@@@@@@@@@@@@@@@@@@")

        if selectedLevel == mapData.level then
            g_airBox.show(g_tr("searchSameLevel"))
            return
        end
    end

    local tbl = 
    {
        ["blockId"] = require("game.maplayer.worldMapLayer_bigMap").getCurrentShowCenterAreaID(),
    }

    if selectedLevel then 
        tbl.elementId = tonumber(selectedLevel) + 1700
        g_MapCollectMode.SetBossLevel(selectedLevel)
    else
        tbl.elementId = tonumber(self.maxLevel) + 1700
        g_MapCollectMode.SetBossLevel(self.maxLevel)
    end

    local function callback(result, data)
        if result == true then
            if self.bossView ~= nil then
                if #data.npc > 0 then
                    g_MapCollectMode.SetBossData(data.npc[1])
                    self.bossView:show(data.npc[1])
                else
                    g_airBox.show(g_tr("noBossFind"))
                end
            end
        end
    end

    g_netCommand.send("Map/findItem", tbl, callback)
end

return searchMasterView

--endregion
