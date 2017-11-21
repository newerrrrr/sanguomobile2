local DialogueLayer = class("DialogueLayer",require("game.uilayer.base.BaseLayer"))

function DialogueLayer:ctor(str,clickCallback,picId,generalNameId,generalPicId,generalPosType,isFromGuide)
    local node = nil 
    if picId and picId > 0 then
        node = g_gameTools.LoadCocosUI("ANovice_panel_1.csb",5)
        local pic = g_resManager.getRes(picId)
        if pic then
            node:getChildByName("scale_node"):getChildByName("picCon"):addChild(pic)
        end
        node:getChildByName("scale_node"):getChildByName("Panel_renwu"):loadTexture(g_resManager.getResPath(1030091))
    else
        node = g_gameTools.LoadCocosUI("ANovice_panel.csb",5)
        local contentLabel = node:getChildByName("scale_node"):getChildByName("Text_1")
        local orgLabelPos = contentLabel:getPositionX()
        local name = ""
        if generalNameId and generalNameId > 0 then
            name = g_tr(generalNameId)
        else
            contentLabel:setPositionX(orgLabelPos - 60)
        end 
        node:getChildByName("scale_node"):getChildByName("Text_name"):setString(name)
        
        local picImageView = node:getChildByName("scale_node"):getChildByName("Panel_renwu")
        local orginalImgPos = picImageView:getPositionX()
        if generalPicId and generalPicId > 0 then
            print(generalPicId,g_resManager.getResPath(generalPicId))
            --assert(false)
            picImageView:loadTexture(g_resManager.getResPath(generalPicId))
        else
            picImageView:loadTexture(g_resManager.getResPath(1030091))
        end
        
        local posx = orginalImgPos
        if generalPosType == 1 then
            posx = orginalImgPos - 395
        elseif generalPosType == 2 then
        
        elseif generalPosType == 3 then
             posx = orginalImgPos + 395
        end
        picImageView:setPositionX(posx)
            
    end

    self:addChild(node)
    
    --node:getChildByName("scale_node"):getChildByName("Text_1"):setString(str or "")
    if isFromGuide == true then
        local guideFontName = "cocostudio_res/SIMLI.TTF"
        node:getChildByName("scale_node"):getChildByName("Text_1"):setFontName(guideFontName)
    end
    
    local richText = g_gameTools.createRichText(node:getChildByName("scale_node"):getChildByName("Text_1"),str or "")
    local strGroups = richText:getCutStr()
    
    richText:setRichText("")
    local strTables = {}
    --拆分每个字符
    do
        for key, var in ipairs(strGroups) do
        	if string.find(var,"<#") then
        	   table.insert(strTables,var)
        	else
        	   --local len = #(string.gsub(var, "[\128-\191]", ""))        -- 计算字符数（不是字节数）
               --local i=1                                                 -- 迭代出每一个字符，并保存在table中
               --local m_table = {}                                            
               for c in string.gmatch(var, ".[\128-\191]*") do       
                 --   m_table[i] = c                                         
                   -- i=i+1
                  table.insert(strTables,c)
               end
        	end
        end
    end
    
    local strIdx = 1
    local str_show = ""
    
    self._printFinished = false
    local function updateText()
      if strIdx > #strTables then 
         self:stopAllActions()
         print("print text finished")
         self._printFinished = true
         return
      end
      --print("setString:",strTables[strIdx])
      str_show = str_show..strTables[strIdx]
      --print("sssss:",str_show)
      richText:setRichText(str_show)
      --richText:formatText()
      
      strIdx = strIdx + 1
    end
    self:schedule(updateText, 0.10) 
    
    g_guideManager.isHaveDialogueOnShow = true
    
    local btnClose = node:getChildByName("mask")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if not self._printFinished then
                self:stopAllActions()
                self._printFinished = true
                richText:setRichText(str)
                return
            end
            
            --[[--for test
            strIdx = 1
            str_show = ""
            self:schedule(updateText, 0.12) ]]
            
            self:removeFromParent()
            g_guideManager.isHaveDialogueOnShow = false
            if clickCallback then
                clickCallback()
            end
            g_guideManager.execute()
        end
    end)
    
end

return DialogueLayer