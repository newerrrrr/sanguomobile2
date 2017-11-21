--region DrillItemView.lua
--Author : luqingqing
--Date   : 2015/10/23
--此文件由[BabeLua]插件自动生成

local DrillItemView = class("DrillItemView", function() 
    return ccui.Widget:create()
end)

local defaultShow = "-"

--local property = {g_tr_original("attack"), g_tr_original("defend"),g_tr_original("life"),g_tr_original("atkRange"), g_tr_original("speed"), g_tr_original("carry")}

function DrillItemView:ctor(generalBack, armyBack, posNumber, maxArmyNum, isCross)
    
    --创建数据--
    self.cropData1 = require("game.gamedata.CropData").new()
    self.cropData2 = require("game.gamedata.CropData").new()

    self.generalBack = generalBack
    self.armyBack = armyBack
    self.pos = posNumber
    self.maxArmy = maxArmyNum
    self.isCross = isCross

    local layout = cc.CSLoader:createNode("xiaochangxinx.csb")

    self.root = layout:getChildByName("scale_node")
    self:setContentSize(cc.size(layout:getContentSize().width, layout:getContentSize().height))

    self:addChild(layout)
    
    --注册新手引导NodeID
    
    g_guideManager.registComponent(9999900 + posNumber,layout:getChildByName("scale_node"):getChildByName("Panel_01"):getChildByName("Panel_zhu1"):getChildByName("Image_22"))
    g_guideManager.registComponent(9999900 + posNumber + 1,layout:getChildByName("scale_node"):getChildByName("Panel_02"):getChildByName("Panel_zhu1"):getChildByName("Image_22"))
    
    g_guideManager.registComponent(9999800 + posNumber,layout:getChildByName("scale_node"):getChildByName("Panel_01"):getChildByName("Panel_zhu2"):getChildByName("Image_3"))
    g_guideManager.registComponent(9999800 + posNumber + 1,layout:getChildByName("scale_node"):getChildByName("Panel_02"):getChildByName("Panel_zhu2"):getChildByName("Image_3"))
    
    for i=1, 2 do
        self["Panel_0"..i] = self.root:getChildByName("Panel_0"..i)
        
        self["Panel_0"..i.."_Image_2"] = self["Panel_0"..i]:getChildByName("Image_2")
        self["Panel_0"..i.."_Panel_zhu2"] = self["Panel_0"..i]:getChildByName("Panel_zhu2")
        self["Panel_0"..i.."_Image_3"] = self["Panel_0"..i.."_Panel_zhu2"]:getChildByName("Image_3")
        self["Panel_0"..i.."_Image_4"] = self["Panel_0"..i.."_Panel_zhu2"]:getChildByName("Image_4")
        self["Panel_0"..i.."_Text_1"] = self["Panel_0"..i]:getChildByName("Text_1")
        self["Panel_0"..i.."_Text_shibingmingc"] = self["Panel_0"..i]:getChildByName("Text_shibingmingc")
        self["Panel_0"..i.."_Text_shibingmingc_0"] = self["Panel_0"..i]:getChildByName("Text_shibingmingc_0")
        self["Panel_0"..i.."_Text_zuixiao"] = self["Panel_0"..i]:getChildByName("Text_zuixiao")
        self["Panel_0"..i.."_Text_zuida"] = self["Panel_0"..i]:getChildByName("Text_zuida")
        self["Panel_0"..i.."_Text_shibingmingc_0_0"] = self["Panel_0"..i]:getChildByName("Text_shibingmingc_0_0")
        self["Panel_0"..i.."_Text_js"] = self["Panel_0"..i]:getChildByName("Text_js")

        self["Panel_0"..i.."_Panel_zhu1"] = self["Panel_0"..i]:getChildByName("Panel_zhu1")
        self["Panel_0"..i.."_Image_22"] = self["Panel_0"..i.."_Panel_zhu1"]:getChildByName("Image_22")
        self["Panel_0"..i.."_Image_22_0"] = self["Panel_0"..i.."_Panel_zhu1"]:getChildByName("Image_22_0")

        self["Panel_0"..i.."_Image_5"] = self["Panel_0"..i]:getChildByName("Image_5")
        self["Panel_0"..i.."_Image_5_Text_4"] = self["Panel_0"..i.."_Image_5"]:getChildByName("Text_4")

        self["Panel_0"..i.."Panel_yc"] = self["Panel_0"..i]:getChildByName("Panel_yc")
        self["Panel_0"..i.."Panel_yc"]:setVisible(false)
    end

    if self.maxArmy < self.pos then
        local view = require("game.uilayer.drill.DrillLockView").new()
        self.Panel_01:addChild(view)
    end

    if self.maxArmy < (self.pos + 1) then
        local view = require("game.uilayer.drill.DrillLockView").new()
        self.Panel_02:addChild(view)
    end

    self.armature1, self.animation1 = g_gameTools.LoadCocosAni("anime/Effect_112PxWaiKuangXuanZhuan/Effect_112PxWaiKuangXuanZhuan.ExportJson", "Effect_112PxWaiKuangXuanZhuan")
    self.armature2, self.animation2 = g_gameTools.LoadCocosAni("anime/Effect_112PxWaiKuangXuanZhuan/Effect_112PxWaiKuangXuanZhuan.ExportJson", "Effect_112PxWaiKuangXuanZhuan")

    self["Panel_01_Image_3"]:addChild(self.armature1)
    self.armature1:setPosition(cc.p(self["Panel_01_Image_3"]:getContentSize().width/2,self["Panel_01_Image_3"]:getContentSize().height/2))
    self.animation1:play("Violet")

    self["Panel_02_Image_3"]:addChild(self.armature2)
    self.armature2:setPosition(cc.p(self["Panel_02_Image_3"]:getContentSize().width/2,self["Panel_02_Image_3"]:getContentSize().height/2))
    self.animation2:play("Violet")

    self:addEvent()
end

function DrillItemView:initLeft()
    self.Panel_01_Text_1:setString(g_tr("addGeneral"))
    self.Panel_01_Text_shibingmingc_0:setString(g_tr("addArmy"))
    self.Panel_01_Image_5_Text_4:setString(defaultShow)
    self["Panel_01_Image_22"]:setVisible(false)
    self["Panel_01_Image_3"]:setVisible(false)
    self["Panel_01_Image_4"]:setVisible(false)
    self["Panel_01_Image_22_0"]:setVisible(true)

    self.Panel_01_Text_shibingmingc:setString("")
    self.Panel_01_Text_shibingmingc_0:setString(g_tr("addArmy"))
    self["Panel_01_Image_2"]:loadTexture(g_resManager.getResPath(1002003))
    if self["Panel_01txtRich"] == nil  then
        self["Panel_01_Image_5_Text_4"]:setString(defaultShow)
    else
        self["Panel_01txtRich"]:setRichText(defaultShow)
    end
    self["Panel_01_Text_js"]:setString("")
end

function DrillItemView:initRight()
    self.Panel_02_Text_1:setString(g_tr("addGeneral"))
    self.Panel_02_Text_shibingmingc_0:setString(g_tr("addArmy"))
    self.Panel_02_Image_5_Text_4:setString(defaultShow)
    self["Panel_02_Image_22"]:setVisible(false)
    self["Panel_02_Image_3"]:setVisible(false)
    self["Panel_02_Image_4"]:setVisible(false)
    self["Panel_02_Image_22_0"]:setVisible(true)

    self.Panel_02_Text_shibingmingc:setString("")
    self.Panel_02_Text_shibingmingc_0:setString(g_tr("addArmy"))
    self["Panel_02_Image_2"]:loadTexture(g_resManager.getResPath(1002003))
    if self["Panel_02txtRich"] == nil  then
        self["Panel_02_Image_5_Text_4"]:setString(defaultShow)
    else
        self["Panel_02txtRich"]:setRichText(defaultShow)
    end
    self["Panel_02_Text_js"]:setString("")
end

function DrillItemView:show()

    self.armature1:setVisible(false)
    self.armature2:setVisible(false)

    --武将信息
    if self.cropData1:getGeneralData() ~= nil then
        self:initGeneral("Panel_01",self.cropData1)
        self:initSoldier("Panel_01",self.cropData1, self.armature1)
    else
        self:initLeft()
    end

    if self.cropData2:getGeneralData() ~= nil then
        self:initGeneral("Panel_02",self.cropData2)
        self:initSoldier("Panel_02",self.cropData2, self.armature2)
    else
        self:initRight()
    end
end

function DrillItemView:initSoldier(ui, data, armature)
    if data:getArmyUnitData() ~= nil and data:getArmyUnitData().soldier_id ~= 0 then
        local gSoldier = g_data.soldier[data:getArmyUnitData().soldier_id]
        self[ui.."_Text_shibingmingc"]:setString(g_tr(gSoldier.soldier_name))

        local maxSoldier = self:countMaxSoldier(data:getGeneralData().general_id)

        self[ui.."_Image_3"]:setVisible(true)
        self[ui.."_Image_4"]:setVisible(true)

        local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Soldier, data:getArmyUnitData().soldier_id, 1)
        self[ui.."_Image_3"]:addChild(item)
        item:setPosition(self[ui.."_Image_3"]:getContentSize().width/2, self[ui.."_Image_3"]:getContentSize().height/2)
        item:setCountEnabled(false)

        self[ui.."_Text_shibingmingc_0"]:setString(g_tr_original("armyEnterNumber"))
        self[ui.."_Image_2"]:loadTexture(g_resManager.getResPath(gSoldier.img_type))

        if self.isCross then
            if maxSoldier > data:getArmyUnitData().soldier_num and g_cityBattle_cross_ui_dataHelper.requireSoldier().GetAllSoldierNumber() > 0 then
                armature:setVisible(true)
            end
        else
            if maxSoldier > data:getArmyUnitData().soldier_num and g_SoldierMode.GetSoldierNumber(data:getArmyUnitData().soldier_id) > 0 then
                armature:setVisible(true)
            end
        end
        

        if self[ui.."txtRich"] == nil then
            self[ui.."txtRich"] = g_gameTools.createRichText(self[ui.."_Image_5_Text_4"], "")
        end

        --|<#253,208,110#>联盟商店|
        if data:getArmyUnitData().soldier_num >= maxSoldier then
            self[ui.."txtRich"]:setRichText("|<#72,255,98#>"..data:getArmyUnitData().soldier_num.."|/"..maxSoldier)
        else
            self[ui.."txtRich"]:setRichText("|<#255,40,50#>"..data:getArmyUnitData().soldier_num.."|/"..maxSoldier)
        end
    else
        local maxSoldier = self:countMaxSoldier(data:getGeneralData().general_id)

        if g_SoldierMode.GetAllSoldierNumber() > 0 then
            if self[ui.."txtRich"] == nil  then
                self[ui.."_Image_5_Text_4"]:setString(g_tr("addArmyType"))
            else
                self[ui.."txtRich"]:setRichText(g_tr("addArmyType"))
            end
        else
            self[ui.."_Image_5_Text_4"]:setString("")if self[ui.."txtRich"] == nil  then
                self[ui.."_Image_5_Text_4"]:setString("")
            else
                self[ui.."txtRich"]:setRichText("")
            end
        end
    end
end

function DrillItemView:initGeneral(ui, data)
    self[ui.."_Image_22"]:removeAllChildren()

    local generalData = data:getGeneralData()
    local gData = g_GeneralMode.GetBasicInfo(generalData.general_id, 1)
    self[ui.."_Text_1"]:setString(g_tr(gData.general_name))
    self[ui.."_Image_22"]:setVisible(true)
    local item = self:createHeroHead(generalData.general_id*100+1)
    item:setPosition(self[ui.."_Image_22"]:getContentSize().width/2, self[ui.."_Image_22"]:getContentSize().height/2)
    self[ui.."_Image_22"]:addChild(item)
    item:showGeneralServerStarLv(generalData.star_lv)

    local soldierType = g_data.equip_skill[g_data.equipment[gData.general_item_id*100].equip_skill_id[1]].equip_arm_type
    self[ui.."_Text_js"]:setString(g_tr("betterArmyUnit", {army=self:getSoldierTypeName(soldierType)}))

    self[ui.."_Image_22_0"]:setVisible(false)
end

function DrillItemView:getSoldierTypeName(type)
    if type == g_ArmyUnitMode.m_SoldierOriginType.infantry then
        return g_tr("infantry")
    elseif type == g_ArmyUnitMode.m_SoldierOriginType.cavalry then
        return g_tr("cavalry")
    elseif type == g_ArmyUnitMode.m_SoldierOriginType.archer then
        return g_tr("archer")
    elseif type == g_ArmyUnitMode.m_SoldierOriginType.vehicles then
        return g_tr("vehicles")
    end
end

function DrillItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended  then
            if sender == self["Panel_01_Panel_zhu1"] then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.generalBack ~= nil then
                    self.generalBack(self.cropData1, self.pos)
                end
            elseif sender == self["Panel_02_Panel_zhu1"] then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.generalBack ~= nil then
                    self.generalBack(self.cropData2, self.pos+1)
                end
            elseif sender == self["Panel_01_Panel_zhu2"] then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.armyBack ~= nil then
                    self.armyBack(self.cropData1, self.pos)
                end
            elseif sender == self["Panel_02_Panel_zhu2"] then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.armyBack ~= nil then
                    self.armyBack(self.cropData2, self.pos+1)
                end
            end
        end
    end

    local function textFieldHandler(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
            local str = sender:getString()
            local pos = 1, ch
            while pos <= str:len() do    
                ch = string.byte(str, pos) 
                if ch < 48 or ch > 57 then 
                    sender:setString("0")
                    break 
                end 
                pos = pos + 1 
            end
        end
    end

    self["Panel_01_Panel_zhu1"]:addTouchEventListener(proClick)
    self["Panel_01_Panel_zhu2"]:addTouchEventListener(proClick)
    self["Panel_02_Panel_zhu1"]:addTouchEventListener(proClick)
    self["Panel_02_Panel_zhu2"]:addTouchEventListener(proClick)
end

function DrillItemView:getLeftAmryNumber()
    return self.leftArmyNumber
end

function DrillItemView:getRightAmryNumber()
    return self.rightArmyNumber
end

function DrillItemView:setLeftCropData(armyData, generalData)
    self.cropData1:setArmyUnitData(armyData)
    self.cropData1:setGeneralData(generalData)
end

function DrillItemView:setRightCropData(armyData, generalData)
    self.cropData2:setGeneralData(generalData)
    self.cropData2:setArmyUnitData(armyData)
end

function DrillItemView:getLeftCropData()
    return self.cropData1
end

function DrillItemView:getRightCropData()
    return self.cropData2
end

function DrillItemView:createHeroHead(heroId)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)

    return item
end

function DrillItemView:countMaxSoldier(gid)
    if self.isCross == true then
        local generalData = g_GeneralMode.GetBasicInfo(gid, 1)
        local crossPlayer = g_cityBattle_cross_ui_dataHelper.requirePlayer().GetData()

        local troop_max_plus = 0
        local percent = 0
        if crossPlayer.buff.troop_max_plus ~= nil then
            troop_max_plus = crossPlayer.buff.troop_max_plus
        end

        if crossPlayer.buff.troop_max_plus_percent ~= nil then
            percent = crossPlayer.buff.troop_max_plus_percent
        end

        local allData = (generalData.max_soldier + troop_max_plus) * (percent+10000)/10000
        allData = math.round(allData)
        return allData
    else
        return g_ArmyMode.GetMaxArmyNum(gid)
    end
    
end

return DrillItemView

--endregion
