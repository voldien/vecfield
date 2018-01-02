#import"PerlinNoise.h"
#include<Foundation/Foundation.h>
#include<hpm/hpm.h>
#include<assert.h>
#include<stdio.h>
#include<time.h>

const int XMAX = 128;
const int YMAX = 128;
static uint8_t* grad = NULL;

static const float gradiant[][2] = {
		{ 1.0f,  1.0f},
		{-1.0f,  1.0f},
		{ 1.0f, -1.0f},
		{-1.0f, -1.0f}
};
const int numGrad = sizeof(gradiant) / sizeof(gradiant[0]);

static float lerp(float a0, float a1, float w) {
	return (1.0 - w)*a0 + w*a1;
}

@implementation PerlinNoise

+(float*) generatePerlinNoise: (int) width: (int) height{
	
	int x,y,z;
	const int octave = 5;
	float amplitude = 2.0f;
	float totalAmplitude = 0;
	float persistance = 0.9;
	
	/*  Check arguments.    */
	if(width < 1 || height < 1){
		@throw [NSException
			exceptionWithName:@"NSInvalidArgumentException"
			reason:@"width and height must be greater than 0"
			userInfo:nil];
	}
	
	/*  Allocate perlin noise map.  */
	const int size = width * height * sizeof(float);
	float* perlin = (float*)malloc(size);
	assert(perlin);
	memset(perlin, 0, size);

	/*  Generate gradiant.  */
	if(grad == NULL)
		grad = [PerlinNoise generateGradient: width / 2: height / 2];
	
	/*  Iterate through each pixel. */
	for(z = 0; z < octave; z++){
		for(y = 0; y < height; y++){
			for(x = 0; x < width; x++){
				amplitude *= persistance;
				totalAmplitude += amplitude;
				
				/*	*/
				const unsigned int samplePeriod = (1 << z);
				const float sampleFrquency = 1.0f / (float)samplePeriod;
				
				/*	*/
				perlin[y * height + x] += [PerlinNoise perlin: ((float)x / (float) samplePeriod)  * sampleFrquency: ((float)y / (float) samplePeriod) * sampleFrquency] * totalAmplitude;
			}
		}
	}
	return perlin;
}

+(uint8_t*) generateGradient: (int) width: (int) height{
	int x,y;
	
	/*  Check arguments.    */
	if(width < 1 || height < 1){
		@throw [NSException
			exceptionWithName:@"NSInvalidArgumentException"
			reason:@"width and height must be greater than 0"
			userInfo:nil];
	}
	
	/*  Allocate.   */
	uint8_t* gradient = (uint8_t*)malloc(width * height * 2 * sizeof(uint8_t));
	assert(gradient);
	
	srand(time(NULL));
	
	/*	Create indicies map.	*/
	for(y = 0; y < height; y++){
		for(x = 0; x < width; x++){
			gradient[y * height + x] = rand() % numGrad;
		}
	}
	
	return gradient;
}

+(float) perlin: (float) x: (float) y{

	/* Determine grid cell coordinates	*/
	int x0 = (int)floor(x) % XMAX;
	int x1 = (x0 + 1) % XMAX;
	int y0 = (int)floor(y) % YMAX;
	int y1 = (y0 + 1) % YMAX;

	// Determine interpolation weights
	// Could also use higher order polynomial/s-curve here
	float sx = x - (float)x0;
	float sy = y - (float)y0;

	/*	Interpolate between grid point gradients	*/
	float n0, n1, ix0, ix1;

	/*	*/
	n0 = [PerlinNoise dotGridGradient:x0: y0: x: y];
	n1 = [PerlinNoise dotGridGradient:x1: y0: x: y];
	ix0 = lerp(n0, n1, sx);

	/*	*/
	n0 = [PerlinNoise dotGridGradient:x0: y1: x: y];
	n1 = [PerlinNoise dotGridGradient:x1: y1: x: y];
	ix1 = lerp(n0, n1, sx);
	
	/*	*/
	return lerp(ix0, ix1, sy);
}

+(float) dotGridGradient: (int) ix: (int) iy: (float) x: (float) y{
	
	float dx = x - (float)ix;
	float dy = y - (float)iy;
	
	/*	Fetch gradient vector.	*/
	const float v0 = gradiant[ grad[iy * YMAX * 2 + 2 * ix] ][0];
	const float v1 = gradiant[ grad[iy * YMAX * 2 + 2 * ix] ][1];
	
	/*	*/
	return (dx*v0 + dy*v1);
}

@end
