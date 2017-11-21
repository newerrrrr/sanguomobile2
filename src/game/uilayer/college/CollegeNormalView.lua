--region CollegeNormalView.lua
--Author : luqingqing
--Date   : 2015/11/5
--此文件由[BabeLua]插件自动生成

local CollegeNormalView = class("CollegeNormalView", function() 
    return ccui.Widget:create()
end)

function CollegeNormalView:ctor(data, callback, delBack, studyBack, finishBack, accessBack)
    self.collegeData = data

    self.clickBack = callback
    self.delBack = delBack
    self.studyBack = studyBack
    self.finishBack = finishBack
    self.accessBack = accessBack

    self.layout = cc.CSLoader:createNode("college_List_normal.csb")
    self:addChild(self.layout)

    self:setContentSize(cc.size(self.layout:getContentSize().width, self.layout:getContentSize().height))

    self.root = self.layout:getChildByName("scale_node")

    self.Panel_8 = self.root:getChildByName("Panel_8")
    self.Panel_8_Text_8 = self.Panel_8:getChildByName("Text_8")

    self.Panel_wujiang = self.root:getChildByName("Panel_wujiang")
    self.Text_4_0 = self.root:getChildByName("Text_4_0")
    self.Text_4 = self.root:getChildByName("Text_4")
    self.Image_1 = self.root:getChildByName("Image_1")
    self.Text_4:setString("0")
    self.Text_4_0:setString(g_tr_original("studyTypeSelect"))

    self.Panel_1 = self.root:getChildByName("Panel_1")
    self.Panel_1_Text_1 = self.Panel_1:getChildByName("Text_1")
    self.Panel_1_Text_1:setString("")

    self.Panel_1_0 = self.root:getChildByName("Panel_1_0")
    self.Panel_1_0_Text_10 = self.Panel_1_0:getChildByName("Text_10")

    self.Button_1 = self.root:getChildByName("Button_1")
    self.Button_1_Text_2 = self.Button_1:getChildByName("Text_2")

    self.Panel_8_Text_8:setString(g_tr_original("studyPanel")..g_tr_original("num"..self.collegeData:getPosition()))

     self.generalView = require("game.uilayer.common.CommonGeneralItemView").new()
     self.generalView:setPosition(self.generalView:getContentSize().width/2, self.generalView:getContentSize().height/2)
     self.Panel_wujiang:addChild(self.generalView)
end

function CollegeNormalView:show(data)
    self.collegeData:setGeneralData(data)

    self:setData()
    self:addEvent()
end

function CollegeNormalView:setData()
    local function callback()
        if self.clickBack ~= nil  then
            self.clickBack(self)
        end
    end

    if self.collegeData:getGeneralData() ~= nil then
        self.generalView:show(self.collegeData:getGeneralData(), callback)
        self.Image_1:setVisible(true)
    else
        self.Image_1:setVisible(false)
        self.generalView:show(nil, callback)
    end

    if self.collegeData:getType() == "0" then
        self.Panel_1_0:setVisible(false)
        self.Panel_1:setVisible(true)
        self.Button_1_Text_2:setString(g_tr_original("studyBtn"))
    else
        self.Panel_1_0:setVisible(true)
        self.Panel_1:setVisible(false)
        self.Button_1_Text_2:setString(g_tr_original("studyClearCd"))

        self:setTime()
    end
    
end

function CollegeNormalView:addEvent()

    local function proType(data)
        self.selectType = data
        if data.cost == 0 then
            self.Panel_1_Text_1:setString(self.selectType.time..g_tr_original("hour"))
        else
            self.Panel_1_Text_1:setString(self.selectType.time..g_tr_original("hour").."("..g_tr_original("gold")..")")
        end

        self.Text_4:setString(data.cost.."")
    end

    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Image_1 then
                if self.delBack ~= nil then
                    self.delBack(self)
                end
            elseif sender == self.Button_1 then
                if self.studyBack ~= nil then
                    if self.collegeData:getType() == 0 then
                        self.studyBack(self)
                    else
                        self.accessBack(self)
                        --self.finishBack(self)
                    end
                end
            elseif sender == self.Panel_1 then
                g_sceneManager.addNodeForUI(require("game.uilayer.college.CollegeTypeView").new(self.selectType, proType))
            end
        end
    end

    self.Image_1:addTouchEventListener(proClick)
    self.Button_1:addTouchEventListener(proClick)
    self.Panel_1:addTouchEventListener(proClick)
end

function CollegeNormalView:setTime()
    
    local function updateTime()
        local dt = self.collegeData:getEndTime() - g_clock.getCurServerTime()
        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.buildTimer)
            self.buildTimer = nil

            if self.finishBack ~= nil  then
                self.finishBack(self)
            end
        end 

        self.Text_4:setString(math.ceil(dt/20).."")

        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)

        self.Panel_1_0_Text_10:setString(string.format("%02d:%02d:%02d", hour, min, sec))      
    end 

    if self.buildTimer then       
        self:unschedule(self.buildTimer)
        self.buildTimer = nil 
    end

    self.needTime = self.collegeData:getEndTime() - self.collegeData:getStartTime() + g_clock.getCurServerTime()

    if self.needTime > g_clock.getCurServerTime() then 
        self.buildTimer = self:schedule(updateTime, 1.0)
        updateTime()
    end 
end

function CollegeNormalView:getCollegeData()
    return self.collegeData
end

function CollegeNormalView:getStudyType()
    return self.selectType
end

function CollegeNormalView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function CollegeNormalView:unschedule(action)
  self:stopAction(action)
end

return CollegeNormalView

--endregion
