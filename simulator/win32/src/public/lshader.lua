local lshader = {}
setmetatable(lshader,{__index = _G})
setfenv(1,lshader)

--这里是还原着色器,但并不是所有还原都是这个,如果自己有把握请自己设置
--一般来说UIImageView里面是Scale9Sprite,最里面有9个Sprite是用这个
--但UIText里面是Lable不同情况用了不同的着色器,
--所以在返回基本着色器时尽量采用先保留之前的原着色器,返回时直接设置回去的方式。不同控件在不同的设置时所使用的着色器是有区别的。
originMode = "ShaderPositionTextureColor_noMVP"


--这里添加
shaderMode = {
	shader_gray = "shader_gray",
	shader_OverlayBlack = "shader_OverlayBlack",
	shader_ToScreenBlur_low = "shader_ToScreenBlur_low",
	shader_ToScreenBlur_high = "shader_ToScreenBlur_high",
	shader_Wave = "shader_Wave",
}


--使用例子
--Widget:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( shaderMode.shader_gray ) )
--Node:setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( shaderMode.shader_gray ) )


local function registerShader()
    for key , name in pairs(shaderMode ) do
        local program
        if not cc.GLProgramState:getOrCreateWithGLProgramName( name ) then
            program = cc.GLProgram:create("shaders/" .. name .. ".vsh", "shaders/" .. name .. ".fsh")
        else
            program = cc.GLProgramState:getOrCreateWithGLProgramName( name ):getGLProgram()
            program:reset()
            program:initWithFilenames("shaders/" .. name .. ".vsh", "shaders/" .. name .. ".fsh")
        end
        program:link()
        program:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram( program , name  )
    end
end

registerShader()

return lshader

