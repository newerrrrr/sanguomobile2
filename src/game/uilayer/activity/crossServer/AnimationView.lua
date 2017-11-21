local AnimationView = class("AnimationView", require("game.uilayer.base.BaseLayer"))

local wordSize = 24

local offSet = 160

function AnimationView:ctor(name)
	AnimationView.super.ctor(self)

	self.layer = self:loadUI("guildwar_fuhuodian_xin03.csb")
	self.root = self.layer:getChildByName("scale_node")
	self.close_btn = self.root:getChildByName("close_btn")
	self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1:setString(g_tr("MasterInfo"))

	self.Panel_dh = self.root:getChildByName("Panel_dh")

	self:addEvent()

	self:playerAnimation(name)
end

function AnimationView:playerAnimation(val)
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
		    self.Panel_dh:removeChild(self.armature)
		    self.armature , self.animation = nil
		    self:close()
        end
	end

	local function onFrameEventCallFunc(bone , frameEventName , originFrameIndex , currentFrameIndex)
        if frameEventName == "QiPao01ChuXian" then
        	self.item = ccui.ImageView:create("cocos/cocostudio_res/MainInterface/Title_build82.png")
            local lvTx = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", wordSize, cc.size(0,0))
            lvTx:setDimensions(200,200)
            lvTx:setString(g_tr(self:getDesc(val).."_1"))
            lvTx:setPositionX((self.item:getContentSize().width - lvTx:getContentSize().width)/2 + offSet)
            lvTx:setPositionY((self.item:getContentSize().height - lvTx:getContentSize().height)/2)
            self.item:addChild(lvTx)
            self.armature:getBone("QiPao"):addDisplay(self.item,0)
            self.item:setOpacity(0)
        elseif frameEventName == "QiPao01XiaoShi" then
        	self.item:removeAllChildren()
        elseif frameEventName == "QiPao02ChuXian" then
            self.item = ccui.ImageView:create("cocos/cocostudio_res/MainInterface/Title_build82.png")
            local lvTx = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", wordSize, cc.size(0,0))
            lvTx:setDimensions(200,200)
            lvTx:setString(g_tr(self:getDesc(val).."_2"))
            lvTx:setPositionX((self.item:getContentSize().width - lvTx:getContentSize().width)/2 + offSet)
            lvTx:setPositionY((self.item:getContentSize().height - lvTx:getContentSize().height)/2)
            self.item:addChild(lvTx)
            self.armature:getBone("QiPao"):addDisplay(self.item,0)
            self.item:setOpacity(0)
        elseif frameEventName == "QiPao02XiaoShi" then
        	self.item:removeAllChildren()
        elseif frameEventName == "QiPao03ChuXian" then
           	self.item = ccui.ImageView:create("cocos/cocostudio_res/MainInterface/Title_build82.png")
            local lvTx = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", wordSize, cc.size(0,0))
            lvTx:setDimensions(200,200)
            lvTx:setString(g_tr(self:getDesc(val).."_3"))
            lvTx:setPositionX((self.item:getContentSize().width - lvTx:getContentSize().width)/2 + offSet)
            lvTx:setPositionY((self.item:getContentSize().height - lvTx:getContentSize().height)/2)
            self.item:addChild(lvTx)
            self.armature:getBone("QiPao"):addDisplay(self.item,0)
            self.item:setOpacity(0)
        elseif frameEventName == "QiPao03XiaoShi" then
        	self.item:removeAllChildren()
        elseif frameEventName == "QiPao04ChuXian" then
           	self.item = ccui.ImageView:create("cocos/cocostudio_res/MainInterface/Title_build82.png")
            local lvTx = cc.Label:createWithTTF("", "cocostudio_res/simhei.ttf", wordSize, cc.size(0,0))
            lvTx:setDimensions(200,200)
            lvTx:setString(g_tr(self:getDesc(val).."_4"))
            lvTx:setPositionX((self.item:getContentSize().width - lvTx:getContentSize().width)/2 + offSet)
            lvTx:setPositionY((self.item:getContentSize().height - lvTx:getContentSize().height)/2)
            self.item:addChild(lvTx)
            self.armature:getBone("QiPao"):addDisplay(self.item,0)
            self.item:setOpacity(0)
        elseif frameEventName == "QiPao04XiaoShi" then
        	self.item:removeAllChildren()
        end
	end

	self.armature , self.animation = g_gameTools.LoadCocosAni("anime/Effect_ZhanLvTuZhiYingDongHua/Effect_ZhanLvTuZhiYingDongHua.ExportJson", 
		"Effect_ZhanLvTuZhiYingDongHua", onMovementEventCallFunc, onFrameEventCallFunc)
    self.armature:setPosition(cc.p(self.Panel_dh:getContentSize().width/2,self.Panel_dh:getContentSize().height/2))
    self.Panel_dh:addChild(self.armature)
    self.animation:play(val)
end

function AnimationView:addEvent()
	local function proClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.close_btn == sender then
				self.Panel_dh:removeChild(self.armature)
				self:close()
			end
		end
	end

	self.close_btn:addTouchEventListener(proClick)
end

function AnimationView:getDesc(val)
	if val == "JingGongA" then
		return "attackA"
	elseif val == "JingGongB" then
		return "attackB"
	elseif val == "FangShouA" then
		return "defenseA"
	elseif val == "FangShouB" then
		return "defenseB"
	end
end

return AnimationView