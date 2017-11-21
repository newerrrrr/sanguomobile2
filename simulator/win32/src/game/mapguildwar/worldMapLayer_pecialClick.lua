local worldMapLayer_pecialClick = {}
setmetatable(worldMapLayer_pecialClick,{__index = _G})
setfenv(1,worldMapLayer_pecialClick)


--点击保存坐标
--bigTileIndex: 	坐标
--mapConfigData: 	Map_Element配置(空地没有)
--buildServerData:	建筑服务器数据(空地没有)
function onClick_SaveIndex(bigTileIndex, mapConfigData, buildServerData)
		local collectLayer = require("game.uilayer.map.collectLayer")
		collectLayer:createLayer(bigTileIndex,mapConfigData,buildServerData)
end



--点击小怪
--mapConfigData: 	Map_Element配置
--buildServerData: 	本地缓存的服务器map数据
function onClick_SmallMonster(mapConfigData, buildServerData)
		
		if buildServerData == nil then
				return
		end

		local function bettleNpc()
				local function gotoAttackNpc(ArmyID,PlaySound,isUseMove)
				local function onRecv(result, msgData)
								g_busyTip.hide_1()
					if(result==true)then
						require "game.mapguildwar.worldMapLayer_bigMap".requestMapAllData_Manual()
										if PlaySound then
												PlaySound()
										end
					end
				end
				
				--新手引导
				local quickMove = nil
				if g_guideManager.getLastShowStep() then
						quickMove = 1
				end
				g_busyTip.show_1()
				g_sgHttp.postData("map/gotoAttackNpc",{ x = buildServerData.x , y = buildServerData.y , armyId = ArmyID , useMove = isUseMove,quickMove = quickMove },onRecv,true)
				
				if quickMove then
						g_guideManager.execute()
				end
			end

				local setLayer = require("game.uilayer.battleSet.battleSettingView")
				setLayer:setUsePowerType(g_Consts.FightCostPowerType.CostNpc)
				setLayer:createLayer(gotoAttackNpc,{ x = buildServerData.x , y = buildServerData.y },g_Consts.FightType.Monster)
		end

		local mapBuildInfoLayer = require("game.uilayer.map.mapBuildInfoLayer")
		g_sceneManager.addNodeForUI(mapBuildInfoLayer.create(buildServerData,bettleNpc))


end



--点击boss怪
--mapConfigData: 	Map_Element配置
--buildServerData: 	本地缓存的服务器map数据
function onClick_BossMonster(mapConfigData, buildServerData)

		if buildServerData == nil then
				return
		end


		--进攻
		local function bettleNpc()
				local function gotoAttackNpc(ArmyID,PlaySound,isUseMove)
				local function onRecv(result, msgData)
					if(result==true)then
						require "game.mapguildwar.worldMapLayer_bigMap".requestMapAllData_Manual()
										if PlaySound then
												PlaySound()
										end
					end
				end
						g_busyTip.show_1()
				g_sgHttp.postData("map/gotoAttackNpc",{ x = buildServerData.x , y = buildServerData.y , armyId = ArmyID,useMove = isUseMove },onRecv)

			end

				local setLayer = require("game.uilayer.battleSet.battleSettingView")
				setLayer:createLayer(gotoAttackNpc,{ x = buildServerData.x , y = buildServerData.y },g_Consts.FightType.Monster)
		end
		--集结
		local function assembleBettleNpc()
				
				--选择时间TYPE
				local muster_time_type = 0

				local function gotoCollection(ArmyID,PlaySound)
						local function onRecv(result, msgData)
								g_busyTip.hide_1()
					if(result==true)then
										--完成集结
						require "game.mapguildwar.worldMapLayer_bigMap".requestMapAllData_Manual()
										if PlaySound then
												PlaySound()
										end
					end
				end
						g_sgHttp.postData("map/startGather",{ x = buildServerData.x , y = buildServerData.y , armyId = ArmyID,time = muster_time_type },onRecv,true)
				end
				
				local BattleCollectTimeView = require("game.uilayer.battleHall.BattleCollectTimeView")
				local view = BattleCollectTimeView:create(
						function (timeType)
								muster_time_type = timeType
								--选择队伍
								local setLayer = require("game.uilayer.battleSet.battleSettingView")
								setLayer:setUsePowerType(g_Consts.FightCostPowerType.CostTeam)
								setLayer:createLayer(gotoCollection,{x = buildServerData.x , y = buildServerData.y},g_Consts.FightType.Monster,true)

						end)
				g_sceneManager.addNodeForUI( view )
		end


		local mapBuildInfoLayer = require("game.uilayer.map.mapBuildInfoLayer")
		g_sceneManager.addNodeForUI(mapBuildInfoLayer.create( buildServerData,bettleNpc,assembleBettleNpc))

end


--点击和氏璧
--mapConfigData: 	Map_Element配置
--buildServerData: 	本地缓存的服务器map数据
function onClick_Heshibi(mapConfigData, buildServerData)
		
	if buildServerData == nil then
				return
		end

		local function sendBattle()
				local function bettleNpc()
						local function onRecv(result , data)
								if result == true then
						require "game.mapguildwar.worldMapLayer_bigMap".requestMapAllData_Manual()
								end
						end
						g_sgHttp.postData("map/gotoFetchItem",{ x = buildServerData.x , y = buildServerData.y	},onRecv)
				end
		
				local mapBuildInfoLayer = require("game.uilayer.map.mapBuildInfoLayer")
				g_sceneManager.addNodeForUI(mapBuildInfoLayer.create( buildServerData,bettleNpc))
		end

		--提示破保护
		require("game.uilayer.battleSet.battleManager").battleHasAvoidMsgShow(sendBattle)

end



return worldMapLayer_pecialClick