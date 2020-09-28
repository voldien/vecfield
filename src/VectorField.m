#import<Foundation/Foundation.h>
#import"VectorField.h"
#import"PerlinNoise.h"
#include<assert.h>
#include<hpm.h>

@implementation VectorField

+(float*) createVectorField: (int) width: (int) height{

	int x, y;
	const float generalAmplitude = 400.0f;
	const int blocksize = width * height * sizeof(hpmvec2f);
	const hpmvec2f lt = {1.0f, -1.0f};
	const hpmvec2f rt = {-1.0f, -1.0f};
	const hpmvec2f lb = {1.0f, 1.0f};
	const hpmvec2f rb = {-1.0f, 1.0f};
	
	/*	*/
	const hpmvec2f left = {1.0f,0.0f};
	const hpmvec2f right = {-1.0f, 0.0f};
	const hpmvec2f top = {0.0f, -1.0f};
	const hpmvec2f bottom = {0.0f, 1.0f};

	/*	Check arguments.	*/
	if(width < 1 || height < 1){
		@throw [NSException
			exceptionWithName:@"NSInvalidArgumentException"
			reason:@"width and height must be greater than 0"
			userInfo:nil];
	}

	/*  Allocate vector field.  */
	hpmvec2f* vectorfield = (hpmvec2f*)malloc(blocksize);
	assert(vectorfield);

	/*  Generate perlin noise.  */
	float* perlin = [PerlinNoise generatePerlinNoise: width: height];
	assert(perlin);
	
	/*  Generate perlin noise.  */
	float* perlinDifferentail = [PerlinNoise generateDifferntialPerlinNoise: width: height];
	assert(perlinDifferentail);

	/*  Generate vector field.  */
	const float scale = 15.0f;
	for(y = 0; y < height; y++){
		for(x = 0; x < width; x++){
			const float theta = perlin[y * height + x];
			const float theta2 = perlin[(height - y) * height + x];
			/*	amplitude.	*/
			const float amplitude = HPM_CLAMP(perlin[y * height + x] * scale, 0.5f, 1000000.0f);
			
			/*	*/
			vectorfield[y * height + x][0] = cos(theta * 2.0f + theta2) * amplitude;
			vectorfield[y * height + x][1] = sin(theta * 2.0f + theta2) * amplitude;
		}
	}
	
	/*	Bottom and top edges.	*/
	y = 0;
	for(x = 0; x < width; x++){
		vectorfield[(y * height) + x] = bottom * generalAmplitude;
	}
	y = height - 1;
	for(x = 0; x < width; x++){
		vectorfield[y * height + x] = top * generalAmplitude;
	}
	
	/*	Left and right edges.	*/
	x = 0;
	for(y = 0; y < height; y++){
		vectorfield[y * height + x] = left * generalAmplitude;
	}
	x = width - 1;
	for(y = 0; y < height; y++){
		vectorfield[y * height + x] = right * generalAmplitude;
	}
	
	/*	Corners.	*/
	vectorfield[0] = lb * generalAmplitude;
	vectorfield[width - 1] = rb * generalAmplitude;
	vectorfield[(height -1) * width] = lt * generalAmplitude;
	vectorfield[width * height] = rt * generalAmplitude;

	free(perlin);
	free(perlinDifferentail);
	return (float*)vectorfield;
}

@end
