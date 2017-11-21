--region 强化
--Author : liuyi
--Date   : 2016/10/28
local GodGeneralPlusLayer = class("GodGeneralPlusLayer",require("game.uilayer.base.BaseLayer"))
local GodGeneralMode = require("game.uilayer.godGeneral.GodGeneralMode"):instance()

function GodGeneralPlusLayer:ctor(gid)
    GodGeneralPlusLayer.super.ctor(self)
    self.selGeneralId = gid
    self.isNeedUpdate = false
    self.nodesList = {}
    self:initData()
    self:initUI()
end

function GodGeneralPlusLayer:initData()
    
    local godGeneralConfig = GodGeneralMode:getGodGeneralConfig()
    
    self.showGodListData = {}

    for key, var in pairs(godGeneralConfig) do
        local ndata = g_GeneralMode.getOwnedGeneralByOriginalId(var.general_original_id)
        --g_GeneralMode.getGeneralById(var.general_original_id)
        table.insert(self.showGodListData,{cdata = var,ndata = ndata })
    end

    table.sort( self.showGodListData,function (a,b)
        
        local Anum = tonumber(a.cdata.id) + (a.ndata and 10000000 or 0)
        local Bnum = tonumber(b.cdata.id) + (b.ndata and 10000000 or 0)
        
        return Anum > Bnum
    end )
end

--原型ID
function GodGeneralPlusLayer:getGodGeneralData( gid )
    local gdata = nil
    self:initData()
    for key, var in ipairs(self.showGodListData) do
        if var.cdata.general_original_id == gid then
            gdata = var
        end
    end
    return gdata
end

function GodGeneralPlusLayer:initUI()
    self.layer = self:loadUI("GodGenerals_Strengthen.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.list = self.root:getChildByName("ListView_2")
    --zhcn
    self.root:getChildByName("Text_27"):setString(g_tr("godGeneralSkillUpStr"))
    self.root:getChildByName("Text_dqxg"):setString(g_tr("godGeneralSkillNowStr"))
    self.root:getChildByName("Text_xjyl"):setString(g_tr("godGeneralNextSkillNowStr"))
    self.root:getChildByName("Text_qhdj"):setString(g_tr("godGeneralQHLvStr"))
    self.root:getChildByName("Textzdxg"):setString(g_tr("godGeneralCZBuffStr"))
    self.root:getChildByName("Text_wdxg"):setString(g_tr("godGeneralWDBuffStr"))
    self.root:getChildByName("Panel_4"):getChildByName("Panel_mat"):getChildByName("Text_qhxh"):setString(g_tr("godGeneralQHUseStr"))
    self.root:getChildByName("Panel_4"):getChildByName("Text_3"):setString(g_tr("godGeneralQHStr"))
    self.root:getChildByName("Text_2"):setString(g_tr("godGeneralTitle"))

    self:loadList()
    
    local closeBtn = self.root:getChildByName("Button_6")
    closeBtn:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            if self._rcall  then
                self._rcall( self.isNeedUpdate)
            end
            self:close()
        end
    end)

end

function GodGeneralPlusLayer:loadList()
    
    self.selNode = nil

    local function nodeTouch(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender ~= self.selNode then
                self.selNode.high:setVisible(false)
                self.selNode = sender
                self.selNode.high:setVisible(true)
                self:showPanel(self.selNode.data)
            end
        end
    end
    
    local mode = cc.CSLoader:createNode("GodGenerals_Strengthen_list.csb")

    for idx, data in ipairs(self.showGodListData) do
        
        local update = function (_node,_data)
            
            local cData = _data.cdata

            local nData = _data.ndata

            local skillcData = g_data.combat_skill[cData.general_combat_skill]

            local node = _node

            local nodeHigh = node:getChildByName("Image_fg")
            nodeHigh:setVisible(false)

            local nodeRed = node:getChildByName("Image_4")
            nodeRed:setVisible(false)
            node.red = nodeRed

            local nodeName = node:getChildByName("Text_2")
            nodeName:setString(g_tr( cData.general_name ))

            local nodeSkillName = node:getChildByName("Text_2_0")

            nodeSkillName:setString(g_tr( skillcData.skill_name ))

            local nodeIcon = node:getChildByName("Image_1_0")
            local nodeIconBorder = node:getChildByName("Image_1")
            --dump(cData)
            if cData.skill_icon ~= 0 then
                nodeIcon:loadTexture( g_resManager.getResPath(cData.skill_icon) )
            end
        
            local nodeLv = node:getChildByName("Text_2_0_0")
            local nodeLvBg = node:getChildByName("Image_9")
            node.data = _data
            node.high = nodeHigh

            if nData == nil then
                nodeIcon:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
                nodeLv:setVisible(false)
                nodeLvBg:setVisible(false)
                nodeIconBorder:loadTexture(GodGeneralMode:getSkillBorderRes(1))
            else
                local skillLv = nData.skill_lv
                local level = nData.lv
                nodeIconBorder:loadTexture(GodGeneralMode:getSkillBorderRes(skillLv))
                nodeLv:setVisible(true)
                nodeLvBg:setVisible(true)
                nodeLv:setString( "Lv." .. tostring(skillLv) )
                nodeLv:enableOutline(cc.c4b(0, 0, 0,255), 1)
                local count,needCount,isMaxLv = GodGeneralMode:getNeedSkillUpItemCount( skillLv )
                if not isMaxLv then
                    node.red:setVisible( (count >= needCount) and (level > skillLv) )
                else
                    node.red:setVisible(false)
                end
            end

            if self.selNode then
                self.selNode.high:setVisible(true)
            end

        end

        local node = mode:clone()

        node.update = update

        node:update(data)

        if self.selGeneralId then
            if data.cdata.general_original_id == self.selGeneralId then
                self.selNode = node
            end
        else
            if idx == 1 then
                self.selNode = node
            end
        end

        node:setTouchEnabled(true)

        node:addTouchEventListener(nodeTouch)

        table.insert(self.nodesList,node)

        self.list:pushBackCustomItem(node)
    end
    
    self:showPanel(self.selNode.data)
    self.selNode.high:setVisible(true)

    local action = nil
    local function jump()
        local h = self.selNode:getContentSize().height
        local nowh = self.list:getIndex( self.selNode ) * h
        local allh = table.nums(self.list:getItems()) * h
        self.list:jumpToPercentVertical( nowh/allh * 100 )
        if action then
            self:stopAction(action)
            action = nil
        end
    end

    action = self:schedule(jump,0.1)
    
end

function GodGeneralPlusLayer:showPanel(data)
    

    local nData = data.ndata
    local cData = data.cdata
    
    local lvTx  = self.root:getChildByName("Text_qhdj1")
    local nextLvTx = self.root:getChildByName("Text_qhdj2")

    local zdxgTx = self.root:getChildByName("Textzdxg_1")
    if self.zdxgTx == nil then
        self.zdxgTx = g_gameTools.createRichText(zdxgTx)
    end

    local zdxgNextTx = self.root:getChildByName("Textzdxg_2")
    if self.zdxgNextTx == nil then
        self.zdxgNextTx = g_gameTools.createRichText(zdxgNextTx)
    end

    local wdxgTx = self.root:getChildByName("Text_wdxg1")
    if self.wdxgTx == nil then
        self.wdxgTx = g_gameTools.createRichText(wdxgTx)
    end

    local wdxgNextTx = self.root:getChildByName("Text_wdxg2")
    if self.wdxgNextTx == nil then
        self.wdxgNextTx = g_gameTools.createRichText(wdxgNextTx)
    end

    
    local panel = self.root:getChildByName("Panel_4")
    local matPanel = panel:getChildByName("Panel_mat")
    local upBtn = panel:getChildByName("Button_1")
    local needLvTx = panel:getChildByName("Text_3_0")
    local skillLv = 1

    if nData == nil then
        upBtn:setVisible(false)
        needLvTx:setVisible(false)
        panel:getChildByName("Text_3"):setVisible(false)
    else
        upBtn:setVisible(true)
        needLvTx:setVisible(true)
        panel:getChildByName("Text_3"):setVisible(true)
        skillLv = tonumber(nData.skill_lv)
    end

    local showBorder = nil
    for i = 1, 5 do
        local itemBorder = matPanel:getChildByName(string.format("Image_List0%d",i))
        if i > 1 then
            itemBorder:setVisible(false)
        else
            showBorder = itemBorder
        end
    end
    
    local iType = g_Consts.DropType.Props
    local iId = 51011
    local iNum = 0
    local count,needCount,isMaxLv = GodGeneralMode:getNeedSkillUpItemCount(skillLv)
    
    if showBorder.item then
        showBorder.item:removeFromParent()
        showBorder.item = nil
    end

    if showBorder.item == nil then
        local itemIcon = require("game.uilayer.common.DropItemView").new(iType,iId,iNum)
        itemIcon:setPosition( cc.p( showBorder:getContentSize().width/2, showBorder:getContentSize().height/2 ) )
        itemIcon:setCountEnabled(false)
        itemIcon:setNameVisible(true)
        --itemIcon:enableTip(true)
        showBorder:addChild(itemIcon)
        showBorder.item = itemIcon
        itemIcon:setTouchEnabled(true)
        itemIcon:addTouchEventListener( function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, iId, function ()
                    --todo
                    print("update")
                    self:showPanel(self.selNode.data)
                end)
                g_sceneManager.addNodeForUI(view)
            end
        end )
    end
    --itemIcon:setTouchEnabled(true)

    local countTx = showBorder:getChildByName("Need_Count")
    countTx:setString( string.format("%d/%d",count,needCount) )
    
    local showData = GodGeneralMode:getLevelFormula(data)
    
    local lvMaxStr = ""

    if skillLv >= table.nums(g_data.general_skill_levelup) then
        lvMaxStr = "(MAX)"
    end

    lvTx:setString( "Lv."..tostring(skillLv) .. lvMaxStr )

    --zdxgTx:setString(showData.dsc1)
    self.zdxgTx:setRichText( showData.rdsc1 )

    --wdxgTx:setString(showData.rddsc1)
    self.wdxgTx:setRichText(showData.rddsc1)
    --wdxgNextTx:setString(showData.rddsc2)

    --技能没有满级
    if not isMaxLv then
        
        local nextSkillLv = skillLv + 1

        matPanel:setVisible(true)

        --needLvTx:setVisible(true)

        needLvTx:setString( g_tr("godLvNeedToUpSkillLvStr",{lv = nextSkillLv }) )
        
        upBtn:setEnabled( ( nData and nData.lv or 0 ) >= nextSkillLv )

        needLvTx:setVisible(  nData and not (nData.lv >= nextSkillLv ) )
        
        self.root:getChildByName("Panel_4"):getChildByName("Panel_mat"):getChildByName("Text_qhxh"):setVisible(true)

        if count >= needCount then
            countTx:setTextColor( cc.c3b(30,230,30) )
        else
            countTx:setTextColor( cc.c3b(230,30,30) )
        end
        
        nextLvTx:setString( "Lv."..tostring(nextSkillLv) )

        --zdxgNextTx:setString( showData.dsc2 )
        self.zdxgNextTx:setRichText( showData.rdsc2 )

        self.wdxgNextTx:setRichText( showData.rddsc2 )
        
        --wdxgNextTx:setString( showData.rddsc2 )

    else
        matPanel:setVisible(false)

        upBtn:setVisible(false)

        needLvTx:setVisible(false)

        panel:getChildByName("Text_3"):setVisible(false)

        self.root:getChildByName("Panel_4"):getChildByName("Panel_mat"):getChildByName("Text_qhxh"):setVisible(false)

        nextLvTx:setString( g_tr("godGeneralSkillLvStr") .. g_tr("godGeneralLvMaxStr") )

        self.zdxgNextTx:setRichText( g_tr("godGeneralSkillXgStr") .. g_tr("godGeneralLvMaxStr") )
        --zdxgNextTx:setString( g_tr("godGeneralSkillXgStr") .. g_tr("godGeneralLvMaxStr") )

        self.wdxgNextTx:setRichText( g_tr("godGeneralSkillXgStr") .. g_tr("godGeneralLvMaxStr") )

    end
    
    upBtn.count = count
    upBtn.needCount = needCount

    if upBtn.isAddListener == nil then
        upBtn:addTouchEventListener( function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if upBtn.count >= upBtn.needCount then
                    local function callback(result,msgData)
                        g_busyTip.hide_1()
                        if result == true then
                            g_airBox.show(g_tr("godGeneralQHOK"))
                            --self:initData()
                            --传化身之后的原型ID给列表定位选中
                            --self:loadList(godRootConfig.general_original_id)
                            self.isNeedUpdate = true
                            local newData = self:getGodGeneralData(self.selNode.data.cdata.general_original_id)
                            if newData then
                                self.selNode:update(newData)

                                self:showPanel(self.selNode.data)

                                self:upShowFx(self.selNode)

                                self:updateNodesRed()
                            end
                        end
                    end
                    g_busyTip.show_1()

                    g_sgHttp.postData("Pub/upGodSkill", { generalId = self.selNode.data.cdata.general_original_id }, callback)
                else
                    g_airBox.show(g_tr("godGeneralUseItemError"))
                    --print("技能书不足")
                end
            end
        end )
        upBtn.isAddListener = true
    end
end

function GodGeneralPlusLayer:removeCallBack(fun)
    if fun then
        self._rcall = fun
    end
end

function GodGeneralPlusLayer:updateNodesRed()
    for key, node in ipairs(self.nodesList) do
        local nData = node.data.ndata
        local cData = node.data.cdata
        if nData then
            local skillLv = nData.skill_lv
            local level = nData.lv
            local count,needCount,isMaxLv = GodGeneralMode:getNeedSkillUpItemCount( skillLv )
            if not isMaxLv then
                node.red:setVisible( (count >= needCount) and (level > skillLv) )
            else
                node.red:setVisible(false)
            end
        end
    end
end

function GodGeneralPlusLayer:upShowFx(_node)
    
    local target = _node:getChildByName("Image_1_0")

    local size = target:getContentSize()

    local armature , animation
    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            armature:removeFromParent()
        end
    end 
  
    armature , animation = g_gameTools.LoadCocosAni(
        "anime/YanJiouSuo_KeJiKaiQi/YanJiouSuo_KeJiKaiQi.ExportJson"
        , "YanJiouSuo_KeJiKaiQi"
        , onMovementEventCallFunc
    )

    armature:setPosition(cc.p(size.width/2, size.height/2 + 9))
    armature:setScale(1.3)
    target:addChild(armature)
    animation:play("Animation1") 
end

return GodGeneralPlusLayer