local mainSurfaceModeShow = {}
setmetatable(mainSurfaceModeShow,{__index = _G})
setfenv(1,mainSurfaceModeShow)

function mainScrfaceChangeView()
    
	local viewPlayer = require("game.uilayer.mainSurface.mainSurfacePlayer")
	local viewChat = require("game.uilayer.mainSurface.mainSurfaceChat")
	local viewMenu = require("game.uilayer.mainSurface.mainSurfaceMenu")
	local viewQueue = require("game.uilayer.mainSurface.mainSurfaceQueue")
	local viewQueueWorld = require("game.uilayer.mainSurface.mainSurfaceQueueWorld")
	local viewPosition = require("game.uilayer.mainSurface.mainSurfacePosition")
	local viewKingWar = require("game.uilayer.mainSurface.mainKingWarLayer")
	local viewEventBar = require("game.uilayer.mainSurface.mainSurfaceEventBar") 
	local viewAllianceInvite = require("game.uilayer.mainSurface.mainSurfaceAllianceInvite") 

	viewPlayer.viewChangeShow()
	viewChat.viewChangeShow()
	viewMenu.viewChangeShow()
	viewQueue.viewChangeShow()
	viewQueueWorld.viewChangeShow()
	viewPosition.viewChangeShow()
	viewKingWar.viewChangeShow()
	viewEventBar.viewChangeShow()
	viewAllianceInvite.viewChangeShow()
	require("game.mapguildwar.worldMapLayer_uiLayer").viewChangeShow()
	require("game.mapcitybattle.worldMapLayer_uiLayer").viewChangeShow()
	require("game.uilayer.mainSurface.mainSurfaceMerryGoRound").viewChangeShow()
	
end

return mainSurfaceModeShow