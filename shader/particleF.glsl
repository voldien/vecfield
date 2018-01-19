#if __VERSION__ > 130
layout(location = 0) out vec4 fragColor;
#elif __VERSION__ == 130
out vec4 fragColor;
#endif

/*  */
uniform sampler2D tex0;
uniform vec4 color = vec4(0.0,1.0,0.0,1.0);
uniform float zoom;
uniform float deltaTime;
uniform float time;

/*  */
#if __VERSION__ > 120
smooth in vec2 uv;
smooth in vec4 gColor;
#else
varying vec2 uv;
varying vec4 gColor;
#endif

vec4 computeColor(){
	return texture(tex0, uv) * color * gColor + ambientColor;
}

void main(void){
#if __VERSION__ > 130
	fragColor = computeColor();
#else
	gl_FragColor = computeColor();
#endif
}
