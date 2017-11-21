local GeneralInfoLayer = class("GeneralInfoLayer",function()
    return cc.Layer:create()
end)

--武将详情展示页面
function GeneralInfoLayer:ctor(generalConfigId)
    local uiLayer =  g_gameTools.LoadCocosUI("Pub_general_info.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    
    local closeBtn = baseNode:getChildByName("close_btn")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    local generalInfo = g_data.general[generalConfigId]
    assert(generalInfo)
    
    if generalInfo then
        --name
        baseNode:getChildByName("general"):getChildByName("bg_name"):getChildByName("name")
        :setString(g_tr(generalInfo.general_name))
        
        --背景
        baseNode:getChildByName("general"):getChildByName("pic_1"):loadTexture(g_resManager.getResPath(1005000 + generalInfo.general_quality))
        --半身像
        baseNode:getChildByName("general"):getChildByName("pic"):loadTexture(g_resManager.getResPath(generalInfo.general_big_icon))
        --边框
        baseNode:getChildByName("general"):getChildByName("pic_0"):loadTexture(g_resManager.getResPath(1005100 + generalInfo.general_quality))
        
        
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_1"):getChildByName("Image_8"):getChildByName("Text_6")
        :setString(g_tr("wu"))--武
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_1"):getChildByName("Text_7")
        :setString(generalInfo.general_force.."")
  
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_2"):getChildByName("Image_8"):getChildByName("Text_6")
        :setString(g_tr("zhi"))--智
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_2"):getChildByName("Text_7")
        :setString(generalInfo.general_intelligence.."")
        
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_3"):getChildByName("Image_8"):getChildByName("Text_6")
        :setString(g_tr("zheng"))--政
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_3"):getChildByName("Text_7")
        :setString(generalInfo.general_political.."")
        
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_4"):getChildByName("Image_8"):getChildByName("Text_6")
        :setString(g_tr("tong"))--统
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_4"):getChildByName("Text_7")
        :setString(generalInfo.general_governing.."")
        
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_5"):getChildByName("Image_8"):getChildByName("Text_6")
        :setString(g_tr("mei"))--魅
        baseNode:getChildByName("prop_row_1"):getChildByName("prop_5"):getChildByName("Text_7")
        :setString(generalInfo.general_charm.."")
        
        
        --skill info
        local skillRowNode = baseNode:getChildByName("prop_row_2")
        skillRowNode:getChildByName("skill_row_1"):setVisible(false)
        skillRowNode:getChildByName("skill_row_2"):setVisible(false)
        skillRowNode:getChildByName("skill_row_3"):setVisible(false)
        
        local skills = generalInfo.general_skill
        for i = 1, #skills do
            local skillId = skills[i]
            local skillInfo = g_data.general_skill[skillId]
            
            skillRowNode:getChildByName("skill_row_"..i):setVisible(true)
            skillRowNode:getChildByName("skill_row_"..i):getChildByName("Image_13"):getChildByName("skill_name")
            :setString(g_tr(skillInfo.general_skill_name))
            
            skillRowNode:getChildByName("skill_row_"..i):getChildByName("skill_effect")
            :setString(g_tr(skillInfo.general_skill_introduction))
            
        end
        
        --general desc
        local uiText = baseNode:getChildByName("prop_row_3"):getChildByName("Text_22")
        uiText:setString(g_tr(generalInfo.description))
    end
    
    
    
end

return GeneralInfoLayer