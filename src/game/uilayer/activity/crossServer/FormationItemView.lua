local FormationItemView = class("FormationItemView", require("game.uilayer.base.BaseWidget"))

function FormationItemView:ctor(idx, clickCallback)
	self.clickCallback = clickCallback
	self.idx = idx

	self.layer = self:LoadUI("battle_select_item_xin1_list1.csb")

	self.item = self.layer:getChildByName("item")
	self.title = self.item:getChildByName("title")
	self.editText = self.item:getChildByName("editText")
	self.title:setString(g_tr("corps_"..idx))
	self.editText:setString(g_tr("MapPosSaveEdit"))

	self.generals_list = self.item:getChildByName("generals_list")

	for i=1, 6 do
		self["item_"..i] = self.generals_list:getChildByName("item_"..i)--Image_sb
		self["item_"..i.."_Image_sb"] = self["item_"..i]:getChildByName("Image_sb")
		self["item_"..i.."_pic_0"] = self["item_"..i]:getChildByName("pic_0")
		self["item_"..i.."_text_num"] = self["item_"..i]:getChildByName("text_num")
		self["item_"..i.."_text_name"] = self["item_"..i]:getChildByName("text_name")
		self["item_"..i.."_Image_15"] = self["item_"..i]:getChildByName("Image_15")
		self["item_"..i.."_Image_15_0"] = self["item_"..i]:getChildByName("Image_15_0")
		self["item_"..i.."_Image_15_1"] = self["item_"..i]:getChildByName("Image_15_1")
		self["item_"..i.."_Image_15_sss"] = self["item_"..i]:getChildByName("Image_15_sss")
		self["item_"..i.."_Image_16_sss"] = self["item_"..i]:getChildByName("Image_16_sss")
		self["item_"..i.."_Image_17_sss"] = self["item_"..i]:getChildByName("Image_17_sss")
		self["item_"..i.."_Image_jia"] = self["item_"..i]:getChildByName("Image_jia")
		self["item_"..i.."_text_wu"] = self["item_"..i]:getChildByName("text_wu")
		self["item_"..i.."_text_wu"]:setString("")
	end

	self:addEvent()
end

function FormationItemView:show(data)
	self.data = data
	
	--local curT = g_clock.getCurServerTime()
	for i=1, 6 do
		self:setData("item_"..i, data[i])
	end

	--print(g_clock.getCurServerTime() - curT, "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
end

function FormationItemView:setData(ui, data)
	self[ui.."_pic_0"]:removeAllChildren()
	if data == nil then
		self[ui.."_pic_0"]:removeAllChildren()
		self[ui.."_text_name"]:setString("")
		self[ui.."_text_num"]:setString("")
		self[ui.."_Image_sb"]:setVisible(false)
		self[ui.."_Image_15_sss"]:setVisible(false)
		self[ui.."_Image_16_sss"]:setVisible(false)
		self[ui.."_Image_17_sss"]:setVisible(false)
		self[ui.."_Image_15"]:setVisible(false)
		self[ui.."_Image_15_0"]:setVisible(false)
		self[ui.."_Image_15_1"]:setVisible(false)
		return
	end

	self[ui.."_Image_jia"]:setVisible(false)
	self[ui.."_Image_sb"]:setVisible(true)
	self[ui.."_Image_15_sss"]:setVisible(true)
	self[ui.."_Image_16_sss"]:setVisible(true)
	self[ui.."_Image_17_sss"]:setVisible(true)
	self[ui.."_Image_15"]:setVisible(true)
	self[ui.."_Image_15_0"]:setVisible(true)
	self[ui.."_Image_15_1"]:setVisible(true)

	local gData = g_GeneralMode.GetBasicInfo(data, 1)
	local generalData = g_GeneralMode.getGeneralById(data)
	
	local item = self:createHeroHead(data*100+1, generalData.star_lv)
    item:setPosition(self[ui.."_pic_0"]:getContentSize().width/2, self[ui.."_pic_0"]:getContentSize().height/2)
    self[ui.."_pic_0"]:addChild(item)

    self[ui.."_text_name"]:setString(item:getName())
    self[ui.."_text_num"]:setString(g_tr("crossSKillInfo"))

    if generalData.cross_skill_id_1 == 0 and generalData.cross_skill_id_2 == 0 and generalData.cross_skill_id_3 == 0 then
    	self[ui.."_Image_15_sss"]:setVisible(false)
		self[ui.."_Image_15"]:setVisible(false)
		self[ui.."_Image_16_sss"]:setVisible(false)
		self[ui.."_Image_15_0"]:setVisible(false)
		self[ui.."_Image_17_sss"]:setVisible(false)
		self[ui.."_Image_15_1"]:setVisible(false)
		self[ui.."_text_wu"]:setString(g_tr("none"))
		return
	else
		self[ui.."_Image_15_sss"]:setVisible(true)
		self[ui.."_Image_15"]:setVisible(true)
		self[ui.."_Image_16_sss"]:setVisible(true)
		self[ui.."_Image_15_0"]:setVisible(true)
		self[ui.."_Image_17_sss"]:setVisible(true)
		self[ui.."_Image_15_1"]:setVisible(true)
		self[ui.."_text_wu"]:setString("")
    end

    if generalData.cross_skill_id_1 ~= 0 then
    	self:loadSkill(ui.."_Image_15_sss", generalData.cross_skill_id_1)
    else
    	self[ui.."_Image_15_sss"]:setVisible(false)
		self[ui.."_Image_15"]:setVisible(false)
    end

    if generalData.cross_skill_id_2 ~= 0 then
    	self:loadSkill(ui.."_Image_16_sss", generalData.cross_skill_id_2)
    else
    	self[ui.."_Image_16_sss"]:setVisible(false)
		self[ui.."_Image_15_0"]:setVisible(false)
    end
    
    if generalData.cross_skill_id_3 ~= 0 then
    	self:loadSkill(ui.."_Image_17_sss", generalData.cross_skill_id_3)
    else
    	self[ui.."_Image_17_sss"]:setVisible(false)
		self[ui.."_Image_15_1"]:setVisible(false)
    end
end

function FormationItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.clickCallback ~= nil then
				self.clickCallback(self)
			end
		end
	end

	self.item:addTouchEventListener(proClick)
end

function FormationItemView:getData()
	return self.data
end

function FormationItemView:getIdx()
	return self.idx
end

function FormationItemView:loadSkill(ui, data)
	local skill = g_data.battle_skill[data]
	self[ui..""]:loadTexture(g_resManager.getResPath(skill.skill_res))
end

function FormationItemView:createHeroHead(heroId, star)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)
    item:showGeneralServerStarLv(star)

    return item
end

return FormationItemView