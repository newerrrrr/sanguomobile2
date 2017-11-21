--region BagEquipInfoView.lua
--Author : luqingqing
--Date   : 2015/12/28
--此文件由[BabeLua]插件自动生成

local BagEquipInfoView = class("BagEquipInfoView", require("game.uilayer.base.BaseLayer"))

local property = {g_tr("wu"),g_tr("zhi"),g_tr("zheng"),g_tr("tong"),g_tr("mei"),}

function BagEquipInfoView:ctor(value, callback)
    BagEquipInfoView.super.ctor(self)

    self.data = value
    self.click = callback

    self.layout = self:loadUI("Useprops__info_0.csb")

    self.root = self.layout:getChildByName("scale_node")
    self.Panel_equip = self.root:getChildByName("Panel_equip")
    self.Button_1 = self.root:getChildByName("Button_1")
    self.Button_2 = self.root:getChildByName("Button_2")
    self.Text_27 = self.root:getChildByName("Text_27")
    self.skill_desc = self.root:getChildByName("skill_desc")
    self.skill_desc_1 = self.root:getChildByName("skill_desc_1")
    self.skill_desc_2 = self.root:getChildByName("skill_desc_2")
    self.Text_nz = self.root:getChildByName("Text_nz")
    self.Text_27:setString(g_tr("equipChange"))
    self.skill_desc_2:setString("")

    for i=1, 5 do
        self["Panel_0"..i] = self.root:getChildByName("Panel_0"..i)
        self["Panel_0"..i.."Text_3"] = self["Panel_0"..i]:getChildByName("Text_3")
        self["Panel_0"..i.."Text_2"] = self["Panel_0"..i]:getChildByName("Text_2")
        self["Panel_0"..i.."Text_3"]:setString(property[i])
    end

    self.star_box = self.root:getChildByName("star_box")
    for j=1, 5 do
        self["star_light_"..j] = self.star_box:getChildByName("star_light_"..j)
        self["star_light_"..j]:setVisible(false)
    end

    self:addEvent()
    self:setData()
end

function BagEquipInfoView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            elseif sender == self.Button_2 then
                if self.click ~= nil then
                    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                    self.click()
                    self:close()
                end
            end
        end
    end

    self.Button_1:addTouchEventListener(proClick)
    self.Button_2:addTouchEventListener(proClick)
end

function BagEquipInfoView:setData()
    local data = g_data.equipment[self.data.item_id]
    self["Panel_01Text_2"]:setString(data.force.."")
    self["Panel_02Text_2"]:setString(data.intelligence.."")
    self["Panel_03Text_2"]:setString(data.political.."")
    self["Panel_04Text_2"]:setString(data.governing.."")
    self["Panel_05Text_2"]:setString(data.charm.."")

    self.Text_nz:setString(g_tr(data.equip_name))

    local star = data.star_level
    for j=1, star do
        self["star_light_"..j]:setVisible(true)
    end

     item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Equipment, self.data.item_id, 1)
     self.Panel_equip:addChild(item)
     item:setPosition(self.Panel_equip:getContentSize().width/2, self.Panel_equip:getContentSize().height/2)
     item:setCountEnabled(false)

    if #data.equip_skill_id == 0 then
        self.skill_desc:setString("")
        self.skill_desc_1:setString("")
    elseif #data.equip_skill_id == 1 then
        if g_data.buff[g_data.equip_skill[data.equip_skill_id[1]].skill_buff_id[1]].buff_type == 1 then
            self.skill_desc:setString(g_tr(g_data.equip_skill[data.equip_skill_id[1]].skill_description, {num=g_data.equip_skill[data.equip_skill_id[1]].num/100}).."%")
        elseif g_data.buff[g_data.equip_skill[data.equip_skill_id[1]].skill_buff_id[1]].buff_type == 2 then
            self.skill_desc:setString(g_tr(g_data.equip_skill[data.equip_skill_id[1]].skill_description, {num=g_data.equip_skill[data.equip_skill_id[1]].num}))
        end
        
        self.skill_desc_1:setString("")
    elseif #data.equip_skill_id == 2 then
        if g_data.buff[g_data.equip_skill[data.equip_skill_id[1]].skill_buff_id[1]].buff_type == 1 then
            self.skill_desc:setString(g_tr(g_data.equip_skill[data.equip_skill_id[1]].skill_description, {num=g_data.equip_skill[data.equip_skill_id[1]].num/100}).."%")
        elseif g_data.buff[g_data.equip_skill[data.equip_skill_id[1]].skill_buff_id[1]].buff_type == 2 then
            self.skill_desc:setString(g_tr(g_data.equip_skill[data.equip_skill_id[1]].skill_description, {num=g_data.equip_skill[data.equip_skill_id[1]].num}))
        end

        if g_data.buff[g_data.equip_skill[data.equip_skill_id[2]].skill_buff_id[1]].buff_type == 1 then
            self.skill_desc_1:setString(g_tr(g_data.equip_skill[data.equip_skill_id[2]].skill_description, {num=g_data.equip_skill[data.equip_skill_id[1]].num/100}).."%")
        elseif g_data.buff[g_data.equip_skill[data.equip_skill_id[2]].skill_buff_id[1]].buff_type == 2 then
            self.skill_desc_1:setString(g_tr(g_data.equip_skill[data.equip_skill_id[2]].skill_description, {num=g_data.equip_skill[data.equip_skill_id[1]].num}))
        end
    end

    local SmithyData = require("game.uilayer.smithy.SmithyData")
    self.skill_desc_2:setString(SmithyData:instance():getRedEquipNewSkillDesc(self.data.item_id))
end


return BagEquipInfoView

--endregion
