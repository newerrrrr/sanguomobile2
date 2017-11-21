local sceneManager = {}
setmetatable(sceneManager,{__index = _G})
setfenv(1,sceneManager)


--有新的场景可以在此加入
sceneMode = {
	unknou = 0,
	login = 1,
	cg = 2,
	clear = 3,
	loading = 4,
	game = 5,
}

local mLastSceneMode = sceneMode.unknou
local mCurrentSceneMode = sceneMode.unknou


--在这里加入进入场景后立刻显示的地图,没有必要加zorder
local function onAddLayerForMap( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_map type:",mode_cur)
	
	if(mode_cur == sceneMode.login)then
	
		g_musicManager.playMusic(g_data.sounds[5000001].sounds_path,true)
	
	elseif(mode_cur == sceneMode.cg)then
		
		g_musicManager.playMusic(g_data.sounds[5000003].sounds_path,true)
		
	elseif(mode_cur == sceneMode.clear)then
	
	
	elseif(mode_cur == sceneMode.loading)then
	
	
	elseif(mode_cur == sceneMode.game)then
	
		--加入游戏地图
		require("game.maplayer.changeMapScene").changeToHome(true) --第一次加入才初始化

	end
end

--在这里加入进入场景后立刻显示的surface,没有必要加zorder
local function onAddLayerForSurface( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_surface type:",mode_cur)
	
	if(mode_cur == sceneMode.login)then

	elseif(mode_cur == sceneMode.cg)then
	
		
	elseif(mode_cur == sceneMode.clear)then
		
		
	elseif(mode_cur == sceneMode.loading)then
	
		
	elseif(mode_cur == sceneMode.game)then
		
		--加入游戏主界面
		parent:addChild(require("game.uilayer.mainSurface.mainSurfaceMerryGoRound").create())
		parent:addChild(require("game.uilayer.mainSurface.mainSurfaceMenu").create())
		parent:addChild(require("game.uilayer.mainSurface.mainSurfaceChat").create())
		parent:addChild(require("game.uilayer.mainSurface.mainSurfacePlayer").create())
		parent:addChild(require("game.uilayer.mainSurface.mainSurfaceQueue").create())
	 
		parent:addChild(require("game.uilayer.mainSurface.mainSurfacePosition").create())
		parent:addChild(require("game.uilayer.mainSurface.mainSurfaceQueueWorld").create())
		--parent:addChild(require("game.uilayer.mainSurface.mainSurfaceQuickLink").create()) --事件调代替
		parent:addChild(require("game.uilayer.mainSurface.mainSurfaceEventBar").create())
		parent:addChild(require("game.uilayer.mainSurface.mainSurfaceAllianceInvite").create())
		
		parent:addChild(require("game.mapguildwar.worldMapLayer_uiLayer").create())
		parent:addChild(require("game.mapcitybattle.worldMapLayer_uiLayer").create())
		
	end
end

--在这里加入进入场景后立刻显示的ui,没有必要加zorder
local function onAddLayerForUI( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_ui type:",mode_cur)
	
	if(mode_cur == sceneMode.login)then
		
		local loginLayer = require("game.uilayer.regist.LoginLayer"):create()
		parent:addChild(loginLayer)
		loginLayer:onClickAccountManagerHandler()

	elseif(mode_cur == sceneMode.cg)then
			
		parent:addChild(require("game.uilayer.CG.CGLayer").create())
		
	elseif(mode_cur == sceneMode.clear)then
		
		parent:addChild(require("game.uilayer.clear.clearLayer").create(mode_last))
		
	elseif(mode_cur == sceneMode.loading)then
	
		parent:addChild(require("game.uilayer.loading.loading").create())
		
	elseif(mode_cur == sceneMode.game)then
		
	end
end


--在这里加入进入场景后立刻显示的msgBox,没有必要加zorder
local function onAddLayerForMsgBox( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_msgBox type:",mode_cur)
	
	if(mode_cur == sceneMode.login)then
		parent:addChild(require("game.msgboxlayer.msgLevelTouchEvent").create())
	elseif(mode_cur == sceneMode.cg)then
		parent:addChild(require("game.msgboxlayer.msgLevelTouchEvent").create())
	elseif(mode_cur == sceneMode.clear)then
		parent:addChild(require("game.msgboxlayer.msgLevelTouchEvent").create())
	elseif(mode_cur == sceneMode.loading)then
		parent:addChild(require("game.msgboxlayer.msgLevelTouchEvent").create())
	elseif(mode_cur == sceneMode.game)then
		parent:addChild(require("game.msgboxlayer.msgLevelTouchEvent").create())
	end
end


--在这里加入进入场景后立刻显示的全场景effect,没有必要加zorder
local function onAddLayerForSceneEffect( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_sceneEffect type:",mode_cur)
	
	if(mode_cur == sceneMode.login)then
	
	elseif(mode_cur == sceneMode.cg)then
	
	elseif(mode_cur == sceneMode.clear)then
	
	elseif(mode_cur == sceneMode.loading)then
	
	elseif(mode_cur == sceneMode.game)then
		parent:addChild(require("game.effectlayer.screenFire").create())
	end
end


--在这里加入进入场景后立刻显示的全场景最顶层effect(只有过场动画在这一层),没有必要加zorder
local function onAddLayerForTopEffect( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_topEffect type:",mode_cur)
	
	if(mode_cur == sceneMode.login)then
	
	elseif(mode_cur == sceneMode.cg)then
	
	elseif(mode_cur == sceneMode.clear)then
	
	elseif(mode_cur == sceneMode.loading)then
	
	elseif(mode_cur == sceneMode.game)then
	
	end
end


--在这里加入进入场景后立刻显示的新手引导显示层
local function onAddLayerForGuideDisplay( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_guideDisplay type:",mode_cur)
	
	if(mode_cur == sceneMode.login)then
	
	elseif(mode_cur == sceneMode.cg)then
	
	elseif(mode_cur == sceneMode.clear)then
	
	elseif(mode_cur == sceneMode.loading)then
	
	elseif(mode_cur == sceneMode.game)then
	
	end
end


--在这里加入进入场景后立刻显示的新手引导mask层
local function onAddLayerForGuideMask( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_guideMask type:",mode_cur)
	
	if(mode_cur == sceneMode.login)then
	
	elseif(mode_cur == sceneMode.cg)then
	
	elseif(mode_cur == sceneMode.clear)then
	
	elseif(mode_cur == sceneMode.loading)then
	
	elseif(mode_cur == sceneMode.game)then
	
	end
end


--在这里加入进入场景后立刻显示的topMsgBox,没有必要加zorder
local function onAddLayerForTopMsgBox( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_topMsgBox type:",mode_cur)
	
	if(mode_cur == sceneMode.login)then
	
	elseif(mode_cur == sceneMode.cg)then
	
	elseif(mode_cur == sceneMode.clear)then
	
	elseif(mode_cur == sceneMode.loading)then
	
	elseif(mode_cur == sceneMode.game)then
	
	end
end


local function onAddLayerForWebView( mode_cur , mode_last , parent , deliver )
	print("onAddLayer_for_webView type:",mode_cur)
		
	if(mode_cur == sceneMode.login)then
	
	elseif(mode_cur == sceneMode.cg)then
	
	elseif(mode_cur == sceneMode.clear)then
	
	elseif(mode_cur == sceneMode.loading)then
	
	elseif(mode_cur == sceneMode.game)then
	
	end
end


local mSceneLayer = nil

local mMapRoot = nil
local mSurfaceRoot = nil
local mUIRoot = nil
local mMsgBoxRoot = nil
local mSceneEffectRoot = nil
local mTopEffectRoot = nil
local mGuideDisplayRoot = nil
local mGuideMaskRoot = nil
local mTopMsgBoxRoot = nil
local mWebViewRoot = nil



--切换场景
function setScene(mode, deliver )
	
	if(mSceneLayer)then--如果需要场景切换效果 这句话应该不保留
		mSceneLayer:removeFromParent()
	end
	
	mLastSceneMode = mCurrentSceneMode
	mCurrentSceneMode = mode
	
	mMapRoot = cc.Node:create()
	mMapRoot:ignoreAnchorPointForPosition(false)
	mMapRoot:setAnchorPoint(cc.p(0.5,0.5))
	mMapRoot:setPosition(g_display.center)
	mMapRoot:setContentSize(g_display.size)
	
	mSurfaceRoot = cc.Node:create()
	mSurfaceRoot:ignoreAnchorPointForPosition(false)
	mSurfaceRoot:setAnchorPoint(cc.p(0.5,0.5))
	mSurfaceRoot:setPosition(g_display.center)
	mSurfaceRoot:setContentSize(g_display.size)
	
	mUIRoot = cc.Node:create()
	mUIRoot:ignoreAnchorPointForPosition(false)
	mUIRoot:setAnchorPoint(cc.p(0.5,0.5))
	mUIRoot:setPosition(g_display.center)
	mUIRoot:setContentSize(g_display.size)
	
	mMsgBoxRoot = cc.Node:create()
	mMsgBoxRoot:ignoreAnchorPointForPosition(false)
	mMsgBoxRoot:setAnchorPoint(cc.p(0.5,0.5))
	mMsgBoxRoot:setPosition(g_display.center)
	mMsgBoxRoot:setContentSize(g_display.size)
	
	mSceneEffectRoot = cc.Node:create()
	mSceneEffectRoot:ignoreAnchorPointForPosition(false)
	mSceneEffectRoot:setAnchorPoint(cc.p(0.5,0.5))
	mSceneEffectRoot:setPosition(g_display.center)
	mSceneEffectRoot:setContentSize(g_display.size)
	
	mTopEffectRoot = cc.Node:create()
	mTopEffectRoot:ignoreAnchorPointForPosition(false)
	mTopEffectRoot:setAnchorPoint(cc.p(0.5,0.5))
	mTopEffectRoot:setPosition(g_display.center)
	mTopEffectRoot:setContentSize(g_display.size)
	
	mGuideDisplayRoot = cc.Node:create()
	mGuideDisplayRoot:ignoreAnchorPointForPosition(false)
	mGuideDisplayRoot:setAnchorPoint(cc.p(0.5,0.5))
	mGuideDisplayRoot:setPosition(g_display.center)
	mGuideDisplayRoot:setContentSize(g_display.size)
	
	mGuideMaskRoot = cc.Node:create()
	mGuideMaskRoot:ignoreAnchorPointForPosition(false)
	mGuideMaskRoot:setAnchorPoint(cc.p(0.5,0.5))
	mGuideMaskRoot:setPosition(g_display.center)
	mGuideMaskRoot:setContentSize(g_display.size)
	
	mTopMsgBoxRoot = cc.Node:create()
	mTopMsgBoxRoot:ignoreAnchorPointForPosition(false)
	mTopMsgBoxRoot:setAnchorPoint(cc.p(0.5,0.5))
	mTopMsgBoxRoot:setPosition(g_display.center)
	mTopMsgBoxRoot:setContentSize(g_display.size)
	
	mWebViewRoot = cc.Node:create()
	mWebViewRoot:ignoreAnchorPointForPosition(false)
	mWebViewRoot:setAnchorPoint(cc.p(0.5,0.5))
	mWebViewRoot:setPosition(g_display.center)
	mWebViewRoot:setContentSize(g_display.size)
	
	mSceneLayer = cc.Layer:create()
	mSceneLayer:ignoreAnchorPointForPosition(false)
	mSceneLayer:setAnchorPoint(cc.p(0.5,0.5))
	mSceneLayer:setPosition(g_display.center)
	
	mSceneLayer:addChild(mMapRoot,1)
	mSceneLayer:addChild(mSurfaceRoot,2)
	mSceneLayer:addChild(mUIRoot,3)
	mSceneLayer:addChild(mMsgBoxRoot,4)
	mSceneLayer:addChild(mSceneEffectRoot,5)
	mSceneLayer:addChild(mTopEffectRoot,6)
	mSceneLayer:addChild(mGuideDisplayRoot,7)
	mSceneLayer:addChild(mGuideMaskRoot,8)
	mSceneLayer:addChild(mTopMsgBoxRoot,9)
	mSceneLayer:addChild(mWebViewRoot,10)
	
	local newScene = cc.Scene:create()
	newScene:addChild(mSceneLayer)
	
	onAddLayerForMap(mode,mLastSceneMode,mMapRoot,deliver)
	onAddLayerForSurface(mode,mLastSceneMode,mSurfaceRoot,deliver)
	onAddLayerForUI(mode,mLastSceneMode,mUIRoot,deliver)
	onAddLayerForMsgBox(mode,mLastSceneMode,mMsgBoxRoot,deliver)
	onAddLayerForSceneEffect(mode,mLastSceneMode,mSceneEffectRoot,deliver)
	onAddLayerForTopEffect(mode,mLastSceneMode,mTopEffectRoot,deliver)
	onAddLayerForGuideDisplay(mode,mLastSceneMode,mGuideDisplayRoot,deliver)
	onAddLayerForGuideMask(mode,mLastSceneMode,mGuideMaskRoot,deliver)
	onAddLayerForTopMsgBox(mode,mLastSceneMode,mTopMsgBoxRoot,deliver)
	onAddLayerForWebView(mode,mLastSceneMode,mWebViewRoot,deliver)
	
	local director = cc.Director:getInstance()
	if require("game.disableFunc").Director.getRunningScene(director) then
        director:replaceScene(newScene)
    else
        director:runWithScene(newScene)
    end
	
end


--得到当前运行场景类型
function getCurrentSceneMode()
	return mCurrentSceneMode
end

--得到前一次运行场景类型
function getLastSceneMode()
	return mLastSceneMode
end

--清理所有地图(不可随意调用)
function clearAllNodeForMap()
	mMapRoot:removeAllChildren()
end

--清理所有surface
function clearAllNodeForSurface()
	mSurfaceRoot:removeAllChildren()
end

--清理所有UI(不可随意调用)
function clearAllNodeForUI()
	mUIRoot:removeAllChildren()
end

--清理所有提示消息框(不可随意调用)
function clearAllNodeForMsgBox()
	mMsgBoxRoot:removeAllChildren()
end

--清理所有场景特效(不可随意调用)
function clearAllNodeForSceneEffect()
	mSceneEffectRoot:removeAllChildren()
end

--清理所有顶层特效(不可随意调用)
function clearAllNodeForTopEffect()
	mTopEffectRoot:removeAllChildren()
end

--清理新手引导显示层所有(不可随意调用)
function clearAllNodeForGuideDisplay()
	mGuideDisplayRoot:removeAllChildren()
end

--清理新手引导mask层所有(不可随意调用)
function clearAllNodeForGuideMask()
	mGuideMaskRoot:removeAllChildren()
end

--清理所有顶层提示消息框(不可随意调用)
function clearAllNodeForTopMsgBox()
	mTopMsgBoxRoot:removeAllChildren()
end

--清理所有webView(不可随意调用)
function clearAllNodeForWebView()
	mWebViewRoot:removeAllChildren()
end


--在mapRoot加入node
function addNodeForMap(node)
	if(node)then
		mMapRoot:addChild(node)
	end
end

--在surfaceRoot中加入node
function addNodeForSurface(node)
	if(node)then
		mSurfaceRoot:addChild(node)
	end
end

--在uiRoot加入node
function addNodeForUI(node)
	if(node)then
		mUIRoot:addChild(node)
	end
end

--在msgBoxRoot加入node
function addNodeForMsgBox(node)
	if(node)then
		mMsgBoxRoot:addChild(node)
	end
end

--在sceneEffectRoot加入node
function addNodeForSceneEffect(node)
	if(node)then
		mSceneEffectRoot:addChild(node)
	end
end

--在topEffectRoot加入node
--最顶层effect(只有过场动画在这一层)
function addNodeForTopEffect(node)
	if(node)then
		mTopEffectRoot:addChild(node)
	end
end

--在guideDisplayRoot加入node (这是新手引导显示层,别瞎加节点)
function addNodeForGuideDisplay(node)
	if(node)then
		mGuideDisplayRoot:addChild(node)
	end
end

--在guideMaskRoot加入node (这是新手引导mask层,别瞎加节点)
function addNodeForGuideMask(node)
	if(node)then
		mGuideMaskRoot:addChild(node)
	end
end

--在topMsgBoxRoot加入node (这是游戏最高层,比新手引导还高,不要随便加到这个节点)
function addNodeForTopMsgBox(node)
	if(node)then
		mTopMsgBoxRoot:addChild(node)
	end
end

--在webViewRoot加入node (webview专用)
function addNodeForWebView(node)
	if(node)then
		mWebViewRoot:addChild(node)
	end
end


--清理界面, 为王大师的新手引导准备
function clearInterfaceForGuide()
	clearAllNodeForUI()
	clearAllNodeForMsgBox()
	clearAllNodeForSceneEffect()
	clearAllNodeForTopEffect()
	if mMsgBoxRoot then
		mMsgBoxRoot:addChild(require("game.msgboxlayer.msgLevelTouchEvent").create())
	end
end


--隐藏地图层（为武斗准备）
function hideMapRoot()
	if mMapRoot then
		mMapRoot:setVisible(false)
	end
end


--显示地图层（为武斗准备）
function showMapRoot()
	if mMapRoot then
		mMapRoot:setVisible(true)
	end
end


return sceneManager