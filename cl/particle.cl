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

/**
 * Motion pointer.
 */
struct motion_t{
	float2 pos;     /*  Position in pixel space.    */
	float2 velocity /*  direction and magnitude of mouse movement.  */;
	float radius;   /*  Radius of incluense, also the pressure of input.    */
};

/*	Particle box wall normal.	*/
__constant float2 wall[4] = {
	(float2)(1,0),
	(float2)(-1,0),
	(float2)(0,1),
	(float2)(0,-1),
};

/**
 * Compute force influence from vector field.
 */
float2 computeInfluence(float4 particle, int2 vectorBox, __global float2* vector){
	int x,y;
	const int infl = 2;
	
	/*	*/
	const float2 pos = particle.xy;
	const int2 ij = convert_int2(floor(pos));
	
	/*	Compute total force.	*/
	float2 force = (0,0);
	for(y = 0; y < infl; y++){
		for(x = 0; x < infl; x++){

			/*	Compute position and memory location.	*/
			const int2 vpos = (ij.y + y, ij.x + x);
			const float2 fvpos = convert_float2(vpos);
			const int index = vpos.y * vectorBox.x + vpos.x;
			const float2 vecforce = vector[index];
			
			/*	Compute influence force.	*/
			const float dist = pown(distance(fvpos, pos), 2);
			const float invDist = 1.0f / (dist + 2.0f);
			force += vecforce * invDist;
		}
	}
	
	return force;
}

/**
 * Compute motion influence from motion pointer.
 */
float2 computeMotionInfluence(float4 particle, struct motion_t* motion){
	/*	*/
	float dist = distance(particle.xy, motion->pos);
	float infl = select(dist, motion->radius, isgreater(motion->radius, dist));
	
	return (0,0);
	return (1.0f / infl) * motion->velocity;
}

/**
* Perform particle simulation with vector field.
*/
__kernel void simulate(__global float4* particles, __global const float2* vectorfield, int2 particleBox, int2 vectorBox, float deltatime, int density, struct motion_t motion){
	

	/*	Particle mass.	*/
	const float mass = 1.0f;
	const float invMass = 1.0f / mass;
	
	/*	*/
	const float2 max = ((float)particleBox.x, (float)particleBox.y);
	const float2 min = (0.0, 0.0);
	
	/*	Iterator.	*/
	int x, y;
	
	const int gx = get_global_id(0);
	const int gy = get_global_id(1);
	
	/*	*/
	const int gw = get_global_size(0);
	const int gh = get_global_size(1);
	
	/*	Private group size.	*/
	const int nhw = 2 * density;
	const int nlw = 2 * density;
	
	/*  Iterate through each particle in block.  */
	for(y = 0; y < nhw; y++){
		/*	Cache particles.	*/
		const int prow = ((nhw * gy) * (gw * nhw)) + (y * gw * nlw) + (gx * nlw);
		prefetch(&particles[prow], nlw);

		/*	*/
		for(x = 0; x < nlw; x++){
			int pindex = prow + x;
			float2 force;

			/*  Get particle.   */
			__global float4* part = &particles[pindex];
			float2 velocity = part->zw;
			float2 pos = part->xy;
			
			/*  Get vector of incluense. - Bilinear   */
			const float2 forceInf = computeInfluence(*part, vectorBox, vectorfield);
			const float2 motionInf = computeMotionInfluence(*part, &motion);
			
			/*  Compute total force.  */
			force = (velocity + forceInf + motionInf);
			
			/*  Add force to particle position. */
			part->zw = force * invMass;
			part->xy = pos.xy + part->zw * deltatime;

			/*	Final position update.	*/
			part->xy = clamp(part->xy, min, max);
		}
	}
	
}
