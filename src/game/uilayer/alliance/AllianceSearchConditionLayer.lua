local AllianceSearchConditionLayer = class("AllianceSearchConditionLayer",function()
    return cc.Layer:create()
end)

function AllianceSearchConditionLayer:ctor()
  	local ui =  g_gameTools.LoadCocosUI("alliance_search_popup.csb",5)
    self:addChild(ui)
    local uiLayer = ui:getChildByName("scale_node"):getChildByName("content_popup")
--    local baseNode = ui:getChildByName("scale_node"):getChildByName("content_popup")
--    self._baseNode = baseNode
    local closeBtn = uiLayer:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
              self:removeFromParent(true)
          end
    end)
    
    uiLayer:getChildByName("bg_title"):getChildByName("Text"):setString(g_tr("searchTitle"))--搜索条件
    uiLayer:getChildByName("text_1"):setString(g_tr("allianceMembersMax"))--联盟人数
    uiLayer:getChildByName("text_2"):setString(g_tr("officialLevelRule"))--官府等级
    uiLayer:getChildByName("text_3"):setString(g_tr("alliancePowerRule"))--联盟战力   
    uiLayer:getChildByName("text_4"):setString(g_tr("needMakeSure"))--入盟确认
        
    --uiLayer:getChildByName("text_tips"):setString(g_tr("publicRecruitRule"))--公开招募规则

    self._checkBoxLeft = uiLayer:getChildByName("Panel_16"):getChildByName("CheckBox")
    self._checkBoxMiddle = uiLayer:getChildByName("Panel_16_0"):getChildByName("CheckBox")
    self._checkBoxRight = uiLayer:getChildByName("Panel_16_0_0"):getChildByName("CheckBox")
    self._checkBoxLeft:setTouchEnabled(false)
    self._checkBoxMiddle:setTouchEnabled(false)
    self._checkBoxRight:setTouchEnabled(false)
    
    local function getSelectedType()
        if self._checkBoxLeft:isSelected() == true then
            return 0
        elseif self._checkBoxMiddle:isSelected() == true then
            return 1
        elseif self._checkBoxRight:isSelected() == true then
            return -1
        end
    end
    
    local condition = g_AllianceMode.getSearchCondition()
    local function setSelectedByType(type)
        self._checkBoxLeft:setSelected(false)
        self._checkBoxMiddle:setSelected(false)
        self._checkBoxRight:setSelected(false)
        if type == 0 then
            self._checkBoxLeft:setSelected(true)
        elseif type == 1 then
            self._checkBoxMiddle:setSelected(true)
        elseif type == -1 then
            self._checkBoxRight:setSelected(true)
        end
        
        condition.need_check = type
    end

    uiLayer:getChildByName("Panel_16"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            setSelectedByType(0)
        end
    end)
    
    uiLayer:getChildByName("Panel_16_0"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            setSelectedByType(1)
        end
    end)
    
    uiLayer:getChildByName("Panel_16_0_0"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            setSelectedByType(-1)
        end
    end)
    --{"code":0,"data":{"id":9,"leader_player_id":100017,"name":"ssss","short_name":"","icon_id":1,"num":0,"max_num":50,"need_check":1,"guild_power":0,"desc":"ffff","condition_fuya_level":1,"condition_player_power":0,"coin":0,"create_time":1448092313,"update_time":1448092313},"basic":[]}
    
    
    setSelectedByType(condition.need_check)
    local condition_fuya_level = condition.condition_fuya_level
    local max_num = condition.max_num
    local condition_player_power = condition.condition_player_power
    local selectType = condition.need_check
    
    setSelectedByType(selectType)

    --fix me
    local maxselect_max_num = 100
    local step_max_num = 10
    
    local maxselect_condition_fuya_level = 50
    local step_condition_fuya_level = 10
    
    local maxselect_condition_player_power = 5000
    local step_condition_player_power = 500
    
--    if self._isSearch == true then
--       condition_fuya_level = step_condition_fuya_level
--       max_num = step_max_num
--       condition_player_power = step_condition_player_power
--       setSelectedByType(-1)
--    end
    
    local updateLabels = function()
        uiLayer:getChildByName("bg_option_1"):getChildByName("text"):setString(">="..max_num)
        uiLayer:getChildByName("bg_option_2"):getChildByName("text"):setString(">="..condition_fuya_level)
        uiLayer:getChildByName("bg_option_3"):getChildByName("text"):setString(">="..condition_player_power)
        
        condition.max_num = max_num
        condition.condition_fuya_level = condition_fuya_level
        condition.condition_player_power = condition_player_power
    end
    
    uiLayer:getChildByName("btn_left_1"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            max_num = max_num - step_max_num
            if max_num < 0 then
                max_num = maxselect_max_num
            end
            updateLabels()
        end
    end)
    
    uiLayer:getChildByName("btn_left_2"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
           condition_fuya_level = condition_fuya_level - step_condition_fuya_level
           if condition_fuya_level < 0 then
              condition_fuya_level = maxselect_condition_fuya_level
           end
           updateLabels()
        end
    end)
    
    uiLayer:getChildByName("btn_left_3"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
           condition_player_power = condition_player_power - step_condition_player_power
           if condition_player_power < 0 then
              condition_player_power = maxselect_condition_player_power
           end
           updateLabels()
        end
    end)
    
    uiLayer:getChildByName("btn_right_1"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            max_num = max_num + step_max_num
            if max_num > maxselect_max_num then
                max_num = 0
            end
            updateLabels()
        end
    end)
    
    uiLayer:getChildByName("btn_right_2"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
           condition_fuya_level = condition_fuya_level + step_condition_fuya_level
           if condition_fuya_level > maxselect_condition_fuya_level then
              condition_fuya_level = 0
           end
           updateLabels()
        end
    end)
    
    uiLayer:getChildByName("btn_right_3"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
           condition_player_power = condition_player_power + step_condition_player_power
           if condition_player_power > maxselect_condition_player_power then
              condition_player_power = 0
           end
           updateLabels()
        end
    end)
    
    updateLabels()
    self:updateView()
    
    local saveBtn = uiLayer:getChildByName("btn_save")
    saveBtn:getChildByName("Text"):setString(g_tr("save")) --保存
    saveBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
              print("save handler")
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              self:removeFromParent()
        end
    end)
    
end

function AllianceSearchConditionLayer:updateView()

end

return AllianceSearchConditionLayer