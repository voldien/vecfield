#import"GeometryFactory.h"
#import"Geometry.h"
#import"Particle.h"
#include<hpm/hpm.h>
#include<assert.h>
#include<GL/glew.h>

@implementation GeometryFactory : NSObject

+(Geometry*) createNormalizedQuad{

	VFGeometryDesc desc = {0};

	const float vertices[][3] = {
			{-1.0f,  1.0f, 0},
			{ 1.0f,  1.0f, 0},
			{ 1.0f, -1.0f, 0},
			{-1.0f, -1.0f, 0},
	};
	const unsigned int indices[] = {
			0, 3, 1, 3, 2, 1,
	};

	/*  */
	desc.buffer = (const void*)vertices;
	desc.indices = (const void*)indices;
	desc.primitive = GL_TRIANGLES;
	desc.indicesStride = 4;
	desc.numIndices = sizeof(indices) / sizeof(indices[0]);
	desc.numVerticecs = sizeof(vertices) / sizeof(vertices[0]);
	desc.vertexStride = sizeof(vertices[0]);
	desc.nElements = 3;

	return [GeometryFactory createGeometry: &desc];
}

+(Geometry*) createParticleBundle: (int) width: (int) height: (int) density{

	int i,j,k;
	Geometry* geometry;
	VFParticle* particles;
	VFGeometryDesc desc = {0};

	/*	Check argument is valid.	*/
	if(density <= 0 || width <= 0 || height <= 0){
		@throw[NSException
			exceptionWithName:@"NSInvalidArgumentException"
			reason:@"numParticles, width and height must all be greater than 0"
			userInfo:nil];
	}

	/*  Allocate particles. */
	const int nParticles = width * height * density;
	particles = (VFParticle*)malloc(nParticles * sizeof(VFParticle));
	assert(particles);

	/*	*/
	srand(time(NULL));

	/*  Create particles.	*/
	for(i = 0; i < height; i++){
		for(j = 0; j < width; j++){
			for(k = 0; k < density; k++){
				VFParticle* p = &particles[i * height * density + j * density + k];
				const float delta = (float)k / (float)density;

				/*	Particle position and init velocity.	*/
				p->y = i - (height / 2) + delta;
				p->x = j - (width / 2) + delta;
				p->xdir = 0;
				p->ydir = 0;
			}
		}
	}

	/*  Assign geometry description.    */
	desc.buffer = (const void*)particles;
	desc.numVerticecs = nParticles;
	desc.vertexStride = sizeof(VFParticle);
	desc.nElements = 4;
	desc.indices = NULL;
	desc.numIndices = 0;
	desc.indicesStride = 0;
	desc.primitive = GL_POINTS;

	/*	Create geometry.	*/
	geometry = [GeometryFactory createGeometry: &desc];
	free(particles);
	return geometry;
}

+(Geometry*) createVectorField: (int) width: (int) height: (const float*) vector{
	
	int i,j;
	Geometry* geometry;
	hpmvec4f* field;
	VFGeometryDesc desc = {0};
	
	/*	Check argument is valid.	*/
	if(width <= 0 || height <= 0){
		@throw[NSException
			exceptionWithName:@"NSInvalidArgumentException"
			reason:@"numParticles, width and height must all be greater than 0"
			userInfo:nil];
	}
	
	const int nVectors = width * height;
	field = (hpmvec4f*)malloc(nVectors * sizeof(hpmvec4f));
	assert(field);
	
	for(i = 0; i < height; i++){
		for(j = 0; j < width; j++){
			hpmvec4f* ve = &field[i * height + j];
			const float* dir = &vector[i * height * 2 + j * 2];
			
			hpm_vec4_setf(ve, (float)i, (float)j, dir[0], dir[1]);
		}
	}
	
	/*  Assign geometry description.    */
	desc.buffer = (const void*)field;
	desc.numVerticecs = nVectors;
	desc.vertexStride = sizeof(hpmvec4f);
	desc.nElements = 4;
	desc.indices = NULL;
	desc.numIndices = 0;
	desc.indicesStride = 0;
	desc.primitive = GL_POINTS;
	
	/*	Create geometry.	*/
	geometry = [GeometryFactory createGeometry: &desc];
	free(field);
	return geometry;
}

+(Geometry*) createGeometry: (VFGeometryDesc*) desc{

	GeometryInit init = {0};

	/*  Check ofr null references.  */
	if(desc == NULL){
		@throw [NSException exceptionWithName:@"NSNullReferenceException"
				reason:@"geometry description is null"
				userInfo:nil];
	}

	/*  Check description is valid.  */
	if(desc->numVerticecs == 0 || desc->vertexStride == 0){
		@throw [NSException
			exceptionWithName:@"NSInvalidArgumentException"
			reason:@"geometry description invalid"
			userInfo:nil];
	}

	/*	Create vertex array.	*/
	glGenVertexArrays(1, &init.vao);
	glBindVertexArray(init.vao);

	/*  */
	if(desc->numIndices > 0){
		/*  Vertices buffer.	*/
		glGenBuffersARB(1, &init.vbo);
		glBindBufferARB(GL_ARRAY_BUFFER_ARB, init.vbo);
		glBufferDataARB(GL_ARRAY_BUFFER_ARB, desc->numVerticecs * desc->vertexStride, desc->buffer, GL_STATIC_READ_ARB);

		/*	Indices buffer.	*/
		glGenBuffersARB(1, &init.ibo);
		glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, init.ibo);
		glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB, desc->numIndices * desc->indicesStride, desc->indices, GL_STATIC_DRAW_ARB);
	}else{	/*	*/
		glGenBuffersARB(1, &init.vbo);
		glBindBufferARB(GL_ARRAY_BUFFER_ARB, init.vbo);
		glBufferDataARB(GL_ARRAY_BUFFER_ARB, desc->numVerticecs * desc->vertexStride, desc->buffer, GL_STREAM_DRAW_ARB);
	}

	/*  */
	glEnableVertexAttribArrayARB(0);
	glVertexAttribPointerARB(0, desc->nElements, GL_FLOAT, GL_FALSE, desc->vertexStride, NULL);

	glBindVertexArray(0);

	/*  Create geometry.	*/
	init.target = desc->primitive;
	init.numVertices = desc->numVerticecs;
	init.numIndices = desc->numIndices;
	return [[[Geometry alloc] initWithGeometryInit: &init] autorelease];
}

@end
