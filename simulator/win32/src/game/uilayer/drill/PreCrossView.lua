local PreCrossView = class("PreCrossView", require("game.uilayer.base.BaseLayer"))

function PreCrossView:ctor(closeWin)
	PreCrossView.super.ctor(self)

	self.closeWin = closeWin
	self.mode = require("game.uilayer.drill.DrillMode").new()

	self.layer = self:loadUI("guildwar_junt1.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.close_btn = self.root:getChildByName("close_btn")
	self.Text_1 = self.root:getChildByName("Text_1")
	self.Text_wbs = self.root:getChildByName("Text_wbs")
	self.Button_1 = self.root:getChildByName("Button_1")
	self.Text_11 = self.Button_1:getChildByName("Text_11")

	for i=1, 6 do
		self["Panel_"..i] = self.root:getChildByName("Panel_"..i)

		self["Panel_"..i]:setVisible(false)
	end

	self.Text_1:setString(g_tr("preCrossSelectArmy"))
	self.Text_wbs:setString(g_tr("preCrossGroup"))
	self.Text_11:setString(g_tr("confirm"))

	self.armyData = g_ArmyMode.GetData()
	self.armyUnitData = g_ArmyUnitMode.GetData()

	self.group = {}

	--self.result = {}

	self.sel1 = nil
	self.sel2 = nil
	self.lay1 = nil
	self.lay2 = nil

	self:initFun()
	self:setData()
	self:addEvent()
end

function PreCrossView:initFun()
	self.clickCallback = function(layer, data)
		if self.lay1 == layer then
			self.sel1 = nil
			self.lay1:setSelected(false)
			self.lay1 = nil
			return
		end

		if self.lay2 == layer then
			self.sel2 = nil
			self.lay2:setSelected(false)
			self.lay2 = nil
			return
		end

		if self.sel1 == nil then
			self.sel1 = data
			self.lay1 = layer
			self.lay1:setSelected(true)
			return
		end

		if self.sel2 == nil then
			self.sel2 = data
			self.lay2 = layer
			self.lay2:setSelected(true)
			return
		end
	end

	self.enterWar = function()
		if self.closeWin ~= nil then
			self.closeWin()
		end
		self:close()
		require("game.mapguildwar.changeMapScene").changeToWorld()
	end
end

function PreCrossView:setData()
	local len = 0
	for key, value in pairs(self.armyData) do
		if value.status == 0 then
			table.insert(self.group, value)
			len = len + 1
		end
	end

	table.sort(self.group, function(a,b)
		return a.position < b.position
	end)

	local index = 1
	for i=1, 6 do
		if i <= len then
			local list = self:getGeneralList(self.group[i].id)
			if self.group[i].leader_general_id > 0 then
				self["Panel_"..index]:setVisible(true)
				local item = require("game.uilayer.drill.PreCrossItemView").new(self["Panel_"..index], list, self.group[i], self.clickCallback)
				if index <= 2 then
					item:setSelected(true)
					self["sel"..index] = list
					self["lay"..index] = item
				end
				index = index + 1
			end
		end
	end
end

function PreCrossView:addEvent()
	local function proClick(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			elseif sender == self.Button_1 then
				local armyId = {}
				if self.sel1 ~= nil then
					table.insert(armyId, self.sel1[1].army_id)
				end

				if self.sel2 ~= nil then
					table.insert(armyId, self.sel2[1].army_id)
				end
				
				if #armyId == 0 then
					g_airBox.show(g_tr("gotoDrillView"))
				else
					self.mode:crossEnterBattlefield(armyId, self.enterWar)
				end
			end
		end
	end
	self.close_btn:addTouchEventListener(proClick)
	self.Button_1:addTouchEventListener(proClick)
end

function PreCrossView:getGeneralList(armyId)
	local result = {}
	for key, value in pairs(self.armyUnitData) do
		if value.army_id == armyId then
			table.insert(result, value)
		end
	end

	return result
end

return PreCrossView