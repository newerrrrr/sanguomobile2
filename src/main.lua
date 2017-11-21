cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("res/cocos/")
cc.FileUtils:getInstance():setPopupNotify(false)
require "cocos.init"
require "public.init"
require "game.initLoadString"
require "game.disableFunc"
require "game.versionConfig"
require "game.gameConfig"
require "game.init"
require "anysdk.init"

math.randomseed(os.time())

local function main()
	-- g_gameCommon.sgNetInit()
	require("game.uilayer.setting.settingLayer").initSettingForMain()
	
  --进入登录场景
  g_sceneManager.setScene(g_sceneManager.sceneMode.login)

  require "game.uilayer.fightperipheral.FightTest"
  
end

xpcall(main, __G__TRACKBACK__)