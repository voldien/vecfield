#import"ShaderFactory.h"
#import"Shader.h"
#import"ZipFile.h"
#include<GL/glew.h>
#include<SDL2/SDL.h>
#include <VecField.h>

@implementation ShaderFactory

+(int) getGLSLVersion{

	unsigned int version;
	char glstring[128] = {0};
	char* wspac;

	/*	Extract version number.	*/
	strcpy(glstring, (const char*)glGetString(GL_SHADING_LANGUAGE_VERSION));
	wspac = strstr(glstring, " ");
	if(wspac){
		*wspac = '\0';
	}
	version = strtof(glstring, NULL) * 100;

	return version;
}

+(Shader*) createShader: (const char*) vpath: (const char*) fpath: (const char*) gpath{
	
	Shader* shader;
	char* vsource = NULL;
	char* fsource = NULL;
	char* gsource = NULL;
	
	/*  Read shader source files.   */
	if(vpath){
		[shaderZip readString: vpath: (void**)&vsource];
	}
	if(fpath){
		[shaderZip readString: fpath: (void**)&fsource];
	}
	if(gpath){
		[shaderZip readString: gpath: (void**)&gsource];
	}
	
	/*  Create shader.  */
	shader = [ShaderFactory createShaderBySource: (const char*)vsource: (const char*)fsource: (const char*)gsource];
	
	/*  Release.    */
	free(vsource);
	free(fsource);
	free(gsource);
	
	return shader;
}

+(Shader*) createShaderBySource: (const char*) vsource: (const char*) fsource: (const char*) gsource{
	
	char glversion[64];
	const char* vsources[2];
	const char* fsources[2];
	const char* gsources[2];
	const int nsources = sizeof(vsources) / sizeof(vsources[0]);
	
	GLint lstatus;
	GLint vstatus;
	GLint len;
	int value;
	const char* strcore;

	GLint vs = 0;
	GLint fs = 0;
	GLint gs = 0;
	GLint program = glCreateProgram();
	if(program < 0){
		@throw [NSException exceptionWithName:@"NSErrorException"
			reason:[[NSString stringWithFormat:@"Error occured - %s", glewGetErrorString(glGetError())] autorelease]
			userInfo:nil];
	}
	
	/*	Check if core.	*/
	SDL_GL_GetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, &value);
	strcore = ( (value & SDL_GL_CONTEXT_PROFILE_CORE) != 0 ) ? "core" : "";

	/*	Generate version decleration.   */
	sprintf(glversion, "#version %d %s\n", [ShaderFactory getGLSLVersion], strcore);

	/*	Assign glsl version decleration.	*/
	vsources[0] = glversion;
	fsources[0] = glversion;
	gsources[0] = glversion;
	
	/*  Vertex shader.  */
	if(vsource){
		vsources[1] = vsource;
		vs = (GLint)[ShaderFactory compileShader: GL_VERTEX_SHADER_ARB: nsources: vsources];
		glAttachShader(program, vs);
	}

	/*  Fragment shader.    */
	if(fsource){
		fsources[1] = fsource;
		fs = (GLint)[ShaderFactory compileShader: GL_FRAGMENT_SHADER_ARB: nsources: fsources];
		glAttachShader(program, fs);
	}

	/*  Geometry shader.    */
	if(gsource){
		gsources[1] = gsource;
		gs = (GLint)[ShaderFactory compileShader: GL_GEOMETRY_SHADER_ARB: nsources: gsources];
		glAttachShader(program, gs);
	}

	/*	Link and check if succesfully linked.	*/
	glLinkProgram(program);
	glGetProgramiv(program, GL_LINK_STATUS, &lstatus);
	if(lstatus == GL_FALSE){
		GLchar errorlog[2048];
		glGetProgramInfoLog(program, sizeof(errorlog), &len, &errorlog[0]);
		@throw [NSException 
				exceptionWithName:@"NSErrorException"
				reason:[[NSString stringWithFormat:@"Linked failed - %s", errorlog] autorelease]
				userInfo:nil];
	}

	/*	Validate status of the shader.	*/
	glValidateProgram(program);
	glGetProgramiv(program, GL_VALIDATE_STATUS, &vstatus);
	if(vstatus == GL_FALSE){
		GLchar errorlog[2048];
		glGetProgramInfoLog(program, sizeof(errorlog), &len, &errorlog[0]);
		/*		*/
		@throw [NSException 
				exceptionWithName:@"NSErrorException"
				reason:[NSString stringWithUTF8String:errorlog]
				userInfo:nil];
	}

	/*	Enable backward compatibility.	*/
	glBindAttribLocationARB(program, 0,  "vertex");
	glBindFragDataLocation(program, 0, "fragColor");
	
	/*  Release shader resources once linked.   */
	if(glIsShader(vs)){
		glDetachShader(program, vs);
		glDeleteShader(vs);
	}
	if(glIsShader(fs)){
		glDetachShader(program, fs);
		glDeleteShader(fs);
	}
	if(glIsShader(gs)){
		glDetachShader(program, gs);
		glDeleteShader(gs);
	}
	
	return [[[Shader alloc] initWithProgram: program] autorelease];
}

+(int) compileShader: (int) type: (int) numshaders: (const char**) sources{
	
	GLint shader;
	GLint cstatus;
	
	/*  Create and compile shader object.   */
	shader = glCreateShader(type);
	glShaderSourceARB(shader, numshaders, sources, NULL);
	glCompileShaderARB(shader);
	
	/*	Check for compiling errors.	*/
	glGetShaderiv(shader, GL_COMPILE_STATUS, &cstatus);
	if(cstatus == GL_FALSE){
		GLchar infolog[2048];
		glGetShaderInfoLog(shader, sizeof(infolog), NULL, infolog);
		@throw [NSException 
				exceptionWithName:@"NSErrorException"
				reason:[[NSString stringWithFormat:@"Failed compiling shader object - %s", infolog] autorelease]
				userInfo:nil];
	}
	
	return shader;
}

@end
