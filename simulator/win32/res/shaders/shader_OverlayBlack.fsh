//李寒松!
#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
	vec4 col = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
	if(col.a<0.004)
		discard;
	vec4 b_col = vec4(0.0,0.0,0.0,0.4);
	float target_factor = (1.0 - b_col.a);
	float alpha_var = b_col.a + col.a * target_factor;
	if(alpha_var>col.a)
		alpha_var = col.a;
	gl_FragColor = vec4(b_col.r + col.r * target_factor, b_col.g + col.g * target_factor, b_col.b + col.b * target_factor, alpha_var);
}