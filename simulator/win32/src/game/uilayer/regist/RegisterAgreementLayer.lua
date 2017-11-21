local RegisterAgreementLayer = class("RegisterAgreementLayer",function()
	return cc.Layer:create()
end)

function RegisterAgreementLayer:ctor()
	local uiLayer =  g_gameTools.LoadCocosUI("login_regist1.csb",5)
	self:addChild(uiLayer)
	
	local closeBtn = uiLayer:getChildByName("scale_node"):getChildByName("Button_x")
	closeBtn:addClickEventListener(function()
		self:removeFromParent()
	end)
	
	local listView = uiLayer:getChildByName("scale_node"):getChildByName("ListView_1")
	
	local str = g_tr("regAgreementContent")
	
	local fontSize = 18
	local label = cc.Label:createWithTTF(str,"cocostudio_res/simhei.ttf",fontSize)
	if label == nil then
	 label = cc.Label:createWithSystemFont(str,"default",fontSize)
	end
	label:setDimensions(listView:getContentSize().width, 0)
	local widget = ccui.Widget:create()
	widget:addChild(label)
	widget:setContentSize(label:getContentSize())
	label:setPosition(cc.p(label:getContentSize().width/2,label:getContentSize().height/2))
	listView:pushBackCustomItem(widget)
	
end
	
return RegisterAgreementLayer