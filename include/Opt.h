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
#ifndef _VF_OPT_H_
#define _VF_OPT_H_ 1
#import<Foundation/Foundation.h>
#import"VecFieldOption.h"

/**
 *  Expert class for reading argument options.
 */
@interface Opt : NSObject

/**
 * Read user argument and assign to option.
 * @throws NSNullReferenceException if option is null.
 */
+(void) readArguments:(int) argc: (const char**) argv:(VecFieldOptions*) option;

@end

#endif
