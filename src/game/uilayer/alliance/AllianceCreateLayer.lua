local AllianceCreateLayer = class("AllianceCreateLayer",function()
    return cc.Layer:create()
end)

function AllianceCreateLayer:ctor(createSuccessCallBack)
    
    self._createSuccessCallBack = createSuccessCallBack
    local uiLayer = cc.CSLoader:createNode("alliance_content_create.csb")
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("content")
    self:setContentSize(baseNode:getContentSize())
    self._baseNode = baseNode
    
    --reset text ui
    baseNode:getChildByName("lable_1"):getChildByName("Text")
    :setString(g_tr("allianceName"))
    
    baseNode:getChildByName("lable_2"):getChildByName("Text")
    :setString(g_tr("allianceAds"))
    
     baseNode:getChildByName("lable_3"):getChildByName("Text")
    :setString(g_tr("allianceShortName"))
    
    baseNode:getChildByName("lable_0"):getChildByName("Text")
    :setString(g_tr("allianceCountry"))
    
--    self._countryFlag = 1
--    local flags = {}
--    local function selectCountryHandler(sender)
--    	local idx = sender.idx
--    	 for i=1, 3 do
--    	 	flags[i]:getChildByName("Image_fag"):setVisible(false)
--    	 end
--    	 flags[idx]:getChildByName("Image_fag"):setVisible(true)
--    	 self._countryFlag = idx
--    end
--    
--    
--    for i=1, 3 do
--    	local con = baseNode:getChildByName("Panel_q"..i)
--    	local icon = cc.CSLoader:createNode("alliance_content_create_new1_list2.csb")
--    	local iconId = g_data.country_camp_list[i].camp_pic
--    	icon:getChildByName("pic_current"):loadTexture(g_resManager.getResPath(iconId))
--    	icon:setTouchEnabled(true)
--    	icon.idx = i
--    	icon:addClickEventListener(selectCountryHandler)
--    	con:addChild(icon)
--    	flags[i] = icon
--    end
--    selectCountryHandler(flags[1])
    
    
--    baseNode:getChildByName("lable_3"):getChildByName("Text")
--    :setString(g_tr("allianceIcon"))
    
    baseNode:getChildByName("btn_save"):getChildByName("Text")
    :setString(g_tr("create"))
    
    baseNode:getChildByName("text_tips_1"):setString(g_tr("inputError"))
    baseNode:getChildByName("text_tips_2"):setString(g_tr("allianceAdsError"))
    baseNode:getChildByName("text_tips_3"):setString(g_tr("allianceShortNameError"))
    
    local costNum = 0
    local costType = 0
    
    local costId = 105
    for key, var in pairs(g_data.cost) do
        if costId == var.cost_id then
           costNum = var.cost_num
           costType = var.cost_type
           break
        end
    end
    assert(costType > 0)
    
    local iconId = g_Consts.CurrencyDefaultId + costType
    self._baseNode:getChildByName("btn_save"):getChildByName("ico_gold"):loadTexture(g_resManager.getResPath(iconId))
    self._baseNode:getChildByName("btn_save"):getChildByName("Text_9"):setString(costNum.."")
    
    if g_playerInfoData.GetData().first_create_guild == 0 then
        self._baseNode:getChildByName("btn_save"):getChildByName("Text_9"):setString(g_tr("air_free"))
    end 
    
    self._baseNode:getChildByName("text_tips_1"):setString("")
    self._baseNode:getChildByName("text_tips_2"):setString("")
    self._baseNode:getChildByName("text_tips_3"):setString("")
    self._baseNode:getChildByName("TextField_1"):setString("")
    self._baseNode:getChildByName("TextField_2"):setString("")
    self._baseNode:getChildByName("TextField_3"):setString("")
    
    self._TextField_1 = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("TextField_1"))
    self._TextField_2 = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("TextField_2"))
    self._TextField_3 = g_gameTools.convertTextFieldToEditBox(self._baseNode:getChildByName("TextField_3"))
    
    self._TextField_1:setPlaceHolder(g_tr("allianceNameRule"))
    self._TextField_2:setPlaceHolder(g_tr("allianceAdsRule"))
    self._TextField_3:setPlaceHolder(g_tr("allianceShortNameRule"))
    
    local saveBtn = baseNode:getChildByName("btn_save")
    saveBtn:setTouchEnabled(true)
    saveBtn:addTouchEventListener(function(sender,eventType)
          if eventType == ccui.TouchEventType.ended then 
              g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
              self:saveHandler()
          end
    end)
    
    --default flag
--    local iconInfo = g_data.alliance_flag[1001]
--    if iconInfo then
--        baseNode:getChildByName("Image_19"):loadTexture(g_resManager.getResPath(iconInfo.res_flag))
--    end
    
end

function AllianceCreateLayer:saveHandler()
    --[[guild/createGuild
      postData: {"create_guild_data":{"name":"god guild","icon_id":1,"need_leader_check":1,
      "desc":"Fire in the hole","condition_fuya_level":10,"condition_player_power":5555}}
      return: {Guild}]]
    self._baseNode:getChildByName("text_tips_1"):setString("")
    self._baseNode:getChildByName("text_tips_2"):setString("")
    self._baseNode:getChildByName("text_tips_3"):setString("")
      
    local allianceName = self._TextField_1:getString()
    allianceName = string.trim(allianceName)
    local iconId = g_Consts.AllianceIconDefaultId
    local condition_fuya_level = 0
    local condition_player_power = 0
    
    local short_name = self._TextField_3:getString()
    short_name = string.trim(short_name)

    local desc = self._TextField_2:getString()
    desc = string.trim(desc)
    
    if allianceName == "" then
        self._baseNode:getChildByName("text_tips_1"):setString(g_tr("inputAllianceName"))
        return
    else
         local length = string.utf8len(allianceName)
         if length < 3 or length > 7 then
            self._baseNode:getChildByName("text_tips_1"):setString(g_tr("allianceNameRule"))
            return
         end
    end
    
    if short_name == "" then
        self._baseNode:getChildByName("text_tips_3"):setString(g_tr("inputAllianceShortName"))
        return
    else
        --[[local haveChn = false
        for i=1, #short_name do
        	local curByte = string.byte(short_name, i)
        	if curByte > 127 then
        	   haveChn = true
        	   break
        	end
        end
        
        if haveChn then
            self._baseNode:getChildByName("text_tips_3"):setString(g_tr("allianceShortNameRule"))
            return
        end]]
        
        local length = string.utf8len(short_name)
        print("length:",length)
        if length < 1 or  length > 3 then
            self._baseNode:getChildByName("text_tips_3"):setString(g_tr("allianceShortNameRule"))
            return
        end
        
    end
    
    
    if desc == "" then
        self._baseNode:getChildByName("text_tips_2"):setString(g_tr("inputAllianceDesc"))
        return
    end
    
    local descLength = string.utf8len(desc)
    if descLength > 20 then
        self._baseNode:getChildByName("text_tips_2"):setString(g_tr("allianceAdsRule"))
        return
    end
    
    local need_check = 0

    print("save handler")
    local resultHandler = function(result, msgData)
        if result then
            print("success")
            g_AllianceMode.reqAllAllianceData()
            if self._createSuccessCallBack then
                self._createSuccessCallBack()
            end
            g_AllianceMode.updateWorldMap()
        end
    end
    
    local data = {}
    data.name = allianceName
    data.icon_id = iconId
    data.condition_fuya_level = condition_fuya_level
    data.condition_player_power = condition_player_power
    data.desc = desc
    data.need_check = need_check
    data.short_name = short_name
    --data.camp_id = self._countryFlag
    g_sgHttp.postData("guild/createGuild",{create_guild_data = data},resultHandler)
end

return AllianceCreateLayer