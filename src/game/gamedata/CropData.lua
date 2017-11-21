--region CropData.lua
--Author : luqingqing
--Date   : 2015/10/29
--此文件由[BabeLua]插件自动生成

local CropData = class("CropData")

function CropData:ctor()

end

function CropData:setGeneralData(value)
    self.generalData = value
end

function CropData:setArmyUnitData(value)
    self.armyUnitData = value
end

function CropData:getGeneralData()
    return self.generalData
end

function CropData:getArmyUnitData()
    return self.armyUnitData
end

return CropData

--endregion
