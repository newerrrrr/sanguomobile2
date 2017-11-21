--region PowerView.lua
--Author : luqingqing
--Date   : 2016/3/31
--此文件由[BabeLua]插件自动生成

local PowerView = class("PowerView", require("game.uilayer.base.BaseLayer"))

function PowerView:ctor()
    PowerView.super.ctor(self)

    self.titleList = {}

    self.btnList = {}

    self.layer = self:loadUI("power.csb")
    self.root = self.layer:getChildByName("scale_node")

    self.close_btn = self.root:getChildByName("close_btn")
    self.ListView_left =self.root:getChildByName("ListView_left")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_title = self.root:getChildByName("Text_title")
    self.Text_nr = self.root:getChildByName("Text_nr")
    self.Panel_1 = self.root:getChildByName("Panel_1")
    self.Text_1:setString(g_tr("powerUpTitle"))

    if self.showtime_tx == nil then
        self.showtime_tx = g_gameTools.createRichText(self.Text_nr,nil)
    end

    self.data = g_data.powerup_guide

    self.curData = self.data[1]
    self.showtime_tx:setRichText(g_tr(self.curData.desc_id))

    self.mainCity = g_PlayerBuildMode.FindBuild_high_OriginID(g_PlayerBuildMode.m_BuildOriginType.mainCity)

    self:initFun()
    self:setData()
    self:setButton()
    self:addEvent()
end

function PowerView:initFun()
    self.clickTitle = function(data)
        self.titleList[self.curData.id]:setState(false)
        self.curData = data
        self.titleList[self.curData.id]:setState(true)
        self.Text_title:setString(g_tr(self.curData.name_id))
        self.showtime_tx:setRichText(g_tr(data.desc_id))
        self:setButton()
    end

    self.gotoView = function(id)
        local v = nil
        if id == g_Consts.PowerUpType.trainInfantry then
            --[[
            v = g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.infantry)
			if v then
				require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(v.position)
			else
				local needBuild = FindBuildConfig_firstBuilding_OriginID(g_PlayerBuildMode.m_BuildOriginType.infantry)
				if needBuild then
					local canBuildPlace = require("game.maplayer.homeMapLayer").getClearingWithBuildID(needBuild.id)
					if canBuildPlace then
						require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(canBuildPlace)
					end
				end
			end
            ]]--
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.infantry)
        elseif id == g_Consts.PowerUpType.trainCavalry then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.cavalry)
        elseif id == g_Consts.PowerUpType.trainArcher then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.archers)
        elseif id == g_Consts.PowerUpType.trainVehicles then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.car)
        elseif id == g_Consts.PowerUpType.buildTrap then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.workshop)
        elseif id == g_Consts.PowerUpType.club then
            v = g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.bar)
            require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(v.position)
        elseif id == g_Consts.PowerUpType.equipStarUp then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.smithy)
        elseif id == g_Consts.PowerUpType.science then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.institute)
        elseif id == g_Consts.PowerUpType.talent then
            require("game.uilayer.master.MasterTalentView"):createLayer()
            --g_sceneManager.addNodeForUI( require("game.uilayer.master.MasterTalentView"):create() )
        elseif id == g_Consts.PowerUpType.master then
            require("game.uilayer.master.MasterView"):createLayer()
        elseif id == g_Consts.PowerUpType.buildUp then
            g_TaskMode.guideToBuildMainTask()
        elseif id == g_Consts.PowerUpType.fight then
            local function callback()
                local view = require("game.uilayer.mainSurface.searchMasterView").new()
                g_sceneManager.addNodeForUI(view)
            end
            require("game.maplayer.changeMapScene").changeToWorld(false, callback)
        elseif id == g_Consts.PowerUpType.mission then
            g_sceneManager.addNodeForUI(require("game.uilayer.task.TaskMainLayer").create())
        end

        self:close()
    end
end

function PowerView:findBuild(buildType)
    local v = g_PlayerBuildMode.FindBuild_OriginID(buildType)
    if v then
	    require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(v.position)
	else
	    local needBuild = g_PlayerBuildMode.FindBuildConfig_firstBuilding_OriginID(buildType)
		if needBuild then
		    local canBuildPlace = require("game.maplayer.homeMapLayer").getClearingWithBuildID(needBuild.id)
			if canBuildPlace then
			    require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(canBuildPlace)
			end
        end
    end
end

function PowerView:setData()
    local title = nil
    for i=1, #self.data do
        title = require("game.uilayer.power.PowerTitleView").new(self.data[i], self.clickTitle)
        if i == self.curData.id then
            title:setState(true)
            self.Text_title:setString(g_tr(self.curData.name_id))
        else
            title:setState(false)
        end
        self.ListView_left:pushBackCustomItem(title)

        table.insert(self.titleList, title)
    end
end

function PowerView:setButton()
    self.Panel_1:removeAllChildren(true)

    local size = self.Panel_1:getContentSize()

    local btnList = {}

    for i=1, #self.curData.redirect_type do
        if self.curData.castle_lv[i] == nil then
            self.curData.castle_lv[i] = 1
        end
        if self.curData.castle_lv[i] <= self.mainCity.build_level then
            local btn = require("game.uilayer.power.PowerButtonView").new(g_tr(self.curData.button_name_id[i]),self.curData.redirect_type[i], self.gotoView)
            self.Panel_1:addChild(btn)
            table.insert(btnList, btn)
        end
    end

    for i=1, #btnList do
        local btn = btnList[i]
         if (#btnList)%2 == 1 then
            btn:setPositionX((size.width - btn:getContentSize().width)/(#btnList + 1) * i + btn:getContentSize().width/2)
        else
            btn:setPositionX(size.width/(#btnList)/2 + (size.width/(#btnList) * (i-1)))
        end
    end
end

function PowerView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                self:close()
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
end

return PowerView

--endregion
