local resManager = {}
setmetatable(resManager,{__index = _G})
setfenv(1,resManager)

local function toint(v)
    return math.round(tonumber(v))
end


function resManager.getResPath(id)
  local resInfo = g_data.sprite[tonumber(id)]
  assert(resInfo,"cannot found res info by id:"..id)
  return resInfo.path
end

function resManager.getRes(id)
  local resInfo = g_data.sprite[tonumber(id)]
  assert(resInfo,"cannot found res info by id:"..id)
  resInfo = g_data.sprite[id]
    --res = cc.Sprite:create(resInfo.path)
  --print(resInfo.path)
  local res = ccui.ImageView:create(resInfo.path)
  assert(res,"create ImageView fail:id"..id)
  res.filePath = resInfo.path
  return res
end

--[[function resManager.getRes(id)
  local type = toint(id / 1000000)
  local resInfo = nil
  local res = nil
  local duration = 0
  local isFlipY = false
  print("type:",type)
  if type == 1 then
    resInfo = g_data.sprite[id]
    --res = cc.Sprite:create(resInfo.path)
    print(resInfo.path)
    res = ccui.ImageView:create(resInfo.path)
    if not res then
      print("id:",id,resInfo.path)
    end
    assert(res,"create sprite fail:id",id)
    res.filePath = resInfo.path
  elseif type == 2 then
    local plistInfo = g_data.plist[id]
    if plistInfo ~= nil then
      cc.SpriteFrameCache:getInstance():addSpriteFrames(plistInfo.path)
    else
      printf("Can nout found res info by id:%d",id)
    end
  elseif type == 3 then
    resInfo = g_data.frames[id]
    if resInfo ~= nil then
      resManager.getResource(resInfo.plist)
      res = cc.Sprite:createWithSpriteFrameName(resInfo.playstates)
      assert(res ~= nil,"can not cc.Sprite:createWithSpriteFrameName with "..resInfo.playstates)
      res.frameName = resInfo.playstates
    else
      printf("Can nout found res info by id:%d",id)
    end
  elseif type == 4 then
    resInfo = g_data.particleanims[id]
    if resInfo == nil then
      printf("Can nout found res info by id:%d",id)
    else  
      local path = resInfo.folder.."/"..resInfo.name
      res = cc.ParticleSystemQuad:create(path)
      res:setAnchorPoint(cc.p(0.5, 0.5))
      if resInfo.isloop == 1 then
        duration = resInfo.duration/1000.0 + 0.06
        res:setDuration(-1)
      else
        res:setAutoRemoveOnFinish(true)
      end
    end
  else
    printf("Can not found handle res[%d] with type:%d",id,type)
  end
  
  return res,duration,isFlipY
end
]]


return resManager