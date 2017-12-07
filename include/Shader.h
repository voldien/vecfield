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
#ifndef _VF_SHADER_H_
#define _VF_SHADER_H_ 1
#import"Resource.h"

/**
 *  OpenGL Shader object.
 */
@interface Shader : Resource{
    unsigned int program;
}

/**
 * Create shader with OpenGL program ID.
 * @return instance reference.
 */
-(id) initWithProgram: (int) glprogram;

/**
 * Bind shader to current binded shader.
 */
-(void) bind;

/**
 * Release all resources associated with
 * the object.
 */
-(void) release;

/**
 * Get the uniform location
 * from the shader object.
 * @return non-negative if uniform exists.
 */
-(int) getUniformLocation: (const char*) name;

/**
 * Set uniform int value.
 */
-(void) setUniformi: (int) uniform: (int) pvalue;

/**
 * Set uniform float value.
 */
-(void) setUniformf: (int) location: (float) pvalue;

/**
 * Set float2 uniform value.
 */
-(void) setUniform2fv: (int) location: (const float*) pvalue;

/**
 * Set uniform matrix value.
 */
-(void) setUniformMatrix: (int) location: (const float*) pvalue;

@end

#endif
