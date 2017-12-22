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
#ifndef _VF_VEC_FIELD_H_
#define _VF_VEC_FIELD_H_ 1

/**
 * Factory class for creating
 * the vecField object.
 */
@interface VecField (FactoryMethod)

/**
 * Create vecField simulation object.
 * @return non-null object.
 */
+(VecField*) createVecField: (int) argc: (const char**) argv;

@end

#endif
