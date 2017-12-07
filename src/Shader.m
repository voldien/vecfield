#import<Foundation/Foundation.h>
#import"Shader.h"
#include<GL/glew.h>

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
		[self bind];
		glUniform1iARB(location, pvalue);
	}
}

-(void) setUniformf: (int) location: (float) pvalue{
	if(glProgramUniform1f){
		glProgramUniform1f(self->program, location, pvalue);
	}
	else{
		[self bind];
		glUniform1fARB(location, pvalue);
	}
}

-(void) setUniform2fv: (int) location: (const float*) pvalue{
	if(glProgramUniform2fv){
		glProgramUniform2fv(self->program, location, 1, pvalue);
	}
	else{
		[self bind];
		glUniform2fv(location, 1, pvalue);
	}
}

-(void) setUniformMatrix: (int) location: (const float*) pvalue{
	if(glProgramUniformMatrix4fv){
		glProgramUniformMatrix4fv(self->program, location,  1, GL_FALSE, (const GLfloat*)pvalue);
	}
	else{
		[self bind];
		glUniformMatrix4fvARB(location, 1, GL_FALSE, (const GLfloat*)pvalue);
	}
}


@end
