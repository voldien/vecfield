#import<Foundation/Foundation.h>
#import"VectorField.h"
#import"PerlinNoise.h"
#include<assert.h>

@implementation VectorField

+(float*) createVectorField: (int) width: (int) height{

	int x, y;
	const int blocksize = width * height * 2 * sizeof(float);

	/*	Check arguments.	*/
	if(width < 1 || height < 1){
		@throw [NSException
			exceptionWithName:@"NSInvalidArgumentException"
			reason:@"width and height must be greater than 0"
			userInfo:nil];
	}

	/*  Allocate vector field.  */
	float* vectorfield = (float*)malloc(blocksize);
	assert(vectorfield);

	/*  Generate perlin noise.  */
	float* perlin = [PerlinNoise generatePerlinNoise: width: height];
	assert(perlin);

	/*  Generate vector field.  */
	for(y = 0; y < height; y++){
		for(x = 0; x < width; x++){
			const float theta = perlin[y * height + x];
			
			/*	amplitude.	*/
			const float amplitude = 1.0f; //(perlin[y* height + (x + 1) % width] - theta) * 10;
			
			/*	*/
			vectorfield[y * height * 2 + x * 2 + 0] = cos(theta) * amplitude;
			vectorfield[y * height * 2 + x * 2 + 1] = sin(theta) * amplitude;
		}
	}

	free(perlin);
	return vectorfield;
}

@end
