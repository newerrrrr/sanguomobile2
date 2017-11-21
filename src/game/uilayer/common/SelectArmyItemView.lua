--region SelectArmyItemView.lua
--Author : luqingqing
--Date   : 2015/10/30
--此文件由[BabeLua]插件自动生成

local SelectArmyItemView = class("SelectArmyItemView", require("game.uilayer.base.BaseWidget"))

local property = {g_tr_original("attack"), g_tr_original("defend"),g_tr_original("life"),g_tr_original("atkRange"), g_tr_original("speed"), g_tr_original("carry")}

local default = "-"

function SelectArmyItemView:ctor(soldierData, cropData, clickBack, updateClear, closeWin, curTab)

    self.soldier = soldierData
    self.cropData = cropData
    self.sData = g_data.soldier[self.soldier.soldier_id]
    self.clickBack = clickBack
    self.updateBack = updateClear
    self.closeWin = closeWin
    self.curTab = curTab

    self.layout =self:LoadUI("xuanzhebudui01.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.Image_3 = self.root:getChildByName("Image_3")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Image_1_1 = self.root:getChildByName("Image_1_1")
    self.Image_3_1 = self.root:getChildByName("Image_3_1")

    local gData = g_GeneralMode.GetBasicInfo(self.cropData:getGeneralData().general_id, 1)
    local soldierType = g_data.equip_skill[g_data.equipment[gData.general_item_id*100].equip_skill_id[1]].equip_arm_type

    if tonumber(soldierType) == tonumber(self.sData.soldier_type) then
        self.Image_3_1:setVisible(true)
    else
        self.Image_3_1:setVisible(false)
    end

    self.Image_shuzi = self.root:getChildByName("Image_shuzi")
    self.Button_1 = self.root:getChildByName("Button_1")
    self.Text_sj = self.root:getChildByName("Text_sj")

    for i=1, 6 do
        self["Panel_xinx0"..i] = self.root:getChildByName("Panel_xinx0"..i)
        self["Panel_xinx0"..i.."_Text_1_1"] = self["Panel_xinx0"..i]:getChildByName("Text_1_1")
        self["Panel_xinx0"..i.."_Text_1_1_0"] = self["Panel_xinx0"..i]:getChildByName("Text_1_1_0")
        self["Panel_xinx0"..i.."_Text_2"] = self["Panel_xinx0"..i]:getChildByName("Text_2")

        self["Panel_xinx0"..i.."_Text_1_1"]:setString(property[i])
        self["Panel_xinx0"..i.."_Text_1_1_0"]:setString(default)
    end

    self.Panel_8 = self.root:getChildByName("Panel_8")
    self.Panel_8_Text_15 = self.Panel_8:getChildByName("Text_15")
    self.Panel_8_Text_15:setString(g_tr("stunt"))

    for i=1, 3 do
        self["Image_jc0"..i] = self.Panel_8:getChildByName("Image_jc0"..i)
        self["Image_jc0"..i.."_Text_15_0"] = self["Image_jc0"..i]:getChildByName("Text_15_0")
    end

    self.Text_6 = self.root:getChildByName("Text_6")
    self.Text_6_0 = self.root:getChildByName("Text_6_0")
    self.Slider_1 = self.root:getChildByName("Slider_1")
    self.Text_9 = self.root:getChildByName("Text_9")

    self.Text_6:setString(g_tr("armyLeftNumber"))
    self.Text_sj:setString(g_tr("startLvUp"))

    self:initFun()
    self:show()
    self:addEvent()
end

function SelectArmyItemView:initFun()
    self.reOpen = function(tab)
        g_sceneManager.addNodeForUI(require("game.uilayer.drill.DrillView").new(nil, tab))
    end
end

function SelectArmyItemView:addEvent()

    local cur = 0
    if self.cropData:getArmyUnitData() ~= nil and self.cropData:getArmyUnitData().soldier_id == self.soldier.soldier_id  then
        cur = self.cropData:getArmyUnitData().soldier_num
    else
        cur = 0
    end

    local num = math.ceil(self.Slider_1:getPercent() * (self.maxSoldier)/100)
    local max = cur + self.soldier.num

    local function valueChange(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            self.updateBack()
            self.Image_1_1:setVisible(true)

            num = math.ceil(self.Slider_1:getPercent() * (self.maxSoldier)/100)
            if num >= max then
                num = max
                self.Slider_1:setPercent(num*100/self.maxSoldier)
            end

            self.num = num
            self.Text_6_0:setString((max - num).."")
            self.Text_9:setString(num.."/"..self.maxSoldier)

            if self.clickBack ~= nil then
                self.clickBack(self)
            end
        elseif eventType == ccui.SliderEventType.slideBallUp then
            if g_guideManager.getLastShowStep() then
                if g_guideManager.execute() then
                    self.updateBack()
                    self.Image_1_1:setVisible(true)
                    
                    num = self.maxSoldier

                    if num >= max then
                        num = max
                        self.Slider_1:setPercent(num*100/self.maxSoldier)
                    end
        
                    self.num = num
                    self.Text_6_0:setString((max - num).."")
                    self.Text_9:setString(num.."/"..self.maxSoldier)
        
                    if self.clickBack ~= nil then
                        self.clickBack(self)
                    end
                end
            end
        end
    end

    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if sender == self.root then
                self.updateBack()
                self.Image_1_1:setVisible(true)

                if self.clickBack ~= nil then
                    self.clickBack(self)
                end
            elseif self.Button_1 == sender or self.Text_sj == sender then
                if self.cropData:getArmyUnitData().soldier_id == self.soldier.soldier_id then
                    g_airBox.show(g_tr("drillUpdateInfo"))
                    return
                end

                local SoldierUpgrade = require("game.uilayer.militaryCamp.SoldierUpgrade")
                SoldierUpgrade:createLayer(self.sData.id, nil)
                SoldierUpgrade:setExitCallBack(self.reOpen, self.curTab)
                if self.closeWin ~= nil then
                    self.closeWin()
                end
            end
        end
    end

    self.Slider_1:addEventListener(valueChange)
    self.root:addTouchEventListener(proClick)
    self.Button_1:addTouchEventListener(proClick)
    self.Text_sj:addTouchEventListener(proClick)
end

function SelectArmyItemView:show()
    --self.soldier.soldier_id
    local pro = require("game.uilayer.common.ArmyInfoView").getSoldierBuffValue(self.soldier.soldier_id)
    self.Text_1:setString(g_tr(self.sData.soldier_name))

    self.Panel_xinx01_Text_1_1_0:setString(self.sData.attack.."")
    if pro[1] ~= 0 then
        self.Panel_xinx01_Text_2:setString("+"..pro[1])
    else
        self.Panel_xinx01_Text_2:setString("")
    end
    
    self.Panel_xinx02_Text_1_1_0:setString(self.sData.defense.."")
    if pro[2] ~= 0 then
        self.Panel_xinx02_Text_2:setString("+"..pro[2])
    else
        self.Panel_xinx02_Text_2:setString("")
    end
    
    self.Panel_xinx03_Text_1_1_0:setString(self.sData.life.."")
    if pro[3] ~= 0 then
        self.Panel_xinx03_Text_2:setString("+"..pro[3])
    else
        self.Panel_xinx03_Text_2:setString("")
    end
    
    self.Panel_xinx04_Text_1_1_0:setString(self.sData.distance.."")
    self.Panel_xinx05_Text_1_1_0:setString(self.sData.speed.."")
    self.Panel_xinx06_Text_1_1_0:setString(self.sData.weight.."")
    self.Panel_xinx04_Text_2:setString("")
    self.Panel_xinx05_Text_2:setString("")
    self.Panel_xinx06_Text_2:setString("")

    if self.cropData:getArmyUnitData() == nil then
        if require("game.uilayer.militaryCamp.MilitaryCampData"):getUpSoldierIsLock(self.sData.id) then
            self.Button_1:setVisible(true)
            self.Text_sj:setVisible(true)
        else
            self.Button_1:setVisible(false)
            self.Text_sj:setVisible(false)
        end
    else
        --[[
        if self.cropData:getArmyUnitData().soldier_id == self.soldier.soldier_id then
            self.Button_1:setVisible(false)
            self.Text_sj:setVisible(false)
        else
            if require("game.uilayer.militaryCamp.MilitaryCampData"):getUpSoldierIsLock(self.soldier.soldier_id) then
                self.Button_1:setVisible(true)
                self.Text_sj:setVisible(true)
            else
                self.Button_1:setVisible(false)
                self.Text_sj:setVisible(false)
            end
        end
        ]]
        
        if require("game.uilayer.militaryCamp.MilitaryCampData"):getUpSoldierIsLock(self.soldier.soldier_id) then
            self.Button_1:setVisible(true)
            self.Text_sj:setVisible(true)
        else
            self.Button_1:setVisible(false)
            self.Text_sj:setVisible(false)
        end
    end

    self.Image_shuzi:loadTexture(g_resManager.getResPath(self.sData.img_level))

    if self.sData.skill_1 ~= 0 then
        self["Image_jc01_Text_15_0"]:setString(g_tr(g_data.soldier_skills[self.sData.skill_1].soldier_skills_name))
    else
        self["Image_jc01"]:setVisible(false)
    end

    if self.sData.skill_2 ~= 0 then
        self["Image_jc02_Text_15_0"]:setString(g_tr(g_data.soldier_skills[self.sData.skill_2].soldier_skills_name))
    else
        self["Image_jc02"]:setVisible(false)
    end

    if self.sData.skill_3 ~= 0 then
        self["Image_jc03_Text_15_0"]:setString(g_tr(g_data.soldier_skills[self.sData.skill_3].soldier_skills_name))
    else
        self["Image_jc03"]:setVisible(false)
    end

    self.Image_3:loadTexture(g_resManager.getResPath(self.sData.img_portrait))

    self.Text_6_0:setString(self.soldier.num.."")

    local max = g_ArmyMode.GetMaxArmyNum(self.cropData:getGeneralData().general_id)
    
    if self.cropData:getArmyUnitData() ~= nil then
        if self.cropData:getArmyUnitData().soldier_id == self.soldier.soldier_id then
            self.Image_1_1:setVisible(true)
            if max  > self.soldier.num + self.cropData:getArmyUnitData().soldier_num then
                self.maxSoldier = self.soldier.num + self.cropData:getArmyUnitData().soldier_num
            else
                self.maxSoldier = max
            end
        else
            self.Image_1_1:setVisible(false)
            if max > self.soldier.num then
                self.maxSoldier = self.soldier.num
            else
                self.maxSoldier =max
            end
        end
    else
        self.Image_1_1:setVisible(false)

        if max > self.soldier.num then
            self.maxSoldier = self.soldier.num
        else
            self.maxSoldier = max
        end
    end

    self.maxSoldier = self.maxSoldier - self.maxSoldier%1

    local percent = 0
    if self.cropData:getArmyUnitData().soldier_id == self.soldier.soldier_id then
        percent = self.cropData:getArmyUnitData().soldier_num*100/self.maxSoldier
        self.Text_9:setString(self.cropData:getArmyUnitData().soldier_num.."/"..self.maxSoldier)
    else
        self.Text_9:setString("0/"..self.maxSoldier)
    end
   
   
   self.Slider_1:setPercent(percent)
end

function SelectArmyItemView:clearSelect()
    self.Image_1_1:setVisible(false)
end

function SelectArmyItemView:getSoliderData()
    return self.soldier
end

function SelectArmyItemView:getSoliderBasicInfo()
    return self.sData
end

function SelectArmyItemView:getNum()
    return self.num
end

function SelectArmyItemView:clearSider()
    self.Slider_1:setPercent(0)
    self.Text_9:setString("0/"..self.maxSoldier)
end

return SelectArmyItemView
--endregion
