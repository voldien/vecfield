#import"Geometry.h"
#include<assert.h>
#include<GL/glew.h>

@implementation Geometry : Resource

-(id) init{
	self = [super init];
	if(self != nil){
		self->vao = 0;
		self->ibo = 0;
		self->vbo = 0;
		self->target = 0;
		self->numIndices = 0;
		self->numVertices = 0;
	}
	return self;
}

-(id) initWithGeometryInit: (GeometryInit*) init{
	self = [super init];
	if(self != nil){
		if(init == NULL){
			@throw [NSException exceptionWithName:@"NSNullReferenceException"
				reason:@"init parameter argument must not be null."
				userInfo:nil];
		}
		self->vao = init->vao;
		self->ibo = init->ibo;
		self->vbo = init->vbo;
		self->target = init->target;
		self->numIndices = init->numIndices;
		self->numVertices = init->numVertices;
	}
	return self;
}

-(void) dealloc{
	[super dealloc];
}

-(void) release{
	if(glIsBufferARB((GLuint)self->ibo))
		glDeleteBuffers(1, (const GLuint*)&self->vbo);
	if(glIsBufferARB((GLuint)self->vbo))
		glDeleteBuffers(1, (const GLuint*)&self->ibo);
	if(glIsVertexArray((GLuint)self->vao))
		glDeleteVertexArrays(1, (const GLuint*)&self->vao);
}

-(void) bind{
	glBindVertexArray(self->vao);
}

-(void) draw{
	switch([self getNumIndices]){
		case 0:
			glDrawArrays(self->target, 0, self->numVertices);
			break;
		default:
			glDrawElements(self->target, self->numIndices, GL_UNSIGNED_INT, NULL);
			break;
	}
}

-(int) getNumVertices{
	return self->numVertices;
}

-(int) getNumIndices{
	return self->numIndices;
}

-(unsigned int) getVBOUID{
	return self->vbo;
}

@end
