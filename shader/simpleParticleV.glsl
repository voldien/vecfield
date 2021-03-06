#if __VERSION__ > 130
layout(location = 0) in vec4 vertex;
#else
attribute vec3 vertex;
#endif

/*	*/
uniform mat4 view;

/*	*/
#if __VERSION__ > 120
smooth out vec4 vColor;
#else
varying vec4 vColor;
#endif

void main(void){
	gl_Position = view * vec4(vertex.xy, 0.0, 1.0);
	
	const vec2 velocity = vertex.zw;
	const float reduce = (1.0/-10.0);
	const float green = (1.0 / 20.0);
	const float blue = (1.0 / 5.0);
	vColor = vec4(length(velocity) * reduce, velocity.x * green, velocity.y * blue, 1.0);
}

