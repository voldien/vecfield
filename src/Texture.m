#import"Texture2D.h"
#include<GL/glew.h>

@implementation Texture2D : Resource

-(id) initWithTexture: (int) ptexture: (int) width: (int) height{
	self = [super init];
	if(self != nil){
		self->texture = ptexture;
		self->width = width;
		self->height = height;
	}
	return self;
}

-(id) init{
	self = [super init];
	if(self != nil){
		self->texture = 0;
		self->width = 0;
		self->height = 0;
	}    
	return self;
}

-(void) dealloc{
	[super dealloc];
}

-(void) release{
	glDeleteTextures(1, &texture);
}

-(void) bind: (int) index{
	glActiveTextureARB(GL_TEXTURE0_ARB + index);
	glBindTexture(GL_TEXTURE_2D, self->texture);
}

-(int) getWidth{
	return self->width;
}

-(int) getHeight{
	return self->height;
}

@end
