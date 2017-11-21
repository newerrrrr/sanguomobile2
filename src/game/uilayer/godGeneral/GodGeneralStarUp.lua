
--神龛武将升星UI

local GodGeneralStarUp = {}
setmetatable(GodGeneralStarUp,{__index = _G})
setfenv(1, GodGeneralStarUp)

local GodGeneralMode = require("game.uilayer.godGeneral.GodGeneralMode"):instance()

local widgetUI
local godData 
local usrCallback --通知外部,本地数据已经更新
local richTips 
local m_delegate 

--初始化UI,进入神龛界面只执行一次，比如注册按钮点击事件
function initUI(widget, callback)
  if nil == widget then return end 

  widgetUI = widget 
  usrCallback = callback 

  local btnStarup = widgetUI:getChildByName("Panel_starup"):getChildByName("Button_starup")
  --新手注册升星按钮
  g_guideManager.registComponent(9999981,btnStarup)
  btnStarup:addClickEventListener(onStarUp)
  --府衙等级>13级时开放升星功能
  local needBuildLv = tonumber(g_data.starting[106].data) 
  local mainCityLevel = g_PlayerBuildMode.getMainCityBuilding_lv()
  btnStarup:setEnabled(mainCityLevel >= needBuildLv) 

  local lbOpenTips = btnStarup:getChildByName("Text_1_0")
  lbOpenTips:setString(g_tr("godGenStarupOpenTips", {lv = needBuildLv}))
  lbOpenTips:setVisible(false == btnStarup:isEnabled())
end 

function deInitUI()
  widgetUI = nil 
  richTips = nil 
  usrCallback = nil 
  godData = nil 
  m_delegate = nil 
end 


function updateInfo(data)
  print("GodGeneralStarUp:updateInfo")

  if nil == widgetUI or nil == data or nil == data.ndata then return end 

  godData = data 

  local function onTouchItem(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
      local id = sender:getTag() 
      local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props, id)
      view:keepShowByCloseCallback(function() updateInfo(godData) end)
      if m_delegate then 
        m_delegate:addChild(view)
      else 
        g_sceneManager.addNodeForUI(view) 
      end 
    end 
  end 

  local nodeStarup = widgetUI:getChildByName("Panel_starup")
  local nodeSoul = widgetUI:getChildByName("Panel_soul")
  local lbTitle = widgetUI:getChildByName("Text_s1")

  if data.ndata.star_lv == 15 then --已满星,显示化魂信息
    nodeStarup:setVisible(false)
    nodeSoul:setVisible(true)

    lbTitle:setString(g_tr("godGeneralStar"))

    nodeSoul:getChildByName("Text_23"):setString(g_tr("generalStarLevelMax"))
    local nodeAnim = nodeSoul:getChildByName("Panel_anim")
    nodeAnim:removeAllChildren()
    do
      local projName = "Effect_ManJiPeiTaoGlow"
      local animPath = "anime/"..projName.."/"..projName..".ExportJson"
      local armature, animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
         if 0 == eventType then --start
         elseif 1 == eventType then --end             
         end
      end)
      nodeAnim:addChild(armature)
      animation:play("Animation1")
    end
    
    do
      local projName = "Effect_ManJiPeiTaoGlowStar"
      local animPath = "anime/"..projName.."/"..projName..".ExportJson"
      local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
         if 0 == eventType then --start
         elseif 1 == eventType then --end             
         end
      end)
      nodeAnim:addChild(armature)
      animation:play("Animation1")
    end


  else --未满星
    nodeStarup:setVisible(true)
    nodeSoul:setVisible(false)    
    lbTitle:setString(g_tr("godGeneralStar"))

    local pic = nodeStarup:getChildByName("Image_1")
    pic:removeAllChildren()
    local mat_s, mat_b = GodGeneralMode:getStarUpConsume(data.ndata) 
    print("general_id, star_lv =", data.ndata.general_id, data.ndata.star_lv)
    dump(mat_s, "===mat_s")
    dump(mat_b, "===mat_b")

    --小星级消耗
    local canEnhance = false 
    if mat_s then 
      local itemId = mat_s[2]
      print("itemId", itemId)
      local ownCount = g_BagMode.findItemNumberById(itemId) 
      local lbCount = nodeStarup:getChildByName("Text_6") 
      local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, itemId, (ownCount or 0))
      if icon then 
        icon:setScale(pic:getContentSize().width/icon:getContentSize().width)
        icon:setPosition(cc.p(icon:getContentSize().width/2, icon:getContentSize().height/2))
        icon:setTag(itemId)
        icon:setCountEnabled(false)
        icon:setNameVisible(true)
        icon:setTouchEnabled(true)
        icon:addTouchEventListener(onTouchItem)      
        pic:addChild(icon) 
      end 
      lbCount:setString(string.format("%d/%d", ownCount, mat_s[3]))
      canEnhance = ownCount >= mat_s[3] 
      lbCount:setTextColor(canEnhance and cc.c3b( 30,230,30 ) or cc.c3b( 230,30,30 )) 
    end 

    --大星级提升消耗数量文字提示
    if mat_b then 
      local str = g_tr("godGenStarupTips", {num = mat_b[3]})
      if nil == richTips then 
        local lbTips = nodeStarup:getChildByName("Text_x2") 
        richTips = g_gameTools.createRichText(lbTips, str) 
      else 
        richTips:setRichText(str)
      end 
    end 

    --进度显示
    --每个星级升级区间细分成5段, 返回第几段, 范围在 0-4 
    local segment = data.ndata.star_lv%5 
    for i = 1, 5 do 
      nodeStarup:getChildByName("Image_lan"..i):setVisible(segment >= i)
    end 

    --按钮状态
    local btnStarup = nodeStarup:getChildByName("Button_starup") 
    if segment == 4 then 
      btnStarup:getChildByName("Text_1"):setString(g_tr("godGeneralStar"))
    else 
      btnStarup:getChildByName("Text_1"):setString(g_tr("godGenStarupEnhance"))
    end 

    --可提升时按钮处添加动画
    if btnStarup:isEnabled() then 
      GodGeneralMode:addCanStarEnhanceAnim(btnStarup, canEnhance) 
    end 
  end 
end 

function onStarUp()
  g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

  local baseproperty1 = g_GeneralMode.getGeneralPropertyByGeneralId(godData.ndata.general_id) 

  local function onStarUpResult(result,msgData)
    if result then 
      local genSrvData = g_GeneralMode.getOwnedGeneralByOriginalId(godData.ndata.general_id) 
      if genSrvData then 
        local star_old = math.floor(godData.ndata.star_lv/5)+1
        local star_new = math.floor(genSrvData.star_lv/5)+1 
        print("onStarUpResult: star_old, star_new", star_old, star_new)
        if star_new > star_old then --显示升星成功弹框
          local pop = require("game.uilayer.godGeneral.GodGeneralStarUpPop").new(godData.ndata, genSrvData)
          g_sceneManager.addNodeForUI(pop) 
        else 
          GodGeneralMode:addStarLvupTextAnim(widgetUI, cc.p(-400, 0))  
          --上浮属性变化
          local baseproperty2 = g_GeneralMode.getGeneralPropertyByGeneralId(genSrvData.general_id) 
          GodGeneralMode:toastGenBaseAttrChanged(widgetUI, cc.p(-500, -20), baseproperty1, baseproperty2)
        end 

        --更新UI
        godData.ndata = genSrvData 
        updateInfo(godData)
        if usrCallback then 
          usrCallback() 
        end 
      end 
    end 
    
    g_guideManager.execute()
  end 

  if godData and godData.ndata then 
    if GodGeneralMode:canStarup(godData.ndata) then 
      g_sgHttp.postData("Pub/starLvUp", {generalId = godData.ndata.general_id}, onStarUpResult) 
    else 
      g_airBox.show(g_tr("no_enough_material"))
    end 
  end 
end 

function setDelegate(delegate)
  m_delegate = delegate 
end 

return GodGeneralStarUp 

