#if __VERSION__ > 130
layout(location = 0) in vec3 vertex;
#else
attribute vec3 vertex;
#endif

#if __VERSION__ > 120
smooth out vec3 vVertex;
#else
varying vec3 vVertex;
#endif

void main(void){
	gl_Position = vec4(vertex, 1.0);
	vVertex = vertex;
}
