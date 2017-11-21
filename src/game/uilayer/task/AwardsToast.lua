
local AwardsToast = class("AwardsToast",function()
    return cc.Layer:create()
end)

function AwardsToast.show(droupGroups)
    g_sceneManager.addNodeForUI(AwardsToast:create(droupGroups))
end

local effectDelay = 0.15
local effectScaleTime = 0.13

function AwardsToast:ctor(droupGroups)
    local widget = g_gameTools.LoadCocosUI("system_tips_award.csb",5)
   
    local itemAwards = droupGroups or {}
    local resourceAwards = {}
    local othersAwards = {}
    for key, dropGroup in pairs(itemAwards) do
        local dropType = dropGroup[1]
        local dropConfigId = dropGroup[2]
        local dropCount = dropGroup[3]
        if --[[dropType == g_Consts.DropType.Resource and]] dropConfigId == 10100 or
        dropConfigId == 10200 or 
        dropConfigId == 10300 or
        dropConfigId == 10400 or
        dropConfigId == 10500
        then
            table.insert(resourceAwards,dropGroup)
        else
            table.insert(othersAwards,dropGroup)
        end
    end
    widget:getChildByName("scale_node"):getChildByName("Text_1"):setString(g_tr("tostAwardTitle"))
    
    --道具显示
    if #othersAwards > 0 then
        local container = cc.Node:create()
        local dropViewWidth = 0
        for key, dropGroup in pairs(othersAwards) do
            local dropView = require("game.uilayer.common.DropItemView"):create(dropGroup[1],dropGroup[2],dropGroup[3])
            if dropView then
                dropView:setCountEnabled(true)
                dropView:setNameVisible(true)
                container:addChild(dropView)
                dropView:setPositionX(dropViewWidth + dropView:getContentSize().width/2)
                dropViewWidth = dropViewWidth + dropView:getContentSize().width + 10
            end
        end
        widget:getChildByName("scale_node"):getChildByName("Panel_3"):addChild(container)
        container:setPositionX(-dropViewWidth/2)
    end
    

    local function playResourceDropEffect()
        --资源掉落效果
        local resourceUi = nil
        local postions = {}
        if #resourceAwards > 0 then
            resourceUi = cc.CSLoader:createNode("task_Resources.csb")
            local eachWidth = resourceUi:getContentSize().width/5
            for i = 1, 5 do
            	resourceUi:getChildByName("Panel_m"..i):setVisible(false)
            	postions[i] = cc.p(resourceUi:getChildByName("Panel_m"..i):getPosition())
            end
            g_sceneManager.addNodeForSceneEffect(resourceUi)
            resourceUi:setPositionX(g_display.cx - eachWidth*#resourceAwards/2 + 160)
            resourceUi:setPositionY(130)
            local showLong = math.max(effectDelay * (#resourceAwards + 1) + effectScaleTime * #resourceAwards,2.5)
            resourceUi:runAction( cc.Sequence:create( cc.DelayTime:create(showLong) , cc.RemoveSelf:create() ) )
        end
    
        local resourceIdx = 1
        for key, dropGroup in pairs(itemAwards) do
            local dropType = dropGroup[1]
            local dropConfigId = dropGroup[2]
            local dropCount = dropGroup[3]
            
            local effect = nil
            local endPosition = nil
            local beginPosition = g_display.center
            local iconName = nil
            local callBack = nil
            
            local beginIcon = nil
            if dropType == g_Consts.DropType.Resource then
                if dropConfigId == 10100 then --黄金
                    if resourceUi then
                         beginIcon = resourceUi:getChildByName("Panel_m1")
                    end
                elseif dropConfigId == 10200 then --粮食
                    if resourceUi then
                         beginIcon = resourceUi:getChildByName("Panel_m2")
                    end
                elseif dropConfigId == 10300 then --木材
                    if resourceUi then
                         beginIcon = resourceUi:getChildByName("Panel_m3")
                    end
                elseif dropConfigId == 10400 then --石材
                    if resourceUi then
                         beginIcon = resourceUi:getChildByName("Panel_m4")
                    end
                elseif dropConfigId == 10500 then --铁矿
                    if resourceUi then
                         beginIcon = resourceUi:getChildByName("Panel_m5")
                    end
                end
                
                local playeffect = function()
                    if dropConfigId == 10100 then --黄金
                        require("game.effectlayer.harvestEffect_Fly").play_Gold_forBeginPosition(beginPosition,dropCount)
                    elseif dropConfigId == 10200 then --粮食
                        require("game.effectlayer.harvestEffect_Fly").play_Food_forBeginPosition(beginPosition,dropCount)
                    elseif dropConfigId == 10300 then --木材
                        require("game.effectlayer.harvestEffect_Fly").play_Wood_forBeginPosition(beginPosition,dropCount)
                    elseif dropConfigId == 10400 then --石材
                        require("game.effectlayer.harvestEffect_Fly").play_Stone_forBeginPosition(beginPosition,dropCount)
                    elseif dropConfigId == 10500 then --铁矿
                        require("game.effectlayer.harvestEffect_Fly").play_Iron_forBeginPosition(beginPosition,dropCount)
                    end
                end
                
                if beginIcon then
                    beginIcon:setAnchorPoint(cc.p(0.5,0.5))
                    beginIcon:setPosition(postions[resourceIdx])
                    if dropCount >= 10000 then
                        beginIcon:getChildByName("BitmapFontLabel_1"):setString("+"..string.formatnumberlogogram(dropCount))
                    else
                        beginIcon:getChildByName("BitmapFontLabel_1"):setString("+"..string.formatnumberthousands(dropCount))
                    end
                    
                    local size = beginIcon:getContentSize()
                    beginPosition = beginIcon:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
                    beginIcon:setScaleX(0.01)
                    beginIcon:setVisible(false)
                    beginIcon:runAction( cc.Sequence:create( cc.DelayTime:create(resourceIdx*effectDelay) ,cc.Show:create(),cc.ScaleTo:create(effectScaleTime,1.0),cc.CallFunc:create(function()
                          playeffect()
                    end) ) ) --run action end
                    
                    resourceIdx = resourceIdx + 1
                end
                
            end
               
        end
    end
    
    local function nodeEventHandler(eventType)
        if eventType == "enter" then
            playResourceDropEffect()
            if #othersAwards > 0 then
                self:runAction( cc.Sequence:create( cc.ScaleTo:create(0.13,1.0) , cc.DelayTime:create(1.5) , cc.ScaleTo:create(0.13,1.0,0.1,1.0) , cc.RemoveSelf:create() ) )
            else
                self:setVisible(false)
                self:runAction( cc.Sequence:create( cc.DelayTime:create(1.5) , cc.RemoveSelf:create() ) )
            end
        elseif eventType == "exit" then
        end
    end
    self:registerScriptHandler(nodeEventHandler)
    self:addChild(widget)
    self:setScaleY(0.1)
    --self:setPositionY(240)
end

return AwardsToast

