local AIModel = {}
setmetatable(AIModel,{__index = _G})
setfenv(1,AIModel)


local weaponType = {}
weaponType.SHORT = 1
weaponType.MIDDLE = 2
weaponType.LONG = 3

--武斗AI

--相对于坐标系Y轴角度
local function _calculateAngleY(p1,p2)
  local a = math.atan2((p2.x - p1.x),(p2.y - p1.y))*(180/math.pi)
  return a
end

--相对于坐标系X轴角度
local function _calculateAngle(p1,p2)
  local a = math.atan2((p2.y-p1.y), (p2.x-p1.x))*(180/math.pi)
  return a
end

local function _getHitPointAngle(randomCanHit,ai_can_move,ai_current_point,target_current_point,target_operate_point,moveSinDivCos,ai_move_range,target_move_range,ai_attack_min_range,ai_attack_max_range,ai_attack_angle_range,func_checkMapPoint,roleRadius,ai_weapon_type,target_weapon_type)
    local distance = math.sqrt((target_operate_point.x-ai_current_point.x)^2+(target_operate_point.y-ai_current_point.y)^2)
    
    local targetMove = nil
    local inAtkRange = false
    
    local hited = false
    if ai_move_range + ai_attack_max_range >= distance and distance >= ai_attack_min_range- ai_move_range then --可以命中范围
        inAtkRange = true
        if randomCanHit then
            local tempMove = math.random(math.floor(math.max(0,distance-ai_attack_max_range,ai_attack_min_range-distance)),math.floor(math.min(ai_move_range,distance+ai_attack_max_range)))
            print("ai_current_point:",ai_current_point.x,ai_current_point.y)
            print("tempMove,distance:",tempMove,distance)
            assert(tempMove <= ai_move_range and tempMove >= 0)
            
            if ai_weapon_type == weaponType.LONG then
                tempMove = ai_move_range
            end
            
            print("final distance:",distance,"tempMove:",tempMove)
            local b = tempMove
            local c = distance
            local a = ai_attack_max_range
            local a1 = ai_attack_min_range
            local cosmax = (math.pow(b,2) + math.pow(c,2) - math.pow(a,2)) / 2 / b / c
            local cosmin = (math.pow(b,2) + math.pow(c,2) - math.pow(a1,2)) / 2 / b /c
        
            print("cosmin,cosmax:",cosmin,cosmax)
            print("abc:",a,b,c,a1)
            
            cosmax = math.min(1,cosmax)
            cosmin = math.max(-1,cosmin)
            
            local t1 = math.acos(math.max(-1,cosmax))
            local t2 = math.acos(math.min(1,cosmin))
            
            local r = math.random(t1*100,t2*100)/100
            print("t1,t2,r:",t1,t2,r)
    
            local cosy = math.cos(r)
            
            if ai_weapon_type == weaponType.LONG--[[and target_weapon_type == weaponType.LONG]] then
                cosy = -cosy
            end
            
            local sinx=(target_operate_point.y-ai_current_point.y)/distance
            local cosx=(target_operate_point.x-ai_current_point.x)/distance
            print("target_operate_point.x,ai_current_point.x)",target_operate_point.x,ai_current_point.x)
          
            local siny= math.sin(r)
            
            print("sinx,siny,cosx,cosy:",sinx,siny,cosx,cosy)
            
            local x1 = ai_current_point.x + (cosx*cosy - sinx*siny) * tempMove
            local y1 = ai_current_point.y + (sinx*cosy + cosx*siny) * tempMove * moveSinDivCos
            
            local x2 = ai_current_point.x + (cosx*cosy + sinx*siny) * tempMove
            local y2 = ai_current_point.y + (sinx*cosy - cosx*siny) * tempMove * moveSinDivCos
            
            print("x1y1,x2,y2:",x1,y1,x2,y2)
            
            local p1IsVaild = func_checkMapPoint(cc.p(x1,y1))
            local p2IsVaild = func_checkMapPoint(cc.p(x2,y2))
            if p1IsVaild or p2IsVaild then
                if p1IsVaild and p2IsVaild then
                    targetMove = cc.p(x1,y1)
                    if math.random(1,2) == 1 then
                        targetMove = cc.p(x2,y2)
                    end
                elseif p1IsVaild then
                    targetMove = cc.p(x1,y1)
                elseif p2IsVaild then
                    targetMove = cc.p(x2,y2)
                end
            else
                local x = ai_current_point.x + math.min(distance/2,ai_move_range)* sinx
                local y = ai_current_point.y + math.min(distance/2,ai_move_range)* cosx * moveSinDivCos
                targetMove = cc.p(x,y)
            end
            
            hited = true
        end
    end
    
    print("inAtkRange:",inAtkRange)
    print("randomCanHit:",randomCanHit)
    print("hited:",hited)
    
    if not hited then
        local sinx=(target_operate_point.y-ai_current_point.y)/distance
        local cosx=(target_operate_point.x-ai_current_point.x)/distance

        local angle = math.random(-60,60)
        if ai_weapon_type == weaponType.SHORT or ai_weapon_type == weaponType.MIDDLE then --近战
        
        elseif ai_weapon_type == weaponType.LONG then --远程
            if target_weapon_type == weaponType.LONG then
                angle = math.random(120,240)
            end
        end
        
        local siny = math.sin(angle * math.pi / 180.0)
        local cosy = math.cos(angle * math.pi / 180.0)
        if ai_weapon_type == weaponType.LONG--[[and target_weapon_type == weaponType.LONG]] then
            cosy = -cosy
        end
        
        local x1 = ai_current_point.x+(cosx*cosy - sinx*siny)* ai_move_range
        local y1 = ai_current_point.y+(sinx*cosy + cosx*siny)* ai_move_range* moveSinDivCos
        
        local x2 = ai_current_point.x+(cosx*cosy + sinx*siny)* ai_move_range
        local y2 = ai_current_point.y+(sinx*cosy - cosx*siny)* ai_move_range* moveSinDivCos
        
        local p1IsVaild = func_checkMapPoint(cc.p(x1,y1))
        local p2IsVaild = func_checkMapPoint(cc.p(x2,y2))
        if p1IsVaild or p2IsVaild then
            if p1IsVaild and p2IsVaild then
                targetMove = cc.p(x1,y1)
                if math.random() > 0.5 then
                    targetMove = cc.p(x2,y2)
                end
            elseif p1IsVaild then
                targetMove = cc.p(x1,y1)
            elseif p2IsVaild then
                targetMove = cc.p(x2,y2)
            end
            print("p1IsVaild or p2IsVaild")
        else
            
            local pointArr = {}
        
            local p1 = {}
            print("p1:",sinx * cosy+cosx * siny,cosx * cosy-sinx * siny)
            p1.x=ai_current_point.x+(sinx * cosy+cosx * siny)* ai_move_range
            p1.y=ai_current_point.y-(cosx * cosy-sinx * siny)* ai_move_range* moveSinDivCos
            if func_checkMapPoint(p1) then
               print("p1 is vaild")
               table.insert(pointArr,p1)
            end
            
            local p2 = {}
            print("p2:",cosx * cosy-sinx * siny,sinx * cosy+cosx * siny)
            p2.x=ai_current_point.x-(cosx * cosy-sinx * siny)* ai_move_range
            p2.y=ai_current_point.y-(sinx * cosy+cosx * siny)* ai_move_range* moveSinDivCos
            if func_checkMapPoint(p2) then
               print("p2 is vaild")
               table.insert(pointArr,p2)
            end
            
            local p3 = {}
            print("p3:",sinx * cosy+cosx * siny,cosx * cosy-sinx * siny)
            p3.x=ai_current_point.x-(sinx * cosy+cosx * siny)* ai_move_range
            p3.y=ai_current_point.y+(cosx * cosy-sinx * siny)* ai_move_range* moveSinDivCos
            if func_checkMapPoint(p3) then
               print("p3 is vaild")
               table.insert(pointArr,p3)
            end
            
            local p4 = {}
            print("p4:",sinx * cosy - cosx * siny,cosx*cosy-sinx*siny)
            p4.x=ai_current_point.x+(sinx * cosy - cosx * siny)* ai_move_range
            p4.y=ai_current_point.y-(cosx*cosy+sinx*siny)* ai_move_range* moveSinDivCos
            if func_checkMapPoint(p4) then
                print("p4 is vaild")
               table.insert(pointArr,p4)
            end
            
            local p5 = {}
            print("p5:",cosx*cosy-sinx*siny,sinx * cosy - cosx * siny)
            p5.x=ai_current_point.x-(cosx*cosy+sinx*siny)* ai_move_range
            p5.y=ai_current_point.y-(sinx * cosy - cosx * siny)* ai_move_range* moveSinDivCos
            if func_checkMapPoint(p5) then
               print("p5 is vaild")
               table.insert(pointArr,p5)
            end
            
            local p6 = {}
            print("p6",sinx * cosy - cosx * siny,cosx*cosy-sinx*siny)
            p6.x=ai_current_point.x-(sinx * cosy - cosx * siny)* ai_move_range
            p6.y=ai_current_point.y+(cosx*cosy + sinx*siny)* ai_move_range* moveSinDivCos
            if func_checkMapPoint(p6) then
               print("p6 is vaild")
               table.insert(pointArr,p6)
            end
            
            if #pointArr > 0 then
                local idx = math.random(1,#pointArr)
                targetMove = pointArr[idx]
                
                print("#pointArr > 0","use p"..idx)
            else
                targetMove = ai_current_point
                print("#pointArr == 0")
            end
            
        end
        
    end
    
    assert(targetMove ~= nil)
    --assert(func_checkMapPoint(targetMove),"target point error")
    
    local t = target_operate_point.x-targetMove.x
    if math.abs(t) < 0.000001 then
        print("0.000001")
        t = 0.000001
    end
    local angle = math.atan((target_operate_point.y - targetMove.y) / t)
    print("angle:",angle)
    angle = angle *180 / math.pi
    if (target_operate_point.x-targetMove.x) < 0 then
        angle = angle + 180
    end
    
    local orginalAngle = angle
    
    local angleRandomOffset = math.random(-math.floor(ai_attack_angle_range/2),math.floor(ai_attack_angle_range/2))
    angle = angle + angleRandomOffset
    
    --不能移动的情况
    if not ai_can_move then
       hited = false
       targetMove = ai_current_point
       orginalAngle = _calculateAngle(ai_current_point,target_operate_point)
       
       local angleRandomOffset = math.random(-math.floor(ai_attack_angle_range/2),math.floor(ai_attack_angle_range/2))
       angle = orginalAngle + angleRandomOffset
       if randomCanHit then
            if inAtkRange then
                hited = true 
            end
       end
    end
    
    if not hited and inAtkRange then
        local maxOffset = 30
        local angleLeft = math.random(math.floor(orginalAngle - ai_attack_angle_range/2),math.floor(orginalAngle - ai_attack_angle_range/2 - maxOffset))
        local angleRight = math.random(math.floor(orginalAngle + ai_attack_angle_range/2),math.floor(orginalAngle + ai_attack_angle_range/2 + maxOffset))
        if math.random() > 0.5 then
            angle = angleLeft
        else
            angle = angleRight
        end
        --angle = math.random(math.floor(orginalAngle + ai_attack_angle_range/2),math.floor(orginalAngle + 360 - ai_attack_angle_range/2) )
    end
    
    --如果ai远程 攻击角度计算校正
    if ai_weapon_type == weaponType.LONG--[[and target_weapon_type == weaponType.LONG]] then
        orginalAngle = _calculateAngle(targetMove,target_current_point)
        
        local t_distance = cc.pGetDistance(targetMove,target_current_point)
        local maxOffset = math.atan(target_move_range/t_distance)
        maxOffset = maxOffset * 180 / math.pi
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~,11111",maxOffset)
        angle = math.random(math.floor(orginalAngle - maxOffset),math.floor(orginalAngle + maxOffset))
    end
    
    print(targetMove.x,targetMove.y,angle)
    
    local dis = cc.pGetDistance(targetMove,ai_current_point)
    print("a:",dis,"b:",ai_move_range)
    assert(dis <= ai_move_range + 0.01,"move out of range")
    
    return targetMove,angle,orginalAngle,inAtkRange,hited
end

--万分比是否命中
local _rate = function(rate)
    return math.random() <= rate/10000 
end

function AI_operate_point_angle_skill(
    ai_duel_rank_id
  , ai_move_range
  , ai_can_move
  , ai_weapon_type
  , ai_attack_min_range
  , ai_attack_max_range
  , ai_attack_angle_range
  , ai_can_attack
  , ai_skill_min_range
  , ai_skill_max_range
  , ai_skill_angle_range
  , ai_can_skill
  , ai_current_point
  , ai_current_angle
  
  , target_duel_rank_id
  , target_move_range
  , target_can_move
  , target_weapon_type
  , target_attack_min_range
  , target_attack_max_range
  , target_attack_angle_range
  , target_can_attack
  , target_skill_min_range
  , target_skill_max_range
  , target_skill_angle_range
  , target_can_skill
  , target_current_point
  , target_current_angle
  
  , target_operate_point
  , target_operate_angle
  , target_operate_skill --0不会使用技能，1使用技能
  
  , roleRadius
  , moveSinDivCos
  , func_checkMapPoint
  )
  
  local movePoint = ai_current_point
  local atkAngle = ai_current_angle
  local orginalAtkAngle = atkAngle
  
  if not ai_can_move then
      return movePoint,atkAngle,0
  end
  
--  ai_attack_min_range = 100
--  ai_attack_max_range = 200
--  target_weapon_type = weaponType.SHORT
--  ai_weapon_type = weaponType.SHORT
--  
  --AI和对手最终落脚点的距离
  local distance = math.sqrt((target_operate_point.x-ai_current_point.x)^2+(target_operate_point.y-ai_current_point.y)^2)
  print("ai_move_range:",ai_move_range)
  print("target_current_point.x,ai_current_point.x)",target_current_point.x,ai_current_point.x)
  print("ai_can_skill:",ai_can_skill)
  print("ai_can_move:",ai_can_move)
  print("ai_can_attack:",ai_can_attack)
  
  local usedSkill = false
  if ai_can_skill then
      local inAtkRange = false
      local rate = g_data.duel_rank[ai_duel_rank_id].rank_hit_rate
      local randomCanHit = _rate(rate)
      
      if target_can_move == false then
          randomCanHit = true
      end
      
      local isHited = false
      
      movePoint,atkAngle,orginalAtkAngle,inAtkRange,isHited = _getHitPointAngle(randomCanHit,ai_can_move,ai_current_point,target_current_point,target_operate_point,moveSinDivCos,ai_move_range,target_move_range,ai_skill_min_range,ai_skill_max_range,ai_skill_angle_range,func_checkMapPoint,roleRadius,ai_weapon_type,target_weapon_type)

      local maxLoopCnt = 10
      local distance = math.sqrt((target_operate_point.x-movePoint.x)^2+(target_operate_point.y-movePoint.y)^2)
      while (distance < roleRadius*2 and maxLoopCnt > 0) or not func_checkMapPoint(movePoint) do
          movePoint,atkAngle,orginalAtkAngle,inAtkRange,isHited = _getHitPointAngle(randomCanHit,ai_can_move,ai_current_point,target_current_point,target_operate_point,moveSinDivCos,ai_move_range,target_move_range,ai_skill_min_range,ai_skill_max_range,ai_skill_angle_range,func_checkMapPoint,roleRadius,ai_weapon_type,target_weapon_type)
          distance = math.sqrt((target_operate_point.x-movePoint.x)^2+(target_operate_point.y-movePoint.y)^2)
          print("while skill~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
          maxLoopCnt = maxLoopCnt - 1
      end
      
      if inAtkRange then
          usedSkill = true
      end
      
      if not func_checkMapPoint(movePoint) then
          movePoint = ai_current_point
      end
      
  end

  if not usedSkill and ai_can_attack then
      local inAtkRange = false
      local rate = g_data.duel_rank[ai_duel_rank_id].rank_hit_rate
      local randomCanHit = _rate(rate)
      
      if target_can_move == false then
          randomCanHit = true
      end
      
      local isHited = false

      movePoint,atkAngle,orginalAtkAngle,inAtkRange,isHited = _getHitPointAngle(randomCanHit,ai_can_move,ai_current_point,target_current_point,target_operate_point,moveSinDivCos,ai_move_range,target_move_range,ai_attack_min_range,ai_attack_max_range,ai_attack_angle_range,func_checkMapPoint,roleRadius,ai_weapon_type,target_weapon_type)
      
      local maxLoopCnt = 10
      local distance = math.sqrt((target_operate_point.x-movePoint.x)^2+(target_operate_point.y-movePoint.y)^2)
      while (maxLoopCnt > 0 and (distance < roleRadius*2 or not func_checkMapPoint(movePoint))) do
          movePoint,atkAngle,orginalAtkAngle,inAtkRange,isHited = _getHitPointAngle(randomCanHit,ai_can_move,ai_current_point,target_current_point,target_operate_point,moveSinDivCos,ai_move_range,target_move_range,ai_attack_min_range,ai_attack_max_range,ai_attack_angle_range,func_checkMapPoint,roleRadius,ai_weapon_type,target_weapon_type)
          distance = math.sqrt((target_operate_point.x-movePoint.x)^2+(target_operate_point.y-movePoint.y)^2)
          print("while attack~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
          maxLoopCnt = maxLoopCnt - 1
      end
      
      if not func_checkMapPoint(movePoint) then
          movePoint = ai_current_point
      end

  end
  
  local isUseSkill = 0
  if usedSkill then
      isUseSkill = 1
  end
  
  return movePoint,atkAngle,isUseSkill
  
end



--自动战斗AI
function AI_operate_point_angle_skill_automatic(
    mt_duel_rank_id
  , mt_move_range
  , mt_can_move
  , mt_weapon_type
  , mt_attack_min_range
  , mt_attack_max_range
  , mt_attack_angle_range
  , mt_can_attack
  , mt_skill_min_range
  , mt_skill_max_range
  , mt_skill_angle_range
  , mt_can_skill
  , mt_current_point
  , mt_current_angle
  
  , target_duel_rank_id
  , target_move_range
  , target_can_move
  , target_weapon_type
  , target_attack_min_range
  , target_attack_max_range
  , target_attack_angle_range
  , target_can_attack
  , target_skill_min_range
  , target_skill_max_range
  , target_skill_angle_range
  , target_can_skill
  , target_current_point
  , target_current_angle
  
  , roleRadius
  , moveSinDivCos
  , func_checkMapPoint
  )
  
  local target_current_point = clone(target_current_point)
  local mtOrginPoint = clone(mt_current_point)
  local targetOrginPoint = clone(target_current_point)

  local movePoint = mt_current_point
  local atkAngle = mt_current_angle
  local isUseSkill = false
  
  local aiMovePoint = target_current_point
  local aiAtkAngle = target_current_angle
  local aiIsUseSkill = false

  --先根据玩家武将当前位置 模拟一个ai的目标位置
  do
      local ai_duel_rank_id = target_duel_rank_id
      local ai_move_range = target_move_range
      local ai_can_move = target_can_move
      local ai_weapon_type = target_weapon_type
      local ai_attack_min_range = target_attack_min_range
      local ai_attack_max_range =  target_attack_max_range
      local ai_attack_angle_range = target_attack_angle_range
      local ai_can_attack = target_can_attack
      local ai_skill_min_range = target_skill_min_range
      local ai_skill_max_range = target_skill_max_range
      local ai_skill_angle_range = target_skill_angle_range
      local ai_can_skill = target_can_skill
      local ai_current_point = target_current_point
      local ai_current_angle = target_current_angle
      
      local mtarget_duel_rank_id = mt_duel_rank_id
      local mtarget_move_range = mt_move_range
      local mtarget_can_move = mt_can_move
      local mtarget_weapon_type = mt_weapon_type
      local mtarget_attack_min_range = mt_attack_min_range
      local mtarget_attack_max_range = mt_attack_max_range
      local mtarget_attack_angle_range = mt_attack_angle_range
      local mtarget_can_attack = mt_can_attack
      local mtarget_skill_min_range = mt_skill_min_range
      local mtarget_skill_max_range = mt_skill_max_range
      local mtarget_skill_angle_range = mt_skill_angle_range
      local mtarget_can_skill = mt_can_skill
      local mtarget_current_point = mt_current_point
      local mtarget_current_angle = mt_current_angle
      
      local mtarget_operate_point = mt_current_point
      local mtarget_operate_angle = mt_current_angle
      local mtarget_operate_skill = 0 --0不会使用技能，1使用技能
      
      aiMovePoint,aiAtkAngle,aiIsUseSkill = AI_operate_point_angle_skill(
            ai_duel_rank_id
          , ai_move_range
          , ai_can_move
          , ai_weapon_type
          , ai_attack_min_range
          , ai_attack_max_range
          , ai_attack_angle_range
          , ai_can_attack
          , ai_skill_min_range
          , ai_skill_max_range
          , ai_skill_angle_range
          , ai_can_skill
          , ai_current_point
          , ai_current_angle
          
          , mtarget_duel_rank_id
          , mtarget_move_range
          , mtarget_can_move
          , mtarget_weapon_type
          , mtarget_attack_min_range
          , mtarget_attack_max_range
          , mtarget_attack_angle_range
          , mtarget_can_attack
          , mtarget_skill_min_range
          , mtarget_skill_max_range
          , mtarget_skill_angle_range
          , mtarget_can_skill
          , mtarget_current_point
          , mtarget_current_angle
          
          , mtarget_operate_point
          , mtarget_operate_angle
          , mtarget_operate_skill --0不会使用技能，1使用技能
          
          , roleRadius
          , moveSinDivCos
          , func_checkMapPoint
          )
          
      target_current_point =  aiMovePoint
      
	end
	
	--再根据模拟出来的ai位置 模拟一个玩家操作的位置
	do
	    local mtarget_duel_rank_id = mt_duel_rank_id --模拟ai
      local mtarget_move_range = mt_move_range
      local mtarget_can_move = mt_can_move
      local mtarget_weapon_type = mt_weapon_type
      local mtarget_attack_min_range = mt_attack_min_range
      local mtarget_attack_max_range = mt_attack_max_range
      local mtarget_attack_angle_range = mt_attack_angle_range
      local mtarget_can_attack = mt_can_attack
      local mtarget_skill_min_range = mt_skill_min_range
      local mtarget_skill_max_range = mt_skill_max_range
      local mtarget_skill_angle_range = mt_skill_angle_range
      local mtarget_can_skill = mt_can_skill
      local mtarget_current_point = mt_current_point
      local mtarget_current_angle = mt_current_angle
      
      
	    local ai_duel_rank_id = target_duel_rank_id --模拟玩家
      local ai_move_range = target_move_range
      local ai_can_move = target_can_move
      local ai_weapon_type = target_weapon_type
      local ai_attack_min_range = target_attack_min_range
      local ai_attack_max_range =  target_attack_max_range
      local ai_attack_angle_range = target_attack_angle_range
      local ai_can_attack = target_can_attack
      local ai_skill_min_range = target_skill_min_range
      local ai_skill_max_range = target_skill_max_range
      local ai_skill_angle_range = target_skill_angle_range
      local ai_can_skill = target_can_skill
      local ai_current_point = target_current_point
      local ai_current_angle = target_current_angle
      
      local mtarget_operate_point = target_current_point
      local mtarget_operate_angle = target_current_angle
      local mtarget_operate_skill = 0 --0不会使用技能，1使用技能

	    movePoint,atkAngle,isUseSkill = AI_operate_point_angle_skill(
            mtarget_duel_rank_id
          , mtarget_move_range
          , mtarget_can_move
          , mtarget_weapon_type
          , mtarget_attack_min_range
          , mtarget_attack_max_range
          , mtarget_attack_angle_range
          , mtarget_can_attack
          , mtarget_skill_min_range
          , mtarget_skill_max_range
          , mtarget_skill_angle_range
          , mtarget_can_skill
          , mtarget_current_point
          , mtarget_current_angle
          
          , ai_duel_rank_id
          , ai_move_range
          , ai_can_move
          , ai_weapon_type
          , ai_attack_min_range
          , ai_attack_max_range
          , ai_attack_angle_range
          , ai_can_attack
          , ai_skill_min_range
          , ai_skill_max_range
          , ai_skill_angle_range
          , ai_can_skill
          , ai_current_point
          , ai_current_angle
          
          , mtarget_operate_point
          , mtarget_operate_angle
          , mtarget_operate_skill --0不会使用技能，1使用技能
          
          , roleRadius
          , moveSinDivCos
          , func_checkMapPoint
          )
          
      mt_current_point = movePoint

	end
	
	-------------------------------------------------------------------------------------
	--下同分割线以上的算法
	--
	 --先根据玩家武将当前位置 模拟一个ai的目标位置
  do
      local ai_duel_rank_id = target_duel_rank_id
      local ai_move_range = target_move_range
      local ai_can_move = target_can_move
      local ai_weapon_type = target_weapon_type
      local ai_attack_min_range = target_attack_min_range
      local ai_attack_max_range =  target_attack_max_range
      local ai_attack_angle_range = target_attack_angle_range
      local ai_can_attack = target_can_attack
      local ai_skill_min_range = target_skill_min_range
      local ai_skill_max_range = target_skill_max_range
      local ai_skill_angle_range = target_skill_angle_range
      local ai_can_skill = target_can_skill
      local ai_current_point = targetOrginPoint
      local ai_current_angle = target_current_angle
      
      local mtarget_duel_rank_id = mt_duel_rank_id
      local mtarget_move_range = mt_move_range
      local mtarget_can_move = mt_can_move
      local mtarget_weapon_type = mt_weapon_type
      local mtarget_attack_min_range = mt_attack_min_range
      local mtarget_attack_max_range = mt_attack_max_range
      local mtarget_attack_angle_range = mt_attack_angle_range
      local mtarget_can_attack = mt_can_attack
      local mtarget_skill_min_range = mt_skill_min_range
      local mtarget_skill_max_range = mt_skill_max_range
      local mtarget_skill_angle_range = mt_skill_angle_range
      local mtarget_can_skill = mt_can_skill
      local mtarget_current_point = mt_current_point
      local mtarget_current_angle = mt_current_angle
      
      local mtarget_operate_point = mt_current_point
      local mtarget_operate_angle = mt_current_angle
      local mtarget_operate_skill = 0 --0不会使用技能，1使用技能
      
      aiMovePoint,aiAtkAngle,aiIsUseSkill = AI_operate_point_angle_skill(
            ai_duel_rank_id
          , ai_move_range
          , ai_can_move
          , ai_weapon_type
          , ai_attack_min_range
          , ai_attack_max_range
          , ai_attack_angle_range
          , ai_can_attack
          , ai_skill_min_range
          , ai_skill_max_range
          , ai_skill_angle_range
          , ai_can_skill
          , ai_current_point
          , ai_current_angle
          
          , mtarget_duel_rank_id
          , mtarget_move_range
          , mtarget_can_move
          , mtarget_weapon_type
          , mtarget_attack_min_range
          , mtarget_attack_max_range
          , mtarget_attack_angle_range
          , mtarget_can_attack
          , mtarget_skill_min_range
          , mtarget_skill_max_range
          , mtarget_skill_angle_range
          , mtarget_can_skill
          , mtarget_current_point
          , mtarget_current_angle
          
          , mtarget_operate_point
          , mtarget_operate_angle
          , mtarget_operate_skill --0不会使用技能，1使用技能
          
          , roleRadius
          , moveSinDivCos
          , func_checkMapPoint
          )
          
      target_current_point = aiMovePoint
      
  end
  
  --再根据模拟出来的ai位置 模拟一个玩家操作的位置
  do
      local mtarget_duel_rank_id = mt_duel_rank_id --模拟ai
      local mtarget_move_range = mt_move_range
      local mtarget_can_move = mt_can_move
      local mtarget_weapon_type = mt_weapon_type
      local mtarget_attack_min_range = mt_attack_min_range
      local mtarget_attack_max_range = mt_attack_max_range
      local mtarget_attack_angle_range = mt_attack_angle_range
      local mtarget_can_attack = mt_can_attack
      local mtarget_skill_min_range = mt_skill_min_range
      local mtarget_skill_max_range = mt_skill_max_range
      local mtarget_skill_angle_range = mt_skill_angle_range
      local mtarget_can_skill = mt_can_skill
      local mtarget_current_point = mtOrginPoint
      local mtarget_current_angle = mt_current_angle
      
      
      local ai_duel_rank_id = target_duel_rank_id --模拟玩家
      local ai_move_range = target_move_range
      local ai_can_move = target_can_move
      local ai_weapon_type = target_weapon_type
      local ai_attack_min_range = target_attack_min_range
      local ai_attack_max_range =  target_attack_max_range
      local ai_attack_angle_range = target_attack_angle_range
      local ai_can_attack = target_can_attack
      local ai_skill_min_range = target_skill_min_range
      local ai_skill_max_range = target_skill_max_range
      local ai_skill_angle_range = target_skill_angle_range
      local ai_can_skill = target_can_skill
      local ai_current_point = target_current_point
      local ai_current_angle = target_current_angle
      
      local mtarget_operate_point = target_current_point
      local mtarget_operate_angle = target_current_angle
      local mtarget_operate_skill = 0 --0不会使用技能，1使用技能

      movePoint,atkAngle,isUseSkill = AI_operate_point_angle_skill(
          mtarget_duel_rank_id
          , mtarget_move_range
          , mtarget_can_move
          , mtarget_weapon_type
          , mtarget_attack_min_range
          , mtarget_attack_max_range
          , mtarget_attack_angle_range
          , mtarget_can_attack
          , mtarget_skill_min_range
          , mtarget_skill_max_range
          , mtarget_skill_angle_range
          , mtarget_can_skill
          , mtarget_current_point
          , mtarget_current_angle
          
          , ai_duel_rank_id
          , ai_move_range
          , ai_can_move
          , ai_weapon_type
          , ai_attack_min_range
          , ai_attack_max_range
          , ai_attack_angle_range
          , ai_can_attack
          , ai_skill_min_range
          , ai_skill_max_range
          , ai_skill_angle_range
          , ai_can_skill
          , ai_current_point
          , ai_current_angle
          
          , mtarget_operate_point
          , mtarget_operate_angle
          , mtarget_operate_skill --0不会使用技能，1使用技能
          
          , roleRadius
          , moveSinDivCos
          , func_checkMapPoint
          )
          
      mt_current_point = movePoint

  end
  
  return movePoint,atkAngle,isUseSkill,aiMovePoint,aiAtkAngle,aiIsUseSkill

end

return AIModel