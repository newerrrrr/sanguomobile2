local display = {}
setmetatable(display,{__index = _G})
setfenv(1,display)


local function initView()
	
	local director = cc.Director:getInstance()
	local view = director:getOpenGLView()
	local sz = director:getWinSize() 
	print("@!!!!!!!!!!!!!!!!!", sz.width, sz.height)
	if not view then
		print("@22222222222222222")
		view = cc.GLViewImpl:createWithRect("sanguo_mobile2", cc.rect(0, 0, 1280, 720))
		director:setOpenGLView(view)
	end
	
	--设计大小
	view:setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.NO_BORDER)
	
	director:setProjection(cc.DIRECTOR_PROJECTION_3D)
	
	director:setAnimationInterval(1.0 / 60.0)
	
	director:setDisplayStats(cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform())
	
	
	local sizeInPixels = view:getFrameSize()
    display.sizeInPixels = {width = sizeInPixels.width, height = sizeInPixels.height}
	
	display.contentScaleFactor = director:getContentScaleFactor()
	display.size 				= director:getWinSize()
	display.width              	= display.size.width
    display.height             	= display.size.height
	display.visibleSize			= director:getVisibleSize()
	display.visibleOrigin 		= director:getVisibleOrigin()
	display.cx                 	= display.width / 2
    display.cy                 	= display.height / 2
	display.left               	= display.visibleOrigin.x
    display.right              	= display.visibleOrigin.x + display.visibleSize.width
    display.top                	= display.visibleOrigin.y + display.visibleSize.height
    display.bottom            	= display.visibleOrigin.y
    display.center             	= cc.p(display.cx, display.cy)
	display.left_top            = cc.p(display.left, display.top)
    display.left_bottom         = cc.p(display.left, display.bottom)
    display.left_center         = cc.p(display.left, display.cy)
    display.right_top           = cc.p(display.right, display.top)
    display.right_bottom        = cc.p(display.right, display.bottom)
    display.right_center        = cc.p(display.right, display.cy)
    display.top_center          = cc.p(display.cx, display.top)
    display.bottom_center         = cc.p(display.cx, display.bottom)
	
	display.scale 				= display.visibleSize.width / display.width
	
	if cToolsForLua:isDebugVersion() then
		print(string.format("# display.sizeInPixels         = {width = %0.2f, height = %0.2f}", display.sizeInPixels.width, display.sizeInPixels.height))
		print(string.format("# display.size                 = {width = %0.2f, height = %0.2f}", display.size.width, display.size.height))
		print(string.format("# display.contentScaleFactor   = %0.2f", display.contentScaleFactor))
		print(string.format("# display.width                = %0.2f", display.width))
		print(string.format("# display.height               = %0.2f", display.height))
		print(string.format("# display.visibleSize          = {width = %0.2f, height = %0.2f}", display.visibleSize.width , display.visibleSize.height))
		print(string.format("# display.visibleOrigin        = {x = %0.2f, y = %0.2f}", display.visibleOrigin.x,display.visibleOrigin.y))
		print(string.format("# display.cx                   = %0.2f", display.cx))
		print(string.format("# display.cy                   = %0.2f", display.cy))
		print(string.format("# display.left                 = %0.2f", display.left))
		print(string.format("# display.right                = %0.2f", display.right))
		print(string.format("# display.top                  = %0.2f", display.top))
		print(string.format("# display.bottom               = %0.2f", display.bottom))
		print(string.format("# display.center               = {x = %0.2f, y = %0.2f}", display.center.x, display.center.y))
		print(string.format("# display.left_top             = {x = %0.2f, y = %0.2f}", display.left_top.x, display.left_top.y))
		print(string.format("# display.left_bottom          = {x = %0.2f, y = %0.2f}", display.left_bottom.x, display.left_bottom.y))
		print(string.format("# display.left_center          = {x = %0.2f, y = %0.2f}", display.left_center.x, display.left_center.y))
		print(string.format("# display.right_top            = {x = %0.2f, y = %0.2f}", display.right_top.x, display.right_top.y))
		print(string.format("# display.right_bottom         = {x = %0.2f, y = %0.2f}", display.right_bottom.x, display.right_bottom.y))
		print(string.format("# display.right_center         = {x = %0.2f, y = %0.2f}", display.right_center.x, display.right_center.y))
		print(string.format("# display.top_center           = {x = %0.2f, y = %0.2f}", display.top_center.x, display.top_center.y))
		print(string.format("# display.bottom_center           = {x = %0.2f, y = %0.2f}", display.bottom_center.x, display.bottom_center.y))
		print(string.format("# display.scale           		= %0.2f", display.scale))
	end
	
end

initView()

return display