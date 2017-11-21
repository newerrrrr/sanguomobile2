local AlliancePlayerManageLayer = class("AlliancePlayerManageLayer",function()
    return cc.Layer:create()
end)

local baseNode = nil
local maxPlayerRank = 5
local minPlayerRank = 1
local actionTag = 452569
function AlliancePlayerManageLayer:ctor(inviteCallback,bigTileIndexPos)
    local node = g_gameTools.LoadCocosUI("alliance_manage_index.csb",5)
    self:addChild(node)
    baseNode = node:getChildByName("scale_node")
    
    self._needReload = false
    self._inviteCallback = inviteCallback --是否是邀请迁城
    self._bigTileIndexPos = bigTileIndexPos
    
    self._requestMemberCnt = 0
    self._requestLeftMenu = nil
    
     --关闭本页
    local btnClose = baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent(true)
        end
    end)
    
    baseNode:getChildByName("Text_1"):setString(g_tr("allianceMembers"))
    
    --添加左侧按钮列表
    local menusTexts = {}
    local baseData = g_AllianceMode.getBaseData()
    for i = 5, 1,-1 do
        local rankName = baseData.GuildRankName[i]
		
		if rankName == nil or rankName == "" then	--李寒松帮你加了这里
			rankName = g_tr("allianceRankName"..i)
		end
		
        table.insert(menusTexts,rankName)
    end
    
    local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
    --R4 R5玩家能查看/处理加入公会；邀请迁城也不需要申请列表
    if myInfo and myInfo.rank >= 4  and self._inviteCallback == nil then
      table.insert(menusTexts,g_tr("applyList"))
    end
    
    self._menusTexts = menusTexts
    local leftListView = baseNode:getChildByName("ListView_left")
    self._leftListView = leftListView
    local itemModel = cc.CSLoader:createNode("alliance_manage_left_menu.csb")
    itemModel:setContentSize(itemModel:getChildByName("pic_select"):getContentSize())
    itemModel:getChildByName("pic_selected"):setVisible(true)
    leftListView:setItemModel(itemModel)
    --leftListView:setItemsMargin(1.0)
    for key, text in pairs(menusTexts) do
       leftListView:pushBackDefaultItem()
    end
    
    local items = leftListView:getItems()
    for i =1, #items do
      local str = tostring(menusTexts[i])
      local item = leftListView:getItem(i - 1)
      if item and str then
          item:getChildByName("text"):setString(str)
      end
      
      --申请列表
      if i == 6 then
          self._requestLeftMenu = item
          self._requestLeftMenu:getChildByName("Image_8"):setVisible(false)
      end
    end
    
    self:updateTipCnt(g_AllianceMode.getRequestNum())
    
    --切换各阶段成员列表
    local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("touched:",sender:getCurSelectedIndex())
            self:changePage(sender:getCurSelectedIndex() + 1)
        end
    end
    leftListView:addEventListener(listViewEvent)

    local memberListView = cc.CSLoader:createNode("alliance_manage_members_scroll.csb")
    local container = baseNode:getChildByName("container")
    container:addChild(memberListView)
    self._memberListViewModel = memberListView:getChildByName("ListView_3")
    self._memberListViewModel:setVisible(false)

    
    self:changePage(1,true)
end

function AlliancePlayerManageLayer:createManageItem(memberInfo,idx)
     local panle = cc.CSLoader:createNode("alliance_manage_members_list2.csb")
     panle.idx = idx
     local menuClickHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
           
           if sender == panle:getChildByName("member_item"):getChildByName("btn_1") then --邀请迁城
              print("btn1")
           elseif sender == panle:getChildByName("member_item"):getChildByName("btn_2") then --邮件
              --print("btn2")
              local nickNamme = memberInfo.Player.nick
              local pop = require("game.uilayer.mail.MailContentWritePop").new(false,nickNamme)
              g_sceneManager.addNodeForUI(pop)
           elseif sender == panle:getChildByName("member_item"):getChildByName("btn_3") then --军团援助
              --print("btn3")
              g_msgBox.show(g_tr("allianceMakeSureHelpPlayer"),nil,nil,function(event)
                if event == 0 then
                    print("make sure")
                    require("game.maplayer.changeMapScene").gotoWorldAndOpenInterface_BigTileIndex( {x = memberInfo.Player.x,y = memberInfo.Player.y} )
                    self:removeFromParent()
                    g_AllianceMode.getMainView():removeFromParent()
                end
              end,1)

           elseif sender == panle:getChildByName("member_item"):getChildByName("btn_4") then --踢出联盟
              print("btn4")
              if memberInfo.player_id == g_PlayerMode.GetData().id then
                g_airBox.show(g_tr("removeSelfFail"))
              else
                g_msgBox.show(g_tr("makeSureRemoveMember"),nil,nil,function(event)
                  if event == 0 then
                      print("make sure")
                      local resultHandler = function(result, msgData)
                        if result then
                            print("removed")
                            assert(self._openedItem)
                            local openedIdx = self._openedItem.idx
                            self._memberListView:removeItem(openedIdx)
                            self._memberListView:removeItem(openedIdx - 1)
                            self._openedItem = nil
                            self._manageItem = nil
                            self._needReload = true
                        end
                      end
                      g_sgHttp.postData("guild/expelPlayer",{targetPlayerId = memberInfo.player_id},resultHandler)
                  end
                end,1)
              end
           elseif sender == panle:getChildByName("member_item"):getChildByName("btn_5") then --提升阶级
              print("btn5")
              g_msgBox.show(g_tr("makeSureUpgradeMemberRank"),nil,nil,function(event)
                if event == 0 then
                    print("make sure")
                    if self:doUpPlayerRank(memberInfo) == true then
                        assert(self._openedItem)
                        local openedIdx = self._openedItem.idx
                        self._memberListView:removeItem(openedIdx)
                        self._memberListView:removeItem(openedIdx - 1)
                        self._openedItem = nil
                        self._manageItem = nil
                        self._needReload = true
                    end
                    
                end
              end,1)
           elseif sender == panle:getChildByName("member_item"):getChildByName("btn_6") then --降低阶级
              print("btn6")
              g_msgBox.show(g_tr("makeSureDemotionMemberRank"),nil,nil,function(event)
                if event == 0 then
                    print("make sure")
                    if self:doDownPlayerRank(memberInfo) == true then
                        assert(self._openedItem)
                        local openedIdx = self._openedItem.idx
                        self._memberListView:removeItem(openedIdx)
                        self._memberListView:removeItem(openedIdx - 1)
                        self._openedItem = nil
                        self._manageItem = nil
                        self._needReload = true
                    end
                end
              end,1)
           elseif sender == panle:getChildByName("member_item"):getChildByName("btn_7") then --盟主转让
              print("btn7")
              
              g_msgBox.show(g_tr("makeSureTransferLeader"),nil,nil,function(event)
                if event == 0 then
                    print("make sure")
                    local resultHandler = function(result, msgData)
                      if result then
                          print("transferLeader success")
                          self._needReload = true
                          g_AllianceMode.reqAllAllianceData()
                          g_AllianceMode.notifyUpdateView()
                          self:updateView()
                      end
                    end
                    g_sgHttp.postData("guild/transferLeader",{targetPlayerId = memberInfo.player_id},resultHandler)
                end
              end,1)
           elseif sender == panle:getChildByName("member_item"):getChildByName("btn_8") then --退出联盟
              g_msgBox.show(g_tr("makeSureExitAlliance"),nil,nil,function(event)
                if event == 0 then
                    print("make sure")
                    local resultHandler = function(result, msgData)
                      if result then
                          print("exit success")
                          self:removeFromParent()
                          g_airBox.show(g_tr("exitAllianceSuccess"))
                          g_AllianceMode.reqAllAllianceData()
                          g_AllianceMode.notifyUpdateView()
                          g_AllianceMode.updateWorldMap()
                      end
                    end
                    g_sgHttp.postData("guild/expelPlayer",{targetPlayerId = memberInfo.player_id},resultHandler)
                end
              end,1)
           elseif sender == panle:getChildByName("member_item"):getChildByName("btn_9") then --武斗切磋
              g_msgBox.show(g_tr("makeSurePk"),nil,nil,function(event)
                if event == 0 then
                    local function onRecv(result, msgData)
                        g_busyTip.hide_1()
                        if result == true then
                           local selfPlaystates = msgData.me
                           local targetPlaystates = msgData.target
                           g_sceneManager.addNodeForSceneEffect(require("game.uilayer.fightperipheral.FightPreview"):create(selfPlaystates,targetPlaystates,-1))
                        end
                    end
                    g_busyTip.show_1()
                    g_sgHttp.postData("pk/getGuildPlayerGeneralInfo",{target_player_id = memberInfo.player_id},onRecv,true) 
                end
              end,1)
           end
        end
     end
     
     --根据权限显示相应的按钮
     local menus = {}
     local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
     local positions = {}
     for i = 1, 9 do
          local currentBtn = panle:getChildByName("member_item"):getChildByName("btn_"..i)
          currentBtn:getChildByName("Text"):setString(g_tr("allianceMemberManager"..i))
          
          table.insert(positions,currentBtn:getPositionX())
          if i == 1 then --邀请迁城
              currentBtn:setVisible(false)
          elseif i == 2 then --邮件
              if myInfo.player_id == memberInfo.player_id then
                  currentBtn:setVisible(false)
              end
          elseif i == 3 then --军团援助
              if myInfo.player_id == memberInfo.player_id then
                  currentBtn:setVisible(false)
              end
          elseif i == 5 or i == 6 then --提升/降低阶级
              if myInfo.rank < 3 or myInfo.rank <= memberInfo.rank then
                  currentBtn:setVisible(false)
              end
              
--              if myInfo.rank == 5 and i == 5 and memberInfo.rank == 4 then
--                  currentBtn:setVisible(false)
--              end
              
              if i == 5 and memberInfo.rank == myInfo.rank - 1 then
                 currentBtn:setVisible(false)
              end
              
              if i == 6 and memberInfo.rank == 1 then
                  currentBtn:setVisible(false)
              end
              
          elseif i == 7 then --盟主转让
              currentBtn:setVisible(false)
              if myInfo.rank == 5 and memberInfo.rank < 5 then
                  currentBtn:setVisible(true)
              end
          elseif i == 4 then --踢出联盟
              if myInfo.rank < 4 or myInfo.rank <= memberInfo.rank then
                  currentBtn:setVisible(false)
              end
          elseif i == 8 then --退出联盟
              currentBtn:setVisible(false)
              if myInfo.rank ~= 5 and myInfo.player_id == memberInfo.player_id then
                  currentBtn:setVisible(true) 
              end
          elseif i == 9 then --武斗切磋
              if myInfo.player_id == memberInfo.player_id then
                  currentBtn:setVisible(false)
              end
          end
          
          if myInfo.rank == 5 and memberInfo.rank == 5 then
              currentBtn:setVisible(false)
          end
          
     	  currentBtn:addTouchEventListener(menuClickHandler)
     	  if currentBtn:isVisible() then
     	      table.insert(menus,currentBtn)
     	  end
     end
     
     --sort positions
     for i=1, #menus do
        local btn = menus[i]
        btn:setPositionX(positions[i])
     end
     
     return panle
end

function AlliancePlayerManageLayer:cleanMemberListView()
    if self._memberListView then
        self._memberListView:removeFromParent()
    end
    self._memberListView = self._memberListViewModel:clone()
    self._memberListViewModel:getParent():addChild(self._memberListView)
    self._memberListView:setVisible(true)
    
    
    self._openedItem = nil--记录已经打开的成员Item
    self._manageItem = nil--打开的操作面板
    local function memberListViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            --如果是邀请迁城，不需要展开玩家管理面板
            if self._inviteCallback ~= nil then
                return
            end
            
            --如果是申请列表页面，不需要展开玩家管理面板
            if self._isApply == true then
                return
            end
            
            local item = sender:getItem(sender:getCurSelectedIndex())
            if self._manageItem == item then --管理面板点击时不需要做操作
                print("manage panle touched")
                return
            end
            
            print("touched:",sender:getCurSelectedIndex())

            if self._openedItem == item then --关闭已经打开的面板
               sender:removeItem(sender:getCurSelectedIndex() + 1)
               self._openedItem = nil
               self._manageItem = nil
               return
            elseif self._openedItem ~= nil then --移除上一个玩家管理面板
               sender:removeItem(self._openedItem.idx)
               self._openedItem = nil
               self._manageItem = nil
            end
            
            item.idx = sender:getCurSelectedIndex() + 1
            self._openedItem = item
            
            local panle = self:createManageItem(self._openedItem.memberInfo,item.idx) --创建新的玩家管理面板
            self._memberListView:insertCustomItem(panle,item.idx)
            self._manageItem = panle
        end
    end
    self._memberListView:addEventListener(memberListViewEvent)
    
end

function AlliancePlayerManageLayer:changePage(idx,forceRefresh)
    if self._changePageIdx == idx and not forceRefresh then
        return 
    end
    self._changePageIdx = idx
    self._openedItem = nil
    self._manageItem = nil
    self:cleanMemberListView()
    self:stopActionByTag(actionTag)
    
    if self._needReload == true then
        g_AllianceMode.reqGuildPlayers()
        self._needReload = false
    end
    
    self._allMembers = g_AllianceMode.getGuildPlayers()
    
    if self._lastMenu then
        self._lastMenu:getChildByName("pic_selected"):setVisible(true)
    end
    
    self._lastMenu = self._leftListView:getItem(idx - 1)
    if self._lastMenu then
      self._lastMenu:getChildByName("pic_selected"):setVisible(false)
    end
    
    local renderListHandler = function(targetRank,members)
    
        local managerSortFunc = function(a,b)
            if a.Player.is_host == b.Player.is_host then
                if a.Player.is_online == b.Player.is_online then
                    return a.Player.power > b.Player.power
                end
                return a.Player.is_online > b.Player.is_online
            end
            return a.Player.is_host > b.Player.is_host
        end
        
        local normalSortFunc = function(a,b)
            if a.Player.is_host == b.Player.is_host then
                return a.Player.power > b.Player.power
            end
            return a.Player.is_host > b.Player.is_host
        end
        
        if g_AllianceMode.isAllianceManager() then
            table.sort(members,managerSortFunc)
        else
            table.sort(members,normalSortFunc)
        end
        
        local isApply = targetRank <= 0
        self._isApply = isApply
        
        local createItem = function(i)
              local item = cc.CSLoader:createNode("alliance_manage_members_list1.csb")
              item.idx = i
              item.memberInfo = members[i]
              if isApply then
                  local base = item:getChildByName("member_item")
                  
                  base:getChildByName("btn_agree").idx = i
                  base:getChildByName("btn_agree").memberInfo = members[i]
                  base:getChildByName("btn_agree").item = item
                  base:getChildByName("btn_agree"):addTouchEventListener(function(sender,eventType)
                      if eventType == ccui.TouchEventType.ended then
                          g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                          local memberInfo = sender.memberInfo
                          local resultHandler = function(result, msgData)
        --                    if result then
        --                        print("agreeed")
        --                        self._memberListView:removeItem(sender.idx - 1)
        --                    end
                              --self._memberListView:removeItem(sender.idx - 1)
                              self:updateTipCnt(self._requestMemberCnt - 1)
                              sender.item:removeFromParent()
                              self._needReload = true
                          end
                          g_sgHttp.postData("guild/agree",{apply_player_id = memberInfo.player_id},resultHandler)
                      end
                  end)
                  
                  base:getChildByName("btn_refuse").idx = i
                  base:getChildByName("btn_refuse").memberInfo = members[i]
                  base:getChildByName("btn_refuse").item = item
                  base:getChildByName("btn_refuse"):addTouchEventListener(function(sender,eventType)
                      if eventType == ccui.TouchEventType.ended then
                          g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                          local resultHandler = function(result, msgData)
                            if result then
                                print("refused")
        --                        if self._allianceMineLayer then
        --                            self._allianceMineLayer:updateMemberTips()
        --                        end
        
                                self:updateTipCnt(self._requestMemberCnt - 1)
                                sender.item:removeFromParent()
                            end
                          end
                          local memberInfo = sender.memberInfo
                          g_sgHttp.postData("guild/refuse",{apply_player_id = memberInfo.player_id},resultHandler)
                      end
                  end)
              end
              self:updateMemberItem(item,members[i],isApply)
              self._memberListView:pushBackCustomItem(item)
        end
        
        local startIdx = 5
        local idx = 1
        for key = 1, #members do
            if key > startIdx then
                break
            else
                createItem(idx)
                idx = idx + 1
            end
        end
        
        local callback = function()
            createItem(idx)
            idx = idx + 1
            if idx > #members then
                self:stopActionByTag(actionTag)
            end
        end
        
        if #members > startIdx then
            local sequence = cc.Sequence:create(cc.DelayTime:create(0.001), cc.CallFunc:create(callback))
            local action = cc.RepeatForever:create(sequence)
            action:setTag(actionTag)
            self:runAction(action)
        end
        
    
        --[[local items = self._memberListView:getItems()
        for i = 1, #items do
          local item = self._memberListView:getItem(i - 1)
          item.idx = i
          item.memberInfo = members[i]
          if isApply then
              local base = item:getChildByName("member_item")
              
              base:getChildByName("btn_agree").idx = i
              base:getChildByName("btn_agree").memberInfo = members[i]
              base:getChildByName("btn_agree").item = item
              base:getChildByName("btn_agree"):addTouchEventListener(function(sender,eventType)
                  if eventType == ccui.TouchEventType.ended then
                      g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                      local memberInfo = sender.memberInfo
                      local resultHandler = function(result, msgData)
    --                    if result then
    --                        print("agreeed")
    --                        self._memberListView:removeItem(sender.idx - 1)
    --                    end
                          --self._memberListView:removeItem(sender.idx - 1)
                          self:updateTipCnt(self._requestMemberCnt - 1)
                          sender.item:removeFromParent()
                      end
                      g_sgHttp.postData("guild/agree",{apply_player_id = memberInfo.player_id},resultHandler)
                  end
              end)
              
              base:getChildByName("btn_refuse").idx = i
              base:getChildByName("btn_refuse").memberInfo = members[i]
              base:getChildByName("btn_refuse").item = item
              base:getChildByName("btn_refuse"):addTouchEventListener(function(sender,eventType)
                  if eventType == ccui.TouchEventType.ended then
                      g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                      local resultHandler = function(result, msgData)
                        if result then
                            print("refused")
    --                        if self._allianceMineLayer then
    --                            self._allianceMineLayer:updateMemberTips()
    --                        end
    
                            self:updateTipCnt(self._requestMemberCnt - 1)
                            sender.item:removeFromParent()
                        end
                      end
                      local memberInfo = sender.memberInfo
                      g_sgHttp.postData("guild/refuse",{apply_player_id = memberInfo.player_id},resultHandler)
                  end
              end)
          end
          self:updateMemberItem(item,members[i],isApply)
        end]]
    
    end
    
    
    
    --dump(self._allMembers)
    --print("#self._menusTexts - idx:",#self._menusTexts - idx)
    local targetRank = 5 - (idx -1)
    local members = {}
    
    
    local currentTime = g_clock.getCurServerTime()
    local myInfo = g_AllianceMode.getSelfGuildPlayerInfo()
    
    print("targetRank~~~~~~~~~~~~~~~~~",targetRank)
    if targetRank > 0 then
        for key, member in pairs(self._allMembers) do
            if member.rank == targetRank then
                member.Player.is_online = 0
                if require("game.gametools.online").operateIsOnline(currentTime, member.Player.last_online_time) then
                    member.Player.is_online = 1
                end
                
                member.Player.is_host = 0
                if myInfo.player_id == member.player_id then
                    member.Player.is_host = 1
                end
                
                table.insert(members,member)
                --self._memberListView:pushBackDefaultItem()
            end
        end
        
        renderListHandler(targetRank,members)

    else
--        local applyMembers = {}
--        local resultHandler = function(result, msgData)
--          g_busyTip.hide_1()
--          if result then
--            print("guild/viewAllRequestMember success")
--            local requestMembers = msgData.PlayerGuildRequest
--            for key, member in pairs(requestMembers) do
--                member.Player.is_online = 0
--                if require("game.gametools.online").operateIsOnline(currentTime, member.Player.last_online_time) then
--                    member.Player.is_online = 1
--                end
--                table.insert(members,member)
--
--                --self._memberListView:pushBackDefaultItem()
--            end
--            self:updateTipCnt(#members)
--            renderListHandler(targetRank,members)
--          end
--        end
--        g_busyTip.show_1()
--        g_sgHttp.postData("guild/viewAllRequestMember",{guild_id = g_AllianceMode.getBaseData().id},resultHandler,true)

        local resultHandler = function(result, msgData)
            g_busyTip.hide_1()
            local requestMembers = g_AllianceMode.getApplyedMembers()
            for key, member in pairs(requestMembers) do
                member.Player.is_online = 0
                if require("game.gametools.online").operateIsOnline(currentTime, member.Player.last_online_time) then
                    member.Player.is_online = 1
                end
                table.insert(members,member)
            end
            self:updateTipCnt(#members)
            renderListHandler(targetRank,members)
        end
        
        g_busyTip.show_1()
        g_AllianceMode.reqApplyedMembersAsync(resultHandler)

    end

end

function AlliancePlayerManageLayer:updateTipCnt(cnt)
    if not g_AllianceMode.isAllianceManager() then
        return
    end

    self._requestMemberCnt = cnt
    
    if self._requestMemberCnt <= 0 then
        self._requestMemberCnt = 0
        g_AllianceMode.clearAllApplyedMembers()
    end
    
    if self._requestLeftMenu then
        self._requestLeftMenu:getChildByName("Image_8"):setVisible(false)
        if cnt > 0 then
            self._requestLeftMenu:getChildByName("Image_8"):setVisible(true)
            self._requestLeftMenu:getChildByName("Image_8"):getChildByName("text_0"):setString(cnt.."")
        end
    end

    if self._allianceMineLayer then
        self._allianceMineLayer:updateMemberTips(cnt)
    end
end

function AlliancePlayerManageLayer:setAllianceMineLayer(layer)
    self._allianceMineLayer = layer
end

function AlliancePlayerManageLayer:getAllianceMineLayer()
    return self._allianceMineLayer
end

function AlliancePlayerManageLayer:updateMemberItem(item,data,isApply)
    local base = item:getChildByName("member_item")
    local iconId = g_data.res_head[data.Player.avatar_id].head_icon
    base:getChildByName("pic_0"):loadTexture(g_resManager.getResPath(iconId))
    base:getChildByName("pic"):loadTexture(g_resManager.getResPath(1010007)) --boader
    base:getChildByName("label_lv"):setString("Lv."..data.Player.level)
    base:getChildByName("label_name"):setString(g_tr("playerName",{name = data.Player.nick}).." "..g_tr("allianceMemberFuyaLevel",{level = data.Player.fuya_build_level}))
    base:getChildByName("label_num"):setString(g_tr("prePlayerPower"))
    base:getChildByName("label_num_0"):setString(string.formatnumberthousands(data.Player.power))
    
    
    local color = g_Consts.ColorType.Normal
    local stateStr = g_tr("offline")
    
    if not g_AllianceMode.isAllianceManager() then
        stateStr = ""
    else
        if data.Player.is_online > 0 then
            stateStr = g_tr("online")
            color = g_Consts.ColorType.Green
        else

           local nowTime = g_clock.getCurServerTime()
           local lastTime = data.Player.last_online_time
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
           stateStr = g_tr("lastOnlineTime")..timeShowStr
        end
        
        if self._inviteCallback and self._bigTileIndexPos then --邀请迁城
            color = g_Consts.ColorType.Normal
            
            if self._bigTileIndexPos == "sendreward" then --发放奖励
                 stateStr = ""
            else
                 local distanceVec = cc.p( data.Player.x - self._bigTileIndexPos.x , data.Player.y - self._bigTileIndexPos.y )
                 local distance = math.floor( math.sqrt( distanceVec.x * distanceVec.x + distanceVec.y * distanceVec.y ) )
                 stateStr = g_tr("allianceInviteDistance")..distance..g_tr("worldmap_KM") 
            end
            
           
        end
    end
    
    base:getChildByName("label_state"):setTextColor(color)
    base:getChildByName("label_state"):setString(stateStr)
    
    base:getChildByName("btn_agree"):setVisible(isApply)
    base:getChildByName("btn_refuse"):setVisible(isApply)
    
    base:getChildByName("btn_agree"):getChildByName("Text"):setString(g_tr("agree"))
    base:getChildByName("btn_refuse"):getChildByName("Text"):setString(g_tr("refuse"))
    
    if self._inviteCallback then
        base:getChildByName("btn_refuse"):setVisible(true)
        if self._bigTileIndexPos == "sendreward" then
            base:getChildByName("btn_refuse"):getChildByName("Text"):setString(g_tr("guildGiftRewardBtn1"))
        else
            base:getChildByName("btn_refuse"):getChildByName("Text"):setString(g_tr("allianceInviteMoveBuild"))
            base:getChildByName("btn_refuse"):setEnabled(data.player_id ~= g_PlayerMode.GetData().id)
        end
        base:getChildByName("btn_refuse").memberInfo = data
        base:getChildByName("btn_refuse"):addTouchEventListener(function(sender,eventType)
              if eventType == ccui.TouchEventType.ended then
                  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                  local memberInfo = sender.memberInfo
                  
                  --如果是邀请迁城
                  if self._inviteCallback then
                      
                      local tipStr = g_tr("allianceMakeSureInviteMoveBuild")
                      if self._bigTileIndexPos == "sendreward" then
                          tipStr = g_tr("guildGiftRewardTip")
                      end
                  
                      g_msgBox.show(tipStr,nil,nil,function(event)
                          if event == 0 then
                              print("make sure")
                              self._inviteCallback(memberInfo)
                              self:removeFromParent()
                          end
                      end,1)
--                  else       
--                      local resultHandler = function(result, msgData)
--                        if result then
--                            print("refused")
--                            self._memberListView:removeItem(sender.idx - 1)
--                        end
--                      end
--                      g_sgHttp.postData("guild/refuse",{apply_player_id = memberInfo.player_id},resultHandler)
                  end
     
              end
          end)
    end
    
end

function AlliancePlayerManageLayer:doChangePlayerRank(playerInfo,targeRank)
    local ret = false

    local resultHandler = function(result, msgData)
      if result then
          print("change player rank success")
          ret = true
          self._needReload = true
      end
    end
    g_sgHttp.postData("guild/changePlayerRank",{targetPlayerId = playerInfo.player_id,targetRank = targeRank},resultHandler)
    
    return ret
end 

function AlliancePlayerManageLayer:doUpPlayerRank(playerInfo)
    if playerInfo.rank >= maxPlayerRank then
        g_airBox.show(g_tr("theHighest"))
        return false
    end

    local targetRank = playerInfo.rank + 1
    if targetRank <= maxPlayerRank then
       return self:doChangePlayerRank(playerInfo,targetRank)
    end
    
    return false
    
end

function AlliancePlayerManageLayer:doDownPlayerRank(playerInfo)
    if playerInfo.rank <= minPlayerRank then
        g_airBox.show(g_tr("theLowest"))
        return false
    end

    local targetRank = playerInfo.rank - 1
    if targetRank >= minPlayerRank then
       return self:doChangePlayerRank(playerInfo,targetRank)
    end
    
    return false
end

function AlliancePlayerManageLayer:updateView()
    self:changePage(self._changePageIdx,self._needReload)
end


return AlliancePlayerManageLayer