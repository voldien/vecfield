#if __VERSION__ > 130
layout(location = 0) out vec4 fragColor;
#elif __VERSION__ == 130
out vec4 fragColor;
#endif

/*	*/
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
	const vec2 halfThick = (invScreen / 2.0) * thick * scale;
	
	/*	*/
	vec2 p = pos.xy;
	vec2 dy = ceil(p) - p;
	
	/*	Compute dotted.	*/
	const float freq = 1000;
	const float xdotted = round(cos(gl_FragCoord.x * freq));
	const float ydotted = round(cos(gl_FragCoord.y * freq));
	
	/*	*/
	bvec2 gr = lessThan(dy, halfThick);
	
	/*	*/
	int s = int(gr.x) * int(xdotted);
	int b = int(gr.y) * int(ydotted);
	
	return (b | s);
}

/*  Compute the grid color. */
vec4 computeColor(){

	/*	constants.	*/
	const float grid1Intensity = 0.8;
	const float grid2Intensity = 0.45;

	/*	*/
	const float zscale = 1.0f / zoom;
	const vec3 pos1 = (view * vec4(vVertex, 0.0)).xyz;
	const vec3 pos2 = (view * vec4(vVertex, 0.0)).xyz + (view * vec4(0.5,0.5,0,0)).xyz;

	/*  Compute grid color.   */
	float color = resultHorVer(pos1, abs(zscale)) * grid1Intensity;
	color += resultHorVer(pos2, zoom) * round( cos(pos2.x)) * grid2Intensity;

	
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
