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
#ifndef _VF_ZIP_H_
#define _VF_ZIP_H_ 1
#import"Resource.h"
#include<zip.h>

/**
 * Class for open and read files
 * from a zip file.
 */
@interface ZipFile : Resource{
    void* pfile;
}

/**
 * Release associated resources.
 */
-(void) release;

/**
 *  Read file inside zfile by cpath.
 * 
 *  @return number of bytes loaded.
 *  @throw NSFileNotFoundException if file does not exists.
 */
-(long int) readFile: (const char*) cpath: (void**) pbuf;

/**
 *  Read string from inside zfile by cpath.
 * 
 *  @return number of bytes loaded.
 *  @throw NSFileNotFoundException if file does not exists.
 */
-(long int) readString: (const char*) cpath: (void**) pbuf;

/**
 *  Create ZipFile object by creating
 *  a valid path. 
 *  @return non-null terminated object.
 *  @throws NSFileNotFoundException if file does not exists.
 *  @throws NSNullReferenceException if path is a null pointer references.
 */
+(ZipFile*) loadFile: (const char*) path;

@end

#endif
