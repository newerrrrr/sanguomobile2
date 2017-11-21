//李寒松!
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform float u_time;
uniform vec3 u_lightColor;

uniform sampler2D u_texture1;
uniform sampler2D u_texture2;

void main() {
	
	float a = mod(u_time * 1.5, 2.0 * 3.1415926535898);
	vec2 texCoord = vec2(fract(v_texCoord.x), fract(v_texCoord.y));
	vec2 dv = vec2(0.3, 0.25) - v_texCoord;
	float dv_len = length(dv);
	float val = dv_len * 1.4142135623731 * 3.1415926535898 * 14.0;
	vec2 uv = texCoord + dv * 0.015 * cos(val + a);
	vec4 col = v_fragmentColor * texture2D(CC_Texture0, uv);
	if(col.a < 0.004)
		discard;
    vec2 textCoord_of = uv;
	textCoord_of.x = fract(textCoord_of.x + 0.01 * u_time);
	textCoord_of.y = fract(textCoord_of.y - 0.04 * u_time);
	float v = texture2D(u_texture1, textCoord_of).x + texture2D(u_texture2, uv).x;
    if(v > 1.25)
        gl_FragColor = vec4(col.xyz + u_lightColor * ((v - 1.0) * 1.6), col.a);
    else
        gl_FragColor = col;
}