local FightResult = class("FightResult",function()
    return cc.Layer:create()
end)

function FightResult.show(fightData)

    --0: 平 1：A胜 2：B胜
    
--    fightData = {
--        ["result"] = {
--            ["1"] = 1,
--            ["2"] = 1,
--            ["3"] = 1,
--            ["backplay"] = "sdfasdfasdfasdf"
--        },
--        ["info"] = {}
--    }
    
    --0负 1胜 2平
    local A_general_1_is_win = 0
    local B_general_1_is_win = 0
    
    local A_general_2_is_win = 0
    local B_general_2_is_win = 0
    
    local A_general_3_is_win = 0
    local B_general_3_is_win = 0
    
    local A_winTims = 0
    local B_winTimes = 0
    for key, var in pairs(fightData.result) do
    	if key == "1" or  key == "2" or  key == "3" then
    	   if var == 1 then
    	       A_winTims = A_winTims + 1
    	       if key == "1" then
        	       A_general_1_is_win = 1
                 B_general_1_is_win = 0
             elseif key == "2" then
                 A_general_2_is_win = 1
                 B_general_2_is_win = 0
             elseif key == "3" then
                 A_general_3_is_win = 1
                 B_general_3_is_win = 0
             end
    	   elseif var == 2 then
    	       B_winTimes = B_winTimes + 1
    	       
    	       if key == "1" then
                 A_general_1_is_win = 0
                 B_general_1_is_win = 1
             elseif key == "2" then
                 A_general_2_is_win = 0
                 B_general_2_is_win = 1
             elseif key == "3" then
                 A_general_3_is_win = 0
                 B_general_3_is_win = 1
             end
    	   elseif var == 0 then
             if key == "1" then
                 A_general_1_is_win = 2
                 B_general_1_is_win = 2
             elseif key == "2" then
                 A_general_2_is_win = 2
                 B_general_2_is_win = 2
             elseif key == "3" then
                 A_general_3_is_win = 2
                 B_general_3_is_win = 2
             end
    	   end
    	end
    end
    
    require("game.uilayer.fightperipheral.FightRankLevelUpEffect").playFightResultScore(A_winTims,B_winTimes)
    require("game.uilayer.tournament.tournament").delete()
    
    --从战斗测试或者切磋进来 不需要结算
    if fightData.info.pk_id == -1 then
        return
    end
    
    local win_player_id = nil
    if A_winTims == B_winTimes then
        win_player_id = 0
    elseif A_winTims > B_winTimes then
        win_player_id = fightData.info.A.player_id
    elseif A_winTims < B_winTimes then
        win_player_id = fightData.info.B.player_id
    end
    
    assert(win_player_id ~= nil)
    
    local isSaving = false
    local sche = nil
    local scheduler = cc.Director:getInstance():getScheduler()
    
    local saveResult = function()
    
        if isSaving == true then
            return
        end
    
        local function onRecv(result, msgData)
            
            isSaving = false
            if result == true then 
                g_busyTip.hide_1()
                scheduler:unscheduleScriptEntry(sche) 
                
                local layer = FightResult:create(msgData,win_player_id)
                g_sceneManager.addNodeForUI(layer)
                
            end
        end
        
        isSaving = true
        g_sgHttp.postData("pk/pkResult",
                            {
                                pk_id = fightData.info.pk_id,
                                win_player_id = win_player_id,
                                pk_result = fightData.result.backplay,
                                self_general_result = {general_1_is_win = A_general_1_is_win,general_2_is_win = A_general_2_is_win,general_3_is_win = A_general_3_is_win} ,
                                target_general_result = {  general_1_is_win = B_general_1_is_win,general_2_is_win = B_general_2_is_win,general_3_is_win = B_general_3_is_win}
                            },
                            onRecv,true)
    end
    
    g_busyTip.show_1()
    --确保成功
    sche = scheduler:scheduleScriptFunc(saveResult, 0.25, false)
end

function FightResult:ctor(resultSeverData,win_player_id)
    

    local uiLayer =  g_gameTools.LoadCocosUI("ArenaRanking_fight_result.csb",5)
    self:addChild(uiLayer)
    --g_resourcesInterface.installResources(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    local closeBtn = self._baseNode:getChildByName("Button_gb")
    self._baseNode:getChildByName("Button_gb"):getChildByName("Text_1"):setString(g_tr("closed"))
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
              self:removeFromParent()
              if g_expeditionData:GetView() then
                  g_expeditionData:GetView():checkRankLevelUp()
              end
          end
    end)
    
    self._baseNode:getChildByName("Text_nr"):setString(g_tr("peripheral_result_title"))
    self._baseNode:getChildByName("Text_jf"):setString(g_tr("peripheral_result_score"))
    
    self._baseNode:getChildByName("Image_s1"):setVisible(false)
    self._baseNode:getChildByName("Image_s2"):setVisible(false)
    self._baseNode:getChildByName("Image_s3"):setVisible(false)
    
    if win_player_id == g_PlayerMode.GetData().id then
        self._baseNode:getChildByName("Image_s1"):setVisible(true)
    elseif win_player_id == 0 then
        self._baseNode:getChildByName("Image_s3"):setVisible(true)
    else
        self._baseNode:getChildByName("Image_s2"):setVisible(true)
    end

    local dropGroups = g_gameTools.getDropGroupByDropIdArray(resultSeverData.drop_id)
    for key, dropGroup in pairs(dropGroups) do
       local type = dropGroup[1]
       local configId = dropGroup[2]
       local cnt = dropGroup[3]

       local itemIcon = require("game.uilayer.common.DropItemView"):create(type,configId,cnt)
       itemIcon:enableTip()
       itemIcon:setAnchorPoint(cc.p(0.5,0.5))
       local listView = self._baseNode:getChildByName("ListView_1")
       local size = listView:getContentSize()
       local iconSize = itemIcon:getContentSize()
       listView:setItemsMargin(2)
       local scale = size.height/iconSize.height
       
       local targetSize = cc.size(iconSize.width*scale,iconSize.height*scale)
       local con = ccui.Widget:create()
       con:setContentSize(targetSize)
       itemIcon:setPosition(cc.p(targetSize.width/2,targetSize.height/2))
       itemIcon:setScale(scale)
       con:addChild(itemIcon)
       
       listView:pushBackCustomItem(con)
    end
    
    local score = resultSeverData.score
    local scoreStr = ""
    local label = self._baseNode:getChildByName("Text_jf_0")
    if score > 0 then
        label:setTextColor(g_Consts.ColorType.Green)
        scoreStr = "+"..score
    else
        label:setTextColor(g_Consts.ColorType.Red)
        scoreStr = score..""
    end
    label:setString(scoreStr)
end

return FightResult