local AllianceMissionRewardLayer = class("AllianceMissionRewardLayer",function()
    return cc.Layer:create()
end)

function AllianceMissionRewardLayer.show(btnSendReward,callback)
    local function onRecv(result, msgData)
      g_busyTip.hide_1()
      if result then
          --for test
--          msgData.giftList = {
--            ["52106"] = 1,
--            ["52107"] = 6,
--            ["52108"] = 3,
--          }
          
          g_AllianceMode.haveShowRewardSend = true
          g_AllianceMode.rewardCnt = 0
          if msgData.giftList and table.nums(msgData.giftList) > 0 then
              local lastGiftCnt = 0
              for key, var in pairs(msgData.giftList) do
                  lastGiftCnt = lastGiftCnt + tonumber(var)
              end
              
              if btnSendReward then
                  btnSendReward:setVisible(lastGiftCnt > 0)
              end
              
              g_AllianceMode.rewardCnt = lastGiftCnt
              
              if lastGiftCnt > 0 then
                  local layer =  require("game.uilayer.alliance.AllianceMissionRewardLayer"):create(msgData.giftList)
                  g_sceneManager.addNodeForUI(layer)
              end
              
              if callback then
                  callback()
              end
          end
      end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("guild/getGuildGiftInfo",{},onRecv,true)

end


function AllianceMissionRewardLayer:ctor(giftList)
    
    local node = g_gameTools.LoadCocosUI("alliance_manager_send_reward.csb",5)
    self:addChild(node)
    self._baseNode = node:getChildByName("scale_node"):getChildByName("content_popup")
    
    --关闭本页
    local btnClose = self._baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    self._baseNode:getChildByName("bg_title"):getChildByName("Text"):setString(g_tr("guildGiftReward"))
    self._baseNode:getChildByName("text_nr_0"):setString(g_tr("guildGiftRewardRule"))
    
    
    local listView = self._baseNode:getChildByName("ListView_1")
    self._listView = listView
    
    self._giftList = giftList
    self:updateView()
end

function AllianceMissionRewardLayer:updateView()
     
     local giftList = self._giftList
     
     if giftList == nil then
        return
     end
     
     self._listView:removeAllChildren()

     for key, var in pairs(giftList) do
         local item = cc.CSLoader:createNode("alliance_manager_send_reward_list1.csb")
         local itemView = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.Props,tonumber(key),tonumber(var))
         itemView:enableTip()
         local imgCon = item:getChildByName("army_item"):getChildByName("pic")
         imgCon:addChild(itemView)
         local size = imgCon:getContentSize()
         itemView:setPosition(cc.p(size.width*0.5,size.height*0.5))
         local scale = size.width/itemView:getContentSize().width
         itemView:setScale(scale)
         item:getChildByName("army_item"):getChildByName("Text_1"):setString(itemView:getName())
         
         item:getChildByName("army_item"):getChildByName("btn_bf"):getChildByName("Text"):setString(g_tr("guildGiftRewardBtn"))
         item:getChildByName("army_item"):getChildByName("btn_bf"):setEnabled(tonumber(var) > 0)
         item:getChildByName("army_item"):getChildByName("btn_bf"):addClickEventListener(function()
              g_sceneManager.addNodeForUI(require("game.uilayer.alliance.AlliancePlayerManageLayer"):create(function(memberInfo)
                  local function onRecv(result, msgData)
                      g_busyTip.hide_1()
                      if result then
                          g_AllianceMode.rewardCnt = 0
                          if msgData.giftList and table.nums(msgData.giftList) > 0 then
                             
                             local lastGiftCnt = 0
                             for key, var in pairs(msgData.giftList) do
                                  lastGiftCnt = lastGiftCnt + tonumber(var)
                             end
 
                             g_AllianceMode.rewardCnt = lastGiftCnt
                          
                             self._giftList = msgData.giftList
                             self:updateView()
                          end
                      end
                  end
                  g_busyTip.show_1()
                  g_sgHttp.postData("guild/distributeGift",{targetPlayerId = memberInfo.player_id,giftId = tonumber(key)},onRecv,true)
              end,"sendreward"))
         end)
         
         self._listView:pushBackCustomItem(item)
      end

end

return AllianceMissionRewardLayer