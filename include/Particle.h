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
#ifndef _VF_PARTICLE_H_
#define _VF_PARTICLE_H_ 1
#import"Resource.h"

/**
 * Particle.
 */
typedef struct vf_particle_t{
	float x, y;             /*	Position.	*/
	float xdir, ydir;       /*	Velocity.	*/
}VF_ALIGN(16) VFParticle;

#endif
