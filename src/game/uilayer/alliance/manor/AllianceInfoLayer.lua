local AllianceInfoLayer = class("AllianceInfoLayer",function()
    return cc.Layer:create()
end)

--直接显示
function AllianceInfoLayer.show(guildId)
    if guildId == nil or tonumber(guildId) == 0 then
        return
    end
    
    local guildInfo = nil
    local function onRecv(result, msgData)
      g_busyTip.hide_1()
      if result == true then
         guildInfo = msgData
         local informationLayer = require("game.uilayer.alliance.manor.AllianceInfoLayer"):create(guildInfo)
    	   g_sceneManager.addNodeForUI(informationLayer)
      end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("guild/viewGuildInfo",{guild_id = guildId},onRecv,true)
end

function AllianceInfoLayer:ctor(guildInfo)
    local uiLayer =  g_gameTools.LoadCocosUI("information_main.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    --关闭本页
    local btnClose = uiLayer:getChildByName("mask")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
  
    local currentIcon = g_AllianceMode.getAllianceIconId(guildInfo.icon_id)
    local iconInfo = g_data.alliance_flag[currentIcon]
    
    baseNode:getChildByName("Image_portrait_1"):loadTexture(g_resManager.getResPath(iconInfo.res_flag))
    
    baseNode:getChildByName("Text_c2"):setString(g_tr("allianceInfoTitle")) --联盟信息
    baseNode:getChildByName("Text_7"):setString(g_tr("allianceInfoBtnTxt")) --联系盟主
    baseNode:getChildByName("Text_1"):setString(g_tr("allianceName")) --联盟名称
    baseNode:getChildByName("Text_1_0"):setString(guildInfo.name) --联盟名称
    baseNode:getChildByName("Text_2"):setString(g_tr("allianceHost")) --盟主
    baseNode:getChildByName("Text_2_0"):setString(guildInfo.leader_player_nick) --盟主
    baseNode:getChildByName("Text_3"):setString(g_tr("allianceMembersMax")) --人员数量
    baseNode:getChildByName("Text_3_0"):setString(guildInfo.num.."/"..guildInfo.max_num) --人员数量
    baseNode:getChildByName("Text_4"):setString(g_tr("alliancePower")) --联盟战力
    baseNode:getChildByName("Text_4_0"):setString(guildInfo.guild_power.."") --人员数量
    baseNode:getChildByName("Text_5"):setString(g_tr("allianceCondition")) --入盟条件
    baseNode:getChildByName("Text_5_0"):setString(g_tr("allianceConditionLevel",{level = guildInfo.condition_fuya_level})) --府衙等级
    baseNode:getChildByName("Text_6"):setString("")
    baseNode:getChildByName("Text_6_0"):setString(g_tr("allianceConditionPlayer",{power = guildInfo.condition_player_power})) --玩家战力
    
    local btnMail = baseNode:getChildByName("Button_1")
    btnMail:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local nickNamme = guildInfo.leader_player_nick
            local pop = require("game.uilayer.mail.MailContentWritePop").new(false,nickNamme)
            g_sceneManager.addNodeForMsgBox(pop)
        end
    end)
    
end

return AllianceInfoLayer