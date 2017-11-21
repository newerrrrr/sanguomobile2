local AllianceMineLayer = class("AllianceMineLayer", require("game.uilayer.base.BaseLayer"))

local baseNode = nil
local haveShowManager = false
function AllianceMineLayer:ctor()
    local uiLayer = cc.CSLoader:createNode("alliance_content_myAlliance.csb")
    self:addChild(uiLayer)
    baseNode = uiLayer:getChildByName("content")
    self:setContentSize(baseNode:getContentSize())
   
    --reset ui text
    baseNode:getChildByName("bg_info"):getChildByName("lable_1"):getChildByName("Text")
    :setString(g_tr("allianceName")) --联盟名称
    
    baseNode:getChildByName("bg_info"):getChildByName("lable_2"):getChildByName("Text")
    :setString(g_tr("allianceHost")) --盟主
    
    baseNode:getChildByName("bg_info"):getChildByName("lable_4"):getChildByName("Text")
    :setString(g_tr("alliancePower")) --联盟战力
    
    baseNode:getChildByName("bg_info"):getChildByName("lable_3"):getChildByName("Text")
    :setString(g_tr("allianceMembersMax")) --人员数量
    
    baseNode:getChildByName("Text_41"):setString(g_tr("allianceNotice")) --联盟公告
    
    baseNode:getChildByName("Button_xiugai"):setVisible(g_AllianceMode.isAllianceManager())
    
    baseNode:getChildByName("Image_3"):setVisible(false)
    
    baseNode:getChildByName("Button_xiugai"):getChildByName("Text_31"):setString(g_tr("modification"))
    baseNode:getChildByName("Button_xiugai"):addClickEventListener(function(sender)
        local managerLayer = require("game.uilayer.alliance.AllianceManageLayer"):create()
        g_sceneManager.addNodeForUI(managerLayer)
        managerLayer:gotoLogicIdx(2) --2指的是修改公告
    end)
    
    self._managerButtons = {}
    
    --发放奖励
    local btnSendReward = baseNode:getChildByName("Button_rc_0"):clone()
    btnSendReward:getChildByName("Text_1"):setString(g_tr("guildGiftRewardBtn1"))
    btnSendReward:addClickEventListener(function()
        if g_AllianceMode.isAllianceLeader() then --盟主
            require("game.uilayer.alliance.AllianceMissionRewardLayer").show(btnSendReward)
        end
    end)
    btnSendReward:setVisible(false)
    baseNode:getChildByName("Button_rc_0"):getParent():addChild(btnSendReward)
    
    
    --日常管理
    local btnMemberManager = baseNode:getChildByName("Button_rc_0")
    self._btnMemberManagerX = btnMemberManager:getPositionX()
    btnMemberManager:getChildByName("Text_1"):setString(g_tr("guildMemberFireBtnText"))
    btnMemberManager:addClickEventListener(function()
        if g_AllianceMode.isAllianceLeader() then --盟主
            local layer =  require("game.uilayer.alliance.AllianceMemberCleanup"):create()
            g_sceneManager.addNodeForUI(layer)
        else --副盟主
            self:changeLeader()
        end
    end)
    btnMemberManager:setVisible(false)

    
    --联盟领地按钮
    g_guideManager.registComponent(9999503,baseNode:getChildByName("Button_place_2"))
    
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          g_AllianceMode.addUpdateView(self)
          self:setVisible(false)
          g_busyTip.show_1()
          g_AllianceMode.reqAllAllianceDataAsync(function(result, msgData)
                g_busyTip.hide_1()
                if result then
                    self:setVisible(true)
                    self:updateView()

                    --聯盟領地提示
                    if g_AllianceMode.isAllianceManager() then
                       
                       --是否已经放置过联盟堡垒
                       local haveFortress = false
                    
                       local canCreateList = g_allianceManorData.GetCanCreateData()
                       local canCreateBuildList = {}
                       for key, var in pairs(canCreateList) do
                            if var.map_element_id == 101 and var.current > 0 then
                                haveFortress = true
                            end
                            
                            if var.map_element_id == 101 or var.map_element_id == 0 then--仅提示堡垒和矿场
                                if var.current < var.max then
                                    table.insert(canCreateBuildList,var)
                                end
                            end
                       end
                       
                       if #canCreateBuildList > 0 then
                           
                           table.sort(canCreateBuildList,function(a,b)
                              return a.map_element_id < b.map_element_id
                           end)
                       
                           baseNode:getChildByName("Image_3"):setVisible(true)
                           local strName = ""
                           do
                               for key, var in ipairs(canCreateBuildList) do
                                  if var.map_element_id == 101 then
                                     strName = g_tr("allianceFortress")
                                     if not haveFortress then
                                        break
                                     end
                                  elseif var.map_element_id == 201 then
                                     strName = g_tr("allianceTower")
                                  elseif var.map_element_id == 0 then
                                     strName = g_tr("allianceRecourse")
                                  elseif var.map_element_id == 801 then
                                     strName = g_tr("allianceWarehouse")
                                  end
                               end
                           end
                           
                           local str = g_tr("guildBuildCanCreateTip",{build_name = strName})
                           baseNode:getChildByName("Image_3"):getChildByName("Text_3"):setString(str)
                           
                           local seq = cc.Sequence:create(cc.DelayTime:create(6.18),cc.CallFunc:create(function()
                               baseNode:getChildByName("Image_3"):setVisible(false)
                           end))
                           baseNode:getChildByName("Image_3"):runAction(seq)
                       end
                       
                    end
                    
                    
                    local currentTime = g_clock.getCurServerTime()
                    --联盟盟主管理
                    if g_AllianceMode.isAllianceLeader() then --盟主
                        local offsetSec =  60*60*48 --48小时
                        local allMembers = g_AllianceMode.getGuildPlayers()
                        local list = {}
                        for key, member in pairs(allMembers) do
                          if currentTime - member.Player.last_online_time > offsetSec then
                              if member.rank < 5 then
                                  table.insert(list,member)
                              end
                          end
                        end
                        btnMemberManager:setVisible(#list > 0)
                        
                        if not haveShowManager and #list > 0 then
                            haveShowManager = true
                            local layer =  require("game.uilayer.alliance.AllianceMemberCleanup"):create()
                            g_sceneManager.addNodeForUI(layer)
                            
                        end
                        
--                        if not g_AllianceMode.haveShowRewardSend then
--                            require("game.uilayer.alliance.AllianceMissionRewardLayer").show(btnSendReward,handler(self,self.updateButtonPos))
--                        else
--                            btnSendReward:setVisible(g_AllianceMode.rewardCnt > 0)
--                        end
                        
                        require("game.uilayer.alliance.AllianceMissionRewardLayer").show(btnSendReward,handler(self,self.updateButtonPos))
                        
                    elseif g_AllianceMode.isAllianceManager() then--副盟主
                        local offsetSec =  60*60*72 --72小时
                        local member = g_AllianceMode.getLeaderInfo()
                        local leaderOfflineLong = currentTime - member.Player.last_online_time > offsetSec
                        btnMemberManager:setVisible(leaderOfflineLong)
                        if leaderOfflineLong then
                            btnMemberManager:setPositionX(btnMemberManager:getPositionX() + 140)
                        end
                        if not haveShowManager and leaderOfflineLong then
                            haveShowManager = true
                            self:changeLeader()
                        end
                    end
                    
                    self:updateButtonPos()
                else
                    g_guideManager.removeGameFeature(g_guideManager.gameFeatures.ALLIANCE)
                end
          end)
    
      elseif eventType == "exit" then
          g_AllianceMode.removeUpdateView(self)
          baseNode = nil
      end 
    end )
    
    local labelsKey = 
    {
        g_tr("allianceBattle"),
        g_tr("allianceField"),
        g_tr("allianceTech"),
        g_tr("allianceShop"),
        g_tr("allianceHelp"),
        g_tr("allianceTask"),
        g_tr("allianceBattleReport"),
        g_tr("allianceComment")
    }
    
    
    local function btnHandler(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if sender.idx == 1 then
                baseNode:getChildByName("Button_place_hongdian"):setVisible(false)
                g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleHallView").new())
            elseif sender.idx == 2 then
                baseNode:getChildByName("Image_3"):stopAllActions()
                baseNode:getChildByName("Image_3"):setVisible(false)
                g_sceneManager.addNodeForUI(require("game.uilayer.alliance.manor.AllianceManorLayer"):create())
            elseif sender.idx == 3 then
                local needLv = tonumber(g_data.starting[82].data)
                local playerLevel = g_PlayerMode.GetData().level
                if playerLevel >= needLv then
                    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.tech.AllianceTechMainLayer"):create())
                else
                    g_airBox.show(g_tr("allianceTechCondition",{lv = needLv}))
                end
                
            elseif sender.idx == 4 then
                g_sceneManager.addNodeForUI(require("game.uilayer.shop.ShopLayer"):create(g_Consts.ShopType.ALLIANCE_PLAYER))
            elseif sender.idx == 5 then
                g_sceneManager.addNodeForUI(require("game.uilayer.tun.TunView").new())
            elseif sender.idx == 6 then
                local curTime = g_clock.getCurServerTime()
                local allianceTaskActivityId = 1003
                local data = require("game.uilayer.activity.ActivityMainLayer").getServerOpenInfoByActivityId(allianceTaskActivityId)
                if data and curTime >= data.start_time and curTime < data.end_time then 
                    require("game.uilayer.activity.ActivityMainLayer").show(allianceTaskActivityId)
                else
                    g_airBox.show(g_tr("allianceTaskClosed"))
                end 
            elseif sender.idx == 7 then --历史战报
                local function getData(data)
                    g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleRecordView").new(data))
                end

                require("game.uilayer.battleHall.BattleHallMode"):getBattleLog(getData)
                
            elseif sender.idx == 8 then --留言板
                g_sceneManager.addNodeForUI(require("game.uilayer.alliance.chat.AllianceCommentLayer"):create())
            end
        end
    end
    
    for i = 1, #labelsKey do
        local btn = baseNode:getChildByName("Button_place_"..i)
        if btn then
            btn.idx = i
            --btn:setTitleText(labelsKey[i])
            baseNode:getChildByName("Text_Button"..i):setString(labelsKey[i])
            btn:addTouchEventListener(btnHandler)
        end
    end
    
    local btnMail = baseNode:getChildByName("btn_mail")
    btnMail:getChildByName("Text"):setString(g_tr("allianceMail")) --群体邮件
    btnMail:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
             g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
             local pop = require("game.uilayer.mail.MailContentWritePop").new(true)
             g_sceneManager.addNodeForUI(pop)
        end
    end)
    
    local btnInvite = baseNode:getChildByName("btn_invite")
    btnInvite:getChildByName("Text"):setString(g_tr("allianceInvite")) --邀请好友
    btnInvite:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            g_sceneManager.addNodeForUI(require("game.uilayer.alliance.invite.AllianceInviteLayer"):create())
        end
    end)
        
    local haveApplyPlayers,count = g_AllianceMode.isHaveApplyedMembers()
    local btnMember = baseNode:getChildByName("btn_member")
    btnMember:getChildByName("Text"):setString(g_tr("allianceMembers")) --成员列表
--    btnMember:getChildByName("Image_8"):setVisible(haveApplyPlayers)
--    btnMember:getChildByName("Image_8"):getChildByName("text_0"):setString(count.."")
    self:updateMemberTips(count)
    btnMember:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local playerManagerLayer = require("game.uilayer.alliance.AlliancePlayerManageLayer"):create()
            playerManagerLayer:setAllianceMineLayer(self)
            g_sceneManager.addNodeForUI(playerManagerLayer)
        end
    end)
    
    local btnManage = baseNode:getChildByName("btn_manage")
    btnManage:getChildByName("Text"):setString(g_tr("allianceManage")) --联盟管理
    btnManage:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            g_sceneManager.addNodeForUI(require("game.uilayer.alliance.AllianceManageLayer"):create())
        end
    end)
    
    --邀请入盟
    local btnInvite = baseNode:getChildByName("Button_rm")
    btnInvite:addTouchEventListener(handler(self, self.onInviteToJoin))
    self:updateInviteBtn()
    
    
    --更新按钮位置
    table.insert(self._managerButtons,btnInvite)
    table.insert(self._managerButtons,btnMemberManager)
    table.insert(self._managerButtons,btnSendReward)
    
    self:updateButtonPos()
end

 --更新按钮位置
function AllianceMineLayer:updateButtonPos()
    local startX = self._btnMemberManagerX + 140
    local idx = 0
    for key, btn in ipairs(self._managerButtons) do
        if btn:isVisible() then
            btn:setPositionX(startX - (btn:getContentSize().width + 10) * idx)
            idx = idx + 1
        end
    end
end

--弹劾盟主
function AllianceMineLayer:changeLeader()
    local member = g_AllianceMode.getLeaderInfo()
    g_msgBox.show(g_tr("guildMemberChangeLeader",{name = member.Player.nick}),nil,nil,function(event)
          if event == 0 then
             local function onResult(result, data)
                g_busyTip.hide_1()
                if result == true then
                    g_busyTip.show_1()
                    g_AllianceMode.reqAllAllianceDataAsync(function(result, msgData)
                        g_busyTip.hide_1()
                        if result then
                            self:updateView()
                        end
                        g_airBox.show(g_tr("guildMemberChangeLeaderSuccess"))
                    end)
                   
                end
             end
             g_busyTip.show_1()
             g_sgHttp.postData("guild/replaceGuildLeader",{}, onResult,true)
          end
    end,1)
end

function AllianceMineLayer:updateMemberTips(count)
    local btnMember = baseNode:getChildByName("btn_member")
    btnMember:getChildByName("Image_8"):setVisible(count > 0)
    btnMember:getChildByName("Image_8"):getChildByName("text_0"):setString(count.."")
end

function AllianceMineLayer:updateView()
--    local data = g_AllianceMode.getBaseData()
--    if data == nil or data.id == nil then
--        g_AllianceMode.getMainView():reload()
--        return
--    end
    if not g_AllianceMode.getSelfHaveAlliance() then
        g_AllianceMode.getMainView():reload()
        return
    end
    
    
    g_guideManager.execute()
    
    local data = g_AllianceMode.getBaseData()
    
    baseNode:getChildByName("Button_place_hongdian"):setVisible(g_battleHallData.showTip())
    baseNode:getChildByName("Button_place_8"):getChildByName("Button_place_hongdian_0"):setVisible(g_allianceCommentData.haveNew())
    
    dump(data)
    local currentIcon = g_AllianceMode.getAllianceIconId()
    local iconInfo = g_data.alliance_flag[currentIcon]
    
    baseNode:getChildByName("pic"):loadTexture(g_resManager.getResPath(iconInfo.res_flag))
    
    baseNode:getChildByName("bg_info"):getChildByName("text_1")
    :setString(data.name)
    
    baseNode:getChildByName("bg_info"):getChildByName("text_2")
    :setString(data.leader_player_nick)
    
    baseNode:getChildByName("bg_info"):getChildByName("text_3")
    :setString(data.num.."")
    
    baseNode:getChildByName("bg_info"):getChildByName("text_3_1")
    :setString("/"..data.max_num)
    
    baseNode:getChildByName("bg_info"):getChildByName("text_4")
    :setString(string.formatnumberthousands(data.guild_power))
    
--    baseNode:getChildByName("bg_notice"):getChildByName("Text")
--    :setString("")
    
    baseNode:getChildByName("bg_notice"):getChildByName("ScrollView_1"):getChildByName("TextField_1")
    :setString(data.notice.."")
    
    baseNode:getChildByName("bg_notice"):getChildByName("ScrollView_1"):getChildByName("TextField_1"):setTouchEnabled(false)
    
    baseNode:getChildByName("bg_notice"):getChildByName("ScrollView_1"):setTouchEnabled(false)
    
    baseNode:getChildByName("bg_info"):getChildByName("LoadingBar_1")
    :setPercent(data.num/data.max_num*100)
    
    self:updateInviteBtn() 
   
       --日常管理按钮坐标
    local btnMemberManager = baseNode:getChildByName("Button_rc_0")
    if g_AllianceMode.isAllianceLeader() then --盟主
        btnMemberManager:setPositionX(self._btnMemberManagerX)
    end
    
    self:updateButtonPos()
end


function AllianceMineLayer:onInviteToJoin() 
    if nil == baseNode then return end 

    local data = g_AllianceMode.getBaseData() 
    if nil == data then return end 

    local function onResult(result, data)
        if result then 
            -- self:updateInviteBtn() 
            g_airBox.show(g_tr("allianceInviteSuccess"))
            self:performWithDelay(handler(self, self.updateInviteBtn), 0)
        end 
    end 

    if g_AllianceMode.isAllianceLeader() then 
        if data.num >= data.max_num then --满员时
            g_airBox.show(g_tr("allianceIsFull"))

        elseif g_clock.getCurServerTime() >= data.invite_end_time then 
            g_sgHttp.postData("guild/inviteRandPlayers",{}, onResult) 
        end 
    end 
end 

--更新邀请按钮状态
function AllianceMineLayer:updateInviteBtn()
    if nil == baseNode then return end 

    local btnInvite = baseNode:getChildByName("Button_rm")

    local function showLeftTime(label, targetTime)
        local function updateTime()
            local dt = targetTime - g_clock.getCurServerTime()
            if dt <= 0 then      
                dt = 0 
                self:unschedule(self.timer)
                self.timer = nil 
                --btnInvite:setEnabled(true)
                btnInvite:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.originMode ) )    
                label:setString(g_tr("allianceInviteToJoin"))
                g_itemTips.clearTip(btnInvite)
            else 
                label:setString(g_gameTools.convertSecondToString(dt))
            end 
            
        end 

        if self.timer then 
            self:unschedule(self.timer)
            self.timer = nil 
        end 
        label:setString("")
        local leftTime = targetTime - g_clock.getCurServerTime() 
        if leftTime > 0 then 
            btnInvite:getVirtualRenderer():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(g_shaders.shaderMode.shader_gray))
            label:setString(g_gameTools.convertSecondToString(leftTime)) 
            self.timer = self:schedule(updateTime, 1.0) 
            g_itemTips.tipStr(btnInvite,g_tr("allianceInviteToJoin"),g_tr("allianceInviteDesc"))
        end
    end 

    btnInvite:setVisible(false)  
    if g_AllianceMode.getSelfHaveAlliance() then --有联盟时
        require("game.uilayer.mainSurface.mainSurfaceAllianceInvite").clearAllInvites() 
        if g_AllianceMode.isAllianceLeader() then --自己是盟主时
            local data = g_AllianceMode.getBaseData()
            if data and data.invite_end_time then 
                btnInvite:setVisible(true)
                local label = btnInvite:getChildByName("Text_1")
                if g_clock.getCurServerTime() >= data.invite_end_time then 
                    label:setString(g_tr("allianceInviteToJoin"))
                else 
                    showLeftTime(label, data.invite_end_time) 
                end 
            end  
        end 
    end 
end 


return AllianceMineLayer