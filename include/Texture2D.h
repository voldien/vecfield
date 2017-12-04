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
#ifndef _VF_TEXTURE_H_
#define _VF_TEXTURE_H_ 1
#import"Resource.h"

/**
 * 
 */
@interface Texture2D : Resource {
    unsigned int texture;
    int width;
    int height;
}

/**
 * Constructor of the object.
 * @return object id.
 */
-(id) initWithTexture: (int) ptexture: (int) width: (int) height;

/**
 * Release all resources assoicated
 * with this object.
 */
-(void) release;

/**
 * Bind texture as current texture
 * assoicated with the index.
 */
-(void) bind: (int) index;

/**
 * Get the width of the texture.
 * @return non-negative width.
 */
-(int) getWidth;

/**
 * Get the height of the texutre.
 * @return non-negative height.
 */
-(int) getHeight;

@end

#endif
