#import<Foundation/Foundation.h>
#import"VectorField.h"
#import"PerlinNoise.h"
#include<assert.h>
#include<hpm/hpm.h>


@implementation VectorField

+(float*) createVectorField: (int) width: (int) height{

	int x, y;
	const int blocksize = width * height * 2 * sizeof(float);
	const hpmvec2f lt = {1.0f, -1.0f};
	const hpmvec2f rt = {-1.0f, -1.0f};
	const hpmvec2f lb = {1.0f, 1.0f};
	const hpmvec2f rb = {-1.0f, 1.0f};
	
	const hpmvec2f left = {1,0};
	const hpmvec2f right = {-1,0};
	const hpmvec2f top = {0,-1};
	const hpmvec2f bottom = {0,1};

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

	/*  Generate vector field.  */
	for(y = 0; y < height; y++){
		for(x = 0; x < width; x++){
			const float theta = perlin[y * height + x];
			
			/*	amplitude.	*/
			const float amplitude = 1.0f; //(perlin[y* height + (x + 1) % width] - theta) * 10;
			
			/*	*/
			vectorfield[y * height + x][0] = cos(theta) * amplitude;
			vectorfield[y * height + x][1] = sin(theta) * amplitude;
		}
	}
	
	/*	Bottom and top edges.	*/
	y = 0;
	for(x = 0; x < width; x++){
		vectorfield[(y * height) + x] = bottom;
	}
	y = height - 1;
	for(x = 0; x < width; x++){
		vectorfield[y * height + x] = top;
	}
	
	/*	Left and right edges.	*/
	x = 0;
	for(y = 0; y < height; y++){
		vectorfield[y * height + x] = left;
	}
	x = width - 1;
	for(y = 0; y < height; y++){
		vectorfield[y * height + x] = right;
	}
	
	/*	Corners.	*/
	vectorfield[0] = lb;
	vectorfield[width - 1] = rb;
	vectorfield[(height -1) * width] = lt;
	vectorfield[width * height] = rt;

	free(perlin);
	return (float*)vectorfield;
}

@end
