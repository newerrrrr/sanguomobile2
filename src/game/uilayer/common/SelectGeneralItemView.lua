--region SelectGeneralItemView.lua
--Author : luqingqing
--Date   : 2015/10/28
--此文件由[BabeLua]插件自动生成

local SelectGeneralItemView = class("SelectGeneralItemView",  require("game.uilayer.base.BaseWidget"))

local _data = nil

local property = {g_tr("wu"), g_tr("zhi"), g_tr("zheng"), g_tr("tong"), g_tr("mei")}
local propertyInfo = {g_tr("wuInfo"), g_tr("zhiInfo"), g_tr("zhengInfo"), g_tr("tongInfo"), g_tr("meiInfo")}

function SelectGeneralItemView:ctor()
    local layout = self:LoadUI("xuanzhewujiang01.csb")
    self.root = layout:getChildByName("scale_node")

    self.Image_2 = self.root:getChildByName("Image_2")
    self.Image_3 = self.root:getChildByName("Image_3")
    self.Image_3_0 = self.root:getChildByName("Image_3_0")
    self.Image_3_0:setVisible(false)
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1_0 = self.root:getChildByName("Text_1_0")
    self.Text_1_0:setVisible(false)
    self.Text_2 = self.root:getChildByName("Text_2")
    self.Text_2_0 = self.root:getChildByName("Text_2_0")
    self.Text_6_0 = self.root:getChildByName("Text_6_0")
    self.Text_zhuangtai01 = self.root:getChildByName("Text_zhuangtai01")
    self.Text_Text_zhuangtai02 = self.root:getChildByName("Text_Text_zhuangtai02")
    self.Text_zhuangtai01:setString(g_tr("status"))
    self.Text_Text_zhuangtai02:setString(g_tr("freeStatus"))
    self.Text_6_0:setString(g_tr("betterArmy"))
    self.Text_2:setString(g_tr("maxArmyCarry"))

    self.Image_2:setVisible(false)

    self.Image_jiche01 = self.root:getChildByName("Image_jiche01")
    self.Image_jiche01_Text_6 = self.Image_jiche01:getChildByName("Text_6")

    self.Panel_yanse = self.root:getChildByName("Panel_yanse")
    for i=1, 5 do
        self["Panel_yanse"..i] = self.Panel_yanse:getChildByName("Panel_yanse"..i)
        self["Panel_yanse"..i]:setTouchEnabled(true)
        self["Panel_yanse"..i.."Text_9"] = self["Panel_yanse"..i]:getChildByName("Text_9")
        self["Panel_yanse"..i.."Text_9"]:setString(property[i])
        self["Panel_yanse"..i.."Text_10"] = self["Panel_yanse"..i]:getChildByName("Text_10")
        self["Panel_yanse"..i.."Text_10_0"] = self["Panel_yanse"..i]:getChildByName("Text_10_0")
        g_itemTips.tipStr(self["Panel_yanse"..i],property[i],propertyInfo[i])
    end
end

function SelectGeneralItemView:show(data, clickBack, isCross)

    _data = data
    self.data = data
    self.click = clickBack
    self.isCross = isCross or false

    local property = require("game.uilayer.godGeneral.GodGeneralMode"):instance():initEquiptSx(_data.general_id)
    local gData = g_GeneralMode.GetBasicInfo(_data.general_id, 1)
    self.Text_1:setString(g_tr(gData.general_name))
    self.Text_1_0:setString("lv".._data.lv)
    self.Text_2_0:setString(self:countMaxSoldier(_data.general_id).."")
    self["Panel_yanse1Text_10"]:setString(property.force.sv.."")
    self["Panel_yanse1Text_10_0"]:setString("+"..property.force.av)
    self["Panel_yanse2Text_10"]:setString(property.intelligence.sv.."")
    self["Panel_yanse2Text_10_0"]:setString("+"..property.intelligence.av)
    self["Panel_yanse3Text_10"]:setString(property.political.sv.."")
    self["Panel_yanse3Text_10_0"]:setString("+"..property.political.av)
    self["Panel_yanse4Text_10"]:setString(property.governing.sv.."")
    self["Panel_yanse4Text_10_0"]:setString("+"..property.governing.av)
    self["Panel_yanse5Text_10"]:setString(property.charm.sv.."")
    self["Panel_yanse5Text_10_0"]:setString("+"..property.charm.av)
 
    local soldierType = g_data.equip_skill[g_data.equipment[gData.general_item_id*100].equip_skill_id[1]].equip_arm_type
    if soldierType == 1 then
        self.Image_jiche01_Text_6:setString(g_tr("infantry"))
    elseif soldierType == 2 then
        self.Image_jiche01_Text_6:setString(g_tr("cavalry"))
    elseif soldierType == 3 then
        self.Image_jiche01_Text_6:setString(g_tr("archer"))
    elseif soldierType == 4 then
        self.Image_jiche01_Text_6:setString(g_tr("vehicles"))
    end

    self.Image_3:removeAllChildren()
    local item = self:createHeroHead(_data.general_id*100+1)
    item:setPosition(self.Image_3:getContentSize().width/2, self.Image_3:getContentSize().height/2)
    self.Image_3:addChild(item)

    self:addEvent()
end

function SelectGeneralItemView:addEvent()

    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.root then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.click ~= nil then
                    self.click(self)
                end
            end
        end
    end

    self.root:addTouchEventListener(proClick)
end

function SelectGeneralItemView:setSelect(value)
    self.Image_2:setVisible(value)
end

function SelectGeneralItemView:getData()
    return self.data
end

function SelectGeneralItemView:createHeroHead(heroId)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)

    return item
end

function SelectGeneralItemView:countMaxSoldier(gid)
    if self.isCross == true then
        local generalData = g_GeneralMode.GetBasicInfo(gid, 1)
        return generalData.max_soldier
    else
        return g_ArmyMode.GetMaxArmyNum(gid)
    end
end

return SelectGeneralItemView

--endregion
