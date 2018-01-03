/**
    Vector field simulation.
    Copyright (C) 2017  Valdemar Lindberg

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
#ifndef _VF_VECFIELD_H_
#define _VF_VECFIELD_H_ 1
#import"Resource.h"
#import"Motion.h"
#import"ShaderFactory.h"
#import"Shader.h"
#import"ZipFile.h"
#import"VecFieldOption.h"
#include<SDL2/SDL.h>
#include<GL/glew.h>
#include<CL/cl.h>
#include<CL/cl_gl.h>

/*  */
extern const char* sharedir;
extern const char* shaderfile;
extern ZipFile* shaderZip;

/**
 * Main object of the program.
 */
@class Texture2D;
@class Geometry;
@interface VecField : Resource{
	Shader* shadParticle;
	Shader* shadGrid;
	Shader* shadSimpleParticle;
	Shader* shadVectorField;
	Texture2D* texCircle;
	Geometry* geoParticles;
	Geometry* geoGridPlane;
	Geometry* geoVectorField;
	/*  */
	VecFieldOptions* options;
	/*  */
	cl_command_queue clqueue;
	cl_program program;
	cl_context context;
	cl_mem vectorfield;
	cl_mem clparticles;
	cl_device_id* devices;
	cl_kernel clfunc;
	int numDevices;
	/*  */
	SDL_Window* window;
	SDL_GLContext glcontext;
}

/**
 * 
 */
-(id) initWithArgs: (int) argc: (const char**) argv; 

/**
 *  Start the particle simulation.
 * 
 *  Will block in till simulation is done.
 */
-(void) startSimulation;

/**
 * Update particles.
 */
-(void) updateParticle: (const Motion*) motion: (float)delta;

/**
 * Create window for displaying.
 * @return non-null window pointer reference.
 * @throws NSErrorException if an error occures.
 */
-(SDL_Window*) createWindow;

/**
 * Create OpenGL context.
 * @return non-null context pointer reference.
 * @throws NSErrorException
 */
-(void) createGLContext;

/**
 * Create OpenCL context.
 * @return non-null context pointer reference.
 * @throws NSErrorException
 */
-(void) createCLContext: (SDL_GLContext) glcontext: (SDL_Window*) window;

/**
 * Get version of the program.
 * @return non-null terminated string.
 */
+(const char*) getVersion;

/**
 * Init library dependices.
 * @throws NSErrorException if an error occures.
 */
+(void) initDependices;

@end



#endif
