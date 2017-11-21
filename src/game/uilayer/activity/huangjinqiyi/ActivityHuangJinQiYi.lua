local ActivityHuangJinQiYi = class("ActivityHuangJinQiYi",function()
    return cc.Layer:create()
end)

local huangjinNpcMode = require("game.uilayer.activity.huangjinqiyi.huangjinNpcData")

--显示界面请用这个方法
function ActivityHuangJinQiYi.show()
    if huangjinNpcMode.RequestData() then
        g_sceneManager.addNodeForUI(ActivityHuangJinQiYi:create())
    end
end

function ActivityHuangJinQiYi:ctor()
    local uiLayer =  g_gameTools.LoadCocosUI("TheYellow_main2.csb",5)
    self:addChild(uiLayer)
    --g_resourcesInterface.installResources(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
              self:removeFromParent()
          end
    end)
    
    baseNode:getChildByName("Text_1_1"):setString(g_tr("huangjinArmyDefTip"))
    baseNode:getChildByName("Text_c2"):setString(g_tr("huangjinqiyiDetailTitle"))
    baseNode:getChildByName("Text_c10"):setString(g_tr("huangjinqiyiArmytitle"))
    baseNode:getChildByName("Button_yq2"):getChildByName("Text_1"):setString(g_tr("huangjinqiyiBtnReport"))
    baseNode:getChildByName("Button_1"):getChildByName("Text_2"):setString(g_tr("huangjinqiyiBtnArmy"))
    baseNode:getChildByName("Button_2"):getChildByName("Text_2"):setString(g_tr("huangjinqiyiBtnRank"))
    
    local battleLogBtn = baseNode:getChildByName("Button_yq2")
    battleLogBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
             local function callback(result,data)
                if result == true then
                    g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleRecordView").new(data))
                end
             end
             g_sgHttp.postData("Army/getBattleLog", {type = 10}, callback)
          end
    end)
    
    local gotoBuildBtn = baseNode:getChildByName("Button_1")
    gotoBuildBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              if g_AllianceMode.getSelfHaveAlliance() then --去往联盟堡垒
                   local data = huangjinNpcMode.GetData()
                   if not data.hasBase then
                      g_airBox.show(g_tr("activityNoAllianceBase"))
                      return 
                   end
                   
                   local targetX = tonumber(data.pos.x)
                   local targetY = tonumber(data.pos.y)
                   
                   local gotoAllianceBuild = function()
                       self:removeFromParent()
                       require("game.maplayer.changeMapScene").gotoWorldAndOpenInterface_BigTileIndex( {x = targetX,y = targetY} )
                   end
              
                   local changeMapScene = require("game.maplayer.changeMapScene")
                   if changeMapScene.getCurrentMapStatus() ~= changeMapScene.m_MapEnum.world then
                        g_msgBox.show(g_tr("goToAllianceTip"),nil,nil,
                            function(event)
                              if event == 0 then
                                  gotoAllianceBuild()
                              end
                            end,1)
                   else
                       gotoAllianceBuild()
                   end
              else
                   g_airBox.show(g_tr("noAllianceTip"))
              end
          end
    end)
    
    local gotoActivityBtn = baseNode:getChildByName("Button_2")
    gotoActivityBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              self:removeFromParent()
              g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.ACTIVITY,{activity_id = 1003,params = 3}) --去联盟任务活动的和黄巾起义标签
          end
    end)
    
    local yingzhanBtn = baseNode:getChildByName("Button_yz")
    yingzhanBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              
          end
    end)
    yingzhanBtn:setVisible(false) --迎战按钮不再使用
    
    --left time label
    self._timeLabelLeft = g_gameTools.createRichText(self._baseNode:getChildByName("Panel_z1"):getChildByName("Text_4"),"")
    self._timeLabelRight = g_gameTools.createRichText(self._baseNode:getChildByName("Panel_z2"):getChildByName("Text_4"),"")
    
    self:updateView()
end

function ActivityHuangJinQiYi:updateView()
    local data = huangjinNpcMode.GetData()
    
    self._baseNode:getChildByName("Panel_z1"):setVisible(false)
    self._baseNode:getChildByName("Panel_z1"):stopAllActions()
    self._baseNode:getChildByName("Panel_z2"):setVisible(false)
    self._baseNode:getChildByName("Panel_z2"):stopAllActions()
    
    local isOpen = true
    
    if data.npc[1] == nil and data.guildHuangjin then
        if data.guildHuangjin.status == 0 then
            data.npc[1] = {}
            data.npc[2] = {}
            data.npc[1].npcId = 1
            data.npc[2].npcId = 2
            isOpen = false
        end
    end
    
    
    --left
    if data.npc[1] then
        self._baseNode:getChildByName("Panel_z1"):setVisible(true)
        local npcGroup = g_data.huangjin_attack_mob[tonumber(data.npc[1].npcId)].type_and_count
        for i = 1, 4 do
             local item = self._baseNode:getChildByName("Panel_z1"):getChildByName("Panel_k"..i)
             item:setVisible(false)
             if npcGroup[i] then
                item:setVisible(true)
                local soldierId = npcGroup[i][1]
                local npcCnt = tonumber(npcGroup[i][2])
                item:getChildByName("Text_mbs1"):setString(string.formatnumberthousands(npcCnt))
                item:getChildByName("Image_shiz1"):loadTexture(g_resManager.getResPath(g_data.soldier[soldierId].img_type))
                
                local imgCon = item:getChildByName("Image_k1")
                imgCon:removeAllChildren()
                local conSize = imgCon:getContentSize()
                
                local scale = 1.0
                local itemView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.Soldier,soldierId,1)
                imgCon:addChild(itemView)
                --itemView:enableTip()
                itemView:setCountEnabled(false)
                local size = imgCon:getContentSize()    
                scale = itemView:getContentSize().width/conSize.width  
                itemView:setPositionX(conSize.width/2)
                itemView:setPositionY(conSize.height/2)
                itemView:setScale(scale)
                
                item:getChildByName("Text_mb1"):setString(itemView:getName())
     
             end
        end
        
        if isOpen then
            local updateTimeStr = function()
              local currentTime = g_clock.getCurServerTime()
             
              local secondsLeft = data.npc[1].arrive_time - currentTime 
              if secondsLeft < 0 then
                  secondsLeft = 0
                  self._baseNode:getChildByName("Panel_z1"):stopAllActions()
                  huangjinNpcMode.RequestData()
                  self:updateView()
              else
                  self._timeLabelLeft:setRichText(g_tr("huangjinArmyArriveTip",{time = g_gameTools.convertSecondToString(secondsLeft)}))
              end
            end
            updateTimeStr()
            local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
            local action = cc.RepeatForever:create(seq)
            self._baseNode:getChildByName("Panel_z1"):runAction(action)
        end
    else
        return
    end
    
    --right
    if data.npc[2] then
        self._baseNode:getChildByName("Panel_z2"):setVisible(true)
        
        local npcGroup = g_data.huangjin_attack_mob[tonumber(data.npc[2].npcId)].type_and_count
        for i = 1, 4 do
             local item = self._baseNode:getChildByName("Panel_z2"):getChildByName("Panel_k"..i)
             item:setVisible(false)
             if npcGroup[i] then
                item:setVisible(true)
                local soldierId = npcGroup[i][1]
                local npcCnt = tonumber(npcGroup[i][2])
                item:getChildByName("Text_mbs1"):setString(string.formatnumberthousands(npcCnt))
                item:getChildByName("Image_shiz1"):loadTexture(g_resManager.getResPath(g_data.soldier[soldierId].img_type))
                
                local imgCon = item:getChildByName("Image_k1")
                imgCon:removeAllChildren()
                local conSize = imgCon:getContentSize()
                
                local scale = 1.0
                local itemView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.Soldier,soldierId,1)
                imgCon:addChild(itemView)
                --itemView:enableTip()
                itemView:setCountEnabled(false)
                local size = imgCon:getContentSize()    
                scale = itemView:getContentSize().width/conSize.width  
                itemView:setPositionX(conSize.width/2)
                itemView:setPositionY(conSize.height/2)
                itemView:setScale(scale)
                
                item:getChildByName("Text_mb1"):setString(itemView:getName())
             end
        end
        
        if isOpen then
            local updateTimeStr = function()
              local currentTime = g_clock.getCurServerTime()
             
              local secondsLeft = data.npc[2].arrive_time - currentTime 
              if secondsLeft < 0 then
                  secondsLeft = 0
                  self._baseNode:getChildByName("Panel_z2"):stopAllActions()
                  huangjinNpcMode.RequestData()
                  self:updateView()
              else
                  self._timeLabelRight:setRichText(g_tr("huangjinArmyArriveTip1",{time = g_gameTools.convertSecondToString(secondsLeft)}))
              end
            end
            updateTimeStr()
            local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
            local action = cc.RepeatForever:create(seq)
            self._baseNode:getChildByName("Panel_z2"):runAction(action)
        end
    end
    
    if not isOpen then
        local unOpenStr = g_tr("huangjinqiyiUnopenArmyTip")
        self._timeLabelLeft:setRichText(unOpenStr)
        self._timeLabelRight:setRichText(unOpenStr)
    end
    
end

return ActivityHuangJinQiYi