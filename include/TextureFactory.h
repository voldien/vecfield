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
#ifndef _VF_TEXTURE_FACTORY_H_
#define _VF_TEXTURE_FACTORY_H_ 1
#import"Texture2D.h"

/**
 * Responsible for creating
 * and loading textures.
 */
@interface TextureFactory : NSObject 

/**
 * Load and create file from file.
 * @return non-null texture object.
 * @throw NSInvalidArgumentException if file does not exist.
 */
+(Texture2D*) loadTexture: (const char*) cpath;

/**
 * Create OpenGL Texture.
 * @return non-null texture object.
 * @throw NSInvalidArgumentException if with or height is less than 1.
 * @throw NSNullReferenceException if pixels is a null argument.
 */
+(Texture2D*) createTexture: (int) width: (int) height: (const void*) pixels;

/**
 * Create Circle Texture.
 * @return non-null texture object.
 * @throw NSInvalidArgumentException if with or height is less than 1.
 */
+(Texture2D*) createCircleTexture: (int) width: (int) height;

@end

#endif
