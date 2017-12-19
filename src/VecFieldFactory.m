#import"VecField.h"
#import"VecFieldFactory.h"
#import"VecFieldCL.h"
#import"VectorField.h"
#import"ShaderFactory.h"
#import"GeometryFactory.h"
#import"TextureFactory.h"

/*  */
static const char* clfile = "share/particle.cl";
#ifdef VF_LINUX
const char* sharedir = "/usr/share/vecfield";
#else
const char* sharedir = "";
#endif
const char* shaderfile = "vfcommon.zip";
ZipFile* shaderZip = nil;

@implementation VecField (FactoryMethod)

+(VecField*) createVecField: (int) argc: (const char**) argv{
	
	/*  Create vector field main object.    */
	VecField* field = [[VecField alloc] initWithArgs: argc: argv];

	/*  Create window.  */
	field->window = [field createWindow];
	
	/*  Create OpenGL and OpenCL context.  */
	[field createGLContext];
	[field createCLContext: field->glcontext: field->window];
	
	/*  Create display shader.  */
	field->shadParticle = [ShaderFactory createShader: "share/particleV.glsl": "share/particleF.glsl": "share/particleG.glsl" ];
	field->shadSimpleParticle = [ShaderFactory createShader: "share/simpleParticleV.glsl": "share/simpleParticleF.glsl": NULL ];
	field->shadGrid = [ShaderFactory createShader: "share/spaceprojectedgridV.glsl": "share/spaceprojectedgridF.glsl": NULL ];
	field->shadVectorField = [ShaderFactory createShader: "share/vectorFieldV.glsl": "share/vectorFieldF.glsl": "share/vectorFieldG.glsl"];
	
	/*  Set constant uniform.	*/
	[field->shadParticle setUniformi: [field->shadParticle getUniformLocation:"tex0"]: 0];
	[field->shadParticle setUniformf: [field->shadParticle getUniformLocation:"zoom"]: 1.0f];
	
	/*  Create textures.    */
	const int circleSize = 1024;
	field->texCircle = [TextureFactory createCircleTexture: circleSize: circleSize];
	
	/*  Create Grid Plane.    */
	field->geoGridPlane = [GeometryFactory createNormalizedQuad];
	
	/*  Create particles.	*/
	field->geoParticles = [GeometryFactory createParticleBundle: field->options->width: field->options->height: field->options->particles];
	

	
	/*  Create CL Program.	*/
	field->program = [VecFieldCL createProgram: field->context: field->numDevices: field->devices: clfile];
	field->clfunc = [VecFieldCL createKernel: field->program: "simulate"];
	
	/*  Create perlin noise for vector field.   */
	float* vectorfield = (float*)[VectorField createVectorField: field->options->width: field->options->height];
	field->vectorfield = [VecFieldCL createReadOnlyMem: field->context: field->options->width * field->options->height * sizeof(float) * 2: vectorfield];
	field->geoVectorField = [GeometryFactory createVectorField: field->options->width: field->options->height: vectorfield];
	free(vectorfield);
	
	/*  Create OpenCL particle.	*/
	field->clparticles = [VecFieldCL createGLWRMem: field->context: field->geoParticles];

	shaderZip = nil;
	return field;    
}

@end
