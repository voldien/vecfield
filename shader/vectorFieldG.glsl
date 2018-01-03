
#extension GL_ARB_geometry_shader4 : enable

layout(points) in;
layout(line_strip) out;
layout(max_vertices = 2) out;

/*  */
uniform mat4 view;

/*  */
#if __VERSION__ > 120
smooth out vec2 amplitude;
#else
varying vec2 amplitude;
#endif

void main(void){
	int i;

	/*  Create Billboard quad.    */
	for(i = 0; i < gl_in.length(); i++){
		const vec4 glpos = gl_in[i].gl_Position;
		
		const vec2 pos = glpos.xy;
		const vec2 dir = glpos.zw;

		/*	*/
		gl_Position = view * vec4(pos, 0.0, 1.0);
		amplitude = dir;
		EmitVertex();
		
		/*	*/
		gl_Position = view * vec4(pos + dir, 0.0, 1.0);
		amplitude = dir;
		EmitVertex();
	}
	EndPrimitive();
}
