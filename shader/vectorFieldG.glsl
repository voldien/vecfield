
#extension GL_ARB_geometry_shader4 : enable

layout(points) in;
layout(line_strip) out;
layout(max_vertices = 6) out;

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
	const vec2 minAmp = vec2(0.0,0.0);
	const vec2 maxAmp = vec2(1.0,1.0);
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
		amplitude = clamp(2 * dir - vec2(1), minAmp, maxAmp);
		EmitVertex();
		
		/*	End position.	*/
		gl_Position = view * vec4(endPos, 0.0, 1.0);
		amplitude = clamp(2.0f * dir - vec2(1), minAmp, maxAmp);
		EmitVertex();
		EndPrimitive();
		
		/*	Start left arrow position.	*/
		gl_Position = view * vec4(endPos, 0.0, 1.0);
		amplitude = clamp(2 * dir - vec2(1), minAmp, maxAmp);
		EmitVertex();

		/*	*/
		const vec2 deltaDir = normalize(endPos - pos);
		const float pgag = dot(deltaDir, identity);
		const float pang = acos(pgag) * sign(deltaDir.y);

		vec2 lvec = vec2(cos(hPI + arrowAngle + pang), sin(hPI + arrowAngle + pang)) * length(dir) * arrowLength;
		gl_Position = view * vec4(endPos + lvec, 0.0, 1.0);
		EmitVertex();
		EndPrimitive();
		
		/*	Start right arrow position.	*/
		gl_Position = view * vec4(endPos, 0.0, 1.0);
		amplitude = clamp(2 * dir - vec2(1), minAmp, maxAmp);
		EmitVertex();

		vec2 rvec = vec2(cos(hPI - arrowAngle + pang), sin(hPI - arrowAngle + pang)) * length(dir) * arrowLength;
		gl_Position = view * vec4(endPos + rvec, 0.0, 1.0);
		EmitVertex();
		EndPrimitive();
		
	}

}
