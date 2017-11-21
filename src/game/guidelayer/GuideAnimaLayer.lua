local GuideAnimaLayer = class("GuideAnimaLayer",function()
    return cc.Layer:create()
end)

function GuideAnimaLayer:ctor(animaName,completeHandler)
  --for test
  animaName = "Effect_JiuGuanZhaoMu"
  
  local animDoneHandler = function()
       if completeHandler then
           completeHandler()
       end
       self:removeFromParent()
       g_guideManager.execute()
  end
  
  --TODO:添加跳过按钮
  
  

   --动画播放事件
   local onMovementEventCallFunc = function(armature , eventType , name)
       if 0 == eventType then --start
       elseif 1 == eventType then --end
          animDoneHandler()
       end
   end
   
   local m_animationNode = ccui.Widget:create()
   self:addChild(m_animationNode)
   m_animationNode:setContentSize(g_display.size)
   m_animationNode:setAnchorPoint(cc.p(0.5,0.5))
   m_animationNode:setPositionX(g_display.cx)
   m_animationNode:setPositionY(g_display.cy)
   m_animationNode:setTouchEnabled(true)
   m_animationNode:setScale(g_display.scale)
      
   --动画加载
   local projName = animaName
   local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName,onMovementEventCallFunc)
   m_animationNode:addChild(armature)
   armature:setPositionX(g_display.cx)
   armature:setPositionY(g_display.cy)
   self._animation = animation
end

function GuideAnimaLayer:play()
    self._animation:play("Effect_JiuGuanZhaoMuYinXiongCenter")
end

return GuideAnimaLayer