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
#ifndef _VF_SHADER_FACTORY_H_
#define _VF_SHADER_FACTORY_H_ 1
#import"Shader.h"

/**
 * Responsible for creating
 * OpenGL shader objects.
 */
@interface ShaderFactory : NSObject

/**
 * Get glsl version.
 * @return version as a decimal.
 */
+(int)getGLSLVersion;

/**
 * Create shader
 * 
 * @return non-null shader object.
 * @throw NSErrorException if an error occurs during compilation. 
 */
+(Shader*)createShader: (const char*) vpath: (const char*) fpath: (const char*) gpath;

/**
 * Create GLSl shader object from
 * shader source code.
 * 
 * @return non-null shader object.
 * @throw NSErrorException if an error occurs during compilation. 
 */
+(Shader*)createShaderBySource: (const char*) vsource: (const char*) fsource: (const char*) gsource;

/**
 * Compile shader.
 * 
 * @return non-negative shader object.
 * @throw NSErrorException if an error occurs during compilation. 
 */
+(int)compileShader: (int) type: (int) numshaders: (const char**) shaders;

@end

#endif
