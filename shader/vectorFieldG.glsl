
#extension GL_ARB_geometry_shader4 : enable

layout(points) in;
layout(line_strip) out;
layout(max_vertices = 6) out;

/*  */
uniform mat4 view;

/*  */
#if __VERSION__ > 120
smooth out vec3 amplitude;
#else
varying vec3 amplitude;
#endif

/*	Compute arrow color.	*/
vec3 computeColor(const in vec2 dir){
	return vec3((dir.x + 1.0) / 2.0, (dir.y + 1.0) / 2.0, (dir.x - 1.0) / 2.0);
}

void main(void){
	int i;
	const float PI = 3.14159265359;
	const float hPI = PI;
	const float arrowAngle = PI / 7.0;
	const vec2 identity = vec2(1.0, 0.0);
	const float arrowLength = 1.0 / 3.5;

	/*  Create Billboard quad.    */
	for(i = 0; i < gl_in.length(); i++){
		const vec4 glpos = gl_in[i].gl_Position;
		
		const vec2 pos = glpos.xy;
		const vec2 dir = glpos.zw;
		const vec2 endPos = pos + dir;

		/*	Start position.	*/
		gl_Position = view * vec4(pos, 0.0, 1.0);
		amplitude = computeColor(dir);
		EmitVertex();
		
		/*	End position.	*/
		gl_Position = view * vec4(endPos, 0.0, 1.0);
		amplitude = computeColor(dir);
		EmitVertex();
		EndPrimitive();
		
		/*	Start left arrow position.	*/
		gl_Position = view * vec4(endPos, 0.0, 1.0);
		amplitude = computeColor(dir);
		EmitVertex();

		/*	Precompute variables.	*/
		const vec2 deltaDir = normalize(endPos - pos);
		const float pgag = dot(deltaDir, identity);
		const float pang = acos(pgag) * sign(deltaDir.y);

		vec2 lvec = vec2(cos(hPI + arrowAngle + pang), sin(hPI + arrowAngle + pang)) * length(dir) * arrowLength;
		gl_Position = view * vec4(endPos + lvec, 0.0, 1.0);
		EmitVertex();
		EndPrimitive();
		
		/*	Start right arrow position.	*/
		gl_Position = view * vec4(endPos, 0.0, 1.0);
		amplitude = computeColor(dir);
		EmitVertex();

		vec2 rvec = vec2(cos(hPI - arrowAngle + pang), sin(hPI - arrowAngle + pang)) * length(dir) * arrowLength;
		gl_Position = view * vec4(endPos + rvec, 0.0, 1.0);
		EmitVertex();
		EndPrimitive();
		
	}

}
