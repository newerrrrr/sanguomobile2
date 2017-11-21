//李寒松!
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying mediump vec4 v_originPosition;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec4 v_originPosition;
#endif

void main()
{
    gl_Position = CC_MVPMatrix * a_position;
    v_texCoord = a_texCoord;
	v_fragmentColor = a_color;
	v_originPosition = a_position * 0.0005;
}