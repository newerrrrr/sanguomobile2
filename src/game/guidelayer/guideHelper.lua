local guideHelper = {}
setmetatable(guideHelper,{__index = _G})
setfenv(1,guideHelper)

--图标开启动画效果
function playIconOpenEffect(iconsTable,callBack)
    local playCallBack = function()
        if callBack then
            callBack()
        end
    end
    
    local targetIcons = iconsTable or {}
    local vaildBtns = {}
    do
        for key, btn in ipairs(targetIcons) do
            if btn:isVisible() then
                table.insert(vaildBtns,btn)
            end
        end
    end
    
    if #vaildBtns == 0 then
        playCallBack()
        return
    end
    
    local played = false
    do
        --black bg
        local bg = cc.LayerColor:create(cc.c4b(0,0,0,255))
        bg:setCascadeOpacityEnabled(true)
        bg:setOpacity(150)
        g_sceneManager.addNodeForSceneEffect(bg)
        local bgAction = cc.Sequence:create(cc.DelayTime:create(0.8),cc.FadeOut:create(0.618),cc.RemoveSelf:create())
        bg:runAction(bgAction)

        --playEffect
        local projName = "Effect_LingQuTuBiaoBeiGuang"
        local animPath = "anime/"..projName.."/"..projName..".ExportJson"
        local armature , animation = g_gameTools.LoadCocosAni(animPath, projName)
        g_sceneManager.addNodeForSceneEffect(armature)
        armature:setPositionX(g_display.cx)
        armature:setPositionY(g_display.cy)
        animation:play("Animation1")
            
        for key, btn in ipairs(vaildBtns) do
            btn:setCascadeOpacityEnabled(true)
            btn:setOpacity(0)
            
            local icon = btn:clone()
            icon:setOpacity(255)
            
            if icon:getChildByName("Text_2") then
                icon:getChildByName("Text_2"):enableOutline(cc.c4b(0, 0, 0,255),1)
            end
            
            local size = btn:getContentSize()
            
            local offset = 20
            local posX = g_display.cx - ((size.width + offset) * (#vaildBtns-1)/2) + (size.width + offset) * (key - 1)
            icon:setPosition(cc.p(posX,g_display.cy))
            g_sceneManager.addNodeForSceneEffect(icon)

            local pos = btn:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
 
            local action = cc.Sequence:create(cc.DelayTime:create(1.5),cc.MoveTo:create(0.618, pos),cc.DelayTime:create(1.0),cc.RemoveSelf:create(),cc.CallFunc:create(function()
               btn:setOpacity(255)
               if not played then
                   armature:removeFromParent()
                   playCallBack()
               end
               played = true
            end))
            icon:runAction(action)
        end
    end
  
end

return guideHelper