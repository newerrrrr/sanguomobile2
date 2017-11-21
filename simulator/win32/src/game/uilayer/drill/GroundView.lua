local GroundView = class("GroundView", require("game.uilayer.base.BaseLayer"))

function GroundView:ctor(callback, curTab)

	GroundView.super.ctor(self)

	g_groundData.SetView(self)

	self.callback = callback

	self.curTab = curTab or 1

	--初始化方法
    self:initFun()

	self:init()

	self.layer = self:loadUI("xiaochang_1.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.Text_jc1 = self.root:getChildByName("Text_jc1")

	--title
	for i=1, self.titleNum do
		self["Button_juntuan0"..i] = self.root:getChildByName("Button_juntuan0"..i)
		self["Button_juntuan0"..i.."_Text_1"] = self["Button_juntuan0"..i]:getChildByName("Text_1")
		--锁
		self["Button_juntuan0"..i.."_Image_s1"] = self["Button_juntuan0"..i]:getChildByName("Image_s1")

		self["Button_juntuan0"..i.."_Text_1"]:setString(g_tr("corp")..g_tr("num"..i))
	end

	self.Button_1 = self.root:getChildByName("Button_1")
	self.Panel_renwu = self.root:getChildByName("Panel_renwu")

	for i=1, 10 do
		self["Panel_renwu_Text"..i] = self.Panel_renwu:getChildByName("Text_"..i)
	end
	self.Panel_renwu_Text1:setString(g_tr("armyHead"))
    self.Panel_renwu_Text3:setString(g_tr("armyEnter"))
    self.Panel_renwu_Text5:setString(g_tr("armyFightForce"))
    self.Panel_renwu_Text7:setString(g_tr("carry"))
    self.Panel_renwu_Text9:setString(g_tr("armyAllNumber"))
    self.Panel_renwu_Text2:setString(self.defaultShow)
    self.Panel_renwu_Text4:setString(self.defaultShow)
    self.Panel_renwu_Text6:setString(self.defaultShow)
    self.Panel_renwu_Text8:setString(self.defaultShow)
    self.Panel_renwu_Text10:setString(self.defaultShow)

    self.Button_kuaisu = self.root:getChildByName("Button_kuaisu")
    self.Button_kuaisu_Text_42 = self.Button_kuaisu:getChildByName("Text_42")
    self.Button_kuaisu_Text_42:setString(g_tr("quickAdd"))
    self.Button_ckyby = self.root:getChildByName("Button_ckyby")
    self.Button_ckyby_Text_42 = self.Button_ckyby:getChildByName("Text_42")
    self.Button_ckyby_Text_42:setString(g_tr("seePrepareArmy"))

    self.Text_y1 = self.root:getChildByName("Text_y1")
    self.Text_y2 = self.root:getChildByName("Text_y2")
    self.Text_y1:setString(g_tr("armyLeft"))
    self.Text_y2:setString(self.defaultShow)

    for i=1, 6 do
    	self["Panel_0"..i] = require("game.uilayer.drill.GroundItemView").new(self.root:getChildByName("Panel_0"..i), i, self.selectGeneral, self.selectArmy, self.maxArmyNum)
    end

    self:addEvent()

    g_groundData.RequestSycData()
end

--一些初始化的数据
function GroundView:init()
	self.defaultShow = "-"
	self.property = {g_tr("attack"), g_tr("defend"),g_tr("life"),g_tr("atkRange"), g_tr("speed"), g_tr("carry")}
	self.titleNum = 6
	self.itemNum = 6
	self.mode = require("game.uilayer.drill.DrillMode").new()
	self.buff = g_BuffMode.GetData()
end

function GroundView:show(data)
	self.data = data

	if self.data.GeneralData == nil or self.data.PlayerData == nil or 
		self.data.ArmyData == nil or self.data.ArmyUnitData == nil or 
		self.data.SoldierData == nil then
    	if self.callback ~= nil then
        	self.callback()
        end
        g_groundData.SetView(nil)
        self:close()
        return
    end

    --计算当前的军团数和武将带兵数
    self:countTabAndArmyNumber()

    --解析所有军团
    self:updateData()

    --填充数据
    self:setContent()

    --军团信息
    self:updatePropertyData()
end

function GroundView:initFun()
	self.getData = function()
		g_groundData.RequestSycData()
	end

	self.selectGeneral = function(gid, pos)
		if self.data == nil then
			return
		end

		if pos > self.maxArmyNum then
            return
        end

        self.curPos = pos

        self:showGeneralView(gid)
	end

	self.selectArmy = function(data, pos)
		if self.data == nil then
			return
		end

		if pos > self.maxArmyNum then
            return
        end

        self.curPos = pos

        self:showSoldierView(data)
	end

	self.postSetGeneral = function(general)
        if self.curGeneral == nil or self.curGeneral.general_id ~= general.general_id then
            self.mode:setGeneral(self.curTab, self.curPos, general.general_id, self.getData)
        else
            self.mode:setGeneral(self.curTab, self.curPos, 0, self.getData)
        end
    end

	self.gotoView = function()
		g_sceneManager.addNodeForUI(require("game.uilayer.pub.PubLayer"):create())
        g_groundData.SetView(nil)
        self:close()
	end

	self.postArmy = function(selectArmyItemView)
        if selectArmyItemView:getNum() == 0 then
            self.mode:setSoldier(self.curTab, self.curPos, nil, 0, self.getData)
        else
            self.mode:setSoldier(self.curTab, self.curPos, selectArmyItemView:getSoliderData().soldier_id, selectArmyItemView:getNum(), self.getData)
        end
        
        if g_guideManager.execute() then
            g_groundData.SetView(nil)
            self:close()
        end
    end

    self.closeWin = function()
        if self.callback ~= nil then
            self.callback()
        end
        g_groundData.SetView(nil)
        self:close()
    end
end

function GroundView:countTabAndArmyNumber()
	local tem = 0
    for key, value in pairs(g_data.vip_privilege) do
        if tonumber(value.vip_lv) == tonumber(self.data.PlayerData.vip_level) then
            if value.privilege_type == 11 then
                tem = tonumber(value.buff_num)
                break
            end
        end
    end
    
    local buildData = g_PlayerBuildMode.FindBuild_high_OriginID(g_PlayerBuildMode.m_BuildOriginType.spectacular)
    
    local maxNum = tonumber(g_data.starting[19].data)
	local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffKeyName("deputy_per_corp",buildData.position)

	if buffType == 1 then --万分比
    	maxNum = math.ceil(maxNum * (10000 + buffValue)/10000)
	elseif buffType == 2 then --固定值
		maxNum = maxNum + buffValue
	end
 	self.maxArmyNum = maxNum
    
    local playerArmyNumber = self.data.PlayerData.army_num

	local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffKeyName("corps_in_control",buildData.position)

	if buffType == 1 then --万分比
		playerArmyNumber = math.ceil(playerArmyNumber * (10000 + buffValue)/10000)
	elseif buffType == 2 then --固定值
		playerArmyNumber = playerArmyNumber + buffValue
	end
	self.allTab = playerArmyNumber + tem
end

function GroundView:setContent()
	for i=1, self.titleNum do
        if i > self.allTab then
            self["Button_juntuan0"..i.."_Image_s1"]:setVisible(true)
        else
            self["Button_juntuan0"..i.."_Image_s1"]:setVisible(false)
        end
        if i  > (self.allTab + 1) and i <= self.titleNum then
            self["Button_juntuan0"..i]:setVisible(false)
        end
    end

    local data = self:getCurArmyUnitData()
    for i=1, 6 do
    	self["Panel_0"..i]:show(nil)
    end

    for i=1, #data do
    	self["Panel_0"..data[i].unit]:show(data[i])
    end

    --必须写在所有DrillItemView创建之后
    g_guideManager.execute()
end

function GroundView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == self.Button_kuaisu then
				g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
				if self.data == nil then
					return
				end
                local tag = false
                local groudData, value = self:getGroupDataByTab(self.curTab)

                for key, value in pairs(groudData) do
                    if value.soldier_id ~= 0 then
                        tag = true
                        break
                    end
                 end
                
                if tag == false then
                    g_airBox.show(g_tr("errorNoSoldier"))
                    return
                end
                self.mode:fullfillSoldier(self.curTab, self.getData)
            elseif sender == self.Button_ckyby then
            	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.data == nil then
					return
				end
                g_sceneManager.addNodeForUI(require("game.uilayer.drill.PrepareArmyView").new())
            elseif sender == self.Button_1 then
				g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
				g_groundData.SetView(nil)
                if self.callback ~= nil then
                    self.callback()
                end
				self:close()
            elseif sender == self.Button_juntuan01 or sender ==  self.Button_juntuan01_Text_1 then
                if self.allTab < 1 then
                    self:tipInfo()
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 1
                self:setTabHightlight(self.curTab)
                --计算当前的军团数和武将带兵数
                self:countTabAndArmyNumber()

                --填充数据
                self:setContent()

                --军团信息
                self:updatePropertyData()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.Button_juntuan02 or sender ==  self.Button_juntuan02_Text_1  then
                if self.allTab < 2 then
                    self:tipInfo()
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 2
                self:setTabHightlight(self.curTab)
                --计算当前的军团数和武将带兵数
                self:countTabAndArmyNumber()

                --填充数据
                self:setContent()

                --军团信息
                self:updatePropertyData()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.Button_juntuan03 or sender ==  self.Button_juntuan03_Text_1  then
                if self.allTab < 3 then
                    self:tipInfo()
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 3
                self:setTabHightlight(self.curTab)
                --计算当前的军团数和武将带兵数
                self:countTabAndArmyNumber()

                --填充数据
                self:setContent()

                --军团信息
                self:updatePropertyData()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.Button_juntuan04 or sender ==  self.Button_juntuan04_Text_1  then
                if self.allTab < 4 then
                    self:tipInfo()
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 4
                self:setTabHightlight(self.curTab)
                --计算当前的军团数和武将带兵数
                self:countTabAndArmyNumber()

                --填充数据
                self:setContent()

                --军团信息
                self:updatePropertyData()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.Button_juntuan05 or sender ==  self.Button_juntuan05_Text_1  then
                if self.allTab < 5 then
                    self:tipInfo()
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 5
                self:setTabHightlight(self.curTab)
                --计算当前的军团数和武将带兵数
                self:countTabAndArmyNumber()

                --填充数据
                self:setContent()

                --军团信息
                self:updatePropertyData()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            elseif sender == self.Button_juntuan06 or sender ==  self.Button_juntuan06_Text_1  then
                if self.allTab < 6 then
                    self:tipInfo()
                    return
                end
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.curTab = 6
                self:setTabHightlight(self.curTab)
                --计算当前的军团数和武将带兵数
                self:countTabAndArmyNumber()

                --填充数据
                self:setContent()

                --军团信息
                self:updatePropertyData()
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 
            end
		end
	end

    for i=1, self.titleNum do
        self["Button_juntuan0"..i]:addTouchEventListener(proClick)
        self["Button_juntuan0"..i.."_Text_1"]:addTouchEventListener(proClick)
    end

	self.Button_kuaisu:addTouchEventListener(proClick)
	self.Button_ckyby:addTouchEventListener(proClick)
	self.Button_1:addTouchEventListener(proClick)
end

--更新军团信息-- 
function GroundView:updatePropertyData()
	local groupData, armyData = self:getGroupDataByTab(self.curTab)

    self.curArmyData = armyData
    if armyData == nil or armyData.leader_general_id == 0 then
        self.Panel_renwu_Text2:setString(defaultShow)
        self.Panel_renwu_Text4:setString(defaultShow)
        self.Panel_renwu_Text6:setString(defaultShow)
        self.Panel_renwu_Text8:setString(defaultShow)
        self.Panel_renwu_Text10:setString(defaultShow)
    else
        local generalData = self:getGeneralDataByGeneralId(armyData.leader_general_id)
        local gData = g_GeneralMode.GetBasicInfo(generalData.general_id, 1)
        self.Panel_renwu_Text2:setString(g_tr(gData.general_name))
        self.Panel_renwu_Text8:setString(armyData.weight.."")
        --兵种数量
        local t1=0
        local t2=0
        local t3=0
        local t4=0

        local power = 0
        
        for i=1, #self.data.ArmyUnitData do
            if self.data.ArmyUnitData[i].army_id == armyData.id then
                power = power + self.data.ArmyUnitData[i].power
            end
            
            if self.data.ArmyUnitData[i].soldier_id ~= 0 and self.data.ArmyData[tostring(self.data.ArmyUnitData[i].army_id)].position == self.curTab then
                local info = g_SoldierMode.GetBasicInfo(self.data.ArmyUnitData[i].soldier_id)
                if info.soldier_type == 1 then
                    t1 = t1 + self.data.ArmyUnitData[i].soldier_num
                elseif info.soldier_type == 2 then
                    t2 = t2 + self.data.ArmyUnitData[i].soldier_num
                 elseif info.soldier_type == 3 then
                    t3 = t3 + self.data.ArmyUnitData[i].soldier_num
                 elseif info.soldier_type == 4 then
                    t4 = t4 + self.data.ArmyUnitData[i].soldier_num
                 end
            end
        end

        self.Panel_renwu_Text10:setString((t1+t2+t3+t4).."")
        self.Panel_renwu_Text6:setString(power.."")
    end

    self.Text_y2:setString(g_SoldierMode.GetAllSoldierNumber().."")
    self.Panel_renwu_Text4:setString(table.getn(groupData).."/"..self.maxArmyNum)
end

function GroundView:updateData()

	--解析所有编组的数据
    self.group1 = {}
    self.group2 = {}
    self.group3 = {}
    self.group4 = {}
    self.group5 = {}
    self.group6 = {}

    if self.data.ArmyUnitData == nil then
        self.data.ArmyUnitData = {}
    end

    for key, value in pairs(self.data.ArmyUnitData) do
        if self.data.ArmyData[tostring(value.army_id)] and self.data.ArmyData[tostring(value.army_id)].position == 1 then
            table.insert(self.group1, value)
        elseif self.data.ArmyData[tostring(value.army_id)] and self.data.ArmyData[tostring(value.army_id)].position == 2 then
            table.insert(self.group2, value)
        elseif self.data.ArmyData[tostring(value.army_id)] and self.data.ArmyData[tostring(value.army_id)].position == 3 then
            table.insert(self.group3, value)
        elseif self.data.ArmyData[tostring(value.army_id)] and self.data.ArmyData[tostring(value.army_id)].position == 4 then
            table.insert(self.group4, value)
        elseif self.data.ArmyData[tostring(value.army_id)] and self.data.ArmyData[tostring(value.army_id)].position == 5 then
            table.insert(self.group5, value)
        elseif self.data.ArmyData[tostring(value.army_id)] and self.data.ArmyData[tostring(value.army_id)].position == 6 then
            table.insert(self.group6, value)
        end
    end
end

function GroundView:showGeneralView(gid)
	if self.curArmyData ~= nil and self.curArmyData.status ~= 0 then
        g_msgBox.show(g_tr("errorEditDrill"))
        return
    end

    local result = {}

    local selectGeneral = nil

    for i=1, #self.data.GeneralData do
    	if self.data.GeneralData[i].status == 0 and gid == self.data.GeneralData[i].general_id then
    		selectGeneral = self.data.GeneralData[i]
    	end

        if self.data.GeneralData[i].status == 0 and self.data.GeneralData[i].army_id == 0 then
            if gid ~= 0 then
                if self.data.GeneralData[i].general_id ~= gid then
                    table.insert(result, self.data.GeneralData[i])
                end
            else
                table.insert(result, self.data.GeneralData[i])
            end
        end
    end

    if selectGeneral ~= nil then
    	table.insert(result, 1, selectGeneral)
    end

    self.curGeneral = selectGeneral

    table.sort(result, function (a, b) 
        local gData1 = g_GeneralMode.GetBasicInfo(a.general_id,  1)
        local gData2 = g_GeneralMode.GetBasicInfo(b.general_id,  1)
        return gData1.general_quality > gData2.general_quality
    end)

    g_sceneManager.addNodeForUI(require("game.uilayer.common.SelectGeneralView").new(result, selectGeneral, self.postSetGeneral, self.gotoView))
end

function GroundView:showSoldierView(data)
	local function showGeneralData()
        self:showGeneralView(0)
    end

    if data.general_id == nil or data.general_id == 0 then
        g_msgBox.show(g_tr("errorSelectGeneral"), "", nil, showGeneralData)
        return
    end

    if self.curArmyData.status ~= 0 then
        g_msgBox.show(g_tr("errorEditDrill"))
        return
    end

    g_sceneManager.addNodeForUI(require("game.uilayer.common.SelectArmyView").new(self.data.SoldierData, data, self.postArmy, self.closeWin, self.curTab))
end

function GroundView:getCurArmyUnitData()
	return self["group"..self.curTab]
end

function GroundView:getGroupDataByTab()
    for key, value in pairs(self.data.ArmyData) do
        if value.position == self.curTab then
            return self["group"..self.curTab], value
        end
    end

    return {}, nil
end

function GroundView:getGeneralDataByGeneralId(gid)
    for i=1, table.getn(self.data.GeneralData) do
        if tonumber(self.data.GeneralData[i].general_id) == tonumber(gid) then
            return self.data.GeneralData[i]
        end
    end
end

function GroundView:tipInfo()
    require("game.uilayer.battleSet.battleSettingView").noArmyConfirm(self.closeWin, self.closeWin)
end

function GroundView:setTabHightlight(index)
    for i=1, self.titleNum do
        self["Button_juntuan0"..i]:setBrightStyle(BRIGHT_NORMAL)
    end

    self["Button_juntuan0"..index]:setBrightStyle(BRIGHT_HIGHLIGHT)
end

return GroundView