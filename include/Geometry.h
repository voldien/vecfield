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
#ifndef _VF_GEOMETRY_H_
#define _VF_GEOMETRY_H_ 1
#include"Resource.h"


typedef struct geometry_init_t{
	unsigned int vbo;
	unsigned int vao;
	unsigned int ibo;
	unsigned int target;
	unsigned int numVertices;
	unsigned int numIndices;
}GeometryInit;

/**
 * Geometry object. contains vertices
 * and indices that describes how the geometry
 * will be drawn.
 */
@interface Geometry : Resource{
	unsigned int vbo;
	unsigned int vao;
	unsigned int ibo;
	unsigned int numVertices;
	unsigned int numIndices;
	unsigned int target;
}

/**
 * Create a geometry instance.
 * @throws NSNullReferenceException if init is an null argument.
 */
-(id) initWithGeometryInit: (GeometryInit*) init;

/**
 * Release all associated resources.
 */
-(void) release;

/**
 * Bind geometry to current.
 */
-(void) bind;

/**
 * Draw geometry.
 */
-(void) draw;

/**
 * @return number vertices;
 */
-(int) getNumVertices;

/**
 * @return number of indices;
 */
-(int) getNumIndices;

/**
 * @return geometry vertices buffer ID.
 */
-(unsigned int) getVBOUID;

@end

#endif
