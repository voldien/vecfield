#if __VERSION__ > 130
layout(location = 0) in vec4 vertex;
#else
attribute vec3 vertex;
#endif

void main(void){
	gl_Position = vertex;
}
