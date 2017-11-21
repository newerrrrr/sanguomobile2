local FormationView = class("FormationView", require("game.uilayer.base.BaseLayer"))

local viewUI 
--battleType: 0 跨服战, 1:城战
function FormationView:ctor(battleType)
	FormationView.super.ctor(self)

	viewUI = self 

	self.battleType = battleType or 0 
	print("FormationView: battleType=", battleType)

	self.layer = self:loadUI("battle_select_army_xin1.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.txtTitle = self.root:getChildByName("title"):getChildByName("text")
	--self.Text_1 = self.root:getChildByName("Text_1")
	self.ListView_1 = self.root:getChildByName("ListView_1")

	self.Panel_37 = self.root:getChildByName("Panel_37")
	self.Text_83 = self.Panel_37:getChildByName("Text_83")
	self.Image_j1_0 = self.Panel_37:getChildByName("Image_j1_0")
	self.Text_ji1 = self.Panel_37:getChildByName("Text_ji1")
	self.Image_j2_0 = self.Panel_37:getChildByName("Image_j2_0")
	self.Text_ji2 = self.Panel_37:getChildByName("Text_ji2")
	self.Image_j1 = self.Panel_37:getChildByName("Image_j1")
	self.Image_j2 = self.Panel_37:getChildByName("Image_j2")

	self.Text_yjh = self.Panel_37:getChildByName("Text_yjh")
	self.Text_yjh:setString("")

	self.Button_gg = self.Panel_37:getChildByName("Button_gg")
	self.txtButton_gg = self.Button_gg:getChildByName("Text_87_0")
	self.Text_nr = self.Panel_37:getChildByName("Text_nr")
	self.Button_sss = self.Panel_37:getChildByName("Button_sss")
	self.txtButton_ss = self.Button_sss:getChildByName("Text_87")

	self.Text_83:setString(g_tr("selCrossSkill"))
	self.Text_ji1:setString("")
	self.Text_ji2:setString("")
	self.txtButton_gg:setString(g_tr("changeSkill"))
	self.txtButton_ss:setString(g_tr("closed"))
	self.Text_nr:setString(g_tr("selectInfo"))
	local strTitle = (battleType == 0) and g_tr("battleSetTitleInfo") or g_tr("cityBattleSetTitleInfo") 
	self.txtTitle:setString(strTitle)
	
	self.general = g_GeneralMode.GetData()

	self.mode = require("game.uilayer.activity.ActivityMode").new()

	self.selLayer = nil

	self.generalList = {}

	--跨服战和城战阵容数据结构一致 
	self.mode:reqArmyInfoByType(battleType, handler(self, self.updataUI))

	self:addEvent()
end

function FormationView:onExit()
	viewUI = nil 
end 

function FormationView:updataUI(data) 

	if nil == viewUI then return end 
	dump(data, "===updataUI")

	if self.battleType == 0 then 
		self.data = data.cross_army_info
	else 
		self.data = data.general_id_list
	end 

	if nil == self.data then
		self:close()
		return
	end

	self:initFun()
	self:initGeneral()
	self:initSkill()
end 


--是否可更换武将
function FormationView:isEnableChangeGeneral() 
	local isEnabled = false 
	local tipStr = ""

	if self.data then  
		if self.battleType == 0 then --跨服战
			tipStr = g_tr("notChangeGeneral") 
			local basicInfo = g_activityData.GetCrossBasicInfo()
			if basicInfo then 
				isEnabled = basicInfo.current_guild_info.round_status == 0 
			end 

		elseif self.battleType == 1 then --城战
			tipStr = g_tr("notChangeGeneral2") 
			local info = require("game.uilayer.cityBattle.CityBattleMode"):GetPrepareInfo()
			if info then 
			 isEnabled = (info.status==g_Consts.CityBattleStatus.SIGN_FIRST or info.status==g_Consts.CityBattleStatus.SIGN_NORMAL)
			end
		end 
	end 

	return isEnabled, tipStr
end 


function FormationView:initFun()
	if self.clickCallback then return end 

	self.clickCallback = function(layer)
		local isEnabled, tipStr = self:isEnableChangeGeneral()
		if not isEnabled then
			g_airBox.show(tipStr)
			return
		end

		self.selLayer = layer

		local insertData = false
		local result = {}
		
		for i=1, #self.selLayer:getData() do
			table.insert(result, {self.selLayer:getData()[i], true})
		end
		
		table.sort(self.general, function(a, b)
			local apower, aquality = self:countPower(a.general_id)			

			local bpower, bquality = self:countPower(b.general_id)

			if aquality == bquality then
				return apower > bpower
			else
				return aquality > bquality
			end
		end)

		for i=1, #self.general do
			local tag = false
			for j=1, 2 do
				for k=1, #self.data.army[j] do
					if self.general[i].general_id == self.data.army[j][k] then
						tag = true
						break
					end
				end

				if tag == true then
					break
				end
			end

			if tag == false then
				insertData = true
				table.insert(result, {self.general[i].general_id, false})
			end
		end

		if insertData == false then
			g_airBox.show(g_tr("noSelGeneral"))
			return
		end
		g_sceneManager.addNodeForUI(require("game.uilayer.activity.crossServer.SelGeneralView").new(result, self.sendGeneral))
	end

	--发送更换武将请求
	self.sendGeneral = function(result)
			self.mode:changeArmyGeneral(self.battleType, result, self.selLayer:getIdx()-1, handler(self, self.updataUI)) 
	end

	--更换城战技能
	self.sendSkill = function(result)
		self.mode:changeBattleSkill(self.battleType, result, self.updateSkill)
	end

	self.updateSkill = function(data) 
		if self.battleType == 0 then 
			self.data = data.cross_army_info
		else 
			self.data = data.general_id_list
		end 
		self:initSkill()
	end
end

function FormationView:initGeneral()
	local item = nil
	for i=1, 2 do
		if self.generalList[i] == nil then
			self.generalList[i] = require("game.uilayer.activity.crossServer.FormationItemView").new(i, self.clickCallback)

			self.ListView_1:pushBackCustomItem(self.generalList[i])
		end

		item = self.generalList[i]

		item:show(self.data.army[i])
	end
end

function FormationView:initSkill()
	if self.data.skill[1] ~= nil and tonumber(self.data.skill[1].skillId) ~= 0 then
		local skill = g_data.battle_skill[tonumber(self.data.skill[1].skillId)]
		self.Image_j1_0:loadTexture(g_resManager.getResPath(skill.skill_res))
		self.Image_j1_0:setVisible(true)
	else
		self.Image_j1_0:setVisible(false)
	end

	if self.data.skill[2] ~= nil and tonumber(self.data.skill[2].skillId) ~= 0 then
		local skill = g_data.battle_skill[tonumber(self.data.skill[2].skillId)]
		self.Image_j2_0:loadTexture(g_resManager.getResPath(skill.skill_res))
		self.Image_j2_0:setVisible(true)
	else
		self.Image_j2_0:setVisible(false)
	end

	if self.data.skill[1] == nil and self.data.skill[2] == nil and (#self.data.total_skill) <= 0 then
		self.Text_yjh:setString(g_tr("noBattleSkillIcon"))
		self.Button_gg:setVisible(false)
		self.Image_j1:setVisible(false)
		self.Image_j2:setVisible(false)
	else
		self.Text_yjh:setString("")
		self.Button_gg:setVisible(true)
		self.Image_j1:setVisible(true)
		self.Image_j2:setVisible(true)
	end
end

function FormationView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_sss then
				self:close()
			elseif sender == self.Button_gg then
				local isEnabled, tipStr = self:isEnableChangeGeneral()
				if not isEnabled then
					g_airBox.show(tipStr)
					return
				end
				local item = require("game.uilayer.activity.crossServer.SelSkillView").new(self.sendSkill)
				g_sceneManager.addNodeForUI(item)
				item:show(self.data.skill, self.data.total_skill)
			end
		end
	end
	self.Button_sss:addTouchEventListener(proClick)
	self.Button_gg:addTouchEventListener(proClick)
end

function FormationView:countPower(generalId)
	local basicData = g_GeneralMode.GetBasicInfo(generalId, 1)
	local generalData = g_GeneralMode.getGeneralById(generalId)

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

	return power, basicData.general_quality
end

return FormationView