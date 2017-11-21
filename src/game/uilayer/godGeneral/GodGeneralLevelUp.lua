
--神龛武将升级UI
--材料消耗由于支持长按吃经验,为了避免数据同步麻烦, 材料消耗部分一直使用原始服务器数据进行维护,
--当等级提升时使用新数据只更新武将基础属性


local GodGeneralLevelUp = {}
setmetatable(GodGeneralLevelUp,{__index = _G})
setfenv(1, GodGeneralLevelUp)

local GodGeneralMode = require("game.uilayer.godGeneral.GodGeneralMode"):instance()

local widgetUI
local materials    --材料table
local touchIndex = 1 --材料 index
local isMoving = false --列表滑动
local godDataOld 
local godDataNew 
local preLevel = 0 
local usrCallback --通知外部,本地数据已经更新

--初始化UI,进入神龛界面只执行一次，比如注册按钮点击事件
function initUI(widget, callback)
  if nil == widget then return end 

  widgetUI = widget 
  usrCallback = callback 

  local node = widgetUI:getChildByName("Panel_dj")
  node:getChildByName("text_dj1"):setString(g_tr("level"))

  local lbTips = node:getChildByName("Text_nr1") 
  local str = g_tr("godGenTouchToLvUp")
  -- lbTips:setString(str)
  -- lbTips:setTextAreaSize(cc.size(400, 0)) 
  g_gameTools.createRichText(lbTips, str) 

  local listView = node:getChildByName("ListView_1") 
  listView:removeAllChildren() 

  local function onScrollViewEvent(sender, eventType) 
    if eventType == ccui.ScrollviewEventType.scrolling then
      print("----moving") 
      isMoving = true 
    end 
  end 

  listView:setTouchEnabled(true)
  listView:addScrollViewEventListener(onScrollViewEvent) 
  -- listView:addEventListener(onSelectItem) 
end 

function deInitUI()
  widgetUI = nil 
  materials = nil 
  touchIndex = 1 
  godDataOld = nil 
  godDataNew = nil 
  usrCallback = nil 
  preLevel = 0 
end 

local function initMat()
  --材料及其对应经验
  materials = {}
  for _, v in pairs(g_data.item) do
    if tonumber(v.item_original_id) == tonumber(g_Consts.UseItemType.GodGenerralExp) then 
      local dropId = g_data.item[tonumber( v.id )].drop[1]
      local dropConfig = g_data.drop[ tonumber(dropId) ].drop_data[1]
      --ownCount:拥有的个数; totalSelCount:累计选择个数; perSel:该次单击/长按选择个数; perExp:每个材料对应获得的经验
      table.insert( materials, {item = v, ownCount = 0, totalSelCount = 0, perSel = 0, perExp = dropConfig[3]} ) 
      print("===item id:", v.id)
    end 
  end
  table.sort(materials,function (a,b) return  a.item.priority <  b.item.priority end) 
end 

local function getTotalSelExp() 
  local exp = 0 
  for k, v in pairs(materials) do 
    exp = exp + v.totalSelCount * v.perExp 
  end 

  return exp 
end 

--根据经验更新等级进度UI
local function updateLevelPercent(exp)
  if nil == widgetUI then return end 

  local destLv = GodGeneralMode:getGenLevelByExp(exp) 
  local cfg1 = g_data.general_exp[destLv] 
  local cfg2 = g_data.general_exp[destLv+1] 
  local percent = 100 
  if cfg2 then 
    percent = math.min(100, 100*(exp - cfg1.general_exp)/(cfg2.general_exp - cfg1.general_exp))
  end 
  local nodeLv = widgetUI:getChildByName("Panel_dj")
  nodeLv:getChildByName("Text_dj2"):setString(""..destLv) 
  nodeLv:getChildByName("LoadingBar_1"):setPercent(percent) 
  nodeLv:getChildByName("Text_bfb1"):setString(string.format("%d%%", percent)) 

  return destLv 
end 

local function updateCanLevelupAnim(exp)
  if nil == widgetUI then return end 
  
  local canLvup = false 
  local destLv = GodGeneralMode:getGenLevelByExp(exp) 
  local cfg1 = g_data.general_exp[destLv] 
  local cfg2 = g_data.general_exp[destLv+1] 
  if cfg2 then 
    local needExp = cfg2.general_exp - exp
    local ownExp = 0 
    for k, v in pairs(materials) do 
      ownExp = ownExp + v.ownCount * v.perExp 
    end
    canLvup = ownExp >= needExp     
  end 

  local root = widgetUI:getChildByName("Panel_dj")
  local listView = root:getChildByName("ListView_1")
  local nodeAnim = root:getChildByName("Panel_anim")  
  if canLvup then 
    GodGeneralMode:addCanLevelupAnim(nodeAnim)
  else 
    nodeAnim:removeAllChildren()
  end 
end 


--材料列表(一直使用原始数据来维护),每个武将只执行一次
local function initMatList()
  if nil == widgetUI then return end 
  if nil == godDataOld then return end 

  print("GodGeneralLevelUp: initMatList")
  preLevel = godDataOld.ndata.lv 

  initMat()

  local listView = widgetUI:getChildByName("Panel_dj"):getChildByName("ListView_1") 
  listView:removeAllChildren()

  --吃掉一个材料,更新icon数字及经验进度; bNotLoop:单击时bNotLoop为true
  local function addOneMatExp(bNotLoop)
    print("addOneMatExp") 

    if nil == widgetUI then return end 

    if isMoving then return end 

    local item = listView:getItem(touchIndex-1):getChildByTag(touchIndex)
    if item then 
      local count = item:getCount()
      if count > 0 then 
        --更新进度
        local addExp = getTotalSelExp() 
        local totleExpMax = g_data.general_exp[table.nums(g_data.general_exp)].general_exp --最大等级对应经验
        
        if godDataOld.ndata and godDataOld.ndata.exp + addExp < totleExpMax then 
          item:setCount(count-1)
          materials[touchIndex].ownCount = count-1 --剩余个数
          materials[touchIndex].perSel = materials[touchIndex].perSel + 1 --本次单击/长按选择个数
          materials[touchIndex].totalSelCount = materials[touchIndex].totalSelCount + 1 --累计选择个数
          
          addExp = addExp + materials[touchIndex].perExp 
          
          --根据经验获取对应等级
          local nextLv = updateLevelPercent(godDataOld.ndata.exp + addExp) 
          print("===curExp, addExp, preLv, nextLv =", godDataOld.ndata.exp, addExp, preLevel, nextLv)
          local isLevelup = nextLv > preLevel 
          preLevel = nextLv 

          --更新可升级动画
          updateCanLevelupAnim(godDataOld.ndata.exp + addExp)

          if bNotLoop then return end 

          --长按过程中满级则后台更新数据,播放升级动画 
          if isLevelup then 
            startAddExp(materials[touchIndex].item.id, materials[touchIndex].perSel)
          end 
          g_autoCallback.addCocosList(addOneMatExp , 0.1) 
        end 
      end 
    end 
  end 

  --长按检测
  local function delayCheckLongPress()
    print("delayCheckLongPress") 
    if nil == widgetUI then return end 

    if isMoving then return end 

    --长按吃经验
    g_autoCallback.addCocosList(addOneMatExp , 0.2)
  end 


  local function onTouchItem(sender,eventType)
    if eventType == ccui.TouchEventType.began then 
      touchIndex = sender:getTag()
      isMoving = false 
      materials[touchIndex].perSel = 0 --本次单击/长按选择个数清零
      
      g_autoCallback.removeCocosList(addOneMatExp)
      g_autoCallback.removeCocosList(delayCheckLongPress)
      g_autoCallback.addCocosList(delayCheckLongPress , 0.8)
      
    elseif eventType == ccui.TouchEventType.moved then
      local pos = sender:convertToNodeSpace(sender:getTouchMovePosition())
      -- print("@@@ touch moved, pos=", pos.x, pos.y) 
      local rect = cc.rect(0, 0, sender:getContentSize().width-5, sender:getContentSize().height-5)
      if not cc.rectContainsPoint(rect, pos) then 
        print("is moving .....")
        isMoving = true 
        startAddExp(materials[touchIndex].item.id, materials[touchIndex].perSel)
      end 

    elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
      g_autoCallback.removeCocosList(addOneMatExp)
      g_autoCallback.removeCocosList(delayCheckLongPress)      

      addOneMatExp(true) --多吃一次

      --发送服务器; 只发送本次单击/长按选择的个数
      print("eat index, count=", touchIndex, materials[touchIndex].perSel) 
      if materials[touchIndex].perSel > 0 then 
        startAddExp(materials[touchIndex].item.id, materials[touchIndex].perSel)
      end
    end
  end 

  --加载列表
  listView:setScrollBarEnabled(false)
  listView:setSwallowTouches(false) 

  for k, v in pairs(materials) do 
    local count = g_BagMode.findItemNumberById(v.item.id) 
    local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props, v.item.id, count)
    if icon then 
      local scale = (listView:getContentSize().height-40)/icon:getContentSize().height
      local layout = ccui.Layout:create()
      layout:setSize(cc.size(icon:getContentSize().width*scale+10, listView:getContentSize().height))
      icon:setScale(scale)
      icon:setNameVisible(true)
      icon:setTag(k)
      icon:setTouchEnabled(true)
      icon:addTouchEventListener(onTouchItem)
      icon:setPosition(layout:getContentSize().width/2, layout:getContentSize().height-icon:getContentSize().height/2)
      layout:addChild(icon)
      listView:pushBackCustomItem(layout) 

      materials[k].ownCount = count      
    end 
  end
end 


--显示基础属性
local function updateAttrInfo(data)
  print("GodGeneralLevelUp: updateAttrInfo")
  if nil == widgetUI or nil == data then return end 

  --["attr1"] = "武",
  --["attr2"] = "智",
  --["attr3"] = "统",
  --["attr4"] = "魅",
  --["attr5"] = "政",
  local strTips = {g_tr("wuInfo"), g_tr("zhiInfo"), g_tr("tongInfo"), g_tr("meiInfo"), g_tr("zhengInfo")}
  local baseproperty = g_GeneralMode.getGeneralPropertyByGeneralId(data.ndata.general_id) 
  local allProperty = g_GeneralMode.getAllGeneralPropertyByGeneralId(data.ndata.general_id) 
  local tmp, lbBase, lbExtra 
  for i = 1, 5 do 
    tmp = widgetUI:getChildByName(string.format("Panel_0%d", i))
    tmp:getChildByName("Text_01"):setString(g_tr("attr"..i))
    g_itemTips.tipStr(tmp:getChildByName("Image_1"), g_tr("attr"..i), strTips[i])

    lbBase = tmp:getChildByName("Text_1") 
    lbExtra = tmp:getChildByName("Text_2") 
    lbBase:setString(""..baseproperty[i]) 
    lbExtra:setString("+"..allProperty[i]-baseproperty[i]) 
    lbExtra:setPositionX(lbBase:getPositionX()+lbBase:getContentSize().width+2) 
  end 
end 


local function removeUsedMatCount(itemId, num) 
  for k, v in pairs(materials) do 
    if v.item.id == itemId then 
      materials[k].perSel = math.max(0, materials[k].perSel-num) 
      -- materials[k].totalSelCount = math.max(0, materials[k].totalSelCount-num)
      print("left perSel, totalSelCount", materials[k].perSel, materials[k].totalSelCount)
      break 
    end 
  end 
end 

--显示所有属性 data = {cdata, ndata}, 其中cdata对应数据表数据,ndata对应服务器数据
function updateInfo(data)
  godDataOld = clone(data) 
  godDataNew = data 

  initMatList()
  updateLevelPercent(data.ndata.exp) 
  updateCanLevelupAnim(data.ndata.exp)
  updateAttrInfo(data)
end 

--星级变化则同步数据,更新基础属性
function updateWhenStarUp(data)
  godDataOld = clone(data) 
  godDataNew = data 

  updateAttrInfo(data)
end 


function startAddExp(itemId, itemCount)
  if itemCount > 0 then

    local baseproperty1 = g_GeneralMode.getGeneralPropertyByGeneralId(godDataNew.ndata.general_id) 

    local function onAddResult(result, msgData)
      if result then 
        print("startAddExp--2")
        if nil == widgetUI then return end 

        dump(msgData, "msgData")

        --判断是否满级
        local genSrvData = g_GeneralMode.getOwnedGeneralByOriginalId(godDataNew.cdata.general_original_id) 
        print(" pre_exp, new_exp:", godDataNew.ndata.exp, genSrvData.exp)

        if usrCallback then 
          usrCallback()
        end 

        --等级提升
        if genSrvData and genSrvData.lv > godDataNew.ndata.lv then           
          print("======lv up success !!!!") 
          godDataNew.ndata = genSrvData 
                  
          updateAttrInfo(godDataNew) 

          --显示升级动画
          GodGeneralMode:addLevelupSuccessAnim(widgetUI, cc.p(-320, 0)) 

          --上浮属性变化
          local baseproperty2 = g_GeneralMode.getGeneralPropertyByGeneralId(genSrvData.general_id) 
          GodGeneralMode:toastGenBaseAttrChanged(widgetUI, cc.p(-500, -20), baseproperty1, baseproperty2)                    
        end 
      end
    end

    --使用道具后,选择的个数需要同步,防止下次请求超量使用道具数
    removeUsedMatCount(itemId, itemCount)

    local ownNum = g_BagMode.findItemNumberById(itemId)
    local count = math.min(ownNum, itemCount)
    if count > 0 then 
      print("startAddExp--1") 
      g_sgHttp.postData("Pub/generalAddExp", {generalId = godDataNew.cdata.general_original_id,itemId = itemId,num = count}, onAddResult, true)
    else 
      print("no enough mat !!!")
    end 
  end
end 


return GodGeneralLevelUp 

