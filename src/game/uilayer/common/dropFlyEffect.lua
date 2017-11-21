local dropFlyEffect = {}
setmetatable(dropFlyEffect,{__index = _G})
setfenv(1,dropFlyEffect)

local scale = 1.0

local effectDelay = 1.60*scale--飞入频率
local effectStay = 1.05 --停留时间
local effectScaleTime = 0.45*scale --飞入速度
local effectScaleTimeOut = 0.30*scale --飞出速度

local bg = nil
--params 
-- droupGroups --掉落
-- startPosition --效果起始坐标
-- disEnableTouch --动画期间屏蔽触摸
function show(droupGroups,startPosition,disEnableTouch)
    
    if table.nums(droupGroups) <= 0 then
        return
    end
    
    local startPos = cc.p(g_display.cx,g_display.cy - 300)
    
    if startPosition then
        startPos = startPosition
    end
    
    local endPos = require("game.uilayer.mainSurface.mainSurfaceMenu").getBagBtnPos()
    
    if bg == nil then
        bg = cc.LayerColor:create(cc.c4b(0,0,0,255))
        if disEnableTouch == true then
        
            local listener = cc.EventListenerTouchOneByOne:create()
            local onTouchBegan = function(touch,event)
                return true
            end
            
            local onTouchEnded = function(touch,event)
               
            end
            
            listener:setSwallowTouches(true)
            listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
            listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
            cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,bg)
        end
        
        g_sceneManager.addNodeForSceneEffect(bg)
        
    end
    
    bg:setCascadeOpacityEnabled(true)
    bg:setOpacity(150)
    --bg:runAction(cc.Sequence:create(cc.FadeTo(1.0,125)))
    
    local idx = 0
    local runIdx = 0
    local total = table.nums(droupGroups)
    for key, dropGroup in pairs(droupGroups) do
        local dropType = dropGroup[1]
        local dropConfigId = dropGroup[2]
        local dropCount = dropGroup[3]
        
        local beginIcon = require("game.uilayer.common.DropItemView"):create(dropType,dropConfigId,dropCount)
        beginIcon:setNameVisible(true)
        beginIcon:setScale(0.618)
        beginIcon:setVisible(false)
        beginIcon:setPosition(startPos)
        beginIcon:runAction( 
            cc.Sequence:create( 
                cc.DelayTime:create(idx*effectDelay) ,
                cc.Show:create(),
                cc.EaseBackOut:create(cc.Spawn:create(cc.ScaleTo:create(effectScaleTime,1.0),
                cc.MoveTo:create(effectScaleTime,cc.p(g_display.cx,g_display.cy + 150)))),
                cc.CallFunc:create(function()
                
                    --playEffect
                    local projName = "Effect_LingQuTuBiaoBeiGuang"
                    local animPath = "anime/"..projName.."/"..projName..".ExportJson"
                    local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
                    beginIcon:addChild(armature,-1)
                    armature:setPositionX(beginIcon:getContentSize().width*0.5)
                    armature:setPositionY(beginIcon:getContentSize().height*0.5)
                    animation:play("Animation1")
                    
                    beginIcon:runAction( 
                        cc.Sequence:create( 
                            cc.DelayTime:create(effectStay) ,
                            cc.CallFunc:create(function()
                                runIdx = runIdx + 1
                                if runIdx == total then
                                    if bg then
                                        bg:removeFromParent()
                                        bg = nil
                                    end
                                end
                            end),
                            cc.EaseBackIn:create(cc.Spawn:create(cc.ScaleTo:create(effectScaleTimeOut,0.5),cc.MoveTo:create(effectScaleTimeOut,endPos))),
                            cc.RemoveSelf:create()
                        )
                    )
                    
                end) 
             ) 
        ) --run action end
        
        g_sceneManager.addNodeForSceneEffect(beginIcon)
        idx = idx + 1
    end
    
    
end

return dropFlyEffect