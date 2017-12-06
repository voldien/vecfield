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
#ifndef _VF_VECTOR_FIELD_H_
#define _VF_VECTOR_FIELD_H_ 1
#import"VecDef.h"
#import<Foundation/Foundation.h>

/**
 * Factory class for creating
 * vector field in R^2.
 */
@interface VectorField

/**
 * Create vector field.
 * @return non null vector field.
 * @throws NSInvalidArgumentException if width or height is less than 1.
 */
+(float*) createVectorField: (int) width: (int) height;

@end

#endif
