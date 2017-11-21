local FightRankLevelUpEffect = {}
setmetatable(FightRankLevelUpEffect,{__index = _G})
setfenv(1,FightRankLevelUpEffect)

function playFightResultScore(left,right)
    
    local canClose = false
    
    --bg
     local layer = cc.LayerColor:create(cc.c4b(0,0,0,188))
     local bg = cc.Sprite:create("cocostudio_res/huodong/huoodng_cank1.jpg")
     layer:addChild(bg)
     
     local uiLayer =  g_gameTools.LoadCocosUI("ArenaRanking_fight_result.csb",5)
     layer:addChild(uiLayer)
     --g_resourcesInterface.installResources(uiLayer)
     local baseNode = uiLayer:getChildByName("scale_node")
     baseNode:setVisible(false)
    
     
     local m_animationNode = ccui.Widget:create()
     m_animationNode:setContentSize(g_display.size)
     m_animationNode:setAnchorPoint(cc.p(0.5,0.5))
     m_animationNode:setPositionX(g_display.cx)
     m_animationNode:setPositionY(g_display.cy)
     m_animationNode:setScale(g_display.scale)
     m_animationNode:setTouchEnabled(true)
     m_animationNode:addClickEventListener(function()
          if canClose then
              layer:removeFromParent()
          end
     end)
     layer:addChild(m_animationNode)
     
     local function playXunHuan()
        --循环动画
         local onMovementEventCallFunc = function(armature , eventType , name)
             if 0 == eventType then --start
             elseif 1 == eventType then --end
                canClose = true
             end
         end
         
         local projName = "Effect_LeiTaiZuiZhongDeFen"
         local animPath = "anime/"..projName.."/"..projName..".ExportJson"
         local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,onMovementEventCallFunc)
         

         local container = cc.Node:create()
         local pic = cc.Sprite:create(g_resManager.getResPath(1999910 + left))
         container:addChild(pic)
         armature:getBone("LNumber"):addDisplay(container,0)

         local container = cc.Node:create()
         local pic = cc.Sprite:create(g_resManager.getResPath(1999920 + right))
         container:addChild(pic)
         armature:getBone("RNumber"):addDisplay(container,0)
         
         m_animationNode:addChild(armature)
         armature:setPositionX(g_display.cx)
         armature:setPositionY(g_display.cy)
         

         animation:play("Animation1")

     end
     
     g_sceneManager.addNodeForSceneEffect(layer)
     playXunHuan()
end

function playBigRankLevelUp(from,to)
    
    
    local canClose = false
    
    --bg
     local layer = cc.LayerColor:create(cc.c4b(0,0,0,188))
     local m_animationNode = ccui.Widget:create()
     m_animationNode:setContentSize(g_display.size)
     m_animationNode:setAnchorPoint(cc.p(0.5,0.5))
     m_animationNode:setPositionX(g_display.cx)
     m_animationNode:setPositionY(g_display.cy)
     m_animationNode:setScale(g_display.scale)
     m_animationNode:setTouchEnabled(true)
     m_animationNode:addClickEventListener(function()
          if canClose then
              layer:removeFromParent()
          end
     end)
     layer:addChild(m_animationNode)
     
     local function playXunHuan()
        --循环动画
         local onMovementEventCallFunc = function(armature , eventType , name)
             if 0 == eventType then --start
             elseif 1 == eventType then --end
                 
             end
         end
         
         local projName = "Effect_JunXianXunHuan"
         local animPath = "anime/"..projName.."/"..projName..".ExportJson"
         local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,onMovementEventCallFunc)
         
         local rankConfig = g_data.duel_rank[to] 
         local container = cc.Node:create()
         local pic = cc.Sprite:create(g_resManager.getResPath(rankConfig.rank_pic))
         container:addChild(pic)
--         armature:getBone("LOGO1"):addDisplay(container,0)
         m_animationNode:addChild(container)
         container:setPositionX(g_display.cx)
         container:setPositionY(g_display.cy)
         
         
         m_animationNode:addChild(armature)
         armature:setPositionX(g_display.cx)
         armature:setPositionY(g_display.cy)
         
         local bigRank = rankConfig.rank
         animation:play(""..bigRank)
         canClose = true
     
     end

     local function playChuXian()
         --出现动画
         local onMovementEventCallFunc = function(armature , eventType , name)
             if 0 == eventType then --start
             elseif 1 == eventType then --end
                armature:removeFromParent()
                playXunHuan()
             end
         end
         local projName = "Effect_JunXianChuXian"
         local animPath = "anime/"..projName.."/"..projName..".ExportJson"
         local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,onMovementEventCallFunc)
         m_animationNode:addChild(armature)
         armature:setPositionX(g_display.cx)
         armature:setPositionY(g_display.cy)
         
         local rankConfig = g_data.duel_rank[to] 
         local container = cc.Node:create()
         local pic = cc.Sprite:create(g_resManager.getResPath(rankConfig.rank_pic))
         container:addChild(pic)
         armature:getBone("LOGO1"):addDisplay(container,0)
         
         local container = cc.Node:create()
         local pic = cc.Sprite:create(g_resManager.getResPath(rankConfig.rank_pic))
         container:addChild(pic)
         armature:getBone("LOGO2"):addDisplay(container,0)
         
         local container = cc.Node:create()
         local pic = cc.Sprite:create(g_resManager.getResPath(rankConfig.rank_pic))
         container:addChild(pic)
         armature:getBone("LOGO3"):addDisplay(container,0)
         
         local bigRank = rankConfig.rank
         animation:play(""..bigRank)
     end
     
     local function playXiaoShi()
         --消失动画
         local onMovementEventCallFunc = function(armature , eventType , name)
             if 0 == eventType then --start
             elseif 1 == eventType then --end
                 playChuXian()
                 armature:removeFromParent()
             end
         end
         local projName = "Effect_JunXianXiaoShi"
         local animPath = "anime/"..projName.."/"..projName..".ExportJson"
         local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,onMovementEventCallFunc)
         m_animationNode:addChild(armature)
         armature:setPositionX(g_display.cx)
         armature:setPositionY(g_display.cy)
         
         local rankConfig = g_data.duel_rank[to] 
         local bigRank = rankConfig.rank
         animation:play("Rank_"..bigRank)
     end
     
     g_sceneManager.addNodeForSceneEffect(layer)
     
     playXiaoShi()
end

function playSmallRankLevelUp(from,to)
    local canClose = false
    
    --bg
     local layer = cc.LayerColor:create(cc.c4b(0,0,0,188))
     local m_animationNode = ccui.Widget:create()
     m_animationNode:setContentSize(g_display.size)
     m_animationNode:setAnchorPoint(cc.p(0.5,0.5))
     m_animationNode:setPositionX(g_display.cx)
     m_animationNode:setPositionY(g_display.cy)
     m_animationNode:setScale(g_display.scale)
     m_animationNode:setTouchEnabled(true)
     m_animationNode:addClickEventListener(function()
          if canClose then
              layer:removeFromParent()
          end
     end)
     layer:addChild(m_animationNode)
     
     local function playXiaoShi()
         local actionList = {"XiaoShi","ChuXian","ChangTai"}
         local actionIdx = 1
         
         local _animation = nil
         --消失动画
         local onMovementEventCallFunc = function(armature , eventType , name)
             if 0 == eventType then --start
             elseif 1 == eventType then --end
                 actionIdx = actionIdx + 1
                 if actionIdx <= #actionList then
                     local rankConfig = g_data.duel_rank[to] 
                     local container = cc.Node:create()
                     local pic = cc.Sprite:create(g_resManager.getResPath(rankConfig.rank_number))
                     container:addChild(pic)
                     armature:getBone("Numbei"):addDisplay(container,0)
                     _animation:play(actionList[actionIdx])
                 else
                     canClose = true
                 end
             end
         end
         local projName = "Effect_JunXianNumber"
         local animPath = "anime/"..projName.."/"..projName..".ExportJson"
         local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,onMovementEventCallFunc)
         _animation = animation
         m_animationNode:addChild(armature)
         armature:setPositionX(g_display.cx)
         armature:setPositionY(g_display.cy)
         
         local rankConfig = g_data.duel_rank[from] 
         local container = cc.Node:create()
         local pic = cc.Sprite:create(g_resManager.getResPath(rankConfig.rank_number))
         container:addChild(pic)
         armature:getBone("Numbei"):addDisplay(container,0)
         animation:play(actionList[actionIdx])

     end
     
     local function playXunHuan()
        --循环动画
         local onMovementEventCallFunc = function(armature , eventType , name)
             if 0 == eventType then --start
             elseif 1 == eventType then --end
                 
             end
         end
         
         local projName = "Effect_JunXianXunHuan"
         local animPath = "anime/"..projName.."/"..projName..".ExportJson"
         local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,onMovementEventCallFunc)
         m_animationNode:addChild(armature)
         armature:setPositionX(g_display.cx)
         armature:setPositionY(g_display.cy)
         
         local rankConfig = g_data.duel_rank[to] 
         local container = cc.Node:create()
         local pic = cc.Sprite:create(g_resManager.getResPath(rankConfig.rank_pic))
         container:addChild(pic)
         --armature:getBone("LOGO1"):addDisplay(container,0)
         m_animationNode:addChild(container)
         container:setPositionX(g_display.cx)
         container:setPositionY(g_display.cy)
         
         local bigRank = rankConfig.rank
         animation:play(""..bigRank)

     end
     
     g_sceneManager.addNodeForSceneEffect(layer)
     
     playXunHuan()
     playXiaoShi()
end

return FightRankLevelUpEffect