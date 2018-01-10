#import<Foundation/Foundation.h>
#import"Shader.h"
#include<stdio.h>
#include<GL/glew.h>

static Shader* prevShader = nil;
static void getCurrentShader(Shader* shader){
	GLint program;
	if(prevShader == nil)
		prevShader = [Shader alloc];
	glGetIntegerv(GL_CURRENT_PROGRAM, &program);
	[shader initWithProgram: program];
}

@implementation Shader : Resource{
	unsigned int program;
}



-(id) initWithProgram: (int) glprogram{
	self = [super init];
	if(self != nil){
		self->program = glprogram;
	}
	return self;
}

-(id) init{
	self =  [super init];
	if(self != nil){
		self->program = 0;
	}
	return self;
}
-(void) dealloc{
	[super dealloc];
}

-(void) release{
	if(glIsProgramARB((GLuint)self->program))
		glDeleteProgramsARB(1, (const GLuint*)&program);
}

-(void) bind{
	glUseProgram(self->program);
}

-(int) getUniformLocation: (const char*) name{
	return glGetUniformLocationARB(program, name);
}

/*  TODO add support for legacy swap GL program.   */
-(void) setUniformi: (int) location: (int) pvalue{
	if(glProgramUniform1i){
		glProgramUniform1i(self->program, location, pvalue);
	}
	else{
		getCurrentShader(prevShader);
		[self bind];
		glUniform1iARB(location, pvalue);
		[prevShader bind];
	}
}

-(void) setUniformf: (int) location: (float) pvalue{
	if(glProgramUniform1f){
		glProgramUniform1f(self->program, location, pvalue);
	}
	else{
		getCurrentShader(prevShader);
		[self bind];
		glUniform1fARB(location, pvalue);
		[prevShader bind];
	}
}

-(void) setUniform2fv: (int) location: (const float*) pvalue{
	if(glProgramUniform2fv){
		glProgramUniform2fv(self->program, location, 1, pvalue);
	}
	else{
		getCurrentShader(prevShader);
		[self bind];
		glUniform2fvARB(location, 1, pvalue);
		[prevShader bind];
	}
}

-(void) setUniformMatrix: (int) location: (const float*) pvalue{
	if(glProgramUniformMatrix4fv){
		glProgramUniformMatrix4fv(self->program, location,  1, GL_FALSE, (const GLfloat*)pvalue);
	}
	else{
		getCurrentShader(prevShader);
		[self bind];
		glUniformMatrix4fvARB(location, 1, GL_FALSE, (const GLfloat*)pvalue);
		[prevShader bind];
	}
}


@end
