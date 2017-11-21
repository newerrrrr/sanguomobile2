--region MasterLevelUpView.lua   --主公升级界面
--Author : liuyi
--Date   : 2016/3/15
local MasterLevelUpView = class("MasterLevelUpView", require("game.uilayer.base.BaseLayer"))
local newData = nil
local oldData = nil
--引导使用判断界面是否打开
local isOpen = false

function MasterLevelUpView:createLayer()
    
    newData = nil
    oldData = nil

    newData = g_PlayerMode.GetData()
    oldData = g_PlayerMode.GetOldData()

    if newData == nil then
        return
    end

    if oldData == nil then
        return
    end

    newData.level = newData.level or 0
    oldData.level = oldData.level or newData.level

    if newData.level > oldData.level then
        g_sceneManager.addNodeForUI(MasterLevelUpView:create())
    end

end

function MasterLevelUpView:ctor()
    MasterLevelUpView.super.ctor(self)
    --self:initUI()
    self:initFx()
end

function MasterLevelUpView:initFx()
    self.layer = self:loadUI("zhugong_GradePromotion.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.layer:getChildByName("mask")

    local can_close = false

    self:regBtnCallback(close_btn,function ()
        if can_close then
		    self:close()
            require("game.uilayer.mainSurface.mainSurfacePlayer").viewChangeShow()
		    g_guideManager.execute()

        end
	end)

    local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
		    can_close = true
        end
	end

    local function onFrameEventCallFunc(bone , frameEventName , originFrameIndex , currentFrameIndex)
        
        --print("frameEventName",frameEventName)
        
        if frameEventName == "ShengJiTextChuXian" then
            local darmature , danimation = g_gameTools.LoadCocosAni(
            "anime/Effect_ShengJiDongShengJiText/Effect_ShengJiDongShengJiText.ExportJson", 
            "Effect_ShengJiDongShengJiText")
            self.root:addChild(darmature,1)
            darmature:setPosition( cc.p(self.root:getContentSize().width/2,self.root:getContentSize().height/2))
            danimation:play("Animation1") 

            local lvTx = cc.Label:createWithCharMap("worldmap/notPlist/master_lv_number.png", 54, 71, 48)
            lvTx:setString(tostring(newData.level))
            local node = cc.Node:create()
            node:setAnchorPoint(cc.p(0.5,0.5))
            node:addChild(lvTx)
            darmature:getBone("Layer2"):addDisplay(node,0)
        end

        if frameEventName == "ShengJiDongHuaQiuXunHuanChuXian" then
            local qarmature , qanimation = g_gameTools.LoadCocosAni(
            "anime/Effect_ShengJiDongHuaQiuXunHuan/Effect_ShengJiDongHuaQiuXunHuan.ExportJson", 
            "Effect_ShengJiDongHuaQiuXunHuan")
            self.root:addChild(qarmature,0)
            qarmature:setPosition( cc.p(self.root:getContentSize().width/2,self.root:getContentSize().height/2))
            qanimation:play("Animation1")
        end


        if frameEventName == "ShengJiDongLiuGuangXunHuanChuXian" then
            local larmature , lanimation = g_gameTools.LoadCocosAni(
            "anime/Effect_ShengJiDongLiuGuangXunHuan/Effect_ShengJiDongLiuGuangXunHuan.ExportJson", 
            "Effect_ShengJiDongLiuGuangXunHuan")
            self.root:addChild(larmature)
            larmature:setPosition( cc.p(self.root:getContentSize().width/2,self.root:getContentSize().height/2))
            lanimation:play("Animation1")
            
            local function playLiuGuang()
                lanimation:play("Animation1")
            end

            self:schedule(playLiuGuang,3)

        end
	end
    
    local armature , animation = g_gameTools.LoadCocosAni(
        "anime/Effect_ShengJiDongHuaZon/Effect_ShengJiDongHuaZon.ExportJson"
        , "Effect_ShengJiDongHuaZon",
        onMovementEventCallFunc,
        onFrameEventCallFunc
    )

    armature:setPosition( cc.p(self.root:getContentSize().width/2,self.root:getContentSize().height/2))
    self.root:addChild(armature)
    
    local itemBone = 
    {   
        armature:getBone("Layer5"),
        armature:getBone("Layer29"),
        armature:getBone("Layer30"),
        armature:getBone("Layer32"),
        armature:getBone("Layer33"),
        armature:getBone("Layer39"),
        armature:getBone("Layer40"),
        armature:getBone("Layer41"),
    }
    

    local levelDropId = nil
    for index, value in ipairs(g_data.master) do
        if value.level == newData.level then
            levelDropId = value.drop
            break
        end
    end
    local dropConfig = nil

    if levelDropId then
        dropConfig = g_data.drop[levelDropId]
    end
    
    for index, bone in ipairs(itemBone) do
        local dropData = dropConfig.drop_data[index]
        if dropData then
            local item_type = dropData[1]
            local item_id = dropData[2]
            local item_num = dropData[3]
            local item = require("game.uilayer.common.DropItemView").new(item_type, item_id,item_num)
            item:setAnchorPoint(cc.p(0.5,0.25))
            local node = cc.Node:create()
            node:setAnchorPoint(cc.p(0.5,0.5))
            node:addChild(item)
            bone:addDisplay(node,0)
        else
            bone:setVisible(false)
        end
    end
    
    --战斗力zhcn
    local node = cc.Node:create()
    node:setAnchorPoint(cc.p(0.5,0.5))
    local tx = ccui.Text:create(g_tr("Power"), "cocostudio_res/simhei.ttf", 24)
    --zhPowerTx:setTextColor(cc.c3b(30,230,50))
    node:addChild(tx)
    armature:getBone("Layer9"):addDisplay(node,0)
    
    local addPowerNum = (newData.power or 0) - (oldData.power or 0)
    if addPowerNum <= 0 then addPowerNum = 0 end

    local node = cc.Node:create()
    node:setAnchorPoint(cc.p(0.5,0.5))
    local tx = ccui.Text:create("+" .. addPowerNum , "cocostudio_res/simhei.ttf", 24)
    tx:setAnchorPoint(cc.p(0.5,0.15))
    tx:setTextColor(cc.c3b(30,230,50))
    node:addChild(tx)
    armature:getBone("Layer19"):addDisplay(node,0)


    --armature:getBone("Layer19"), vlaue
    --天赋点
    --armature:getBone("Layer10"),

    local node = cc.Node:create()
    node:setAnchorPoint(cc.p(0.5,0.5))
    local tx = ccui.Text:create(g_tr("TalentPoint"), "cocostudio_res/simhei.ttf", 24)
    --zhPowerTx:setTextColor(cc.c3b(30,230,50))
    node:addChild(tx)
    armature:getBone("Layer10"):addDisplay(node,0)

    local addTalentPoint = 0
    local newP = 0
    local oldP = 0
    for index, var in ipairs(g_data.master) do
        if var.level == newData.level then
            newP = var.talent_num
        end

        if var.level == oldData.level then
            oldP = var.talent_num
        end
    end
    
    addTalentPoint = newP - oldP

    --local addPowerNum = (newData.power or 0) - (oldData.power or 0)
    local node = cc.Node:create()
    node:setAnchorPoint(cc.p(0.5,0.5))
    local tx = ccui.Text:create("+" .. addTalentPoint , "cocostudio_res/simhei.ttf", 24)
    tx:setAnchorPoint(cc.p(0.5,0.15))
    tx:setTextColor(cc.c3b(30,230,50))
    node:addChild(tx)
    armature:getBone("Layer20"):addDisplay(node,0)

    --armature:getBone("Layer20"), vlaue

    --[[local node = cc.Node:create()
    node:setAnchorPoint(cc.p(0.5,0.5))
    local LVTx = ccui.Text:create(tostring(newData.level), "cocostudio_res/simhei.ttf", 85)
    node:addChild(LVTx)
    armature:getBone("Layer49"):addDisplay(node,0)]]
    
    animation:play("Animation1")



    --Layer32
    --Layer33
    --Layer34
    --Layer35
    --Layer39
    --Layer38
    --Layer37
    --Layer36
end


function MasterLevelUpView:initUI()
    self.layer = self:loadUI("zhugong_GradePromotion.csb")
	self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.layer:getChildByName("mask")
	local can_close = false

    print("this is scale value",self.root:getScale())
    local scaleVar = self.root:getScale()

    self.root:setScale(0.1)
    
    local toScale = cc.ScaleTo:create(0.25,scaleVar)
    local toFun = cc.CallFunc:create(function ()
        can_close = true
    end)

    self:regBtnCallback(close_btn,function ()
        if can_close then
		    self:close()
        end
	end)

    self.root:runAction( cc.Sequence:create( toScale, toFun))
    self.root:getChildByName("Text_1"):setString(g_tr("Power"))
    self.root:getChildByName("Text_2"):setString(g_tr("TalentPoint"))

    self.root:getChildByName("Text_13"):setString( tostring(newData.level) )


    local addPowerNum = newData.power - oldData.power
    local powerTx = self.root:getChildByName("Text_1_0")
    powerTx:setString( "+" .. addPowerNum )

    --local lvNum = newData.level - oldData.level
    local addTalentPoint = 0
    local newP = 0
    local oldP = 0
    for index, var in ipairs(g_data.master) do
        if var.level == newData.level then
            newP = var.talent_num
        end

        if var.level == oldData.level then
            oldP = var.talent_num
        end
    end
    
    addTalentPoint = newP - oldP

    --lvNum * 

    local talentTx = self.root:getChildByName("Text_2_0")
    talentTx:setString( "+" .. addTalentPoint )

    local nodes = {}
    local index = 1
    while (index) do
        local node = self.root:getChildByName(  string.format("kuang_%d",index))
        local nodeTx = self.root:getChildByName(  string.format("kuang_0%d",index))
        if node and nodeTx then
            --table.insert( nodes,node )
            nodes[index] = { node = node, nodeTx = nodeTx }
            index = index + 1
        else
            break
        end
    end
    

    local levelDropId = nil
    
    for index, value in ipairs(g_data.master) do
        if value.level == newData.level then
            levelDropId = value.drop
            break
        end
    end

    print("levelDropId",levelDropId)

    local dropConfig = nil
    if levelDropId then
        dropConfig = g_data.drop[levelDropId]
    end
    
    dump(dropConfig)
    --420001
    
    for index, var in ipairs(nodes) do
        --var.node:setVisible(false)
        var.nodeTx:setVisible(false)
        local dropData = dropConfig.drop_data[index]
        if dropData then
            --local itemID = dropData[2]
            --local itemNum =
            local item_type = dropData[1]
            local item_id = dropData[2]
            local item_num = dropData[3]
            local item = require("game.uilayer.common.DropItemView").new(item_type, item_id,item_num)
            item:setPosition(cc.p( var.node:getContentSize().width/2, var.node:getContentSize().height/2))
            var.node:addChild(item)
            item:setNameVisible(true)
        else
            var.node:setVisible(false)
        end
    end
    
end

function MasterLevelUpView:onEnter()
    isOpen = true
end

function MasterLevelUpView:onExit()
    isOpen = false
end

function MasterLevelUpView:getViewIsOpen()
    return isOpen
end

return MasterLevelUpView
