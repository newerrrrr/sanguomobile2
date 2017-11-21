--region ActivityLimitedReward.lua   --限时奖励活动
--Author : liuyi
--Date   : 2016/4/6
local ActivityLimitedReward = class("ActivityLimitedReward", require("game.uilayer.base.BaseLayer"))


function ActivityLimitedReward:createLayer()

    self.showData = require("game.uilayer.activity.ActivityMode"):getNowShowData()
    if self.showData == nil then
        return
    end
    g_sceneManager.addNodeForUI( ActivityLimitedReward:create())
end

function ActivityLimitedReward:ctor()
    ActivityLimitedReward.super.ctor(self)
    self:initUI()
end

function ActivityLimitedReward:initUI()
    self.layout = self:loadUI("TimeLimitActivity_Popup.csb")
    self.root = self.layout:getChildByName("scale_node")
    local closeMask = self.layout:getChildByName("mask")
    closeMask:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:close()
        end
    end)
    
    --zhcn
    self.root:getChildByName("Text_c2"):setString(g_tr("LimitedRewardTitle"))
    self.root:getChildByName("Text_dj1"):setString(g_tr("LimitedRewardOverTime"))
    self.root:getChildByName("Text_a1"):setString(g_tr("LimitedRewardGetOk"))
    --self.root:getChildByName("Text_a2"):setString(g_tr("LimitedRewardGetCancel"))
    self.root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))
    
    self.timeTx = self.root:getChildByName("Text_dj2")
    local borderImg = self.root:getChildByName("Image_wp1")
    local itemData = self.showData.award_item[1]
    local item_type = tonumber(itemData[1])
    local item_id = tonumber(itemData[2])
    local item_num = tonumber(itemData[3])

    local item = require("game.uilayer.common.DropItemView").new(item_type, item_id,item_num)
    --item:setPosition( cc.p(borderImg:getContentSize().width/2,borderImg:getContentSize().height/2) )
    --borderImg:addChild(item)

    item:setScale(1.25)
    --local fx1 = 

    local fxPath = "anime/Effect_XianShiJiangLiXunHuan/Effect_XianShiJiangLiXunHuan.ExportJson"
    local fxName = "Effect_XianShiJiangLiXunHuan"
    local armature , animation = g_gameTools.LoadCocosAni(fxPath, fxName)
    armature:setPosition(borderImg:getPosition())
    self.root:addChild(armature)
    animation:play("Animation1")

    local node = cc.Node:create()
    node:setAnchorPoint(cc.p(0.5,0.5))
    node:addChild(item)

    armature:getBone("Layer15"):addDisplay(node,0)


    --[[local fxPath = "anime/Effect_XianShiJiangLiXunHuanDown/Effect_XianShiJiangLiXunHuanDown.ExportJson"
    local fxName = "Effect_XianShiJiangLiXunHuanDown"
    local armature , animation = g_gameTools.LoadCocosAni(fxPath, fxName)
    armature:setPosition(borderImg:getPosition())
    self.root:addChild(armature)
    animation:play("Animation1")]]


    local itemDescTx = self.root:getChildByName("Text_nr")
    itemDescTx:setString( item:getDesc() )
    
    self.getGiftBtn = self.root:getChildByName("btn_a1")
    self.getGiftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local overTime = self.endTime - g_clock.getCurServerTime()
            if overTime > 0 then
                
            else
                local function onRecv(result, msgData)
                    if true == result then
                        local groups = 
                        {
                            {
                                item_type,
                                item_id,
                                item_num
                            }
                        }
                        require("game.uilayer.task.AwardsToast").show(groups)
                        self:close()
                    end
                end
                g_sgHttp.postData("award/doGetOnlineAward",{name = {"PlayerOnlineAward",}},onRecv)
            end
        end
    end)

    self.endTime = self.showData.time_start + self.showData.online_award_duration
    local overTime = self.endTime - g_clock.getCurServerTime()
    
    if overTime > 0 then
        self.getGiftBtn:setEnabled(false)
        self.getGiftBtn:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
        self.timeTx:setString(g_gameTools.convertSecondToString(overTime))
        self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateTime),1,false)
    else
        --self.timeTx:setString(g_gameTools.convertSecondToString(0))
        self.timeTx:setVisible(false)
    end
end

function ActivityLimitedReward:updateTime()
    local overTime = self.endTime - g_clock.getCurServerTime()
    if overTime >= 0 then
        self.timeTx:setString(g_gameTools.convertSecondToString(overTime))
        if overTime == 0 then
            self.getGiftBtn:setEnabled(true)
            self.getGiftBtn:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )  
            self.timeTx:setVisible(false)
        end
    else
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
        self.timer = nil
    end
end

function ActivityLimitedReward:onEnter()
    
end

function ActivityLimitedReward:onExit()
    if self.timer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
        self.timer = nil
    end
end



return ActivityLimitedReward
