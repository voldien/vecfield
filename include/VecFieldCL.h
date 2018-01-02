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
#ifndef _VECTOR_FIELD_OPENCL_H_
#define _VECTOR_FIELD_OPENCL_H_ 1
#import"Geometry.h"
#include<SDL2/SDL.h>
#include<CL/cl.h>

/**
 * Factory class for creating
 * OpenCL objects.
 */
@interface VecFieldCL

/**
 * Get OpenCL error string.
 * @return non-null context.
 */
+(const char*) getCLStringError: (unsigned int) errorcode;

/**
 * Create OpenCL context.
 * @throws NSInvalidArgumentException if any of the argument is invalid.
 * @throws NSErrorException Error occured.
 * @return non-null context.
 */
+(cl_context) createCLcontext:(int*) ndevices: (cl_device_id**) devices: (SDL_Window*) window: (SDL_GLContext) glcontext;

/**
 * Create OpenCL program.
 * @throws NSInvalidArgumentException if any of the argument is invalid.
 * @throws NSErrorException Error occured.
 * @return non-null program.
 */
+(cl_program) createProgram: (cl_context) context: (unsigned int) nDevices: (cl_device_id*) device: (const char*) cfilename;

/**
 * Create kernel for OpenCL program entry function.
 * @throws NSInvalidArgumentException if any of the argument is invalid.
 * @throws NSErrorException Error occured.
 * @return non-null kernel.
 */
+(cl_kernel) createKernel: (cl_program) program: (const char*) name;

/**
 * Create command queue.
 * @throws NSInvalidArgumentException if context or device is an invalid argument.
 * @throws NSErrorException Error occured.
 * @return non-null command queue.
 */
+(cl_command_queue) createCommandQueue: (cl_context) context: (cl_device_id) device;

/**
 * Create Mem object from OpenGL buffer
 * object.
 * @throws NSInvalidArgumentException if context or geometry is an invalid argument.
 * @throws NSErrorException Error occured.
 * @return non-null memory.
 */

+(cl_mem) createGLWRMem: (cl_context) context: (Geometry*) geometry;

/**
 * Create readonly opencl memory.
 * @throws NSInvalidArgumentException if context or size is an invalid argument.
 * @throws NSErrorException Error occured.
 * @return non-null reference pointer.
 */
+(cl_mem) createReadOnlyMem: (cl_context) context: (int) size: (void*) pbuffer;

/**
 * Acquire OpenGL memory object reference to queue.
 * @throws NSInvalidArgumentException if context or size is an invalid argument.
 * @throws NSErrorException Error occured.
 */
+(void) aquireGLObject: (cl_command_queue) queue: (cl_mem) mem;

/**
 * Release OpenGL memory object reference from queue.
 * @throws NSInvalidArgumentException if context or size is an invalid argument.
 * @throws NSErrorException Error occured.
 */
+(void) releaseGLObject: (cl_command_queue) queue: (cl_mem) mem;

@end

#endif
