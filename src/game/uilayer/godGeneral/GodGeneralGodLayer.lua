--region 化神
--Author : liuyi
--Date   : 2016/10/28
local GodGeneralGodLayer = class("GodGeneralGodLayer",require("game.uilayer.base.BaseLayer"))
local GodGeneralMode = require("game.uilayer.godGeneral.GodGeneralMode"):instance()
local m_Root = nil

function GodGeneralGodLayer:ctor(gid,callback)
    GodGeneralGodLayer.super.ctor(self)

    if m_Root then
        m_Root:close()
    end

    m_Root = self
    
    self.callback = callback
    self.gid = gid
    self.sxPanels = {}
    self:initGodData()
    self:initUI()
end

function GodGeneralGodLayer:initGodData()
     --化身成功之后的武将数据
    self.showGodListData = {}
    local godGeneralConfig = GodGeneralMode:getGodGeneralConfig()
    for key, var in pairs(godGeneralConfig) do
        local ndata = g_GeneralMode.getOwnedGeneralByOriginalId(var.general_original_id)
        --g_GeneralMode.getGeneralById(var.general_original_id)
        --if ndata then
        table.insert(self.showGodListData,{cdata = var,ndata = ndata})
        --end
    end

    table.sort( self.showGodListData,function (a,b)
        local Anum = tonumber(a.cdata.id) + (a.ndata and 10000000 or 0)
        local Bnum = tonumber(b.cdata.id) + (b.ndata and 10000000 or 0)

        return Anum > Bnum
    end )
end

function GodGeneralGodLayer:getGodGeneralData(gid)
    local gdata = nil
    self:initGodData()
    for key, var in ipairs(self.showGodListData) do
        if var.cdata.general_original_id == gid then
            gdata = var
        end
    end
    return gdata
end

function GodGeneralGodLayer:initUI()
    
    self.layer = self:loadUI("GodGenerals_God.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.list = self.root:getChildByName("ListView_2") 
    --是神武将界面
    self.godGeneralPanel = self.root:getChildByName("Panel_4")
    --不是神武将界面
    self.noGodGeneralPanel = self.root:getChildByName("Panel_3")
    
    local closeBtn = self.root:getChildByName("Button_6")
    closeBtn:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            
            if self.callback then
                self.callback()
            end

            self:close()
        end
    end)

    --zhcn
    self.root:getChildByName("Text_2"):setString(g_tr("godGeneralTitle"))
    self.showTipsBtn = self.root:getChildByName("Image_1")
    
    self:loadList()
    
    if g_guideManager.execute() then
        self:jumpNode( 10050 )
    end

    local action = nil
    local function jump()
        local h = self._selNode:getContentSize().height
        local nowh = self.list:getIndex( self._selNode ) * h
        local allh = table.nums(self.list:getItems()) * h
        self.list:jumpToPercentVertical( nowh/allh * 100 )
        if action then
            self:stopAction(action)
            action = nil
        end
    end

    action = self:schedule(jump,0.1)
    
end

function GodGeneralGodLayer:loadList(origin_id)
    
    self.list:removeAllItems()
    self.nodes = {}
    self._selNode = nil

    local origin_id = origin_id

    --选中的方法
    local function selNode()
        if self._selNode then
            self._selNode.high:setVisible(true)
            self:changeGeneral(self._selNode.data)
        end
    end
    
    local function touchNodes( sender,evenType )
        if evenType == ccui.TouchEventType.ended then
            if self._selNode ~= sender then
                if self._selNode then
                    self._selNode.high:setVisible(false)
                end
                self._selNode = sender
                selNode()
            end
        end
    end
    
    local mode = cc.CSLoader:createNode("GodGenerals_God_list.csb")
    local normalNode = nil

    for idx, data in ipairs(self.showGodListData) do
        
        local cdata = data.cdata  --配置表数据
        local ndata = data.ndata

        local node = mode:clone()

        node.data = data

        local gtype = g_Consts.DropType.General
        local gid = cdata.id
        local num = 1
        local nodePic = require("game.uilayer.common.DropItemView").new(gtype,gid,num)
        local nodePicPanel = node:getChildByName("Image_1")
        nodePic:setPosition( cc.p(nodePicPanel:getContentSize().width/2,nodePicPanel:getContentSize().height/2) )
        nodePicPanel:addChild(nodePic)
        nodePic:setCountEnabled(false)
        
        --没有拥有这个武将
        local redData = data
        if ndata == nil then
            nodePic:getIconRender():getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
        end

        local nodeRed = node:getChildByName("Red")
        node.red = nodeRed
        nodeRed:setVisible(GodGeneralMode:isShowRP(redData))
        
        local nodeName = node:getChildByName("Text_1")
        nodeName:setString( g_tr(cdata.general_name) )
        
        --高亮
        local nodeHigh = node:getChildByName("Image_fg")
        nodeHigh:setVisible(false)

        node.high = nodeHigh

        if self._selNode == nil then
            if origin_id then
                if cdata.general_original_id == origin_id then
                    self._selNode = node
                end
            else
                if self.gid then
                    if cdata.general_original_id == self.gid or cdata.general_original_id == self.gid + 10000 then
                        self._selNode = node
                    end
                else
                    if idx == 1 then
                        self._selNode = node
                    end
                end
            end
        end

        if idx == 1 then
            normalNode = node
        end

        --配置
        node:setTouchEnabled(true)
        node:addTouchEventListener(touchNodes)
        
        table.insert(self.nodes,node)
        nodeName:setString( g_tr(cdata.general_name))

        self.list:pushBackCustomItem(node)
    end

    if self._selNode == nil then
        self._selNode = normalNode
    end

    selNode()

end

function GodGeneralGodLayer:changeGeneral(data)
    
    if data == nil then
        return
    end

    local showPic = self.root:getChildByName("Image_renwu")
    local cdata = data.cdata
    local ndata = data.ndata
    
    --是否是神武将
    --local isGodGeneral = data.cdata.general_quality == g_GeneralMode.godQuality
    local icon
    
    --已经化神
    if ndata then
        self.showTipsBtn:setVisible(false)
        icon = cdata.general_big_icon
        showPic:loadTexture( g_resManager.getResPath(icon) )
        self:initGodGeneralLayer(data)
    else
    --没有化神 获取没有化神的原始武将的数据
        self.showTipsBtn:setVisible(true)
        icon = cdata.general_big_icon
        local _cdata = GodGeneralMode:getGeneralConfigByRootId(cdata.root_id)
        local _ndata = g_GeneralMode.getOwnedGeneralByOriginalId(_cdata.general_original_id)
        local _data = { cdata = _cdata ,ndata = _ndata }
        showPic:loadTexture( g_resManager.getResPath(icon) )
        showPic:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
        self:initNoGodGeneralLayer(_data)
    end
    
    self:sxUpDis()
    --local godConfig = GodGeneralMode:getGodGeneralConfigByRootId(data.cdata.root_id)
    g_itemTips.tip(self.showTipsBtn ,g_Consts.DropType.General,cdata.id)
    
end

function GodGeneralGodLayer:initGodGeneralLayer(data)
    self.godGeneralPanel:setVisible(true)
    self.noGodGeneralPanel:setVisible(false)

    self.sxPanels = {}

    local cdata = data.cdata
    local ndata = data.ndata
    local lv = ndata.lv

    local nameTx = self.godGeneralPanel:getChildByName("Text_shenmingzi")
    local str = g_tr(cdata.general_name)
    nameTx:setString(string.utf8sub(str,2,string.utf8len(str)))
    
    local lvTx = self.godGeneralPanel:getChildByName("Text_dj")
    lvTx:setString( tostring(lv) )

    --local strTitle = {g_tr("wu"), g_tr("zhi"), g_tr("zheng"), g_tr("tong"), g_tr("mei")}
    --local strTips = {g_tr("wuInfo"), g_tr("zhiInfo"), g_tr("zhengInfo"), g_tr("tongInfo"), g_tr("meiInfo")}

    local sxStr = {
        { name = g_tr("wu"), key = "force",tips = g_tr("wuInfo")  },
        { name = g_tr("zhi"),key = "intelligence",tips = g_tr("zhiInfo") },
        { name = g_tr("zheng"),key = "political",tips = g_tr("zhengInfo") },
        { name = g_tr("tong"), key = "governing",tips = g_tr("tongInfo") },
        { name = g_tr("mei"),key = "charm",tips = g_tr("meiInfo") },
    }

    local sxValue = GodGeneralMode:initEquiptSx(ndata.general_id)
    
    for i, var in ipairs(sxStr) do
        local sxPanel = self.godGeneralPanel:getChildByName( string.format("Panel_tiao_%d",i) )
        if sxPanel.addTips == nil then
            sxPanel:setTouchEnabled(true)
            g_itemTips.tipStr(sxPanel, var.name, var.tips)
        end
        
        sxPanel.key = var.key
        local sxNameTx = sxPanel:getChildByName("Text_20")
        sxNameTx:setString( var.name )

        local jcValueTx = sxPanel:getChildByName("Text_22")
        jcValueTx:setString( tostring(sxValue[var.key].sv) )

        local zbValueTx = sxPanel:getChildByName("Text_24")
        if sxValue[var.key].av > 0 then
            zbValueTx:setVisible(true)
            zbValueTx:setString("+" .. sxValue[var.key].av)
        else
            zbValueTx:setVisible(false)
        end

        table.insert(self.sxPanels,sxPanel)
    end
    
    local expBar = self.godGeneralPanel:getChildByName("LoadingBar_1")
    local expTx = self.godGeneralPanel:getChildByName("Text_sz")
    
    local nowLvConfig  = g_data.general_exp[lv]
    local nextLvConfig = g_data.general_exp[ lv + 1 ]

    --当前神武将经验
    local nowExp = 0
    --下一等级需要的经验
    local nextLvExp = 0
    
    if nextLvConfig then
        nextLvExp = nextLvConfig.general_exp - nowLvConfig.general_exp
        nowExp = ndata.exp - nowLvConfig.general_exp
        expTx:setString( string.format( "%d/%d", nowExp,nextLvExp) )
        expBar:setPercent( (nowExp/nextLvExp) * 100 )
    else
        expTx:setString( "MAX" )
        expBar:setPercent( 100 )
    end
    
    local upSkillBtn = self.godGeneralPanel:getChildByName("Image_jnd1_0")
    if upSkillBtn.isAddTouchListener == nil then
        upSkillBtn:addTouchEventListener(  function ( sender,evenType)
            if evenType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self:setVisible(false)
                local GodGeneralPlusLayer = require("game.uilayer.godGeneral.GodGeneralPlusLayer"):create( self._selNode.data.cdata.general_original_id )
                GodGeneralPlusLayer:removeCallBack( function (isChange)
                    self:setVisible(true)
                    if isChange then
                        self:updateOnceNode()
                    end
                end )
                g_sceneManager.addNodeForUI(GodGeneralPlusLayer)
            end
        end  )
        upSkillBtn.isAddTouchListener = true
    end
    
    local upBtn = self.godGeneralPanel:getChildByName("Image_jiahao")
    if upBtn.isAddTouchListener == nil then
        upBtn:addTouchEventListener(  function ( sender,evenType)
            if evenType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                local GodGeneralLvUp = require("game.uilayer.godGeneral.GodGeneralLvUp"):create( self._selNode.data )
                GodGeneralLvUp:addCallBack( function (isChange)
                    if isChange then
                        self:updateOnceNode()
                    end
                end )

                g_sceneManager.addNodeForUI(GodGeneralLvUp)
            end
        end)

        upBtn.isAddTouchListener = true
    end
    
    --local godRootConfig = GodGeneralMode:getGodGeneralConfigByRootId(cdata.root_id) --获取当前武将对应的神武将配置
    local godSkillId = cdata.general_combat_skill
    local godSkillConfig = g_data.combat_skill[godSkillId]

    self.godGeneralPanel:getChildByName("Text_jinngm"):setString(g_tr(godSkillConfig.skill_name))
    self.godGeneralPanel:getChildByName("Image_jnd1_0"):loadTexture( g_resManager.getResPath(cdata.skill_icon) )
    self.godGeneralPanel:getChildByName("Text_jinngm_0_0"):setString( "Lv." .. ndata.skill_lv )
    
    local skillLv = ndata.skill_lv or 1
    local resPath = GodGeneralMode:getSkillBorderRes( skillLv )
    self.godGeneralPanel:getChildByName("Image_jnd1"):loadTexture( resPath )
    local count,needCount,isMaxLv = GodGeneralMode:getNeedSkillUpItemCount( skillLv )

    if not isMaxLv then
        self.godGeneralPanel:getChildByName("Image_Red"):setVisible( (count >= needCount) and (lv > skillLv) )
        --self.godGeneralPanel:getChildByName("Image_Red"):setVisible(lv > skillLv)
    else
        self.godGeneralPanel:getChildByName("Image_Red"):setVisible(false)
    end

    local isLvUp = GodGeneralMode:getCanLvUp(data)
    self.godGeneralPanel:getChildByName("Image_Red_0"):setVisible(isLvUp)

    if lv >= table.nums(g_data.general_exp) then
        upBtn:setVisible(false)
    else
        upBtn:setVisible(true)
    end

end
--传入没有化神的普通武将配置表
function GodGeneralGodLayer:initNoGodGeneralLayer(data)
    
    self.godGeneralPanel:setVisible(false)
    self.noGodGeneralPanel:setVisible(true)
    
    --zhcn
    self.noGodGeneralPanel:getChildByName("Text_7"):setString(g_tr("godGeneralAdd1"))
    self.noGodGeneralPanel:getChildByName("Text_7_0"):setString(g_tr("godGeneralAdd2"))
   
    local cdata = data.cdata
    local ndata = data.ndata

    local nameStr = g_tr(cdata.general_name)
    local nameTx = self.noGodGeneralPanel:getChildByName("Text_shenmingzi")
    nameTx:setString(nameStr)
    
    --信物
    local xwPanel = self.noGodGeneralPanel:getChildByName("Panel_1")
    --条件
    local tjPanel = self.noGodGeneralPanel:getChildByName("Panel_2")
    --拥有武将
    local wjPanel = self.noGodGeneralPanel:getChildByName("Panel_3")
    wjPanel:setTouchEnabled(true)
    

    --拥有武将
    --进度
    local jdTx = tjPanel:getChildByName("Text_3")
    --条件
    local tjTx = tjPanel:getChildByName("Text_3_0")

    local tjIcon = tjPanel:getChildByName("Image_8")
    
    --isCom是否完成，
    --comStr进度
    --comDsc条件名称
    local comTb = GodGeneralMode:getGodConditionInfo3(data)


    dump(comTb)

    --isCom,comStr,comDsc,comPic,build

    jdTx:setString( comTb.comStr )

    if comTb.isCom then
        jdTx:setTextColor( cc.c3b( 30,230,30 ) )
    else
        jdTx:setTextColor( cc.c3b( 230,30,30 ) )
    end

    tjTx:setString( comTb.comDsc )
    
    tjIcon:loadTexture( g_resManager.getResPath(comTb.comPic) )

    if not comTb.isCom then
        tjIcon:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
    end

    tjPanel.build = comTb.build
    tjPanel.isCom = comTb.isCom
    tjPanel.menu1 = comTb.hmenu1
    tjPanel.menu2 = comTb.hmenu2
    
    if tjPanel.istouch == nil then
        tjPanel:setTouchEnabled(true)
        tjPanel:addTouchEventListener( function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                --条件不满足跳转
                if not tjPanel.isCom then
                    local buildData = g_PlayerBuildMode.FindBuild_high_OriginID(tjPanel.build)

                    if buildData then
                        local buildName = g_tr(g_data.build[tonumber(buildData.build_id)].build_name)
                        g_msgBox.show( g_tr("godGeneralJumpToBuild",{ name = buildName }),nil,nil,
                        function ( eventType )
                            --确定
                            if eventType == 0 then 
                                local pos = buildData.position
                                local function gotoSuccessHandler()
                                    if buildData then
                                        local tipMenuId = tjPanel.menu1
                                        if buildData.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng then --升级中
                                            tipMenuId = tjPanel.menu2 --升级加速
                                        end
                                        require("game.maplayer.smallBuildMenu").setTipMenuID(tipMenuId)
                                    else
                                        print("建筑不存在")
                                    end
                                end
                                require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(pos,gotoSuccessHandler)
                                self:close()
                            end
                        end , 1)
                    end
                end
            end
        end)
        tjPanel.istouch = true
    end

    --get_path
    --武将
    local wjPic = wjPanel:getChildByName("Image_db")
    wjPic:removeAllChildren()

    local general = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General,cdata.id, 1)
    general:setCountEnabled(false)
    general:setPosition( cc.p( wjPic:getContentSize().width/2,wjPic:getContentSize().height/2 ) )
    wjPic:addChild(general)

    local wjName = wjPanel:getChildByName("Text_3_0")
    wjName:setString(g_tr( "godGeneralHasIt",{ name = nameStr } ))
    local wjYYTx = wjPanel:getChildByName("Text_3")

    --信物ID
    local godRootConfig = GodGeneralMode:getGodGeneralConfigByRootId(cdata.root_id) --获取当前武将对应的神武将配置
    local godXwItemId = godRootConfig.consume[1][2]
    local godXwCount = g_BagMode.findItemNumberById(godXwItemId) 
    local itemConfig = g_data.item[godXwItemId]
    local itemIconID = itemConfig.res_icon
    local needItemCount = godRootConfig.consume[1][3]
    
    --信物图标的显示
    local xwPic = xwPanel:getChildByName("Image_db")
    xwPic:removeAllChildren()

    local xwNameTx = xwPanel:getChildByName("Text_3_0")
    local xwJdTx = xwPanel:getChildByName("Text_3")

    local iType = g_Consts.DropType.Props
    local iId = godXwItemId
    local iNum = godXwCount
    local itemIcon = require("game.uilayer.common.DropItemView").new(iType,iId,iNum)
    itemIcon:setPosition( cc.p( xwPic:getContentSize().width/2,xwPic:getContentSize().height/2 ) )
    itemIcon:setCountEnabled(false)
    xwPic:addChild(itemIcon)
    xwNameTx:setString( g_tr(itemConfig.item_name))
    --满足条件
    if godXwCount >= needItemCount then
        xwJdTx:setTextColor( cc.c3b( 30,230,30 ) )
        xwJdTx:setString(g_tr("godGeneralXWHave"))
    else
        itemIcon:getIconRender():getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
        xwJdTx:setTextColor( cc.c3b( 230,30,30 ) )
        xwJdTx:setString(string.format("%d/%d",godXwCount,1))
    end

    local godSkillId = godRootConfig.general_combat_skill
    local godSkillConfig = g_data.combat_skill[godSkillId]
    
    local godNewEquiptTx = self.noGodGeneralPanel:getChildByName("Text_7_1")
    godNewEquiptTx:setString(g_tr("godGeneralNewEquiptStr"))

    local godSkillNameTx = self.noGodGeneralPanel:getChildByName("Text_7_2")
    godSkillNameTx:setString(g_tr(godSkillConfig.skill_name))

    local godSkillDecTx = self.noGodGeneralPanel:getChildByName("Text_7_0_0")
    godSkillDecTx:setString(g_tr(godRootConfig.general_intro))
    
    local godSkillBorder = self.noGodGeneralPanel:getChildByName("Image_jn1")
    --没有化神的技能显示白边框
    godSkillBorder:loadTexture( GodGeneralMode:getSkillBorderRes( 1 ) )
    local godSkillIcon = self.noGodGeneralPanel:getChildByName("Image_jin2")
    godSkillIcon:loadTexture( g_resManager.getResPath(godRootConfig.skill_icon) )

    local movePosX = godSkillNameTx:getPositionX() + godSkillNameTx:getContentSize().width + 20
    godSkillBorder:setPositionX( movePosX + godSkillBorder:getContentSize().width/2 * godSkillBorder:getScale() )
    godSkillIcon:setPositionX( (movePosX + 6.5 * godSkillIcon:getScale() ) + godSkillIcon:getContentSize().width/2 * godSkillBorder:getScale() )

    --local godConfig = GodGeneralMode:getGodGeneralConfigByRootId(cdata.root_id)
    --g_itemTips.tipGodGeneralData(godSkillIcon,godConfig.id)
      g_itemTips.tipGodGeneralData(godSkillIcon,cdata)

    --化神按钮
    local bGodBtn = self.noGodGeneralPanel:getChildByName("Button_1")
    if bGodBtn.fx == nil then
        self:setChangeGodBtnFx(bGodBtn)
    end

    if ndata == nil then
        general:getIconRender():getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
        --bGodBtn:setEnabled(false)
        wjYYTx:setTextColor( cc.c3b( 230,30,30 ) )
        wjYYTx:setString(g_tr("godGeneralNoThis"))
        local function outPut(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                --local dropshowGroups = cdata.drop_show
                local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.General, cdata.id, function ()
                    self:close()
                    require("game.maplayer.changeMapScene").changeToWorld()
                    require("game.uilayer.mainSurface.mainSurfaceChat").createFindMosterHand()
                end)
                g_sceneManager.addNodeForUI(view)
            end
        end
        general:setTouchEnabled(true)
        general:addTouchEventListener( outPut )
    else
        --bGodBtn:setEnabled(true)
        wjYYTx:setTextColor( cc.c3b( 30,230,30 ) )
        wjYYTx:setString(g_tr("godGeneralXWHave"))
        --弹出武将属性TIPS
        g_itemTips.tip(general ,g_Consts.DropType.General,cdata.id)
    end
    
    --skill_icon
    bGodBtn.godRootConfig = godRootConfig
    bGodBtn.cdata = cdata
    bGodBtn.isHS = (ndata and godXwCount >= needItemCount and comTb.isCom)  --是否可以化生的条件
    
    bGodBtn.fx:setVisible(bGodBtn.isHS)
    --bGodBtn:setEnabled(bGodBtn.isHS)
    g_guideManager.registComponent(9999986,bGodBtn)
    
    if bGodBtn.isAddTouchListener == nil then
        bGodBtn:addTouchEventListener( function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                if sender.isHS then
                    local function callback(result,msgData)
                        g_guideManager.clearGuideLayer()
                        g_busyTip.hide_1()
                        if result == true then
                            g_musicManager.playEffect(g_data.sounds[5300003].sounds_path)
                            self:initGodData()
                            --传化身之后的原型ID给列表定位选中
                            self:loadList(sender.godRootConfig.general_original_id)
                            self:updateAllRP()
                            self:setChangeGodFx(bGodBtn.cdata)
                        end
                    end
                    g_busyTip.show_1()
                    g_sgHttp.postData("Pub/turnGod", { generalId = sender.cdata.general_original_id,steps = g_guideManager.getToSaveStepId() }, callback)
                else
                    g_airBox.show(g_tr("godGeneralConditionsError"))
                end
            end
        end )
        bGodBtn.isAddTouchListener = true
    end
    

    itemIcon.isJump = (godXwCount >= needItemCount)
    itemCData = bGodBtn.cdata
    itemIcon:setTouchEnabled(true)
    itemIcon:addTouchEventListener( function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            --没有获得
            --张辽特殊处理
            if not itemIcon.isJump then
                if itemCData.id == 2009301 then
                    g_airBox.show(g_tr("godGetPathZhangLiao"))
                else
                    g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(1,function ()
                        self:updateOnceNode()
                    end ))
                end
            end
            --self:setZOrder(1)
            --self:close()
        end
    end)
end

function GodGeneralGodLayer:updateAllRP()
    if self.nodes == nil then return end
    
    for _ ,node in ipairs(self.nodes) do
        local cdata = node.data.cdata
        local newData = self:getGodGeneralData(cdata.general_original_id)
        node.data = newData
        --如果没有找到神武将就寻找普通武将数据判断红点
        local redData = nil
        if node.data.ndata == nil then
            local _cdata = GodGeneralMode:getGeneralConfigByRootId(cdata.root_id )
            local _ndata = g_GeneralMode.getOwnedGeneralByOriginalId(_cdata.general_original_id)
            redData = {}
            redData.cdata = _cdata
            redData.ndata = _ndata
        else
            redData = newData
        end
        
        node.red:setVisible(GodGeneralMode:isShowRP(redData))
    end
end

function GodGeneralGodLayer:updateOnceNode()
    
    local oldLevel = 0
    local oldSxValue = nil
    local newSxValue = nil

    if self._selNode.data.ndata then
        oldLevel = self._selNode.data.ndata.lv
        oldSxValue = GodGeneralMode:initEquiptSx(self._selNode.data.ndata.general_id,self._selNode.data.ndata)
    end

    local newData = self:getGodGeneralData(self._selNode.data.cdata.general_original_id)
    
    if newData.ndata then
        newSxValue = GodGeneralMode:initEquiptSx(newData.ndata.general_id)
    end

    self._selNode.data = newData
                
    self:changeGeneral(self._selNode.data)

    self:updateAllRP()
    
    --计算增加值
    if newSxValue then
        local addAll = {}
        for key, var in pairs(newSxValue) do
            addAll[key] = (var.av + var.sv) - (oldSxValue[key].av + oldSxValue[key].sv)
        end

        if newData.ndata.lv > oldLevel then
            self:upLvFx()
            self:sxUpAction(addAll)
        end
    end
end

function GodGeneralGodLayer:upLvFx()
    
    local size = self.root:getContentSize()

    local armature , animation
    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            armature:removeFromParent()
        end
    end 
  
    armature , animation = g_gameTools.LoadCocosAni(
        "anime/Effect_HuaShenKaPaiShengJi/Effect_HuaShenKaPaiShengJi.ExportJson"
        , "Effect_HuaShenKaPaiShengJi"
        , onMovementEventCallFunc
    )

    armature:setPosition(cc.p(size.width/2, size.height/2 + 9))
    --armature:setScale(1.3)
    self.root:addChild(armature)
    animation:play("XuLie")
end

function GodGeneralGodLayer:sxUpDis()
    for idx, node in ipairs(self.sxPanels) do
        local panel = node:getChildByName("Panel")
        local addTx = panel:getChildByName("Text")
        addTx:setPositionY(-15)
        --addTx:setVisible(false)
    end
end

function GodGeneralGodLayer:sxUpAction(addVer)
    for idx, node in ipairs(self.sxPanels) do
        local panel = node:getChildByName("Panel")
        local var = addVer[node.key]
        local addTx = panel:getChildByName("Text")
        if var > 0 then
            addTx:setString( tostring(var) .. "↑" )
            --addTx:setVisible(true)
            addTx:runAction( cc.Sequence:create( cc.MoveTo:create( 0.5,cc.p( addTx:getPositionX(),15 ) ), cc.DelayTime:create(3),cc.MoveTo:create( 0.3,cc.p( addTx:getPositionX(),-15 ) ) ) )
        end
    end
end

function GodGeneralGodLayer:godGeneralFx(icon)
    local armature, animation = g_gameTools.LoadCocosAni("anime/Effect_ChouKaKaPai/Effect_ChouKaKaPai.ExportJson", "Effect_ChouKaKaPai")
	armature:setPosition(cc.p(icon:getContentSize().width/2,icon:getContentSize().height/2 ))
	icon:addChild(armature)
	animation:play("Animation1")
end

function GodGeneralGodLayer:setChangeGodFx(cdata)
    
    self:setMaskFx()

    local armature, animation
    local cData = cdata

    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            armature:removeFromParent()
            g_guideManager.execute()
        end
    end

    local function onFrameEventCallFunc(bone , frameEventName , originFrameIndex , currentFrameIndex)
        if frameEventName == "ChuXian" then
            local bone = armature:getBone("ShenWuJian")
            armature:getBone("Wujian"):setVisible(false)
            bone:setVisible(true)
            local gcData = GodGeneralMode:getGodGeneralConfigByRootId(cData.root_id)
            local bone = armature:getBone("Wujian")
            local image = ccui.ImageView:create(g_resManager.getResPath(gcData.general_big_icon))
            image:setPositionX( image:getPositionX() + 13 )
            image:setPositionY( image:getPositionY() + 3 )
            bone:addDisplay( image,0 )
        end
    end

    armature, animation = g_gameTools.LoadCocosAni("anime/Effect_WuJiangHuaShen/Effect_WuJiangHuaShen.ExportJson", "Effect_WuJiangHuaShen", onMovementEventCallFunc,onFrameEventCallFunc)
	armature:setPosition(cc.p(self.root:getContentSize().width/2 + 35,self.root:getContentSize().height/2 ))
	self.root:addChild(armature)

    local bone = armature:getBone("Wujian")
    local image = ccui.ImageView:create(g_resManager.getResPath(cData.general_big_icon))
    image:setPositionX( image:getPositionX() + 15 )
    image:setPositionY( image:getPositionY() + 5 )
    bone:addDisplay( image,0 )

	animation:play("Animation1")
end

function GodGeneralGodLayer:setMaskFx()

    local size = self.root:getContentSize()

    --遮挡层
    local lyout = ccui.Layout:create()
    lyout:setSize( size )
    lyout:setTouchEnabled(true)

    local armature , animation
    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            lyout:removeFromParent()
            armature:removeFromParent()
        end
    end 
  
    armature , animation = g_gameTools.LoadCocosAni(
        "anime/Effect_HuaShenKaPaiShengJiMask/Effect_HuaShenKaPaiShengJiMask.ExportJson"
        , "Effect_HuaShenKaPaiShengJiMask"
        , onMovementEventCallFunc
    )

    armature:setPosition(cc.p(size.width/2, size.height/2 + 9))
    --armature:setScale(1.3)
    self.root:addChild(armature)
    self.root:addChild(lyout)
    animation:play("Mask") 
end

function GodGeneralGodLayer:setChangeGodBtnFx(node)
    local armature , animation = g_gameTools.LoadCocosAni(
        "anime/Effect_HuaShenAnNiuXunHuan/Effect_HuaShenAnNiuXunHuan.ExportJson"
        , "Effect_HuaShenAnNiuXunHuan"
    )
    armature:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
    node:addChild(armature)
    animation:play("Animation1")
    node.fx = armature
end

function GodGeneralGodLayer:jumpNode(gid)
    if #self.nodes > 0 then
        for _ ,node in ipairs(self.nodes) do
            if node.data.cdata.general_original_id == gid then
                self._selNode.high:setVisible(false)
                self._selNode = node
                self._selNode.high:setVisible(true)
                self:changeGeneral(self._selNode.data)
                break
            end
        end
    end
end

function GodGeneralGodLayer:onExit()
    m_Root = nil
end


return GodGeneralGodLayer


