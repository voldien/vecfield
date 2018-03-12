#if __VERSION__ > 130
layout(location = 0) out vec4 fragColor;
#elif __VERSION__ == 130
out vec4 fragColor;
#endif

uniform vec4 ambientColor = vec4(0.15, 0.15, 0.15, 0.0);
uniform vec4 color = vec4(1.0,0.0,0.0,1.0);

/*  */
#if __VERSION__ > 120
smooth in vec4 vColor;
#else
varying vec4 vColor;
#endif

vec4 computeColor(){
	return (color + vColor) + ambientColor;
}

void main(void){
#if __VERSION__ > 130
	fragColor = computeColor();
#else
	gl_FragColor = computeColor();
#endif
}
