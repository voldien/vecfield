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
#ifndef _PERLIN_NOISE_H_
#define _PERLIN_NOISE_H_ 1
#import<Foundation/Foundation.h>

/**
 * Factory class for generating
 * perlin noise.
 */
@interface PerlinNoise

/**
 * Create perlin noise.
 * @return non-null float2 array.
 * @throws NSInvalidArgumentException if width or height is less than 1.
 */
+(float*)generatePerlinNoise:(int) width: (int) height;

/**
 * Generate gradient plane.
 * @returns float, 2D array of R^2 vectors.
 * @throws NSInvalidArgumentException if width or height is less than 1.
 */
+(uint8_t*) generateGradient:(int) width: (int) height;

/**
 * Compute perlin noise for at x and y.
 * @return perlin value.
 */
+(float) perlin: (float) x: (float) y;

/**
 * Compute dot gradient value.
 * @return gradient dot product.
 */
+(float) dotGridGradient: (int) ix: (int) iy: (float) x: (float) y;

@end

#endif
