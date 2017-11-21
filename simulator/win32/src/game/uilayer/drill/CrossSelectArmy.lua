local CrossSelectArmy = class("CrossSelectArmy", require("game.uilayer.base.BaseLayer"))

function CrossSelectArmy:ctor(soldierData, armyUnitData, postArmy)
	CrossSelectArmy.super.ctor(self)

	local crossPlayer = g_guildWarPlayerData.GetData()

	self.soldierData = soldierData[1]
	self.armyUnitData = armyUnitData
	self.generalData = g_GeneralMode.GetBasicInfo(self.armyUnitData.general_id, 1)

	local max_plus = 0
	local plus_percent = 0

	if crossPlayer.buff.troop_max_plus ~= nil then
		max_plus = crossPlayer.buff.troop_max_plus
	end

	if crossPlayer.buff.troop_max_plus_percent ~= nil then
		plus_percent = crossPlayer.buff.troop_max_plus_percent
	end

	self.maxArmy = (self.generalData.max_soldier + max_plus) * (plus_percent+10000)/10000
	self.maxArmy = math.round(self.maxArmy)
	self.postArmy = postArmy

	self.sid1 = tonumber(self.generalData.soldier_type.."0019")
	self.sid2 = tonumber(self.generalData.soldier_type.."0020")

	self.selectType = self.sid1

	self.layer = self:loadUI("guildwar_juntuan_info.csb")
	self.root = self.layer:getChildByName("scale_node")

	self.Text_1 = self.root:getChildByName("Text_1")
	self.Button_x = self.root:getChildByName("Button_x")

	self.Panel_1 = self.root:getChildByName("Panel_1")
	self.Text_sl = self.Panel_1:getChildByName("Text_sl")
	self.Text_4 = self.Panel_1:getChildByName("Text_4")
	self.Slider_1 = self.Panel_1:getChildByName("Slider_1")

	self.Image_t1_0 = self.root:getChildByName("Image_t1_0")
	self.Image_t1faguang = self.root:getChildByName("Image_t1faguang")
	self.Image_dh1 = self.root:getChildByName("Image_dh1")
	self.Image_t2_0 = self.root:getChildByName("Image_t2_0")
	self.Image_t2faguang = self.root:getChildByName("Image_t2faguang")
	self.Image_dh2 = self.root:getChildByName("Image_dh2")

	self.Image_t1faguang:setVisible(false)
	self.Image_t2faguang:setVisible(false)
	self.Image_dh1:setVisible(false)
	self.Image_dh2:setVisible(false)

	self.Button_3 = self.root:getChildByName("Button_3")
	self.Text_28 = self.Button_3:getChildByName("Text_28")

	self.Text_1:setString(g_tr("itemTipsDefaultTitle"))
	self.Text_sl:setString(g_tr("armyNumber"))
	self.Text_28:setString(g_tr("confirm"))

	self:addEvent()
	self:setData()
end

function CrossSelectArmy:setData()
	local curNum = 0
	if self.armyUnitData ~= nil then
		curNum = self.armyUnitData.soldier_num
	end

    local max = curNum + self.soldierData.num

    if max > self.maxArmy then
    	self.Text_4:setString(curNum.."/"..self.maxArmy)
    	self.Slider_1:setPercent(curNum*100/self.maxArmy)
    else
    	self.Text_4:setString(curNum.."/"..max)
    	self.Slider_1:setPercent(curNum*100/max)
    end
	
	

	local item1 = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Soldier, self.sid1, 1)
	local item2 = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Soldier, self.sid2, 1)

	self.Image_t1_0:addChild(item1)
	item1:setPosition(self.Image_t1_0:getContentSize().width/2, self.Image_t1_0:getContentSize().height/2)
	item1:setCountEnabled(false)

	self.Image_t2_0:addChild(item2)
	item2:setPosition(self.Image_t2_0:getContentSize().width/2, self.Image_t2_0:getContentSize().height/2)
	item2:setCountEnabled(false)

	if self.armyUnitData ~= nil and self.armyUnitData.soldier_id ~= nil then
		if self.sid1 == self.armyUnitData.soldier_id then
			self.Image_t1faguang:setVisible(true)
			self.Image_dh1:setVisible(true)
			self.selectType = self.sid1
		elseif self.sid2 == self.armyUnitData.soldier_id then
			self.Image_t2faguang:setVisible(true)
			self.Image_dh2:setVisible(true)
			self.selectType = self.sid2
		end
	end
end

function CrossSelectArmy:addEvent()
	local cur = 0
    if self.armyUnitData ~= nil then
    	cur = self.armyUnitData.soldier_num
    else
    	cur = 0
    end

    
    local max = cur + self.soldierData.num
    if max > self.maxArmy then
    	max = self.maxArmy
    end
    local num = math.ceil(self.Slider_1:getPercent() * (max)/100)

    local function valueChange(sender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
            num = math.ceil(self.Slider_1:getPercent() * (max)/100)
            if num >= max then
                num = max
                self.Slider_1:setPercent(num*100/max)
            end
            self.Text_4:setString(num.."/"..max)
        end
	end

	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_x then
				self:close()
			elseif sender == self.Image_t1_0 then
				self.Image_t1faguang:setVisible(true)
				self.Image_t2faguang:setVisible(false)
				self.Image_dh1:setVisible(true)
				self.Image_dh2:setVisible(false)
				self.selectType = self.sid1
			elseif sender == self.Image_t2_0 then 
				self.Image_t1faguang:setVisible(false)
				self.Image_t2faguang:setVisible(true)
				self.Image_dh1:setVisible(false)
				self.Image_dh2:setVisible(true)
				self.selectType = self.sid2
			elseif self.Button_3 == sender then
				print(num, max * math.ceil(self.Slider_1:getPercent()/100, "1111111111111111111111"))
				num = math.ceil(self.Slider_1:getPercent() * (max)/100)
				if self.postArmy ~= nil then
					self.postArmy(num, self.selectType)
				end
				self:close()
			end
		end
	end

	self.Button_x:addTouchEventListener(proClick)
	self.Image_t1_0:addTouchEventListener(proClick)
	self.Image_t2_0:addTouchEventListener(proClick)
	self.Button_3:addTouchEventListener(proClick)
	self.Slider_1:addEventListener(valueChange)
end

return CrossSelectArmy