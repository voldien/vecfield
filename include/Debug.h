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
#ifndef _VF_DEBUG_H_
#define _VF_DEBUG_H_ 1
#import<Foundation/Foundation.h>
#include<GL/glew.h>

/**
 *  Class responsible for handling
 *  debugging.
 */
@interface Debug : NSObject

/**
 *  Enable OpenGL debug.
 */
+(void) enableGLDebug;

/**
 * Get OpenCL notification callback for errors.
 * @return non-null function pointer.
 */
+(const void*) getPfnNotifyCallBack;

/**
 * Get OpenGL debug callback.
 * @return non-null function pointer.
 */
+(const void*) getGLDebugCallBack;

@end

#endif 
