local worldMapLayer_smallMenuClick = {}
setmetatable(worldMapLayer_smallMenuClick,{__index = _G})
setfenv(1,worldMapLayer_smallMenuClick)


local QueueHelperMD = require "game.mapguildwar.worldMapLayer_queueHelper"
local HelperMD = require "game.mapguildwar.worldMapLayer_helper"
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

--领主详情
function onClick_112(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_112")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    --dump(playerData)
    --dump(queueServerData)
    if buildServerData then
        local guildWarInfo = require("game.uilayer.map.guildWarInfo")
        g_sceneManager.addNodeForUI(guildWarInfo:create(buildServerData.x,buildServerData.y))
    end
end

--侦查
function onClick_113(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_113")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    if buildServerData then
        local guildWarInfo = require("game.uilayer.map.guildWarInfo")
        g_sceneManager.addNodeForUI(guildWarInfo:create(buildServerData.x,buildServerData.y))
    end
end

--攻击
function onClick_114(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_114")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoAttack2GuildWar({ buildServerData = buildServerData })
end

--我的详情
function onClick_116(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_116")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    dump(playerData)

end

--城市增益
function onClick_117(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_117")
end

--进入城池
function onClick_118(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_118")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	require("game.mapguildwar.changeMapScene").changeToHome()
end

--召回
function onClick_134(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoBackQueue({ queueServerData = queueServerData })
end

function onClick_135(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	--print("onClick_135")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	if queueServerData and queueServerData.id then
		local fightingInfoLayer = require("game.uilayer.map.fightingInfoLayer")
		fightingInfoLayer:createLayer(queueServerData.id)
	end
end

--队列加速
function onClick_136(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	print("onClick_136")
    battleManager.speedDialog( { queueServerData = queueServerData} )
end

--驻守	攻城锤
function onClick_168(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_168")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoAttack2GuildWar({ buildServerData = buildServerData })
end

--驻守详情	攻城锤	
function onClick_169(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_169")
    if buildServerData then
        local guildWarInfo = require("game.uilayer.map.guildWarInfo")
        g_sceneManager.addNodeForUI(guildWarInfo:create(buildServerData.x,buildServerData.y))
    end
end

--召回	攻城锤
function onClick_170(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_170")
	battleManager.gotoBackStayQueue(buildServerData.id,QueueHelperMD.QueueTypes.TYPE_HAMMER_ING)
end

--说明	攻城锤
function onClick_171(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_171")
    dump(mapConfigData)
    require("game.uilayer.common.HelpInfoBox"):show( tonumber(mapConfigData.help_type_id))
end

--攻击	城门
function onClick_172(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	--print("onClick_172")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoAttack2GuildWar({ buildServerData = buildServerData })
end

--说明	城门
function onClick_173(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_173")
    require("game.uilayer.common.HelpInfoBox"):show( tonumber(mapConfigData.help_type_id))
end

--驻守	床弩
function onClick_174(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_174")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoAttack2GuildWar({ buildServerData = buildServerData })
end

--驻守详情	床弩
function onClick_175(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_175")
    if buildServerData then
        local guildWarInfo = require("game.uilayer.map.guildWarInfo")
        g_sceneManager.addNodeForUI(guildWarInfo:create(buildServerData.x,buildServerData.y))
    end
end

--召回	床弩
function onClick_176(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_176")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoBackStayQueue(buildServerData.id,QueueHelperMD.QueueTypes.TYPE_CROSSBOW_ING)
end

--说明	床弩
function onClick_177(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_177")
    require("game.uilayer.common.HelpInfoBox"):show( tonumber(mapConfigData.help_type_id))
end

--驻守	云梯
function onClick_178(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_178")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoAttack2GuildWar({ buildServerData = buildServerData })
end

--驻守详情	云梯
function onClick_179(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_179")
    if buildServerData then
        local guildWarInfo = require("game.uilayer.map.guildWarInfo")
        g_sceneManager.addNodeForUI(guildWarInfo:create(buildServerData.x,buildServerData.y))
    end
end

--召回	云梯
function onClick_180(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_180")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoBackStayQueue(buildServerData.id,QueueHelperMD.QueueTypes.TYPE_LADDER_ING)
end

--说明	云梯
function onClick_181(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_181")
    require("game.uilayer.common.HelpInfoBox"):show( tonumber(mapConfigData.help_type_id))
end

--驻守	投石车
function onClick_182(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_182")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoAttack2GuildWar({ buildServerData = buildServerData })
end

--驻守详情	投石车
function onClick_183(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_183")
    if buildServerData then
        local guildWarInfo = require("game.uilayer.map.guildWarInfo")
        g_sceneManager.addNodeForUI(guildWarInfo:create(buildServerData.x,buildServerData.y))
    end
end

--召回	投石车
function onClick_184(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_184")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoBackStayQueue(buildServerData.id,QueueHelperMD.QueueTypes.TYPE_CATAPULT_ING)
end

--说明	投石车
function onClick_185(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_185")
    require("game.uilayer.common.HelpInfoBox"):show( tonumber(mapConfigData.help_type_id))
end

--攻击	投石车
function onClick_186(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_186")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoAttack2GuildWar({ buildServerData = buildServerData })
end

--攻击	大本营
function onClick_187(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_187")
	g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	battleManager.gotoAttack2GuildWar({ buildServerData = buildServerData })
end

--说明	大本营
function onClick_188(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_188")
    require("game.uilayer.common.HelpInfoBox"):show( tonumber(mapConfigData.help_type_id))
end

--敌军详情 老家的
function onClick_189(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_189")
    if buildServerData then
        local guildWarInfo = require("game.uilayer.map.guildWarInfo")
        g_sceneManager.addNodeForUI(guildWarInfo:create(buildServerData.x,buildServerData.y))
    end
end

--说明	老家的
function onClick_190(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_190")
    require("game.uilayer.common.HelpInfoBox"):show( tonumber(mapConfigData.help_type_id))
end

--我的军团	老家的
function onClick_191(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_191")
    g_sceneManager.addNodeForUI(require("game.uilayer.drill.CrossDrillView").new(callback))
end

--迁城	老家的
function onClick_192(mapConfigData , buildServerData , queueServerData , playerData , guildData , bigTileIndex)
	print("onClick_192")
  require("game.uilayer.guildwar.GuildWarFuHuoDianLayer").show()
end

return worldMapLayer_smallMenuClick