--region actSevenDayView.lua
--Author : luqingqing
--Date   : 2016/5/3
--此文件由[BabeLua]插件自动生成

local actSevenDayView = class("actSevenDayView", function() 
    return cc.Layer:create()
end)

function actSevenDayView:ctor(callback)
    self.callback = callback

    self.canGetData = false
    self.uilist = {}
    self.mode = require("game.uilayer.activity.ActivityMode").new()

    self.layer = cc.CSLoader:createNode("NoviceTarget_main1.csb")

    self:addChild(self.layer)

    self.Text_30 = self.layer:getChildByName("Text_30")
    self.LoadingBar_1 = self.layer:getChildByName("LoadingBar_1")
    self.Panel_gyhd = self.layer:getChildByName("Panel_gyhd")
    self.Text_time = self.Panel_gyhd:getChildByName("Text_time")
    self.Text_1 = self.layer:getChildByName("Text_1")
    self.Text_2 = self.layer:getChildByName("Text_2")
    self.Text_3 = self.layer:getChildByName("Text_3")
    self.Text_4 = self.layer:getChildByName("Text_4")

     self.Text_30:setString(g_tr("guanyu"))
     self.Text_1:setString(g_tr("timeTip"))
     self.Text_3:setString(g_tr("timeEnd"))
     self.Text_4:setString(g_tr("rewardTip"))

     self.animation = false
     self:initFun()

     local function handler(event)
        if event == "enter" then
            g_actSevenDayTarget.SetView(self)
        elseif event == "exit" then
            g_actSevenDayTarget.SetView(nil)
        end
    end
    
    self:registerScriptHandler(handler)

    local function callback()
        g_busyTip.hide_1()
    end
    
    self:setVisible(false)
    g_busyTip.show_1()
    g_actSevenDayTarget.RequestSycData(callback)
end

function actSevenDayView:show()
    self:setVisible(true)
    self.data = g_actSevenDayTarget.GetData()
    self:initUI()
end

function actSevenDayView:initFun()
    self.gotoView = function(data)
        if data.jump == 1 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.mainCity)
        elseif data.jump == 2 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.gold)
        elseif data.jump == 3 then
            local MasterView = require("game.uilayer.master.MasterView")
            MasterView:createLayer()
        elseif data.jump == 4 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.bar)
        elseif data.jump == 5 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.mainCity)
        elseif data.jump == 6 then
            require("game.maplayer.changeMapScene").changeToWorld(false)
        elseif data.jump == 7 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.infantry)
        elseif data.jump == 8 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.institute)
        elseif data.jump == 9 then
            local mianSkillView = require("game.uilayer.mainSurface.mianSkillView")
            mianSkillView:createLayer()
        elseif data.jump == 10 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.smithy)
        elseif data.jump == 11 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.smithy)
        elseif data.jump == 12 then
            if g_AllianceMode.getSelfHaveAlliance() == false then
                g_airBox.show(g_tr("battleHallNoAlliance"))
                return
            end
            g_sceneManager.addNodeForUI(require("game.uilayer.alliance.tech.AllianceTechMainLayer"):create())
        elseif data.jump == 13 then
            if g_AllianceMode.getSelfHaveAlliance() == false then
                g_airBox.show(g_tr("battleHallNoAlliance"))
                return
            end
             g_sceneManager.addNodeForUI(require("game.uilayer.shop.ShopLayer"):create(g_Consts.ShopType.ALLIANCE_PLAYER))
        elseif data.jump == 14 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.thePlace)
        elseif data.jump == 15 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.hospital)
        elseif data.jump == 16 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.workshop)
        elseif data.jump == 17 then
            local VIPMainLayer = require("game.uilayer.vip.VIPMainLayer").new()
            g_sceneManager.addNodeForUI(VIPMainLayer)
        elseif data.jump == 18 then
            self:findBuild(g_PlayerBuildMode.m_BuildOriginType.tower)
        elseif data.jump == 19 then
		    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.AllianceMainLayer"):create())
        end

        if self.callback ~= nil then
            self.callback()
        end
    end

    self.getReward = function(itemView)
        self.postItem = itemView
        self.temData = self.postItem:getData()
        self.mode:getTargetReward(self.postItem:getData().id, self.update)
    end

    self.update = function(data)
        local playerInfo = g_playerInfoData.GetData()

        local value = g_data.target[self.temData.target_id]

        local drop = nil

        if playerInfo.sub_day == 1 then
            drop = g_data.drop[value.drop[1]]
        elseif playerInfo.sub_day == 2 then
            drop = g_data.drop[value.drop_2]
        elseif playerInfo.sub_day == 3 then
            drop = g_data.drop[value.drop_3]
        elseif playerInfo.sub_day == 4 then
            drop = g_data.drop[value.drop_4]
        elseif playerInfo.sub_day == 5 then
            drop = g_data.drop[value.drop_5]
        elseif playerInfo.sub_day == 6 then
            drop = g_data.drop[value.drop_6]
        elseif playerInfo.sub_day >= 7 then
            drop = g_data.drop[value.drop_7]
        end

        local view = require("game.uilayer.task.TaskAwardAlertLayer").new(drop.drop_data)
        g_sceneManager.addNodeForUI(view)

        self:playAnimation()

        if data == null or #data == 0 or data == {} then
            self.refresh()
        else
            self.postItem:show(data)
        end
        self:updateBag()
        g_actSevenDayTarget.NotificationUpdateShow()
    end

    self.refresh = function()
        local function getData(data)
            self.data = data

            if #self.data == 0 then
                if self.canGetData == false then
                    self.canGetData = true
                    local playerInfo = g_playerInfoData.GetData()
                    local t = playerInfo.sub_day
                    if t >= g_data.target[(#g_data.target)].open_time then
                        g_airBox.show(g_tr("actAllComplete"))
                    else
                        g_airBox.show(g_tr("noTaskInfo"))
                    end
                end
            end

            for i=1, 4 do
                self.uilist[i]:show(self.data[i])
            end
        end
        self.mode:getTargetInfo(getData)
    end

    self.showInfo = function(itemData)
        local itemView = require("game.uilayer.bag.BagItemNoButtonView").new(itemData)
        g_sceneManager.addNodeForUI(itemView)
    end
end

function actSevenDayView:initUI()

    if #self.data == 0 then
        if self.canGetData == false then
            self.canGetData = true

            local playerInfo = g_playerInfoData.GetData()
            local t = playerInfo.sub_day
            if t >= g_data.target[(#g_data.target)].open_time then
                g_airBox.show(g_tr("actAllComplete"))
            else
                g_airBox.show(g_tr("noTaskInfo"))
            end
        end
    end

    for i=1, 4 do
        if self.uilist[i] == nil then
            self["Panel_"..i] = self.layer:getChildByName("Panel_"..i)
            self.uilist[i] = require("game.uilayer.activity.sevenTarget.SevenDayItemView").new(self["Panel_"..i], self.gotoView, self.getReward, self.refresh,  self.showInfo)
        end
        self.uilist[i]:show(self.data[i])
    end

    self:updateBag()
    self:processTime()
end

function actSevenDayView:updateBag()
    local general = g_GeneralMode.getGeneralById(20106)
    if general ~= nil then
        self.LoadingBar_1:setPercent(100)
        self.Panel_gyhd:setPositionX(self.LoadingBar_1:getPositionX() + self.LoadingBar_1:getContentSize().width/2)
        self.Text_time:setString("100/100")
        return
    end

    local bagData = g_BagMode.GetData()
    if bagData["40106"] == nil then
        self.LoadingBar_1:setPercent(0)
        self.Text_time:setString("0/100")
    else
        self.LoadingBar_1:setPercent(bagData["40106"].num)
        self.Text_time:setString(bagData["40106"].num.."/100")
    end
    self.Panel_gyhd:setPositionX(self.LoadingBar_1:getPositionX()-self.LoadingBar_1:getContentSize().width/2 + self.LoadingBar_1:getContentSize().width*self.LoadingBar_1:getPercent()/100)
end

function actSevenDayView:processTime()
    local function updateTime()
        for key, value in pairs(self.uilist) do
            value:showTime()
        end

        local dt = g_playerInfoData.GetData().target_end_time - g_clock.getCurServerTime()

        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.time)
            self.time = nil
        end

        self.Text_2:setString(g_gameTools.convertSecondToString(dt))      
    end

    if self.time ~= nil then
        self:unschedule(self.time)
        self.time = nil
    end

    self.needTime = g_playerInfoData.GetData().target_end_time - g_clock.getCurServerTime()

    if self.needTime > 0 then
        self.time = self:schedule(updateTime, 1.0)
        updateTime()
    end
end

function actSevenDayView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self.layer:runAction(action)
  return action
end 

function actSevenDayView:unschedule(action)
  self.layer:stopAction(action)
end

function actSevenDayView:findBuild(buildType)
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

function actSevenDayView:playAnimation()
    if self.animation == true then
        return
    end

    self.animation = true

    local btn = self.postItem:getBtn()
    local mc = self.postItem:getMc()
    local pos = cc.p(mc:getPositionX()+btn:getPositionX(), mc:getPositionY()+btn:getPositionY())

    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_RenWUTuoWei/Effect_RenWUTuoWei.ExportJson", "Effect_RenWUTuoWei")
    self.layer:addChild(armature)
	armature:setPosition(pos)
	animation:play("Effect_RenWUTuoWei")

    local targetPos = cc.p(self.LoadingBar_1:getPositionX() + self.LoadingBar_1:getContentSize().width*self.LoadingBar_1:getPercent()/100, self.LoadingBar_1:getPositionY())


    local function callback1()
        self.layer:removeChild(armature)
        self.animation = false
    end

    local action = cc.MoveTo:create(1, targetPos)
    local callFunc=cc.CallFunc:create(callback1)
    local seq=cc.Sequence:create(action, callFunc)
    armature:runAction(seq)
end

return actSevenDayView

--endregion
