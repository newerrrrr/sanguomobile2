local SelGeneralItemView = class("SelGeneralItemView", require("game.uilayer.base.BaseWidget"))

function SelGeneralItemView:ctor(clickCallback)
	self.layer = self:LoadUI("battle_select_army1_list2.csb")

	self.clickCallback = clickCallback

	for i=1, 2 do
		self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
		self["Panel_"..i.."_pic"] = self["Panel_"..i]:getChildByName("equip"):getChildByName("pic")
		self["Panel_"..i.."_Text_1"] = self["Panel_"..i]:getChildByName("equip"):getChildByName("Text_1")
		self["Panel_"..i.."_Text_z"] = self["Panel_"..i]:getChildByName("Text_z")
		self["Panel_"..i.."_Text_z_0"] = self["Panel_"..i]:getChildByName("Text_z_0")
		self["Panel_"..i.."_Text_z_2"] = self["Panel_"..i]:getChildByName("Text_z_2")
		self["Panel_"..i.."_Text_z_3"] = self["Panel_"..i]:getChildByName("Text_z_3")
		self["Panel_"..i.."_Text_z_2_0"] = self["Panel_"..i]:getChildByName("Text_z_2_0")
		self["Panel_"..i.."_Text_z_3_0"] = self["Panel_"..i]:getChildByName("Text_z_3_0")
		self["Panel_"..i.."_Text_z_3_0_0"] = self["Panel_"..i]:getChildByName("Text_z_3_0_0")
		self["Panel_"..i.."_Image_j1"] = self["Panel_"..i]:getChildByName("Image_j1")
		self["Panel_"..i.."_Image_j2"] = self["Panel_"..i]:getChildByName("Image_j2")
		self["Panel_"..i.."_Image_j3"] = self["Panel_"..i]:getChildByName("Image_j3")
		self["Panel_"..i.."_Image_j4"] = self["Panel_"..i]:getChildByName("Image_j4")
		self["Panel_"..i.."_Image_j5"] = self["Panel_"..i]:getChildByName("Image_j5")
		self["Panel_"..i.."_Image_j6"] = self["Panel_"..i]:getChildByName("Image_j6")
		self["Panel_"..i.."_Text_nr1"] = self["Panel_"..i]:getChildByName("Text_nr1")
		self["Panel_"..i.."_Text_nr1"]:setString("")

		self["Panel_"..i.."_Image_ggg1_0"] = self["Panel_"..i]:getChildByName("Image_ggg1_0")
		self["Panel_"..i.."_Image_17"] = self["Panel_"..i]:getChildByName("Image_17")

		self["Panel_"..i.."_Text_z"]:setString(g_tr("generalPower"))
		self["Panel_"..i.."_Text_z_2"]:setString(g_tr("betterArmy"))
		self["Panel_"..i.."_Text_z_2_0"]:setString(g_tr("maxArmyCarry"))
		self["Panel_"..i.."_Image_17"]:setVisible(false)
	end

	self:addEvent()
end

function SelGeneralItemView:show(data1, data2)
	self.data1 = data1
	self.data2 = data2

	self:setData("Panel_1", data1)
	self:setData("Panel_2", data2)
end

function SelGeneralItemView:setData(ui, data)
	if data == nil then
		self[ui..""]:setVisible(false)
		return
	end

	local basicData = g_GeneralMode.GetBasicInfo(data[1], 1)
	local generalData = g_GeneralMode.getGeneralById(data[1])

	local item = self:createHeroHead(data[1]*100+1, generalData.star_lv)
    item:setPosition(self[ui.."_pic"]:getContentSize().width/2, self[ui.."_pic"]:getContentSize().height/2)
    self[ui.."_pic"]:addChild(item)
    self[ui.."_Text_1"]:setString(item:getName())

	local power = basicData.power + (generalData.lv - 1)*95

	if generalData.weapon_id ~= 0 then
		power = power + g_data.equipment[generalData.weapon_id].power
	end

	if generalData.armor_id ~= 0 then
		power = power + g_data.equipment[generalData.armor_id].power
	end

	if generalData.horse_id ~= 0 then
		power = power + g_data.equipment[generalData.horse_id].power
	end

	if generalData.zuoji_id ~= 0 then
		power = power + g_data.equipment[generalData.zuoji_id].power
	end

	self[ui.."_Text_z_0"]:setString(power.."")

	local soldierType = g_data.equip_skill[g_data.equipment[basicData.general_item_id*100].equip_skill_id[1]].equip_arm_type
	self[ui.."_Text_z_3"]:setString(self:getSoldierTypeName(soldierType))

	self[ui.."_Text_z_3_0"]:setString(basicData.max_soldier.."")

	if data[2] == false then
		self[ui.."_Image_ggg1_0"]:setVisible(false)
	else
		self[ui.."_Image_ggg1_0"]:setVisible(true)
	end

	if generalData.cross_skill_id_1 == 0 and generalData.cross_skill_id_2 == 0 and generalData.cross_skill_id_3 == 0 then
    	self[ui.."_Text_nr1"]:setString(g_tr("noBattleSkill"))

    	self[ui.."_Image_j1"]:setVisible(false)
		self[ui.."_Image_j2"]:setVisible(false)
		self[ui.."_Image_j3"]:setVisible(false)
		self[ui.."_Image_j4"]:setVisible(false)
		self[ui.."_Image_j5"]:setVisible(false)
		self[ui.."_Image_j6"]:setVisible(false)
		return
    end

	if generalData.cross_skill_id_1 ~= 0 then
		self[ui.."_Image_j1"]:setVisible(true)
    	self:loadSkill(ui.."_Image_j2", generalData.cross_skill_id_1)
    else
    	self[ui.."_Image_j1"]:setVisible(false)
		self[ui.."_Image_j2"]:setVisible(false)
    end

    if generalData.cross_skill_id_2 ~= 0 then
    	self[ui.."_Image_j3"]:setVisible(true)
    	self:loadSkill(ui.."_Image_j4", generalData.cross_skill_id_2)
    else
    	self[ui.."_Image_j3"]:setVisible(false)
		self[ui.."_Image_j4"]:setVisible(false)
    end
    
    if generalData.cross_skill_id_3 ~= 0 then
    	self[ui.."_Image_j5"]:setVisible(true)
    	self:loadSkill(ui.."_Image_j6", generalData.cross_skill_id_3)
    else
    	self[ui.."_Image_j5"]:setVisible(false)
		self[ui.."_Image_j6"]:setVisible(false)
    end
end

function SelGeneralItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Panel_1 then
				if self.clickCallback ~= nil then
					self.clickCallback(self.data1, handler(self, self.update1))
				end
			elseif sender == self.Panel_2 then
				if self.clickCallback ~= nil then
					self.clickCallback(self.data2, handler(self, self.update2))
				end
			end
		end
	end

	self.Panel_1:addTouchEventListener(proClick)
	self.Panel_2:addTouchEventListener(proClick)
end

function SelGeneralItemView:update1(data)
	self.data1 = data
	self:setData("Panel_1", self.data1)
end

function SelGeneralItemView:update2(data)
	self.data2 = data
	self:setData("Panel_2", self.data2)
end

function SelGeneralItemView:getData1()
	return self.data1
end

function SelGeneralItemView:getData2()
	return self.data2
end

function SelGeneralItemView:getSoldierTypeName(type)
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

function SelGeneralItemView:createHeroHead(heroId, star)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)
    item:showGeneralServerStarLv(star)
    return item
end

function SelGeneralItemView:loadSkill(ui, data)
	local skill = g_data.battle_skill[data]
	self[ui..""]:setVisible(true)
	self[ui..""]:loadTexture(g_resManager.getResPath(skill.skill_res))
end

return SelGeneralItemView