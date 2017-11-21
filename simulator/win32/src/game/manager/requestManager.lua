local requestManager = {}
setmetatable(requestManager,{__index = _G})
setfenv(1,requestManager)



--错误码提示
function onRequestAutoErrorCodeTips(errorID)
	local er = g_data.error_code[tonumber(errorID)]
	if er then
		local text = er[ require("public.localization").language ]
		if text then
			g_airBox.show(text,3)
			return
		end
	end
	g_airBox.show("error: not found error id : "..tostring(errorID), 3)
end

--服务器带回数据自动更新
function onRequestAutoUpdate(basicTable)

    if(basicTable.Player)then
        g_PlayerMode.SetData(basicTable.Player)
        g_PlayerMode.NotificationUpdateShow()
    end

    if(basicTable and basicTable.PlayerGeneral)then
        g_GeneralMode.SetData(basicTable.PlayerGeneral)
        g_GeneralMode.NotificationUpdateShow()
    end

    if(basicTable and basicTable.PlayerArmy)then
        g_ArmyMode.SetData(basicTable.PlayerArmy)
        g_ArmyMode.NotificationUpdateShow()
    end

    if(basicTable and basicTable.PlayerArmyUnit)then
        g_ArmyUnitMode.SetData(basicTable.PlayerArmyUnit)
        g_ArmyUnitMode.NotificationUpdateShow()
    end

    if(basicTable.PlayerBuild)then
        g_PlayerBuildMode.SetData(basicTable.PlayerBuild)
        g_PlayerBuildMode.NotificationUpdateShow()
    end

    if(basicTable and basicTable.PlayerItem)then
        g_BagMode.SetData(basicTable.PlayerItem)
        g_BagMode.NotificationUpdateShow()
    end

    if(basicTable and basicTable.PlayerEquipment)then
        g_EquipmentlMode.SetData(basicTable.PlayerEquipment)
        g_EquipmentlMode.NotificationUpdateShow()
    end
    
	--主公宝物列表
    if basicTable and basicTable.PlayerEquipMaster then
         g_MasterEquipMode.SetData(basicTable.PlayerEquipMaster)
         g_MasterEquipMode.NotificationUpdateShow()
    end

    if basicTable and basicTable.PlayerTalent then
        g_MasterTalentMode.SetData(basicTable.PlayerTalent)
        g_MasterTalentMode.NotificationUpdateShow()
    end

    if basicTable and basicTable.PlayerMasterSkill then
        g_MasterSkillMode.SetData(basicTable.PlayerMasterSkill)
        g_MasterSkillMode.NotificationUpdateShow()
    end

    if basicTable and basicTable.PlayerCoordinate then
        g_MapCollectMode.SetData(basicTable.PlayerCoordinate)
        g_MapCollectMode.NotificationUpdateShow()
    end
    
    if basicTable and basicTable.PlayerSoldierInjured then
         g_PlayerSoldierInjuredMode.setData(basicTable.PlayerSoldierInjured)
         g_PlayerSoldierInjuredMode.notificationUpdateShow()
    end
    
	  if basicTable and basicTable.PlayerPub then
         g_PlayerPubMode.setData(basicTable.PlayerPub)
         g_PlayerPubMode.notificationUpdateShow()
    end

    if(basicTable and basicTable.PlayerScience)then
        g_ScienceMode.SetData(basicTable.PlayerScience)
        g_ScienceMode.NotificationUpdateShow()
    end	

    if(basicTable and basicTable.PlayerSoldier)then
        g_SoldierMode.SetData(basicTable.PlayerSoldier)
        g_SoldierMode.NotificationUpdateShow()
    end 

    if(basicTable and basicTable.PlayerTrap)then
        g_TrapMode.SetData(basicTable.PlayerTrap)
        g_TrapMode.NotificationUpdateShow()
    end 
    
    if basicTable and basicTable.Guild then
        g_AllianceMode.setBaseData(basicTable.Guild)
    end  
    
    if basicTable and basicTable.GuildScience then
        g_AllianceMode.setTechData(basicTable.GuildScience)
    end  
    
    if basicTable and basicTable.GuildShop then
        require("game.gamedata.AllianceShop").setBaseData(basicTable.GuildShop)
    end 
    
    if basicTable and basicTable.PlayerMission then
        g_TaskMode.setBaseData(basicTable.PlayerMission)
        g_TaskMode.NotificationUpdateShow()
    end 

    if basicTable and basicTable.ChatBlackList then
        g_chatData.SetBlackList(basicTable.ChatBlackList)
    end 
    
    if basicTable and basicTable.PlayerShop then
        g_playerShop.SetData(basicTable.PlayerShop)
        g_playerShop.NotificationUpdateShow()
    end
    
    if basicTable and basicTable.PlayerMarket then
        g_shopMarketData.SetData(basicTable.PlayerMarket)
        g_shopMarketData.NotificationUpdateShow()
    end

    if basicTable and basicTable.PlayerBuff then
        g_BuffMode.SetData(basicTable.PlayerBuff)
        g_BuffMode.NotificationUpdateShow()
    end
    
     --basicTable.PlayerBuff 和 basicTable.PlayerGeneralBuff数据信息一致
    if basicTable and basicTable.PlayerGeneralBuff then
        g_BuffMode.SetData(basicTable.PlayerGeneralBuff)
        g_BuffMode.NotificationUpdateShow()
    end 

    --basicTable.PlayerBuff 和 basicTable.PlayerBuffTemp数据信息一致
    if basicTable and basicTable.PlayerBuffTemp then
        g_BuffMode.SetData(basicTable.PlayerBuffTemp)
        g_BuffMode.NotificationUpdateShow()
    end 

    if basicTable and basicTable.PlayerOnlineAward then
        g_limitRewardData.SetData(basicTable.PlayerOnlineAward)
        g_limitRewardData.NotificationUpdateShow()
    end

    if(basicTable and basicTable.PlayerHelp)then
        g_PlayerHelpMode.SetData(basicTable.PlayerHelp)
        g_PlayerHelpMode.NotificationUpdateShow()
    end

    if(basicTable and basicTable.PlayerTarget) then
        g_actSevenDayTarget.SetData(basicTable.PlayerTarget)
        g_actSevenDayTarget.NotificationUpdateShow()
    end

    if(basicTable and basicTable.PlayerSignAward) then
        g_actSign.SetData(basicTable.PlayerSignAward)
        g_actSign.NotificationUpdateShow()
    end
    
    if(basicTable and basicTable.PlayerMill) then
        g_millData.SetData(basicTable.PlayerMill)
        g_millData.NotificationUpdateShow()
    end
    
    if(basicTable and basicTable.PlayerGrowth) then
        g_playerGrownFundData.SetData(basicTable.PlayerGrowth)
        g_playerGrownFundData.NotificationUpdateShow()
    end
    
    if(basicTable and basicTable.GuildBoard) then
        g_allianceCommentData.SetData(basicTable.GuildBoard)
        g_allianceCommentData.NotificationUpdateShow()
    end
    
    if(basicTable and basicTable.PlayerInfo) then
        g_playerInfoData.SetData(basicTable.PlayerInfo)
        g_playerInfoData.NotificationUpdateShow()
    end

    if (basicTable and basicTable.PlayerLotteryInfo ) then
        g_zhuanPanData.SetZhuanPanData(basicTable.PlayerLotteryInfo)
    end

    if (basicTable and basicTable.PlayerDrawCard) then
        g_zhuanPanData.SetFanPaiData(basicTable.PlayerDrawCard)
    end
    
    if basicTable and basicTable.PkPlayerInfo then
        g_expeditionData.SetData(basicTable.PkPlayerInfo)
        g_expeditionData.NotificationUpdateShow()
    end

    if basicTable and basicTable.PlayerNewbieActivityLogin then
        g_activityData.SetNewbieLogin(basicTable.PlayerNewbieActivityLogin)
        g_activityData.NotificationEffect()
    end

    if basicTable and basicTable.PlayerNewbieActivityCharge then
        g_activityData.SetNewbieCharge(basicTable.PlayerNewbieActivityCharge)
        g_activityData.NotificationEffect()
    end

    if basicTable and basicTable.PlayerNewbieActivityConsume then
        g_activityData.SetNewbieConsume(basicTable.PlayerNewbieActivityConsume)
        g_activityData.NotificationEffect()
    end
    
    if basicTable and basicTable.CrossPlayer then
        g_guildWarPlayerData.SetData(basicTable.CrossPlayer)
        g_guildWarPlayerData.NotificationUpdateShow()
    end

     if basicTable and basicTable.CrossPlayerSoldier then
        g_crossSoldier.SetData(basicTable.CrossPlayerSoldier)
        g_crossSoldier.NotificationUpdateShow()
    end

     if basicTable and basicTable.CrossPlayerGeneral then
        g_crossGeneral.SetData(basicTable.CrossPlayerGeneral)
        g_crossGeneral.NotificationUpdateShow()
    end

     if basicTable and basicTable.CrossPlayerArmy then
        g_crossArmy.SetData(basicTable.CrossPlayerArmy)
        g_crossArmy.NotificationUpdateShow()
    end

    if basicTable and basicTable.CrossPlayerArmyUnit then
        g_crossArmyUnit.SetData(basicTable.CrossPlayerArmyUnit)
        g_crossArmyUnit.NotificationUpdateShow()
    end
    
    if basicTable and basicTable.CrossGuild then
        g_crossGuild.SetData(basicTable.CrossGuild)
        g_crossGuild.NotificationUpdateShow()
    end
    
    if basicTable and basicTable.CrossPlayerMasterskill then
        g_crossPlayerMasterskill.SetData(basicTable.CrossPlayerMasterskill)
        g_crossPlayerMasterskill.NotificationUpdateShow()
    end
    
    --城战
    if basicTable and basicTable.CityBattlePlayer then
        g_cityBattlePlayerData.SetData(basicTable.CityBattlePlayer)
        g_cityBattlePlayerData.NotificationUpdateShow()
    end

     if basicTable and basicTable.CityBattlePlayerSoldier then
        g_cityBattleSoldier.SetData(basicTable.CityBattlePlayerSoldier)
        g_cityBattleSoldier.NotificationUpdateShow()
    end

     if basicTable and basicTable.CityBattlePlayerGeneral then
        g_cityBattleGeneral.SetData(basicTable.CityBattlePlayerGeneral)
        g_cityBattleGeneral.NotificationUpdateShow()
    end

     if basicTable and basicTable.CityBattlePlayerArmy then
        g_cityBattleArmy.SetData(basicTable.CityBattlePlayerArmy)
        g_cityBattleArmy.NotificationUpdateShow()
    end

    if basicTable and basicTable.CityBattlePlayerArmyUnit then
        g_cityBattleArmyUnit.SetData(basicTable.CityBattlePlayerArmyUnit)
        g_cityBattleArmyUnit.NotificationUpdateShow()
    end
    
    if basicTable and basicTable.CityBattleCamp then
        g_cityBattleCamp.SetData(basicTable.CityBattleCamp)
        g_cityBattleCamp.NotificationUpdateShow()
    end
    
    if basicTable and basicTable.CityBattlePlayerMasterskill then
        g_cityBattlePlayerMasterskill.SetData(basicTable.CityBattlePlayerMasterskill)
        g_cityBattlePlayerMasterskill.NotificationUpdateShow()
    end

    if basicTable and basicTable.PlayerCitybattleDonate then
        g_PlayerMode.SetDonateData(basicTable.PlayerCitybattleDonate)
        g_PlayerMode.NotificationUpdateDonateShow()
    end

end

--批量请求data/index数据
function RequestDataIndex(dataList)
    local ret = false
    local function onRecv(result, msgData)
      if(result==true)then
        ret = true
        onRequestAutoUpdate(msgData)
      end
    end
    g_sgHttp.postData("data/index",{name = dataList},onRecv)
    return ret
end

local function _formatMsgKey(str)
    if string.sub(str, 1, 1) == "/" then 
       str = string.sub(str, 2)
    end 
    return string.lower(str)
end

--批量请求接口
function RequestCombo(comboList)
    
--    local comboList = {
--      {url ="data/index",field = {name = dataIndexList}}
--    }
    
    --format url
    for key, var in pairs(comboList) do
    	  var.url = _formatMsgKey(var.url)
    end


    local ret = false
    local function onRecv(result, msgData)
      if(result==true)then
        ret = true
        onRequestComboAutoUpdate(msgData)
      end
    end
    g_sgHttp.postData("common/combo",{combo = comboList},onRecv)
    return ret
end

--批量请求接口后处理数据
function onRequestComboAutoUpdate(comboTable)

    for key, msgData in pairs(comboTable) do
    
    	  if _formatMsgKey("data/index") == key then
    	     onRequestAutoUpdate(msgData)
    	  end
    	  
    	  if _formatMsgKey("Guild/comboGuildMemberInfo") == key then
           g_AllianceMode.SetAllAllianceData(msgData)
        end
        
        if _formatMsgKey("King/getInfo") == key then
           g_kingInfo.SetData(msgData)
        end
        
    	  if _formatMsgKey("Lottery/checkPlayerLotteryInfo") == key then
           g_zhuanPanData.SetZhuanPanData(msgData.PlayerLotteryInfo)
           g_zhuanPanData.SetFanPaiData(msgData.PlayerDrawCard)
        end
        
        if _formatMsgKey("limit_match/showLimitMatch") == key then
           require("game.uilayer.activity.timelimitmatch.timeLimitMatchData").SetData(msgData)
        end
        
        if _formatMsgKey("Player/getBuff") == key then
           g_BuffMode.SetData(msgData.PlayerBuff)
        end

        if _formatMsgKey("Mail/getList") == key then
           g_MailMode.SetData(msgData, g_MailMode.getPreReqMailTypeWhenEnter())
        end 

        if _formatMsgKey("Mail/getUnread") == key then
            if msgData and msgData.mailCount then 
                g_MailMode.setUnreadInfo(msgData.mailCount)
            end 
        end 

        -- if _formatMsgKey("common/comboChat") == key then
        --    g_chatData.setComboData(msgData)
        -- end 
        if _formatMsgKey("common/lastWorldChatMsg") == key then
           g_chatData.setLastWorldChatItem(msgData)
        end         
    end
end

function onItemAutoConverted(extraData) 
    if extraData and extraData.jiangyin then 
        local items = {}
        for k, v in pairs(extraData.jiangyin) do 
            table.insert(items, {g_Consts.DropType.Props, tonumber(k), v.toNum})
        end 
        local view = require("game.uilayer.common.ItemAutoConvertPop"):create(items)
        g_sceneManager.addNodeForUI(view)        
    end 
end 

return requestManager