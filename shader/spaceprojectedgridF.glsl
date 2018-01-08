#if __VERSION__ > 130
layout(location = 0) out vec4 fragColor;
#elif __VERSION__ == 130
out vec4 fragColor;
#endif

/*	*/
uniform sampler2D tex1;
uniform mat4 view;
uniform float zoom = 1.0;
uniform float thick = 10.0205;
uniform vec2 screen = vec2(1.0f);

#if __VERSION__ > 120
smooth in vec3 vVertex;
#else
varying vec3 vVertex;
#endif

/*	Compute horizontal and vertical grid lines.	*/
float resultHorVer(const in vec3 pos, float scale){

	/*	*/
	const float z = scale;
	const vec2 invScreen = 1.0f / screen;
	
	vec2 ex_UV = (invScreen * vec2(gl_FragCoord.xy)) * scale + pos.xy ;
	
	return texture(tex1, ex_UV).a;
}

/*  Compute the grid color. */
vec4 computeColor(){

	/*	constants.	*/
	const float zoomLevel = 68.0;
	const float grid1Intensity = 0.75;
	const float grid2Intensity = 0.45;

	/*	*/
	const float zscale = (zoomLevel - zoom);
	const vec3 pos1 = (view * vec4(vVertex, 0.0)).xyz;
	const vec3 pos2 = (view * vec4(vVertex, 0.0)).xyz + (view * vec4(0.5,0.5,0,0)).xyz;

	/*  Compute grid color.   */
	float color = resultHorVer(pos1, zscale) * grid1Intensity;
	color += resultHorVer(pos2, zscale)* grid2Intensity;
	/*  Final color.	*/
	return vec4(color, color, color, 1.0);
}

void main(void){
#if __VERSION__ < 130
	fragColor = computeColor();
#else
	gl_FragColor = computeColor();
#endif
}
