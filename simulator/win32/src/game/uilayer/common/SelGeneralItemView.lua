local SelGeneralItemView = class("SelGeneralItemView", require("game.uilayer.base.BaseWidget"))

function SelGeneralItemView:ctor()
	self.layout = self:LoadUI("xuanzhewujiang_xin1.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.Image_fg = self.root:getChildByName("Image_fg")
    self.Image_3 = self.root:getChildByName("Image_3")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1_0 = self.root:getChildByName("Text_1_0")
    self.Text_ys1 = self.root:getChildByName("Text_ys1")
    self.Text_ys2 = self.root:getChildByName("Text_ys2")
    self.Text_ys1_0 = self.root:getChildByName("Text_ys1_0")
    self.Text_ys2_0 = self.root:getChildByName("Text_ys2_0")

    self.Panel_yanse = self.root:getChildByName("Panel_yanse")

    for i=1, 5 do
        self["Panel_yanse"..i] = self.Panel_yanse:getChildByName("Panel_yanse"..i)
        self["Panel_yanse"..i]:setTouchEnabled(true)
        self["Panel_yanse"..i.."Text_9"] = self["Panel_yanse"..i]:getChildByName("Text_9")
        self["Panel_yanse"..i.."Text_10"] = self["Panel_yanse"..i]:getChildByName("Text_10")
        self["Panel_yanse"..i.."Text_10_0"] = self["Panel_yanse"..i]:getChildByName("Text_10_0")
        self["Panel_yanse"..i]:setVisible(false)
    end

    self.Image_fg:setVisible(false)

    self.Text_bz = self.root:getChildByName("Text_bz")
    self.Text_bz1 = self.root:getChildByName("Text_bz1")
    self.Text_bz1_0 = self.root:getChildByName("Text_bz1_0")
    self.Text_bz1_0_0 = self.root:getChildByName("Text_bz1_0_0")
    self.Text_bz1:setString("")
    self.Text_bz1_0:setString("")
    self.Text_bz1_0_0:setString("")

    self.Text_ys1:setString(g_tr("betterArmy"))
    self.Text_ys1_0:setString(g_tr("maxArmyCarry"))
    self.Text_bz:setString(g_tr("buffArmy"))

    self:addEvent()
end

function SelGeneralItemView:show(data, clickBack, isCross)
    self.data = data
    self.click = clickBack
    self.isCross = isCross or false

    local property = require("game.uilayer.godGeneral.GodGeneralMode"):instance():initEquiptSx(self.data.general_id)
    local gData = g_GeneralMode.GetBasicInfo(self.data.general_id, 1)
    local generalData = nil

    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()
    if mapStatus == changeMapScene.m_MapEnum.guildwar then
        generalData = g_crossGeneral.getGeneralById(self.data.general_id)
    elseif mapStatus == changeMapScene.m_MapEnum.guildwar then
        generalData = g_cityBattleGeneral.getGeneralById(self.data.general_id)
    else
        generalData = g_GeneralMode.getGeneralById(self.data.general_id)
    end

    self.Text_1:setString(g_tr(gData.general_name))
    if gData.general_quality == 6 then
        self.Text_1_0:setString("lv"..self.data.lv)
    else
        self.Text_1_0:setString("")
    end
    
    self.Text_ys2_0:setString(self:countMaxSoldier(self.data.general_id).."")
    if gData.general_type == 1 then
        self["Panel_yanse1"]:setVisible(true)
        self["Panel_yanse1Text_10"]:setString(property.force.sv.."")
        self["Panel_yanse1Text_10_0"]:setString("+"..property.force.av)
        self["Panel_yanse1Text_9"]:setString(g_tr("wu"))
        g_itemTips.tipStr(self["Panel_yanse1"],g_tr("wu"),g_tr("wuInfo"))
    else
        self["Panel_yanse2"]:setVisible(true)
        self["Panel_yanse2Text_10"]:setString(property.intelligence.sv.."")
        self["Panel_yanse2Text_10_0"]:setString("+"..property.intelligence.av)
        self["Panel_yanse2Text_9"]:setString(g_tr("zhi"))
        g_itemTips.tipStr(self["Panel_yanse2"],g_tr("zhi"),g_tr("zhiInfo"))
    end

    self["Panel_yanse4"]:setVisible(true)
    self["Panel_yanse4Text_10"]:setString(property.governing.sv.."")
    self["Panel_yanse4Text_10_0"]:setString("+"..property.governing.av)
    self["Panel_yanse4Text_9"]:setString(g_tr("tong"))
    g_itemTips.tipStr(self["Panel_yanse4"],g_tr("tong"),g_tr("tongInfo"))
 
    local soldierType = g_data.equip_skill[g_data.equipment[gData.general_item_id*100].equip_skill_id[1]].equip_arm_type
    if soldierType == 1 then
        self.Text_ys2:setString(g_tr("infantry"))
    elseif soldierType == 2 then
        self.Text_ys2:setString(g_tr("cavalry"))
    elseif soldierType == 3 then
        self.Text_ys2:setString(g_tr("archer"))
    elseif soldierType == 4 then
        self.Text_ys2:setString(g_tr("vehicles"))
    end

    self.Image_3:removeAllChildren()
    local item = self:createHeroHead(self.data.general_id*100+1)
    item:setPosition(self.Image_3:getContentSize().width/2, self.Image_3:getContentSize().height/2)
    self.Image_3:addChild(item)
    item:showGeneralServerStarLv(generalData.star_lv)
    
    local skillData = nil
    if generalData ~= nil then
    	if generalData.weapon_id > 0 then
    		skillData = g_data.equip_skill[g_data.equipment[generalData.weapon_id].equip_skill_id[1]]
            
            local txtRich = g_gameTools.createRichText(self.Text_bz1, "")
            local value = ""
            if skillData.equip_arm_type == gData.soldier_type or skillData.equip_arm_type == 6 then
                value = "|<#72,252,98#>"
                
            else
                value = "|<#255,255,255#>"
            end

            if g_data.buff[skillData.skill_buff_id[1]].buff_type == 1 then
                value = value..g_tr(skillData.skill_description,{num = skillData.num/100}).."%"
            elseif g_data.buff[skillData.skill_buff_id[1]].buff_type == 2 then
                value = value..g_tr(skillData.skill_description,{num = skillData.num})
            end
            value = value.."|"
            txtRich:setRichText(value)
        else
            self.Text_bz1:setString(g_tr("guild_war_get_nothing"))
    	end

    	if generalData.zuoji_id > 0 then
    		skillData = g_data.equip_skill[g_data.equipment[generalData.zuoji_id].equip_skill_id[1]]

            local txtRich = g_gameTools.createRichText(self.Text_bz1_0_0, "")
            local value = ""
            if skillData.equip_arm_type == gData.soldier_type or skillData.equip_arm_type == 6 then
                value = "|<#72,252,98#>"
                
            else
                value = "|<#255,255,255#>"
            end

            if g_data.buff[skillData.skill_buff_id[1]].buff_type == 1 then
                value = value..g_tr(skillData.skill_description,{num = skillData.num/100}).."%"
            elseif g_data.buff[skillData.skill_buff_id[1]].buff_type == 2 then
                value = value..g_tr(skillData.skill_description,{num = skillData.num})
            end
            value = value.."|"
            txtRich:setRichText(value)
        else
            self.Text_bz1_0_0:setString(g_tr("guild_war_get_nothing"))
    	end

    	if generalData.armor_id > 0 then
    		skillData = g_data.equip_skill[g_data.equipment[generalData.armor_id].equip_skill_id[1]]

            local txtRich = g_gameTools.createRichText(self.Text_bz1_0, "")
            txtRich:setRichSize(100)
            local value = ""
            if skillData.equip_arm_type == gData.soldier_type or skillData.equip_arm_type == 6 then
                value = "|<#72,252,98#>"
                
            else
                value = "|<#255,255,255#>"
            end

            if g_data.buff[skillData.skill_buff_id[1]].buff_type == 1 then
               value = value..g_tr(skillData.skill_description,{num = skillData.num/100}).."%"
            elseif g_data.buff[skillData.skill_buff_id[1]].buff_type == 2 then
                value = value..g_tr(skillData.skill_description,{num = skillData.num})
            end
            value = value.."|"
            txtRich:setRichText(value)
        else
            self.Text_bz1_0:setString(g_tr("guild_war_get_nothing"))
    	end
    end
end

function SelGeneralItemView:addEvent()

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

function SelGeneralItemView:setSelect(value)
    self.Image_fg:setVisible(value)
end

function SelGeneralItemView:getData()
    return self.data
end

function SelGeneralItemView:createHeroHead(heroId)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)

    return item
end

function SelGeneralItemView:countMaxSoldier(gid)
    if self.isCross == true then
        local generalData = g_GeneralMode.GetBasicInfo(gid, 1)
        return generalData.max_soldier
    else
        return g_ArmyMode.GetMaxArmyNum(gid)
    end
end

return SelGeneralItemView