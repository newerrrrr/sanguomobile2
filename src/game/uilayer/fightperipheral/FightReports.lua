local FightReports = class("FightReports",function()
    return cc.Layer:create()
end)

function FightReports:ctor()
    local uiLayer =  g_gameTools.LoadCocosUI("ArenaGrand_popup.csb",5)
    self:addChild(uiLayer)
    --g_resourcesInterface.installResources(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
          end
    end)
    self._listView = baseNode:getChildByName("ListView_1")
    
    baseNode:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("peripheral_report_title"))
    
    self:registerScriptHandler(function(eventType)
        if eventType == "enter" then
            local function onRecv(result, msgData)
                g_busyTip.hide_1()
                if result == true then
                   local function createItem(reportData)
                      local item = cc.CSLoader:createNode("ArenaGrand_list1.csb")                      
                      item:getChildByName("Panel_1"):setVisible(false)
                      item:getChildByName("Panel_2"):setVisible(false)
                      item:getChildByName("Panel_3"):setVisible(false)
                      
                      if reportData.win_player_id == 0 then
                          item:getChildByName("Panel_3"):setVisible(true)
                      elseif reportData.win_player_id == g_PlayerMode.GetData().id then
                          item:getChildByName("Panel_1"):setVisible(true)
                      else
                          item:getChildByName("Panel_2"):setVisible(true)
                      end
                      
                      
                      item:getChildByName("Image_fs"):setVisible(false)
                      item:getChildByName("Image_fs_0"):setVisible(false)
                      
                      local myScore = 0
                      if g_PlayerMode.GetData().id == reportData.me.player_id then
                         myScore = reportData.me.score
                         item:getChildByName("Image_fs_0"):setVisible(true)
                      elseif g_PlayerMode.GetData().id == reportData.target.player_id then
                         myScore = reportData.target.score
                         item:getChildByName("Image_fs"):setVisible(true)
                      end
                      
                      if myScore >= 0 then
                          item:getChildByName("Text_3_1"):setTextColor(g_Consts.ColorType.Green)
                          item:getChildByName("Text_3_1"):setString("+"..myScore)
                      else
                          item:getChildByName("Text_3_1"):setTextColor(g_Consts.ColorType.Red)
                          item:getChildByName("Text_3_1"):setString(""..myScore)
                      end

                      local avatarId = reportData.me.avatar_id
                      if avatarId < 1 then
                          avatarId = 1
                      end
                      local iconId = g_data.res_head[avatarId].head_icon
                      item:getChildByName("Image_t1"):loadTexture(g_resManager.getResPath(iconId))
                      item:getChildByName("Image_t1_1"):loadTexture(g_resManager.getResPath(1010007)) --boader
                      
                      local avatarId = tonumber(reportData.target.avatar_id)
                      if avatarId < 1 then
                          avatarId = 1
                      end
                      local iconId = g_data.res_head[avatarId].head_icon
                      item:getChildByName("Image_t2"):loadTexture(g_resManager.getResPath(iconId))
                      item:getChildByName("Image_t2_1"):loadTexture(g_resManager.getResPath(1010007)) --boader
                      
                      local targetName = "S"..reportData.target.server_id.." "..reportData.target.nick
                      if reportData.type == 0 then
                          targetName = "S"..reportData.target.server_id.." "..g_tr(reportData.target.nick)
                      end
                      
                      item:getChildByName("Text_n1"):setString("S"..reportData.me.server_id.." "..reportData.me.nick)
                      item:getChildByName("Text_n2"):setString(targetName)
                      
                      local nowTime = g_clock.getCurServerTime()
                      local lastTime = reportData.end_time
                      local timeShowStr = ""
                      if lastTime > 0 then 
                         local miniutes = math.ceil((nowTime - lastTime)/60)             
                         if miniutes < 60 then
                             timeShowStr = g_tr("miniuteago",{value = miniutes})
                         elseif miniutes >= 60 and miniutes < 1440 then
                             timeShowStr =  g_tr("hourago",{value = math.floor(miniutes/60)})
                         else
                             timeShowStr = g_tr("dayago",{value = math.min(7, math.floor(miniutes/1440))})
                         end
                      else 
                         timeShowStr = g_tr("dayago",{value = 7})
                      end 
                      item:getChildByName("Text_3"):setString(timeShowStr)
                      item:getChildByName("Text_3_0"):setString(g_tr("peripheral_score_unit"))
                      
                      item:getChildByName("Text_dengji1"):setString("Lv"..reportData.me.level)
                      item:getChildByName("Text_dengji2"):setString("Lv"..reportData.target.level)
                      
                      --分享
                      item:getChildByName("Button_2"):setVisible(false)
                      
                      --回放
                      item:getChildByName("Button_1"):addClickEventListener(function()
                                 --TODO:战报里需要增加 玩家的段位，积分和武将信息
                
                                 local function onResult(result, msgData)
                                    g_busyTip.hide_1()
                                    if result == true then
                                        local data = {
                                            ["playerData_A"] = {
                                                name = "S"..reportData.me.server_id.." "..reportData.me.nick,
                                                player_id = reportData.me.player_id,
                                                avatar_id = reportData.me.avatar_id,
                                                level = reportData.me.level
                                            },
                                            ["playerData_B"] = {
                                                name = targetName,
                                                player_id = reportData.target.player_id,
                                                avatar_id = reportData.target.avatar_id,
                                                level = reportData.target.level
                                            },
                                            ["backPlayData"] = msgData.pk_result,
                                        }
                                        
                                        if data.backPlayData and type(data.backPlayData) == "string" and data.backPlayData ~= "" then
                                            local selfPlaystates = {
                                                nick = reportData.me.nick,
                                                server_id = reportData.me.server_id,
                                                duel_rank_id = reportData.me.duel_rank_id,
                                                score = reportData.me.total_score,
                                                general_1 = {general_id = reportData.me.general_info.general_1.general_id},
                                                general_2 = {general_id = reportData.me.general_info.general_2.general_id},
                                                general_3 = {general_id = reportData.me.general_info.general_3.general_id},
                                            }
                                            
                                            local targetPlaystates = {
                                                nick = reportData.target.nick,
                                                server_id = reportData.target.server_id,
                                                duel_rank_id = reportData.target.duel_rank_id,
                                                score = reportData.target.total_score,
                                                general_1 = {general_id = reportData.target.general_info.general_1.general_id},
                                                general_2 = {general_id = reportData.target.general_info.general_2.general_id},
                                                general_3 = {general_id = reportData.target.general_info.general_3.general_id},
                                            }
                                        
                                            g_sceneManager.addNodeForSceneEffect(require("game.uilayer.fightperipheral.FightPreview"):create(selfPlaystates,targetPlaystates,reportData.id,data))
                                        else
                                            g_airBox.show(g_tr("peripheral_replay_invaild"))
                                        end
                                    end
                                 end
                                 g_busyTip.show_1()
                                 g_sgHttp.postData("pk/getPkResult",{id = reportData.id},onResult,true)
 
                          end)
                          
                          self._listView:pushBackCustomItem(item)
                    end
                    
                    local reportDatasArr = {}
                    for key, reportData in pairs(msgData) do
                        table.insert(reportDatasArr,reportData)
                    end
                    
                    local actionTag = 1254698
                    local numbers = #reportDatasArr
                    if numbers > 0 then
                        local startIdx = 5
                        local idx = 1
                        for key = 1, numbers do
                            if key > startIdx then
                                break
                            else
                                createItem(reportDatasArr[idx])
                                idx = idx + 1
                            end
                        end
                        
                        local callback = function()
                            createItem(reportDatasArr[idx])
                            idx = idx + 1
                            if idx > numbers then
                                self:stopActionByTag(actionTag)
                            end
                        end
                        
                        if numbers > startIdx then
                            local sequence = cc.Sequence:create(cc.DelayTime:create(0.001), cc.CallFunc:create(callback))
                            local action = cc.RepeatForever:create(sequence)
                            action:setTag(actionTag)
                            self:runAction(action)
                        end
                    end
                else
                    self:removeFromParent()
                end
            end
        
            g_busyTip.show_1()
            g_sgHttp.postData("pk/getPkList",{},onRecv,true)
        elseif eventType == "exit" then
            
        end
    end)
    
end

return FightReports