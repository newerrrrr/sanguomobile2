local GroundItemView = class("GroundItemView")

function GroundItemView:ctor(mc, pos, generalCallback, armyCallback, maxArmy)
	self.defaultShow = ""
	self.layer = mc
	self.Panel_zhu1 = self.layer:getChildByName("Panel_zhu1")
	self.Panel_zhu1_Image_22 = self.Panel_zhu1:getChildByName("Image_22")
	self.Panel_zhu2 = self.layer:getChildByName("Panel_zhu2")
	self.Panel_zhu2_Image_3 = self.Panel_zhu2:getChildByName("Image_3")
	self.Panel_zhu2_Image_4 = self.Panel_zhu2:getChildByName("Image_4")
	self.Text_1 = self.layer:getChildByName("Text_1")
	self.Text_shibingmingc = self.layer:getChildByName("Text_shibingmingc")
	self.Image_5_Text_4 = self.layer:getChildByName("Image_5"):getChildByName("Text_4")
	self.Image_2 = self.layer:getChildByName("Image_2")
	self.Text_js = self.layer:getChildByName("Text_js")

	self:initItem()

	self.generalCallback = generalCallback
	self.armyCallback = armyCallback
	self.pos = pos
	self.maxArmy = maxArmy

	self:addEvent()
end

function GroundItemView:initItem()
	self.Text_1:setString(self.defaultShow)
	self.Text_shibingmingc:setString(self.defaultShow)
	self.Image_5_Text_4:setString("0/0")
	self.Text_js:setString(self.defaultShow)
	self.Panel_zhu1_Image_22:setVisible(false)
	self.Panel_zhu2_Image_3:setVisible(false)
end

function GroundItemView:lockView(maxArmy)
	if maxArmy < self.pos then
        local view = require("game.uilayer.drill.DrillLockView").new()
        self.Panel_01:addChild(view)
    end
end

function GroundItemView:show(data)
	self.data = data


	
	if self.data == nil then
		self:initItem()
		return
	end

	if self.data.general_id > 0 then
    	local gData = g_GeneralMode.GetBasicInfo(self.data.general_id, 1)
    	self.Text_1:setString(g_tr(gData.general_name))
    	self.Panel_zhu1_Image_22:setVisible(true)
    	local item = self:createHeroHead(self.data.general_id*100+1)
    	item:setPosition(self.Panel_zhu1_Image_22:getContentSize().width/2, self.Panel_zhu1_Image_22:getContentSize().height/2)
    	self.Panel_zhu1_Image_22:addChild(item)

    	local soldierType = g_data.equip_skill[g_data.equipment[gData.general_item_id*100].equip_skill_id[1]].equip_arm_type
    	self.Text_js:setString(g_tr("betterArmyUnit", {army=self:getSoldierTypeName(soldierType)}))
	else
		self.Text_1:setString("")
		self.Panel_zhu1_Image_22:setVisible(false)
		self.Text_js:setVisible(false)
	end

	if self.data.soldier_id > 0 then
		local gSoldier = g_data.soldier[self.data.soldier_id]
		self.Text_shibingmingc:setString(g_tr(gSoldier.soldier_name))
        
		local maxSoldier = g_ArmyMode.GetMaxArmyNum(self.data.general_id)
		self.Image_5_Text_4:setString(self.data.soldier_num.."/"..maxSoldier)
		self.Panel_zhu2_Image_3:setVisible(true)
		local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Soldier, self.data.soldier_id, 1)
		self.Panel_zhu2_Image_3:addChild(item)
		item:setPosition(self.Panel_zhu2_Image_3:getContentSize().width/2, self.Panel_zhu2_Image_3:getContentSize().height/2)
		item:setCountEnabled(false)

		self.Text_shibingmingc:setString(g_tr("armyEnterNumber"))
		self.Image_2:loadTexture(g_resManager.getResPath(gSoldier.img_type))
	end
end

function GroundItemView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Panel_zhu1 then
				if self.generalCallback ~= nil then
					if self.data == nil then
						self.generalCallback(0, self.pos)
					else
						self.generalCallback(self.data.general_id, self.pos)
					end
					
				end
			elseif sender == self.Panel_zhu2 then
				if self.armyCallback ~= nil then
					self.armyCallback(self.data, self.pos)
				end
			end
		end
	end

	self.Panel_zhu1:addTouchEventListener(proClick)
	self.Panel_zhu2:addTouchEventListener(proClick)
end

function GroundItemView:createHeroHead(heroId)
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, heroId, 1)
    item:setCountEnabled(false)

    return item
end

function GroundItemView:getSoldierTypeName(type)
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

return GroundItemView