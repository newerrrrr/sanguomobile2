local SelSkillItemView = class("SelSkillItemView", require("game.uilayer.base.BaseWidget"))

function SelSkillItemView:ctor(clickCallback)
	self.layer = self:LoadUI("battle_select_army1_list1.csb")
	self.clickCallback = clickCallback
	for i=1, 4 do
		self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
		self["Panel_"..i.."_Image_1_0"] = self["Panel_"..i]:getChildByName("Image_1_0")
		self["Panel_"..i.."_Text_1"] = self["Panel_"..i]:getChildByName("Text_1")
		self["Panel_"..i.."_Image_fg"] = self["Panel_"..i]:getChildByName("Image_fg")
		self["Panel_"..i.."_Image_3"] = self["Panel_"..i]:getChildByName("Image_3")
		self["Panel_"..i.."_Image_3_0"] = self["Panel_"..i]:getChildByName("Image_3_0")

		self["Panel_"..i.."_Image_3"]:setVisible(false)
		self["Panel_"..i.."_Image_3_0"]:setVisible(false)
		self["Panel_"..i.."_Image_fg"]:setVisible(false)
	end

	self:addEvent()
end

function SelSkillItemView:show(data1, data2, data3, data4, skill)
	self.data1 = data1
	self.data2 = data2
	self.data3 = data3
	self.data4 = data4
	self.skill = skill

	self.sel1 = false
	self.sel2 = false
	self.sel3 = false
	self.sel4 = false

	local function isSkillSelected(data)
		
		if nil == data then return false end 

		if skill[1] and skill[1].generalId == data.generalId and skill[1].skillId == data.skillId then 
			return true 
		end 

		if skill[2] and skill[2].generalId == data.generalId and skill[2].skillId == data.skillId then 
			return true 
		end 

		return false  		
	end 

	self.sel1 = isSkillSelected(data1)
	self.sel2 = isSkillSelected(data2)
	self.sel3 = isSkillSelected(data3)
	self.sel4 = isSkillSelected(data4)

	self:setData("Panel_1", self.data1)
	self:setData("Panel_2", self.data2)
	self:setData("Panel_3", self.data3)
	self:setData("Panel_4", self.data4)

	self:update1(self.sel1)
	self:update2(self.sel2)
	self:update3(self.sel3)
	self:update4(self.sel4)
end

function SelSkillItemView:setData(ui, data)
	if data == nil then
		self[ui..""]:setVisible(false)
		return
	end

	self[ui..""]:setVisible(true)

	local skillData = g_data.battle_skill[data.skillId]
	self[ui.."_Image_1_0"]:loadTexture(g_resManager.getResPath(skillData.skill_res))
	self[ui.."_Text_1"]:setString(g_tr(skillData.skill_name))

	if (self.skill[1] ~= nil and data.skillId == self.skill[1].skillId) or (self.skill[2] ~= nil and data.skillId == self.skill[2].skillId) then
		self[ui.."_Image_fg"]:setVisible(true)
		self[ui.."_Image_3"]:setVisible(true)
	end
end

function SelSkillItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self["Panel_1"] then
				if self.clickCallback ~= nil then
					self.clickCallback(self.data1, self.sel1, handler(self, self.update1))
				end
			elseif sender == self["Panel_2"] then
				if self.clickCallback ~= nil then
					self.clickCallback(self.data2, self.sel2, handler(self, self.update2))
				end
			elseif sender == self["Panel_3"] then
				if self.clickCallback ~= nil then
					self.clickCallback(self.data3, self.sel3, handler(self, self.update3))
				end
			elseif sender == self["Panel_4"] then
				if self.clickCallback ~= nil then
					self.clickCallback(self.data4, self.sel4, handler(self, self.update4))
				end
			end
		end
	end

	self["Panel_1"]:addTouchEventListener(proClick)
	self["Panel_2"]:addTouchEventListener(proClick)
	self["Panel_3"]:addTouchEventListener(proClick)
	self["Panel_4"]:addTouchEventListener(proClick)
end

function SelSkillItemView:update1(sel)
	self.sel1 = sel
	if self.sel1 == true then
		self["Panel_1".."_Image_fg"]:setVisible(true)
		self["Panel_1".."_Image_3"]:setVisible(true)
	else
		self["Panel_1".."_Image_fg"]:setVisible(false)
		self["Panel_1".."_Image_3"]:setVisible(false)
	end
end

function SelSkillItemView:update2(sel)
	self.sel2 = sel
	if self.sel2 == true then
		self["Panel_2".."_Image_fg"]:setVisible(true)
		self["Panel_2".."_Image_3"]:setVisible(true)
	else
		self["Panel_2".."_Image_fg"]:setVisible(false)
		self["Panel_2".."_Image_3"]:setVisible(false)
	end
end

function SelSkillItemView:update3(sel)
	self.sel3 = sel
	if self.sel3 == true then
		self["Panel_3".."_Image_fg"]:setVisible(true)
		self["Panel_3".."_Image_3"]:setVisible(true)
	else
		self["Panel_3".."_Image_fg"]:setVisible(false)
		self["Panel_3".."_Image_3"]:setVisible(false)
	end
end

function SelSkillItemView:update4(sel)
	self.sel4 = sel
	if self.sel4 == true then
		self["Panel_4".."_Image_fg"]:setVisible(true)
		self["Panel_4".."_Image_3"]:setVisible(true)
	else
		self["Panel_4".."_Image_fg"]:setVisible(false)
		self["Panel_4".."_Image_3"]:setVisible(false)
	end
end

function SelSkillItemView:getSel1()
	return self.sel1, self.data1
end

function SelSkillItemView:getSel2()
	return self.sel2, self.data2
end

function SelSkillItemView:getSel3()
	return self.sel3, self.data3
end

function SelSkillItemView:getSel4()
	return self.sel4, self.data4
end

return SelSkillItemView