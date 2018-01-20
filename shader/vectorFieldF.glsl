#if __VERSION__ > 130
layout(location = 0) out vec4 fragColor;
#elif __VERSION__ == 130
out vec4 fragColor;
#endif

/*  */
uniform vec4 color = vec4(0.0,1.0,0.0,1.0);

/*  */
#if __VERSION__ > 120
smooth in vec3 amplitude;
#else
varying vec3 amplitude;
#endif

vec4 computeColor(){
	return vec4(amplitude, 1.0);
}

void main(void){
#if __VERSION__ > 130
	fragColor = computeColor();
#else
	gl_FragColor = computeColor();
#endif
}
