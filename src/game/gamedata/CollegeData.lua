--region CollegeData.lua
--Author : luqingqing
--Date   : 2015/11/5
--此文件由[BabeLua]插件自动生成

local CollegeData = class("CollegeData")

function CollegeData:ctor()
    
end

function CollegeData:setGeneralData(value)
    self.general = value
end

function CollegeData:getGeneralData()
    return self.general
end

function CollegeData:setPosition(pos)
    self.position = pos
end

function CollegeData:getPosition()
    return self.position
end

function CollegeData:setType(value)
    self.collegeType = value
end

function CollegeData:getType()
    return self.collegeType
end

function CollegeData:setGainExp(value)
    self.gainExp = value
end

function CollegeData:getGainExp()
    return self.gainExp
end

function CollegeData:setStartTime(value)
    self.startTime = value
end

function CollegeData:getStartTime()
    return self.startTime
end

function CollegeData:setEndTime(value)
    self.endTime = value
end

function CollegeData:getEndTime()
    return self.endTime
end

return CollegeData

--endregion