
--神龛武将化神UI

local GodGeneralToGod = {}
setmetatable(GodGeneralToGod,{__index = _G})
setfenv(1, GodGeneralToGod)

local GodGeneralMode = require("game.uilayer.godGeneral.GodGeneralMode"):instance()

local widgetUI
local btnToGod --化神按钮
local m_godData 
local m_usrCallback --通知外部,本地数据已经更新
local m_delegate 

--初始化UI,进入神龛界面只执行一次，比如注册按钮点击事件
function initUI(widget, callback)
  if nil == widget then return end 

  widgetUI = widget 
  m_usrCallback = callback 

  --化神按钮
  btnToGod = widgetUI:getChildByName("Button_hs")
  btnToGod:getChildByName("Text_77"):setString(g_tr("godGeneralGod"))
  btnToGod:addClickEventListener(onStarToGod)
end 

function deInitUI()
  widgetUI = nil 
  btnToGod = nil 
  m_usrCallback = nil 
  m_godData = nil 
  m_delegate = nil 
end 

function setDelegate(delegate)
  m_delegate = delegate 
end 

--data包含 cdata 和 ndata, 此时在这里 ndata必定为nil
function showToGodInfo(data)
  print("showToGodInfo")

  if nil == widgetUI or nil == data or nil == data.cdata then return end 
 
  m_godData = data 

  --定位
  widgetUI:getChildByName("Text_dw1"):setString(g_tr("godGenPosition"))
  widgetUI:getChildByName("Text_dw2"):setString(g_tr(data.cdata.general_intro))

  --新增
  widgetUI:getChildByName("Text_xz"):setString(g_tr("godGenAddNew"))
  local lbAdd1 = widgetUI:getChildByName("Text_xz1")
  local lbAdd2 = widgetUI:getChildByName("Text_xz2")
  local lbAdd3 = widgetUI:getChildByName("Text_xz3")
  local lbAdd4 = widgetUI:getChildByName("Text_xz4")
  lbAdd1:setString(g_tr("godGeneralAdd1"))
  lbAdd2:setString(g_tr("godGeneralNewEquiptStr"))
  lbAdd3:setString(g_tr("godGeneralAdd2"))
  lbAdd4:setString(g_tr(g_data.combat_skill[data.cdata.general_combat_skill].skill_name))
  lbAdd2:setPositionX(lbAdd1:getPositionX()+lbAdd1:getContentSize().width+10)
  lbAdd4:setPositionX(lbAdd3:getPositionX()+lbAdd3:getContentSize().width+10)

  --新增的技能icon
  local imgSkillBg = widgetUI:getChildByName("Image_ding1")
  local imgSkill = widgetUI:getChildByName("Image_sun")
  imgSkillBg:loadTexture( GodGeneralMode:getSkillBorderRes( 1 ) ) --没有化神的技能显示白边框
  imgSkill:loadTexture( g_resManager.getResPath(data.cdata.skill_icon) )
  local pos_x = lbAdd4:getPositionX()+lbAdd4:getContentSize().width + imgSkillBg:getContentSize().width/2 + 10
  imgSkillBg:setPositionX(pos_x)
  imgSkill:setPositionX(pos_x)
  g_itemTips.tipGodGeneralData(imgSkill, data.cdata)

  --条件
  local nodeCondition = widgetUI:getChildByName("Panel_tj")
  nodeCondition:getChildByName("Text_tj"):setString(g_tr("godGenCondition")) 

  --1)信物
  local xw_img = nodeCondition:getChildByName("Image_ding1")
  local xw_id = data.cdata.consume[1][2]
  local xw_need = data.cdata.consume[1][3]
  local xw_own = g_BagMode.findItemNumberById(xw_id)
  xw_img:removeAllChildren()
  local icon1 = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props,xw_id,xw_own) 
  if icon1 then 
    icon1:setPosition(cc.p( xw_img:getContentSize().width/2,xw_img:getContentSize().height/2 ) )
    icon1:setCountEnabled(false)
    xw_img:addChild(icon1) 
    -- g_itemTips.tip(icon1, g_Consts.DropType.Props,xw_id)
  end 

  local lbXWFlag = nodeCondition:getChildByName("Text_dj1")
  if xw_own >= xw_need then
    lbXWFlag:setTextColor( cc.c3b( 30,230,30 ) )
    lbXWFlag:setString(g_tr("godGeneralXWHave"))
  else
    lbXWFlag:setTextColor( cc.c3b( 230,30,30 ) )
    lbXWFlag:setString(string.format("%d/%d",xw_own, xw_need))
    if icon1 then 
      icon1:getIconRender():getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )    
      addSourcePath(icon1, g_Consts.DropType.Props, xw_id) 
    end 
  end 

  nodeCondition:getChildByName("Text_nz1"):setString( g_tr(g_data.item[xw_id].item_name))
  print("xw_id, xw_need, xw_own", xw_id, xw_need, xw_own)

  --2)武将
  local gen_img = nodeCondition:getChildByName("Image_ding2")
  local lbGenFlag = nodeCondition:getChildByName("Text_dj2")
  gen_img:removeAllChildren()
  local common_gen = GodGeneralMode:getGeneralConfigByRootId(data.cdata.root_id ) --对应的普通武将
  local common_own = g_GeneralMode.getOwnedGeneralByOriginalId(common_gen.general_original_id)
  local gen_icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General,common_gen.id, 1)
  gen_icon:setCountEnabled(false)
  gen_icon:setPosition( cc.p( gen_img:getContentSize().width/2,gen_img:getContentSize().height/2 ) )
  gen_img:addChild(gen_icon)

  if nil == common_own then --未拥有该普通武将
    gen_icon:getIconRender():getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
    lbGenFlag:setTextColor( cc.c3b( 230,30,30 ) )
    lbGenFlag:setString(g_tr("godGeneralNoThis"))
    local function outPut(sender,eventType)
      if eventType == ccui.TouchEventType.ended then
        local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.General, common_gen.id, function ()
          if m_delegate then 
            m_delegate:close()
          end 
          require("game.maplayer.changeMapScene").changeToWorld()
          require("game.uilayer.mainSurface.mainSurfaceChat").createFindMosterHand()
        end)
        g_sceneManager.addNodeForUI(view)
      end
    end
    gen_img:setTouchEnabled(true)
    gen_img:addTouchEventListener( outPut )  
  else 
    lbGenFlag:setTextColor( cc.c3b( 30,230,30 ) )
    lbGenFlag:setString(g_tr("godGeneralXWHave"))
    --弹出武将属性TIPS
    g_itemTips.tip(gen_img ,g_Consts.DropType.General,common_gen.id)
  end 

  nodeCondition:getChildByName("Text_nz2"):setString(g_tr(common_gen.general_name))
  print("common_gen id =", common_gen.general_original_id)


  --3)条件3
  local comTb = GodGeneralMode:getGodConditionInfo3(data.cdata) 
  dump(comTb, "comTb")

  --显示icon并且根据条件来跳转
  local img_Cond = nodeCondition:getChildByName("Image_ding3")
  img_Cond:removeAllChildren()
  local icon3 = g_resManager.getRes(comTb.comPic)
  if icon3 then 
    icon3:setPosition(cc.p( img_Cond:getContentSize().width/2,img_Cond:getContentSize().height/2 ) )
    icon3:setScale((img_Cond:getContentSize().width-8) / icon3:getContentSize().width)
    img_Cond:addChild(icon3) 
    if not comTb.isCom then
      icon3:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
    end 

    icon3:setTouchEnabled(true)
    local function onTouchIcon3(sender,eventType) 
      if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        --条件不满足跳转
        if not comTb.isCom then
          local buildData = g_PlayerBuildMode.FindBuild_high_OriginID(comTb.build)
          if buildData then
            local buildName = g_tr(g_data.build[tonumber(buildData.build_id)].build_name)
            g_msgBox.show( g_tr("godGeneralJumpToBuild",{ name = buildName }),nil,nil,
              function ( eventType )
                --确定
                if eventType == 0 then 
                    local pos = buildData.position
                    local function gotoSuccessHandler()
                      if buildData then
                        local tipMenuId = comTb.menu1
                        if buildData.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng then --升级中
                          tipMenuId = comTb.menu2 --升级加速
                        end
                        require("game.maplayer.smallBuildMenu").setTipMenuID(tipMenuId)
                      else
                        print("建筑不存在")
                      end
                    end
                    require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(pos,gotoSuccessHandler)
                    if m_delegate then 
                      m_delegate:close()
                    end 
                end

              end , 1)
          end
        end
      end
    end 

    icon3:addTouchEventListener(onTouchIcon3)
  end 

  local lbConFlag = nodeCondition:getChildByName("Text_dj3")
  lbConFlag:setString( comTb.comStr )
  if comTb.isCom then
    lbConFlag:setTextColor( cc.c3b( 30,230,30 ) )
  else
    lbConFlag:setTextColor( cc.c3b( 230,30,30 ) )
  end

  nodeCondition:getChildByName("Text_nz3"):setString( comTb.comDsc )


  --化神按钮
  btnToGod.isOk = xw_own >= xw_need and common_own and comTb.isCom 
  btnToGod.common_gen = common_gen 
  btnToGod.god_gen = data.cdata 
  GodGeneralMode:addToGodAnim(btnToGod, btnToGod.isOk) 

  g_guideManager.registComponent(9999986, btnToGod)
end 

--获得途径
function addSourcePath(icon, itype, id)
  local function onClickIcon(sender)
    local view = require("game.uilayer.common.ItemPathView").new(sender.itype, sender.id, function()
                    if m_delegate then 
                      m_delegate:close()
                    end 
                  end)
    g_sceneManager.addNodeForUI(view) 
  end 
  icon.itype = itype 
  icon.id = id 
  icon:setTouchEnabled(true)
  icon:addClickEventListener(onClickIcon)
end 

function onStarToGod(sender)
  print("onStarToGod")

  g_musicManager.playEffect(g_SOUNDS_SURE_PATH) 

  if not btnToGod.isOk then 
    g_airBox.show(g_tr("godGeneralConditionsError"))
    return 
  end 

  local function callback(result,msgData) 
    g_guideManager.clearGuideLayer()

    if nil == widgetUI then return end 

    g_busyTip.hide_1()
    if result == true then
      g_musicManager.playEffect(g_data.sounds[5300003].sounds_path)

      if m_usrCallback then 
        m_usrCallback(btnToGod.common_gen, btnToGod.god_gen)
      end 
    end 
  end
  g_busyTip.show_1()
  g_sgHttp.postData("Pub/turnGod", { generalId = btnToGod.common_gen.general_original_id,steps = g_guideManager.getToSaveStepId() }, callback) 
end 




return GodGeneralToGod 

