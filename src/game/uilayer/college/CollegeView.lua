--region CollegeView.lua
--Author : luqingqing
--Date   : 2015/11/4
--此文件由[BabeLua]插件自动生成

local CollegeView = class("CollegeView", require("game.uilayer.base.BaseLayer"))

local playerData = nil
local generalData = nil
local studyData = nil
local buildData = nil
local payData = nil

local OpenType = 1
local BuyType = 2
local LockType = 3

function CollegeView:ctor()
    CollegeView.super.ctor(self)

    self.uilist = {}
    self.mode = require("game.uilayer.college.CollegeMode").new()

    local function getData(player, general, study, build)
        playerData = player
        generalData = general
        buildData = build
        studyData = study

        self:initFun()
        self:initUi()
    end

    --获取当前数据
    self.mode:getData(getData)
end

function CollegeView:initFun()
    self.showHero = function(collegeNormalView)
        self:showGeneralHero(collegeNormalView)
    end

    self.delHero = function(collegeNormalView)
        self:postSetGeneral(collegeNormalView, 0)
    end

    self.study = function(collegeNormalView)
        self:postStudy(collegeNormalView)
    end

    self.buyItem = function(collegeBuyView)
        self:buyPosition(collegeBuyView)
    end

    self.finish = function(collegeNormalView)
        self:postFinish(collegeNormalView)
    end

    self.accelerate = function(collegeNormalView)
        self:postAccelerate(collegeNormalView)
    end

    self.updateAllData = function(player, general, study, build)
        playerData = player
        generalData = general
        buildData = build
        studyData = study

        self:updateUiList()
    end
end

function CollegeView:initUi()
    self.layer = self:loadUI("college_Panel.csb")
    self.root = self.layer:getChildByName("scale_node")

    self.Button_6 = self.root:getChildByName("Button_6")
    self.ListView_1 = self.root:getChildByName("ListView_1")

    self:addEvent()
    --self:getData()
end

function CollegeView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_6 then
                self:close()
            end
        end
    end

    self.Button_6:addTouchEventListener(proClick)
end

function CollegeView:getData()
    --获取建筑等级build表
    local blv = 0
    for key, value in pairs(buildData) do
        if value.origin_build_id == "13" then
            blv = value.build_level
            break
        end
    end
    local index = 13*1000 + blv

    --cost表(潜规则)--
    self.payList = {}
    table.insert(self.payList, g_data.cost[10101])
    table.insert(self.payList, g_data.cost[10102])
    table.insert(self.payList, g_data.cost[10103])
    table.insert(self.payList, g_data.cost[10104])
    table.insert(self.payList, g_data.cost[10105])

    self.loclList = {}
    if tonumber(blv) < g_data.starting[22].data then
        table.insert(self.loclList, g_data.starting[22].data)
        table.insert(self.loclList, g_data.starting[23].data)
        table.insert(self.loclList, g_data.starting[24].data)
        self:setList(2)
    elseif tonumber(blv) < g_data.starting[23].data then
        table.insert(self.loclList, g_data.starting[23].data)
        table.insert(self.loclList, g_data.starting[24].data)
        self:setList(3)
    elseif tonumber(blv) < g_data.starting[24].data then
        table.insert(self.loclList, g_data.starting[24].data)
        self:setList(4)
    else
        self:setList(5)
    end
end

function CollegeView:setList(num)
    --当前开放栏--
    self.itemLen = playerData.study_pay_num + num

    local item = nil
    local collegeData = nil
    for i=1, self.itemLen do
        item = self:createItem(OpenType, i, nil)
        self.ListView_1:pushBackCustomItem(item)
    end

     self:updateUiList()
   
    --解锁栏--
    for i=1, #self.loclList do
        item = self:createItem(LockType, 0, self.loclList[i])
        self.ListView_1:pushBackCustomItem(item)
    end

    --购买栏--
    if playerData.study_pay_num < #self.payList then
        item = self:createItem(BuyType, 0, self.payList[playerData.study_pay_num + 1])
        item:show(self.buyItem)
        self.ListView_1:pushBackCustomItem(item)
    end
end

function CollegeView:showGeneralHero(collegeNormalView)
    local function clickHero(generalData)
        self:postSetGeneral(collegeNormalView, generalData.general_id)
    end

    --筛选数据--
    local result = {}

    for i=1, #generalData do
        if generalData[i].status == 0 and generalData[i].army_id == 0 and generalData[i].build_id == 0 then
            --去除当前学位栏里已经有的
            local tab = false
            for j=1, #studyData do
                if studyData[j].general_id == generalData[i].general_id then
                    tab = true
                    break
                end
            end

            if tab == false then
                table.insert(result, generalData[i])
            end
        end
    end

    g_sceneManager.addNodeForUI(require("game.uilayer.common.SelectGeneralView").new(result, clickHero))
end

function CollegeView:postStudy(collegeNormalView)
    if collegeNormalView:getCollegeData():getGeneralData() == nil then
        return
    end

    if collegeNormalView:getStudyType() == nil then
        return 
    end

    self.mode:study(collegeNormalView:getCollegeData():getPosition(),  collegeNormalView:getStudyType().id,  self.updateAllData)
end

function CollegeView:postAccelerate(collegeNormalView)
    self.mode:accelerate(collegeNormalView:getCollegeData():getPosition(), self.updateAllData)
end

function CollegeView:postFinish(collegeNormalView)
    self.mode:finish(self.updateAllData)
end

function CollegeView:postSetGeneral(collegeNormalView, gid)
    local function getData(player, general, study, build)
        playerData = player
        generalData = general
        buildData = build
        studyData = study

        if gid == 0 then
            collegeNormalView:show(nil)
         else
            local data = self:getGeneralDataByGid(gid)
            collegeNormalView:show(data)
        end
    end

    self.mode:setGeneral(collegeNormalView:getCollegeData():getPosition(), gid, getData)
end

-------------工具------------------------

--创建一个ITEM--
function CollegeView:createItem(itemType, num, data)
    local item = nil
    if itemType == OpenType then
        --创建学院数据--
        local cd = require("game.gamedata.CollegeData").new()
        cd:setPosition(num)
        cd:setType("0")
        cd:setStartTime(0)
        cd:setEndTime(0)

        --创建UI--
        item = require("game.uilayer.college.CollegeNormalView").new(cd, self.showHero, self.delHero, self.study, self.finish, self.accelerate)
        item:show(nil)

        table.insert(self.uilist, item)
    elseif itemType == BuyType then
        item = require("game.uilayer.college.CollegeBuyView").new(data)
    elseif itemType == LockType then
        item = require("game.uilayer.college.CollegeLockView").new(data)
    end

    return item
end

function CollegeView:updateUiList()
    for i=1, #studyData do
        self.uilist[tonumber(studyData[i].position)]:getCollegeData():setType(studyData[i].type)
        self.uilist[tonumber(studyData[i].position)]:getCollegeData():setGainExp(studyData[i].gain_exp)
        self.uilist[tonumber(studyData[i].position)]:getCollegeData():setStartTime(studyData[i].start_time)
        self.uilist[tonumber(studyData[i].position)]:getCollegeData():setEndTime(studyData[i].end_time)

        local data = self:getGeneralDataByGid(studyData[i].general_id)

        self.uilist[tonumber(studyData[i].position)]:show(data)
    end
end

--购买栏位--
function CollegeView:buyPosition(collegeBuyView)
    local function updateList()
        playerData.study_pay_num = playerData.study_pay_num + 1
        if tonumber(playerData.study_pay_num) < #self.payList then
            collegeBuyView:updateData(self.payList[playerData.study_pay_num + 1])
        else
            self.ListView_1:removeItem(self.ListView_1:getIndex(collegeBuyView))
        end

        self.itemLen = self.itemLen + 1
        local item = self:createItem(OpenType, self.itemLen)
        self.ListView_1:insertCustomItem(item, self.itemLen-1)
        item:show(nil)
    end

    self.mode:buyPosition(updateList)
end

--获取generalData--
function CollegeView:getGeneralDataByGid(gid)
    for key, value in pairs(generalData) do
        if value.general_id == gid then
            return value
        end
    end
end

return CollegeView

--endregion
