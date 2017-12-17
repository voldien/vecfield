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
#ifndef _VF_GEOMETRY_FACTORY_H_
#define _VF_GEOMETRY_FACTORY_H_ 1
#import"Geometry.h"

/**
 * Factory class responsible for
 * creating Geomtry objects.
 */
@interface GeometryFactory : NSObject

typedef struct vf_geomtry_desc_t{
	unsigned int primitive;			/*	Primitive type.	*/
	unsigned int numVerticecs;		/*	Number of vertices.	*/
	unsigned int numIndices;		/*	Number of indices.	*/
	unsigned int indicesStride;		/*	Size per indices in bytes.	*/
	unsigned int vertexStride;		/*	Size per vertex in bytes.	*/
	unsigned int nElements;			/*	Number of elements in vertex attribute - [1,4]*/
	const void* indices;			/*	Indices host pointer data.	*/
	const void* buffer;				/*	Vertex buffer.	*/
}VFGeometryDesc;

/**
 * Create normalized quad.
 * @return non-null geometry object.
 */
+(Geometry*) createNormalizedQuad;

/**
 * Create particle bundle inside rectangle specified
 * by the width and height.
 * @throw NSInvalidArgumentException if width, height or density is less than equal to 0.
 * @return non-null geometry object.
 */
+(Geometry*) createParticleBundle: (int) width: (int) height: (int) density;

/**
 * Create vector field representation.
 * @return non-null geometry object.
 * @throw NSNullReferenceException if vector array is null.
 * @throw NSInvalidArgumentException if width or height is less than equal to zero.
 */
+(Geometry*) createVectorField: (int) width: (int) height: (const float*) vector;

/**
 * Create geometry object from description.
 * @return non-null geometry object.
 * @throw NSNullReferenceException if description is a null reference.
 * @throw NSInvalidArgumentException if any of the argument in description is invalid.
 */
+(Geometry*) createGeometry: (VFGeometryDesc*) desc;

@end

#endif
