local worldMapLayer_smallMenuClick = {}
setmetatable(worldMapLayer_smallMenuClick,{__index = _G})
setfenv(1,worldMapLayer_smallMenuClick)


local QueueHelperMD = require "game.maplayer.worldMapLayer_queueHelper"
local HelperMD = require "game.maplayer.worldMapLayer_helper"
local battleManager = require("game.uilayer.battleSet.battleManager")

function onClick(cellType , mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	local func = worldMapLayer_smallMenuClick[string.format("onClick_%s",tostring(cellType))]
	if(func and type(func)=="function")then
		func(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	else
		assert(false,"not found func id : "..tostring(cellType))
	end
end



--函数编号对应的意思看配置表Map_Element.xlsx中的Build_menu_type sheet
--参数为: 
--mapConfigData: 	Map_Element配置(点击建筑触发的菜单才会有这个数据)
--buildServerData: 	本地缓存的服务器map数据(点击建筑触发的菜单才会有这个数据)
--queueServerData: 	本地缓存的服务器队列数据(点击队伍触发的菜单才会有这个数据)
--playerData: 		buildServerData或者queueServerData的所属玩家的服务器数据(只有在确实有玩家的情况下才有这个数据)
--guildData:		buildServerData或者queueServerData的所属公会的服务器数据(只有在确实有公会的情况下才有这个数据)
--bigTileIndex:		触发菜单的空地大索引坐标(点击空地触发菜单才有这个数据)
--参数只能使用,不能修改,配置数据被改了就麻烦了


function onClick_101(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    --dump(mapConfigData)
    --print("说明")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if mapConfigData then
        local resInfoLayer = require("game.uilayer.map.resInfoLayer")
        resInfoLayer:createLayer(mapConfigData.id)
        --g_sceneManager.addNodeForUI(resInfoLayer:create(mapConfigData.id))
        
    end
end

--采集黄金（测）
function onClick_102(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.gotoCollect({ buildServerData = buildServerData })
end

--采集粮食（测）
function onClick_103(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.gotoCollect({ buildServerData = buildServerData })
end

--采集木头（测）
function onClick_104(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.gotoCollect({ buildServerData = buildServerData })
end

--采集石头（测）
function onClick_105(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.gotoCollect({ buildServerData = buildServerData })
end

--采集铁矿（测）
function onClick_106(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.gotoCollect({ buildServerData = buildServerData })
end

--建造联盟建筑（测）
function onClick_107(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.gotoBuildGuild({ buildServerData = buildServerData })
end


function onClick_108(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)

end


function onClick_109(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.manor.AllianceManorInfoLayer"):create(mapConfigData.id,buildServerData))
end


function onClick_110(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if g_AllianceMode.getBaseData() and g_AllianceMode.getBaseData().id == guildData.id then
        local idx = require("game.uilayer.alliance.manor.AllianceManorLayer").getIndexByMapElementId(mapConfigData.id)
        g_sceneManager.addNodeForUI(require("game.uilayer.alliance.manor.AllianceManorLayer"):create(nil,idx))
    else
        g_sceneManager.addNodeForUI(require("game.uilayer.alliance.manor.AllianceManorDescription"):create(buildServerData))
    end
    
end


function onClick_111(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    onClick_107(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
end


function onClick_112(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    print("onClick_112")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    g_sceneManager.addNodeForUI(require("game.uilayer.map.mapPlayerInfoView"):create( playerData.id ))
end


--侦查
function onClick_113(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    local detectLayer = require("game.uilayer.map.detectLayer")
    detectLayer:createLayer(buildServerData,playerData,guildData,mapConfigData)
end


--攻击城市（测）
function onClick_114(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
	battleManager.gotoAttack({ buildServerData = buildServerData })
end


--宣战(集结)（测 89服务端报错）
function onClick_115(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    battleManager.gotoGather( {buildServerData = buildServerData} )
end


function onClick_116(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    print("onClick_116")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    g_sceneManager.addNodeForUI(require("game.uilayer.map.mapPlayerInfoView"):create( playerData.id ))
end


function onClick_117(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    print("城池增益")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local cityBufferLayer = require("game.uilayer.map.cityBufferLayer")
    cityBufferLayer:createLayer()
end


function onClick_118(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	require("game.maplayer.changeMapScene").changeToHome()
end


function onClick_119(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    --士兵援助
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.gotoSendArmy( {buildServerData = buildServerData,playerData = playerData} )
end

--联盟资源采集黄金
function onClick_120(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.gold) == nil then
		g_airBox.show(g_tr("worldmap_not_gold"), 2)
		return
	end
    battleManager.gotoBuildGuild({ buildServerData = buildServerData })
end

--联盟资源采集粮食
function onClick_121(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.food) == nil then
		g_airBox.show(g_tr("worldmap_not_food"), 2)
		return
	end
    battleManager.gotoBuildGuild({ buildServerData = buildServerData })
end

--联盟资源采集木头
function onClick_122(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.wood) == nil then
		g_airBox.show(g_tr("worldmap_not_wood"), 2)
		return
	end
	battleManager.gotoBuildGuild({ buildServerData = buildServerData })
end

--联盟资源采集石头
function onClick_123(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.stone) == nil then
		g_airBox.show(g_tr("worldmap_not_stone"), 2)
		return
	end
	battleManager.gotoBuildGuild({ buildServerData = buildServerData })
end

--联盟资源采集铁矿
function onClick_124(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.iron) == nil then
		g_airBox.show(g_tr("worldmap_not_iron"), 2)
		return
	end
    battleManager.gotoBuildGuild({ buildServerData = buildServerData })
end


--返回
function onClick_125(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function callbackStayQueue()
		local function onRecv(result, msgData)
			g_busyTip.hide_1()
			if(result==true)then
				require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
			end
		end
		local queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING)
		if queueSD then
			g_busyTip.show_1()
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
			return
		end
		queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_CITYASSIST_ING)
		if queueSD then
			g_busyTip.show_1()
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
			return
		end
		queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_GUILDBASE_BUILD)
		if queueSD then
			g_busyTip.show_1()
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
			return
		end
		queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_GUILDBASE_REPAIR)
		if queueSD then
			g_busyTip.show_1()
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
			return
		end
		queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_GUILDBASE_DEFEND)
		if queueSD then
			g_busyTip.show_1()
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
			return
		end
		queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_GUILDWAREHOUSE_BUILD)
		if queueSD then
			g_busyTip.show_1()
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
			return
		end
		queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_GUILDTOWER_BUILD)
		if queueSD then
			g_busyTip.show_1()
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
			return
		end
		queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_BUILD)
		if queueSD then
			g_busyTip.show_1()
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
			return
		end
		queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_GUILDCOLLECT_ING)
		if queueSD then
			g_busyTip.show_1()
			g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
			return
		end
	end
	callbackStayQueue()
end


function onClick_126(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    onClick_107(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
end


function onClick_127(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.manor.AllianceManorResource"):create(1,buildServerData))
end


function onClick_128(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.manor.AllianceManorResource"):create(2,buildServerData))
end


--集结
function onClick_129(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)

end


function onClick_130(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)

end


function onClick_131(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)

end


function onClick_132(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)

end


--迁城
function onClick_133(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local function onMoveCity(bti)
		local function onRecv(result, msgData)
			if(result==true)then
				require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
				require("game.maplayer.worldMapLayer_bigMap").playRebuild()
			end
		end
		--type : 1指定 2随机 3联盟
		local t = (g_gameTools.canUseUnionMoveCity(bti) and 3 or 1)
		g_sgHttp.postData("map/changeCastleLocation",{ type = t , x = bti.x , y = bti.y },onRecv,true)
	end
	require("game.maplayer.worldMapLayer_bigMap").openInputMenu_moveCity(bigTileIndex, onMoveCity, nil)
end


--召回
function onClick_134(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.gotoBackQueue({ queueServerData = queueServerData })
end


function onClick_135(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    --print("onClick_135")
    --dump(queueServerData.id)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if queueServerData and queueServerData.id then
        local fightingInfoLayer = require("game.uilayer.map.fightingInfoLayer")
        fightingInfoLayer:createLayer(queueServerData.id)
    end
end


--队列加速
function onClick_136(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    --local UseOnlyPowerLayer = require("game.uilayer.publicMode.UseOnlyPowerLayer"):create(queueServerData)
    --g_sceneManager.addNodeForUI(UseOnlyPowerLayer)
    battleManager.speedDialog( { queueServerData = queueServerData} )


end


function onClick_137(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
  --放置联盟建筑
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
  local function inputHandler(map_element_id,type)
      print("input Handler")
      local successHandler = function(bigTileIndexSelected)
          g_allianceManorData.RequestCreateGuildBuild(bigTileIndexSelected.x,bigTileIndexSelected.y,map_element_id,type)
      end
      
      local cancleHandler = function()
          
      end
      
      --require("game.maplayer.worldMapLayer_bigMap").openInputMenu_build(map_element_id, bigTileIndex, 成功回调-有参数为bigTileIndex , 取消回调)
      require("game.maplayer.worldMapLayer_bigMap").openInputMenu_build(map_element_id, bigTileIndex,successHandler, cancleHandler)
  end
  
  local allianceManorLayer = require("game.uilayer.alliance.manor.AllianceManorLayer"):create(inputHandler)
  g_sceneManager.addNodeForUI(allianceManorLayer)
end


--攻击资源
function onClick_138(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    --判断是否有保护
    battleManager.battleHasAvoidMsgShow(function ()
        battleManager.gotoCollect({buildServerData = buildServerData})
    end)
end


--攻击王城
function onClick_139(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
   g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
	--王城不能攻击,已作废
end


--攻击多人怪物
function onClick_140(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    print("onClick_140")
	--多人怪物没有菜单,已作废
end


--攻击小营寨
function onClick_141(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    battleManager.gotoBattleTown({ buildServerData = buildServerData })
end

--小营寨(宣战集结)
function onClick_142(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    battleManager.gotoGather({buildServerData = buildServerData})
end

--小营斋查看
function onClick_143(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    print("onClick_143")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.showTown( { buildServerData = buildServerData,guildData = guildData } )
end

--小营寨驻守
function onClick_144(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    battleManager.gotoGarrison({buildServerData = buildServerData})
end

--小营寨返回
function onClick_145(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function onRecv(result, msgData)
		g_busyTip.hide_1()
		if(result==true)then
			require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
		end
	end
    local queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_KINGTOWN_DEFENCE)
	if queueSD then
		g_busyTip.show_1()
		g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv)
		return
	end
	queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCE)
	if queueSD then
		g_busyTip.show_1()
		g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv)
		return
	end
	queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCEASIST)
	if queueSD then
		g_airBox.show(g_tr("queue_back_error_1"))
		return
	end
end

--小营寨侦查
function onClick_146(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    local detectLayer = require("game.uilayer.map.detectLayer")
    detectLayer:createLayer(buildServerData,playerData,guildData,mapConfigData)
end

--攻击中营寨
function onClick_147(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    battleManager.gotoBattleTown({ buildServerData = buildServerData })
end

--中营寨(宣战集结)
function onClick_148(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    
    g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    battleManager.gotoGather({buildServerData = buildServerData})

end

--中营寨查看
function onClick_149(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    battleManager.showTown( { buildServerData = buildServerData,guildData = guildData } )
end

--中营寨驻守
function onClick_150(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    battleManager.gotoGarrison({buildServerData = buildServerData})
end

--中营寨返回
function onClick_151(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	local function onRecv(result, msgData)
		g_busyTip.hide_1()
		if(result==true)then
			require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
		end
	end
    local queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_KINGTOWN_DEFENCE)
	if queueSD then
		g_busyTip.show_1()
		g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv)
		return
	end
	queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCE)
	if queueSD then
		g_busyTip.show_1()
		g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv)
		return
	end
	queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_KINGGATHERBATTLE_DEFENCEASIST)
	if queueSD then
		g_airBox.show(g_tr("queue_back_error_1"))
		return
	end
end

--中营寨（侦查）
function onClick_152(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_data.sounds[5000041].sounds_path)
    local detectLayer = require("game.uilayer.map.detectLayer")
    detectLayer:createLayer(buildServerData,playerData,guildData,mapConfigData)
end

--集结部队的未集合部队的详情
function onClick_153(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    --print("onClick_153")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if queueServerData and queueServerData.id then
        local fightingInfoLayer = require("game.uilayer.map.fightingInfoLayer")
        fightingInfoLayer:createLayer(queueServerData.id)
    end
end

--王城详情
function onClick_154(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    --print("onClick_154")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingInfoLayer"):create())

end

--国王选举
function onClick_155(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    print("onClick_155")
    --local kingWarData = g_kingInfo.GetData()
    if g_kingInfo.isKingBattleStarted() then
        g_airBox.show(g_tr("kwar_battleing"))
        return
    end
    
    g_busyTip.show_1()
    g_kingInfo.RequestData_Async( function (result,msgData)
        g_busyTip.hide_1()
        if result == true then
            g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingEnthroneLayer"):create())
        end
    end )

    --if g_kingInfo.RequestData() then
    --g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingEnthroneLayer"):create())
    --end



    --if kingWarData.status == g_Consts.KingWarStatusType.Enthrone then
        --登基
        --local kingEnthroneLayer = require("game.uilayer.kingWar.kingEnthroneLayer")
        --kingEnthroneLayer:createLayer()
    --else
        --local kingPromotedLayer = require("game.uilayer.kingWar.kingPromotedLayer")
        --kingPromotedLayer:createLayer()
    --end

    --local kingPromotedLayer = require("game.uilayer.kingWar.kingPromotedLayer")
    --kingPromotedLayer:createLayer()

end

--王城详情
function onClick_156(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    print("onClick_156")
    g_sceneManager.addNodeForUI(require("game.uilayer.kingWar.kingInfoLayer"):create())
end


--邀请迁城
function onClick_157(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    print("onClick_157")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local m_bigTileIndexSelected = nil
    local function inviteHandler(playerInfo)
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        if m_bigTileIndexSelected and playerInfo then
            local resultHandler = function(result, msgData)
                if result then
                    g_airBox.show(g_tr("allianceInviteMoveBuildSuccess"))
                end
            end
            g_sgHttp.postData("Guild/inviteChangeCastleLocation",{target_player_id = playerInfo.player_id,x = m_bigTileIndexSelected.x,y = m_bigTileIndexSelected.y},resultHandler)
        end
    end
    
    local map_element_id = 1501 --1级城堡ID
    local successHandler = function(bigTileIndexSelected)
        m_bigTileIndexSelected = bigTileIndexSelected
        g_sceneManager.addNodeForUI(require("game.uilayer.alliance.AlliancePlayerManageLayer"):create(inviteHandler,m_bigTileIndexSelected))
    end
    
    local cancleHandler = function()
        
    end
    
    require("game.maplayer.worldMapLayer_bigMap").openInputMenu_invite(map_element_id, bigTileIndex,successHandler, cancleHandler)
end

function onClick_158(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if buildServerData then
        local mapResGetInfoLayer = require("game.uilayer.map.mapResGetInfoLayer")
        --dump(buildServerData)
        mapResGetInfoLayer:createLayer(buildServerData.id)
    end
end

--据点占领
function onClick_159(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    print("onClick_159")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if buildServerData == nil then
        return
    end
    battleManager.battleHasAvoidMsgShow(function ()
        
        battleManager.gotoCollect({ buildServerData = buildServerData},g_Consts.FightCostPowerType.CostJudian )
    end)
end

--据点返回
function onClick_160(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

    local function onRecv(result, msgData)
		g_busyTip.hide_1()
		if(result==true)then
			require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
		end
	end
    
    local queueSD = require "game.maplayer.worldMapLayer_bigMap".getSelfQueueDoing_bigTileIndex_queueType(buildServerData.id, QueueHelperMD.QueueTypes.TYPE_COLLECT_ING)
	if queueSD then
        g_busyTip.show_1()
		g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueSD.id },onRecv,true)
		return
	end
	
end
--据点说明
function onClick_161(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

    if mapConfigData == nil then
        return
    end

    local resInfoLayer = require("game.uilayer.map.resInfoLayer")
    resInfoLayer:createLayer(mapConfigData.id)
        --g_sceneManager.addNodeForUI(resInfoLayer:create(mapConfigData.id))


    print("onClick_161")
end
--据点侦查
function onClick_162(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    print("onClick_162")
    local detectLayer = require("game.uilayer.map.detectLayer")
    detectLayer:createLayer(buildServerData,playerData,guildData,mapConfigData)
end
--据点领主详情
function onClick_163(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    print("onClick_163")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    g_sceneManager.addNodeForUI(require("game.uilayer.map.mapPlayerInfoView"):create( playerData.id ))
end
--查看详情
function onClick_164(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if buildServerData == nil then
        return
    end

    local mapResGetInfoLayer = require("game.uilayer.map.mapResGetInfoLayer")
    --dump(buildServerData)
    mapResGetInfoLayer:createLayer(buildServerData.id,true)
    
    print("onClick_164")
end

--敌方说明状态   积分高
function onClick_165(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_165")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    require("game.uilayer.common.HelpInfoBox"):show(21)
	
end

--敌方说明状态   积分低
function onClick_166(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_166")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    require("game.uilayer.common.HelpInfoBox"):show(20)
end


function onClick_167(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_167")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    require("game.uilayer.common.HelpInfoBox"):show(22)
end


return worldMapLayer_smallMenuClick