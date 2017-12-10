#import"TextureFactory.h"
#import"Texture2D.h"
#include<GL/glew.h>

@implementation TextureFactory

+(Texture2D*) createTexture: (int) width: (int) height: (const void*) pixels{

	Texture2D* texture;
	GLuint text;
	const int numlevel = 5;

	if(width < 1 || height < 1){
		@throw [NSException
				exceptionWithName:@"NSInvalidArgumentException"
				reason:@"width and height must be greater than 0"
				userInfo:nil];
	}

	if(pixels == NULL){
		@throw [NSException
				exceptionWithName:@"NSNullReferenceException"
				reason:@"pixels argument must not be a null argument"
				userInfo:nil];
	}

	/*  Create texture. */
	glGenTextures(1, &text);
	glBindTexture(GL_TEXTURE_2D, text);
	glPixelStorei(GL_PACK_ALIGNMENT, 4);

	/*	Repeat UV corrdinates.	*/
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, GL_CLAMP);

	/*  Bilinear interploation on the pixel colors. */
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);

	/*  Assign texture data.    */
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);

	/*  Create mipmap.  */
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, numlevel);
	glGenerateMipmap(GL_TEXTURE_2D);

	/*  */
	glBindTexture(GL_TEXTURE_2D, 0);
	/*  Create texture. */
	return [[[Texture2D alloc] initWithTexture: text: width: height] autorelease];
}

+(Texture2D*) createCircleTexture: (int) width: (int) height{

	int x,y;
	int cx = width / 2;
	int cy = height / 2;
	uint32_t* pixels;
	Texture2D* texture;

	/*  Check if argument is valid. */
	if(width < 1 || height < 1){
		@throw [NSException
				exceptionWithName:@"NSInvalidArgumentException"
				reason:@"width and height must be greater than 0"
				userInfo:nil];
	}

	/*  Allocate pixel block.   */
	pixels = (uint32_t*)malloc(width * height * sizeof(uint32_t));
	assert(pixels);

	/*  Iterate through each pixel. */
	for(y = 0; y < height; y++){
		for(x = 0; x < width; x++){
			float distance = sqrtf(powf((x - cx), 2.0f) + powf((y - cy), 2.0f));
			if(distance <= (float)cx){
				pixels[y * height + x] = UINT_MAX;
			}else{
				pixels[y * height + x] = 0;
			}
		}
	}

	/*  */
	texture = [TextureFactory createTexture: width: height: pixels];
	free(pixels);
	return texture;
}


@end
