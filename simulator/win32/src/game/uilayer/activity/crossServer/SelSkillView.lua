local SelSkillView = class("SelSkillView", require("game.uilayer.base.BaseLayer"))

function SelSkillView:ctor(clickCallback)
	SelSkillView.super.ctor(self)

	self.clickCallback = clickCallback

	self.layer = self:loadUI("battle_select_army1.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.text = self.root:getChildByName("text")
	self.close_btn = self.root:getChildByName("close_btn")

	self.Panel_1 = self.root:getChildByName("Panel_1")
	self.Text_1 = self.Panel_1:getChildByName("Text_1")
	self.Text_4 = self.Panel_1:getChildByName("Text_4")
	self.Text_1_0 = self.Panel_1:getChildByName("Text_1_0")
	self.ownedGen = self.Panel_1:getChildByName("Text_wj2")
	self.usedTimes = self.Panel_1:getChildByName("Text_cs2") 
	self.ListView_1 = self.Panel_1:getChildByName("ListView_1")
	self.Button_2 = self.Panel_1:getChildByName("Button_2")
	self.Text_3 = self.Button_2:getChildByName("Text_3")

	self.text:setString(g_tr("selSkillTop"))
	self.Text_1:setString(g_tr("skillDescInfo"))
	self.Text_4:setString("")
	self.Text_3:setString(g_tr("select"))
	self.Panel_1:getChildByName("Text_wj1"):setString(g_tr("SkillownedGen"))
	self.Panel_1:getChildByName("Text_cs1"):setString(g_tr("skillUsedTimes"))
	self.ownedGen:setString("") 
	self.usedTimes:setString("") 

	self.uiList = {}
	self.tem = {}

	self:initFun()
	self:addEvent()
end

function SelSkillView:initFun()

	self.click =function(data, sel, fun) 

		if sel == true then --取消
			if self.tem[2] ~= nil and self.tem[2].skillId == data.skillId then
				self.tem[2] = nil
			elseif self.tem[1].skillId == data.skillId then
				self.tem[1] = self.tem[2]
				self.tem[2] = nil
			end

			self.Text_4:setString("")
			fun(false) 

			if self.tem[1] then 
				self:updateSkillInfo(self.tem[1].generalId, self.tem[1].skillId) 
			elseif self.tem[2] then 
				self:updateSkillInfo(self.tem[2].generalId, self.tem[2].skillId) 
			else 
				self:updateSkillInfo(nil, nil) --clear
			end 

		else --选中
			if #self.tem >=2 then
				g_airBox.show(g_tr("notSelectTwoMoreSkill"))
				return
			end

			if self.tem[1] == nil then
				self.tem[1] = data
			else
				self.tem[2] = data
			end
			
			fun(true) 

			self:updateSkillInfo(data.generalId, data.skillId) 
		end  
	end
end

function SelSkillView:updateSkillInfo(genId, skillId)
	if self.txtRich == nil then
		self.txtRich = g_gameTools.createRichText(self.Text_4, "")
	end

	if nil == genId or nil == skillId then 
		self.txtRich:setRichText("")
		self.ownedGen:setString("") 
		self.usedTimes:setString("") 
		self.Text_1_0:setString(g_tr("selSkillNum", {num=(#self.tem).."/2"}))	
		return 
	end 

	local skillDesc, genName, skillCount = self:getSkillInfos(genId, skillId)

	self.txtRich:setRichText(skillDesc)

	self.ownedGen:setString(genName) 
	self.usedTimes:setString(""..skillCount) 
	self.Text_1_0:setString(g_tr("selSkillNum", {num=string.format("%d/2", #self.tem)}))
end 

function SelSkillView:show(skill, total_skill)
	self.skill = skill
	self.totalSkill = total_skill

	self.tem[1] = self.skill[1]
	self.tem[2] = self.skill[2]

	local len = 0
	if (#self.totalSkill)%4 ~= 0 then
		len = math.ceil((#self.totalSkill)/4)
	else
		len = (#self.totalSkill)/4
	end

	for i=1, len do
		local item = require("game.uilayer.activity.crossServer.SelSkillItemView").new(self.click)

		self.ListView_1:pushBackCustomItem(item)

		item:show(self.totalSkill[i*4-3], self.totalSkill[i*4-2], self.totalSkill[i*4-1], self.totalSkill[i*4], self.skill)

		table.insert(self.uiList, item)
	end 

	--默认显示第一个已选的技能信息
	if self.skill[1] then 
		self:updateSkillInfo(self.skill[1].generalId, self.skill[1].skillId)
	end 
end

function SelSkillView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.close_btn then
				self:close()
			elseif sender == self.Button_2 then
				local result = {}
				for k, v in pairs(self.uiList) do
					local s, d = v:getSel1()
					if s == true then
						table.insert(result,d)
					end

					s, d = v:getSel2()
					if s == true then
						table.insert(result,d)
					end

					s, d = v:getSel3()
					if s == true then
						table.insert(result,d)
					end

					s, d = v:getSel4()
					if s == true then
						table.insert(result,d)
					end
				end

				if #self.totalSkill >= 2 and #self.totalSkill > #self.skill then
					if #result < 2 then
						g_airBox.show(g_tr("sel2Skill"))
						return
					end
				end
				

				if self.clickCallback ~= nil then
					self.clickCallback(result)

					self:close()
				end
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)
	self.Button_2:addTouchEventListener(proClick)
end

--获取主动技描述,所属武将,及主动技次数(默认为1, 当有锦囊技能时,主动技次数加1)
function SelSkillView:getSkillInfos(genId, skillId)
	local skillDesc = ""
	local genName = ""
	local skillCount = 1 

	local serverData, idx  
	local genData = g_GeneralMode.GetData()
	for k, v in pairs(genData) do 
		if v.general_id == genId then 
			serverData = v 

			for i=1, 3 do 
				if serverData["cross_skill_id_"..i] == skillId then 
					idx = i 
				elseif serverData["cross_skill_id_"..i] == 1 then --当有锦囊技能时,主动技次数加1
					skillCount = 2 
					if genId == 10110 then --神诸葛亮
						skillCount = 3 
					end 
				end 
			end 
			break 
		end 
	end 

	local baseGen = g_data.general[genId*100+1] 
	if baseGen then 
		genName = g_tr(baseGen.general_name) 
	end 

	if serverData and idx then 
		local currentGeneral = {}
		currentGeneral.cdata = g_GeneralMode.getGeneralByOriginalId(serverData.general_id)
		currentGeneral.ndata = serverData
		local showData = require("game.uilayer.godGeneral.GodGeneralMode"):instance():getBattleSkillFormula(currentGeneral,idx) 
		skillDesc = showData.skill_desc_org 
	end 

	return skillDesc, genName, skillCount 
end 



return SelSkillView