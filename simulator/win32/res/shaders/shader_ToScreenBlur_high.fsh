//李寒松!
#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

varying vec4 v_originPosition;

uniform vec2 u_lhs_center;
uniform vec2 u_lhs_vec2_1; //x=radius , y=minRadius
uniform vec2 u_lhs_vec2_2; //x=onePixelSizeX , y=onePixelSizeY
uniform vec2 u_lhs_vec2_3; //x=burlVar , y=alpha

void main()
{
	float dt = distance(v_originPosition.xy, u_lhs_center.xy);
	float weight = 1.0;
	if (dt < u_lhs_vec2_1.x)
	{
		if (dt <= u_lhs_vec2_1.y)
		{
			gl_FragColor = texture2D(CC_Texture0,vec2(v_texCoord.x,v_texCoord.y));
			return;
		}
		else
			weight = (dt - u_lhs_vec2_1.y) / (u_lhs_vec2_1.x - u_lhs_vec2_1.y);
	}
	vec4 col = vec4(0.0);
	float blurStep = u_lhs_vec2_3.x * weight;
	float x = u_lhs_vec2_2.x * blurStep;
	float y = u_lhs_vec2_2.y * blurStep;
	vec2 v = vec2(0.75,7.0);
	col += texture2D(CC_Texture0,vec2(v_texCoord.x,v_texCoord.y));
	if (blurStep >= 2.0)
	{
		v = vec2(0.25,3.0);
		float x_h = x * 0.5;
		float y_h = y * 0.5;
		vec4 sample1 = texture2D(CC_Texture0,vec2(v_texCoord.x - x_h, v_texCoord.y - y_h));
		vec4 sample2 = texture2D(CC_Texture0,vec2(v_texCoord.x + x_h, v_texCoord.y + y_h));
		vec4 sample3 = texture2D(CC_Texture0,vec2(v_texCoord.x + x_h, v_texCoord.y - y_h));
		vec4 sample4 = texture2D(CC_Texture0,vec2(v_texCoord.x - x_h, v_texCoord.y + y_h));
		vec4 sample5 = texture2D(CC_Texture0,vec2(v_texCoord.x - x_h, v_texCoord.y));
		vec4 sample6 = texture2D(CC_Texture0,vec2(v_texCoord.x + x_h, v_texCoord.y));
		vec4 sample7 = texture2D(CC_Texture0,vec2(v_texCoord.x, v_texCoord.y - y_h));
		vec4 sample8 = texture2D(CC_Texture0,vec2(v_texCoord.x, v_texCoord.y + y_h));
		col = (col + (sample1 + sample2 + sample3 + sample4 + sample5 + sample6 + sample7 + sample8) * 0.75) / 7.0;
	}
	vec4 sample1 = texture2D(CC_Texture0,vec2(v_texCoord.x - x, v_texCoord.y - y));
	vec4 sample2 = texture2D(CC_Texture0,vec2(v_texCoord.x + x, v_texCoord.y + y));
	vec4 sample3 = texture2D(CC_Texture0,vec2(v_texCoord.x + x, v_texCoord.y - y));
	vec4 sample4 = texture2D(CC_Texture0,vec2(v_texCoord.x - x, v_texCoord.y + y));
	vec4 sample5 = texture2D(CC_Texture0,vec2(v_texCoord.x - x, v_texCoord.y));
	vec4 sample6 = texture2D(CC_Texture0,vec2(v_texCoord.x + x, v_texCoord.y));
	vec4 sample7 = texture2D(CC_Texture0,vec2(v_texCoord.x, v_texCoord.y - y));
	vec4 sample8 = texture2D(CC_Texture0,vec2(v_texCoord.x, v_texCoord.y + y));
	col = (col + (sample1 + sample2 + sample3 + sample4 + sample5 + sample6 + sample7 + sample8) * v.x) / v.y;
	float alpha = u_lhs_vec2_3.y * weight;
	float target_factor = (1.0 - alpha);
	gl_FragColor = vec4(col.r * target_factor, col.g * target_factor,col.b * target_factor, alpha + col.a * target_factor);
}
