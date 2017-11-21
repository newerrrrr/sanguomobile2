local mainSurfaceMerryGoRound = {}
setmetatable(mainSurfaceMerryGoRound,{__index = _G})
setfenv(1,mainSurfaceMerryGoRound)

--主界面菜单

local m_Root = nil
local m_Widget = nil
local m_TextPanels = nil

--走马灯消息列表
local m_MsgVec = {}
--当前走马灯是否还在滚动当中
local m_IsKeepRun = false

local function clearGlobal()
	m_Root = nil
    m_Widget = nil
	m_TextPanels = nil
	m_MsgVec = {}
	g_gameCommon.removeAllEventHandlers(mainSurfaceMerryGoRound)
end

function create()
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
    m_Widget = g_gameTools.LoadCocosUI("zhuchengjiemian_05.csb", 8)
    
    rootLayer:addChild(m_Widget)
	
	m_TextPanels = m_Widget:getChildByName("scale_node"):getChildByName("Panel_2")
	
    local function foramtStr(gData)
        
        local desc = nil
       
        if gData == nil then
            return 
        end
        
        local dataConfig = g_data.title_notice
        local gType = tonumber(gData.type)

        
        if gType == 0 then
            return gData.gm_notice
        end

        --主公%{playernameA}↓%{powerA}攻破了{playernameB}↓%{powerB}的城门！
        if gType == 1 then
            local battleType = tonumber(gData.battle_type)
            local descModeStr = ""
            --野外
            if battleType == 1 then
                --进攻方胜利
                if tonumber(gData.battle_win) == 1 then
                    descModeStr = dataConfig[3].desc
                end
                --进攻方失败
                if tonumber(gData.battle_win) == 0 then
                    descModeStr = dataConfig[4].desc
                end
                local playerA = {nick = gData.player_nick,power = gData.battle_attacker_power_loss}
                local playerB = {nick = gData.battle_defender_player_nick,power = gData.battle_defender_power_loss}
                return g_tr(descModeStr,{playernameA = playerA.nick,powerA = playerA.power,playernameB = playerB.nick,powerB = playerB.power})
            end
            --城池
            if battleType == 2 then
                --胜利
                if tonumber(gData.battle_win) == 1 then
                    descModeStr = dataConfig[1].desc
                end
                --失败
                if tonumber(gData.battle_win) == 0 then
                    descModeStr = dataConfig[2].desc
                end
                local playerA = {nick = gData.player_nick,power = gData.battle_attacker_power_loss}
                local playerB = {nick = gData.battle_defender_player_nick,power = gData.battle_defender_power_loss}
                return g_tr(descModeStr,{playernameA = playerA.nick,powerA = playerA.power,playernameB = playerB.nick,powerB = playerB.power})
            end
            --堡垒
            if battleType == 3 then
                --胜利
                if tonumber(gData.battle_win) == 1 then
                    descModeStr = dataConfig[5].desc
                end
                --失败
                if tonumber(gData.battle_win) == 0 then
                    descModeStr = dataConfig[6].desc
                end
                local playerA = {guildName = gData.battle_attacker_guild_short_name}
                local playerB = {guildName = gData.battle_defender_guild_short_name}
                return g_tr(descModeStr,{guildnameA = playerA.guildName,guildnameB = playerB.guildName})
            end
        end
        --由于主公%{playernameA}↓%{powerA}的英勇表现，，击退了敌方%{playernameB}↓%{powerB}的百万大军！保卫了自己的边疆领土！
        if gType == 2 then
            local nickName = gData.player_nick
            --武将配置表
            local generalConfig = g_GeneralMode.GetBasicInfo( tonumber(gData.general_id),1)

            local generalName = g_tr(generalConfig.general_name)
                
            local generalQuality = tonumber(generalConfig.general_quality)

            local descModeStr = ""

            if generalQuality == 4 then --紫色
                descModeStr = dataConfig[11].desc
            elseif generalQuality == 5 then --橙色
                descModeStr = dataConfig[7].desc
            end

            return g_tr(descModeStr,{playername = nickName,generalname = generalName })
        end

        --主公%{playernameA}↓%{powerA}抢夺了{playernameB}↓%{powerB}的野外采集资源！
        if gType == 3 then
            local nickName = gData.player_nick
            --野怪配置
            local mConfig = g_data.npc[ tonumber(gData.boss_npc_id) ]
            --野怪名称
            local bossName = g_tr( mConfig.monster_name )
            local descModeStr = dataConfig[8].desc
            return g_tr(descModeStr,{playername = nickName,bossname = bossName})
        end

        --由于主公%{playernameA}↓%{powerA}的英勇表现，，击退了敌方%{playernameB}↓%{powerB}的部队！保卫了自己的采集资源！
        if gType == 4 then
            --local playerA = {nick = gData.player_nick,power = gData.battle_attacker_power_loss}
            --local playerB = {nick = gData.battle_defender_player_nick,power = gData.battle_defender_power_loss}
            --desc = g_tr(dataConfig[gType].desc,{playernameA = playerA.nick,powerA = playerA.power,playernameB = playerB.nick,powerB = playerB.power})
            local nickName = gData.player_nick
            --装备配置
            local eConfig = g_data.equipment[ tonumber(gData.equipment_id)]
            --装备名称
            local eName = g_tr(eConfig.equip_name)
            --装备星级
            local eStar = tonumber(gData.equipment_star)
            --装备品质
            local eQuality = eConfig.quality_id

            local descModeStr = dataConfig[9].desc
            
            if eQuality == 4 then
                descModeStr = dataConfig[9].desc
            elseif eQuality == 5 then
                descModeStr = dataConfig[10].desc
            end
            
            return g_tr(descModeStr,{playername = nickName,equipmentname = eName,startstar = eStar - 1,endstar = eStar })
        end

        --恭贺吾皇{playernameA}龙袍加身登基称帝！万民朝拜，万岁万万岁！

        if gType == 5 then --皇帝
            
            --local nickName = gData.player_nick
            --local descModeStr = dataConfig[12]
            --return g_tr(descModeStr,{ playernameA = nickName } )

        end

        --圣上%{playernameA}讲%{playernameB}册封为%{playertitle}
        --圣上%{playernameA}将%{playernameB}谪贬为%{playertitle}

        if gType == 6 then  --册封或者谪贬

            local playerANick = gData.data.king_nick
            
            local playerBNick = gData.data.target_player_nick
            local playerBJobId = gData.data.target_player_job
            local playerBId = gData.data.target_player_id
            
            --更新BUFF
            if tonumber(playerBId) == tonumber(g_PlayerMode.GetData().id) then
                g_BuffMode.RequestDataAsync()
            end

            local jobConfig = g_data.king_appoint[playerBJobId]

            local playerTitle = g_tr(jobConfig.position_name)
            
            local descModeStr = (jobConfig.type == 1 and dataConfig[13].desc or dataConfig[14].desc)
            
            return g_tr(descModeStr,{playernameA = playerANick, playernameB = playerBNick, playertitle = playerTitle })
        end
        --鸿运当头！%{playername}获得了%{itemname}，军威大振！
        if gType == 8 then
            local playerNick = gData.data.player_nick
            local itemId = gData.data.item_id
            local itemName = g_tr(g_data.item[itemId].item_name)
            local descModeStr = dataConfig[15].desc
            return g_tr( descModeStr,{ playername = playerNick,itemname = itemName } )
        end

        --%{playername}成功化神大将%{generalname}，战力飙升！
        if gType == 9 then
            local playerNick = gData.data.player_nick
            local ganeralID = tonumber(gData.data.general_id .. "01" )
            local ganeralName = g_tr(g_data.general[ ganeralID ].general_name)
            local descModeStr = dataConfig[16].desc
            return g_tr( descModeStr,{ playername = playerNick,generalname = ganeralName } )
        end
    end

	local function onRecvNewMsg(obj, tcpData)
		--print("Merry go round :")
		--播完一条一定要删掉
		--后面的一定要加在前一条距离之后，并且在屏幕外面 ，哪个距离值更靠右就以哪个为准
		--做一个队列上限30条,怕万一服务器出问题爆了客户端

        dump(tcpData)
        local str = foramtStr(tcpData.data)
        --print("==========================================",str)
        if str ~= nil and #m_MsgVec < 30 then
            table.insert(m_MsgVec,str)
        end

        if not m_IsKeepRun then 
            goRound()
        end
	end

	g_gameCommon.addEventHandler(g_Consts.CustomEvent.MerryGoRound, onRecvNewMsg, mainSurfaceMerryGoRound)
	

    --[[测试数据
    table.insert( m_MsgVec,{gm_notice = "12"} )
    table.insert( m_MsgVec,{gm_notice = "我是走马灯测试数据不知道这个数据的速度是多少我自己来阿奎介绍的吉安市大家看哈邓丽君很快就离婚岁的花季里卡号是肯定接哈冷静思考都会看见啦"} )
    table.insert( m_MsgVec,{gm_notice = "alkjsjhdjklashfjhasjklfhjkashfjkahsjkdlhajklsfhjklashfjkafhl"} )
    ]]


    if table.nums(m_MsgVec) > 0 then
        goRound()
    end


	return rootLayer
end


function goRound()
    
    local function msgRunAction(msg)
        --local rText = g_gameTools
        table.remove(m_MsgVec,1)

        local rText = ccui.Text:create()
        rText:setFontName("cocostudio_res/simhei.ttf")
        rText:setString(msg)
        rText:setFontSize(25)
        rText:setAnchorPoint(0,0.5)
        rText:setPosition( cc.p(g_display.width,m_TextPanels:getContentSize().height/2 - 3) ) 
        rText:setVisible(false)
        m_TextPanels:addChild(rText)
        local rich = g_gameTools.createRichText( rText , msg)

        local sd = 150 
        local t = (m_TextPanels:getContentSize().width + rText:getContentSize().width) / sd

        local moveOver = cc.MoveTo:create( t , cc.p( 0 - rText:getContentSize().width, rText:getPositionY() ) )
        local runOverFun = cc.CallFunc:create( function ()
            rText:removeFromParent()
            rich:removeFromParent()
            goRound()
        end)

        rich:runAction( cc.Sequence:create(moveOver,runOverFun) )

    end 

    if table.nums(m_MsgVec) > 0 then
        m_IsKeepRun = true
        msgRunAction(m_MsgVec[1])
    else
        m_IsKeepRun = false
    end

end


--城内外切换UI变更
function viewChangeShow()
    if m_Root then
			local changeMapScene = require("game.maplayer.changeMapScene")
			local mapStatus = changeMapScene.getCurrentMapStatus()
			if mapStatus == changeMapScene.m_MapEnum.home then
				m_Root:setVisible(true)
			elseif mapStatus == changeMapScene.m_MapEnum.world then
				m_Root:setVisible(true)
		  elseif mapStatus == changeMapScene.m_MapEnum.guildwar then
	      m_Root:setVisible(false)
	    elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
	      m_Root:setVisible(false)
			end
    end
end


return mainSurfaceMerryGoRound