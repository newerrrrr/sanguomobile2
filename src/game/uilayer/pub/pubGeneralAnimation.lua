local pubGeneralAnimation = {}

local m_isPlayEnd = true
local m_isPubAnimOnShow = false

local projName = "Effect_JiuGuanZhaoMu"
local animPath = "anime/"..projName.."/"..projName..".ExportJson"
   
function pubGeneralAnimation.isPubAnimOnShow()
	return m_isPubAnimOnShow
end

--播放酒馆招募动画
function pubGeneralAnimation.playRecruitAnimation(generalInfo,type,parent)
   
   if not m_isPlayEnd then
	  return
   end
   
   g_guideManager.clearGuideLayer()
   
   m_isPlayEnd = false
   m_isPubAnimOnShow = true
   
   local m_animationNode = ccui.Widget:create()
   parent:addChild(m_animationNode)

   m_animationNode:setContentSize(g_display.size)
   m_animationNode:setAnchorPoint(cc.p(0.5,0.5))
   m_animationNode:setPositionX(g_display.cx)
   m_animationNode:setPositionY(g_display.cy)
   m_animationNode:setTouchEnabled(true)
   m_animationNode:setScale(g_display.scale)
   
   local onAnimationCloseHandler = function()
--		  m_animationNode:stopAllActions()
--		  m_animationNode:removeAllChildren()
--		  m_animationNode:setVisible(false)
		  m_animationNode:removeFromParent()
		  m_isPubAnimOnShow = false
		  if g_guideManager.execute() then
			parent:removeFromParent()
		  end
		  
		  g_autoCallback.addCocosList(function () 
			  ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath) 
		  end , 0.01 )
   end
   
   m_animationNode:addClickEventListener(function()
		if m_isPlayEnd then
			onAnimationCloseHandler()
		end
   end)

--   m_animationNode:removeAllChildren()
--   m_animationNode:setVisible(true)
   
   --武将信息面板
   local nodePanleInfo = cc.CSLoader:createNode("Pub_general_info1.csb")
   
   nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_28"):setVisible(false)
   nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_28"):setString(g_tr("clickhereclose"))
   nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_1"):getChildByName("Text_24"):setString(g_tr("generalInfo"))
   nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_1"):getChildByName("Text_xm")
   :setString(g_tr(generalInfo.general_name))
   nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_14")
   :setString(g_tr(generalInfo.description))
   
   --武将属性
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_1"):getChildByName("Text_6")
	:setString(g_tr("wu"))--武
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_1"):getChildByName("Text_7")
	:setString(generalInfo.general_force.."")
	  
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_2"):getChildByName("Text_6")
	:setString(g_tr("zhi"))--智
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_2"):getChildByName("Text_7")
	:setString(generalInfo.general_intelligence.."")
	
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_3"):getChildByName("Text_6")
	:setString(g_tr("zheng"))--政
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_3"):getChildByName("Text_7")
	:setString(generalInfo.general_political.."")
	
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_4"):getChildByName("Text_6")
	:setString(g_tr("tong"))--统
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_4"):getChildByName("Text_7")
	:setString(generalInfo.general_governing.."")
	
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_5"):getChildByName("Text_6")
	:setString(g_tr("mei"))--魅
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("prop_5"):getChildByName("Text_7")
	:setString(generalInfo.general_charm.."")
	
	--优势兵种
	local equipInfo = g_data.equipment[generalInfo.general_item_id*100]
	local str = ""
	for i=1, #equipInfo.equip_skill_id do
		local skillInfo =  g_data.equip_skill[equipInfo.equip_skill_id[i]]
		local troopType = skillInfo.equip_arm_type
		local troopStr = ""
		if troopType == 1 then
			troopStr = g_tr("infantry")
		elseif troopType == 2 then
			troopStr = g_tr("cavalry")
		elseif troopType == 3 then
			troopStr = g_tr("archer")
		elseif troopType == 4 then
			troopStr = g_tr("vehicles")
		end
		str = str..troopStr.." "
	end
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("Panel_6"):getChildByName("skill_effect2")
	:setString(str)
	
	nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_2"):getChildByName("Panel_6"):getChildByName("skill_effect1")
	:setString(g_tr("betterArmy"))--优势兵种
	
	local orgGetWayRichLabelPosX = nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_5"):getPositionX()
	local orgGetWayRichLabelWidth = nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_5"):getContentSize().width
	
	g_custom_loadFunc("CalculateTalent", "(star)", " return "..generalInfo.general_talent_value_client)
	local starLv = 0
  local talentVal = externFunctionCalculateTalent(starLv) 
	local talentStr = g_tr(generalInfo.general_talent_description,{num = talentVal})
	local getWayRichLabel = g_gameTools.createRichText(nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_5"),talentStr)
	local size = getWayRichLabel:getRealSize()
	getWayRichLabel:setPositionX(orgGetWayRichLabelPosX + orgGetWayRichLabelWidth/2 - size.width/2)
	
   --招募动画播放事件
   local onMovementEventCallFunc = function(armature , eventType , name)
	   if 0 == eventType then --start
	   elseif 1 == eventType then --end
		   m_isPlayEnd = true
		   if nodePanleInfo then
			   nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_28"):setVisible(true)
		   end
	   end
   end
   
  
   local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,onMovementEventCallFunc)
   m_animationNode:addChild(armature)
   armature:setPositionX(g_display.cx)
   armature:setPositionY(g_display.cy)
   
   if type == 1 then
	  animation:play("Effect_JiuGuanZhaoMuYinXiongLeft")
   elseif type == 2 then
	  animation:play("Effect_JiuGuanZhaoMuYinXiongCenter")
   else
	  animation:play("Effect_JiuGuanZhaoMuYinXiongRight")
   end
	
	--武将半身像
	local container = cc.Node:create()
	--local bg = cc.Sprite:create(g_resManager.getResPath(1005000 + generalInfo.general_quality))
	--container:addChild(bg)
	local pic = cc.Sprite:create(g_resManager.getResPath(generalInfo.general_big_icon))
	container:addChild(pic)
	--local frame = cc.Sprite:create(g_resManager.getResPath(1005100 + generalInfo.general_quality))--边框
	--container:addChild(frame)
	armature:getBone("Layer5"):addDisplay(container,0)
	
	--武将信息面板动画
	local function showInfoPanle()
		for i = 1, 4 do
			local part = nodePanleInfo:getChildByName("scale_node"):getChildByName("prop_row_"..i)
			if i == 3 then
				part = nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_14")
			elseif i == 4 then
				part = getWayRichLabel
				
				local projName = "Effect_ShenWuJianUiText"
				local animPath = "anime/"..projName.."/"..projName..".ExportJson"
				local armature , animation = g_gameTools.LoadCocosAni(animPath, projName,function(armature , eventType , name)
				   if 0 == eventType then --start
				   elseif 1 == eventType then --end
				   	  
				   end
			  end)
			  
			  local orgLabel = nodePanleInfo:getChildByName("scale_node"):getChildByName("Text_5")
   			orgLabel:addChild(armature)
   			orgLabel:setString("")
   			orgLabel:setVisible(true)
   			armature:setPosition(cc.p(orgLabel:getContentSize().width/2,orgLabel:getContentSize().height/2))
   			
   			g_autoCallback.addCocosList(function () 
				  animation:play("Effect_TianFuCHuXian")
			  end , 0.20 * (i+1))
   			
			end
			part:setCascadeOpacityEnabled(true)
			part:setOpacity(0)
			local action = cc.Sequence:create( 
				cc.DelayTime:create(0.20 * i),
				cc.FadeTo:create(1.0,255)
			)
			part:runAction(action)
		end
	end
	
	local action = cc.Sequence:create( 
		cc.Hide:create(),
		cc.DelayTime:create(2.5),
		cc.Show:create(),
		cc.CallFunc:create(showInfoPanle)
	)
	m_animationNode:addChild(nodePanleInfo)
	nodePanleInfo:runAction(action)
	
end

return pubGeneralAnimation