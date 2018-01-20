
#extension GL_ARB_geometry_shader4 : enable

layout(points) in;
layout(triangle_strip) out;
layout(max_vertices = 4) out;

/*  */
uniform float zoom = 1.0;
uniform mat4 view;
uniform float deltaTime;
uniform float time;

/*  */
#if __VERSION__ > 120
smooth out vec2 uv;
smooth out vec4 gColor;
#else
varying vec2 uv;
varying vec4 gColor;
#endif

void main(void){
	const int noffsets = 4;
	int i, j;

	/*	Polygone offset.	*/
	const vec3 polyoffset[] = vec3[](
		vec3( 1.0, 1.0, 0),
		vec3( 1.0,-1.0, 0),
		vec3(-1.0, 1.0, 0),
		vec3(-1.0,-1.0, 0)
	);

	/*	UV  coordinate.	*/
	const vec2 cUV[] = vec2[](
		vec2(1.0, 1.0),
		vec2(1.0, 0.0),
		vec2(0.0, 1.0),
		vec2(0.0, 0.0)
	);

	/*  Create Billboard quad.    */
	for(i = 0; i < gl_in.length(); i++){
		for(j = 0; j < noffsets; j++){

			/*	Compute inverse zoom - expressed as a polynominal.	*/
			const float invZoom = (1.0f / zoom + zoom * (1.0f / 150.0f)) * 0.5f;
			const vec3 particlePos = vec3(gl_in[i].gl_Position.xy, 0.0) + polyoffset[j] * invZoom;

			/*	Velocity.	*/
			const vec2 velocity = gl_in[i].gl_Position.zw;

			/*	*/
			gl_Position = view * vec4(particlePos, 1.0);
			gColor = vec4(velocity, 0.0, 1.0);
			uv = cUV[j];
			EmitVertex();
		}
	}
	EndPrimitive();
}
