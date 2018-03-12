#import"VecField.h"
#import"PerlinNoise.h"
#import"VecFieldCL.h"
#import"VectorField.h"
#import"TextureFactory.h"
#import"GeometryFactory.h"
#import"Geometry.h"
#import"Debug.h"
#import"Opt.h"
#include<hpm/hpm.h>
#include<SDL2/SDL.h>

@implementation VecField : Resource

-(id) initWithArgs: (int) argc: (const char**) argv{
	
	self = [super init];
	if(self != nil){
		self->options = (VecFieldOptions*)malloc(sizeof(VecFieldOptions));
		[Opt readArguments: argc: argv: self->options];
		[VecField initDependices];
	}
	return self;
}

-(id) init{
	self = [super init];
	if(self != nil){
		self->shadParticle = NULL;
		self->shadGrid = NULL;
		self->shadSimpleParticle = NULL;
		self->texCircle = NULL;
		self->geoParticles = NULL;
		self->geoGridPlane = NULL;
		
		/*  */
		self->options = NULL;
		
		/*  */
		self->clqueue = NULL;
		self->program = NULL;
		self->context = NULL;
		self->vectorfield = NULL;
		self->clparticles = NULL;
		self->devices = NULL;
		self->numDevices = 0;
		
		/*  */
		self->window = NULL;
		self->glcontext = NULL;
	}
	return self;
}

-(void) release{
	free(self->options);
	
	/*	Release	OpenCL*/
	[VecFieldCL releaseGLObject: self->clqueue: self->clparticles];
	clReleaseCommandQueue(self->clqueue);
	clReleaseKernel(self->clfunc);
	clReleaseProgram(self->program);
	clReleaseMemObject(self->clparticles);
	clReleaseMemObject(self->vectorfield);
	clReleaseContext(self->context);
		
	/*	Release objects.	*/
	self->texCircle = nil;
	self->texCircle = nil;
	self->geoParticles = nil;
	self->geoGridPlane = nil;
	self->shadGrid = nil;
	self->shadParticle = nil;
	self->shadSimpleParticle = nil;
	self->shadVectorField = nil;
	
	/*	Release OpenGL context.	*/
	SDL_GL_MakeCurrent(self->window, NULL);
	SDL_GL_DeleteContext(self->glcontext);
	
	/*	Release SDL.	*/
	SDL_Quit();
}

-(void) dealloc{
	[super dealloc];
}

-(void) startSimulation{
	
	/*	*/
	hpmvec4x4f_t proj;
	hpmvec4x4f_t view;
	hpmvec4x4f_t translation;
	hpmvec4x4f_t scale;
	hpmvec4x4f_t viewproj;
	hpmvec3f cameraPos = {0.0f,0.0f,0.0f};

	float delta = 1.0f;
	const float maxZoom = 64.0f;
	const float minZoom = 0.8;
	Uint64 ntime;
	
	/*	*/
	const int timeout = 0;
	const float orthdiv = 4.0f;
	int visible = 1;
	float screen[2];
	int width, height;
	int background = 0;
	float zoom = 1.0f;
	SDL_Event event = {0};
	bool needMatrixUpdate = true;
	
	/*	*/
	
	/*	Init values.	*/
	ntime = SDL_GetPerformanceCounter();
	SDL_GetWindowSize(self->window, &width, &height);
	screen[0] = width;
	screen[1] = height;
	[self->shadGrid setUniform2fv: [self->shadGrid getUniformLocation: "screen"]: screen];
	cameraPos[0] = options->width / -2;
	cameraPos[1] = options->height / -2;
	
	/*  Set init matrix.	*/
	hpm_mat4x4_orthfv(proj, -(float)width/ orthdiv, (float)width / orthdiv, -(float)height / orthdiv, (float)height / orthdiv, -1.0f, 1.0f);
	hpm_mat4x4_scalef(scale, zoom, zoom, 0);
	hpm_mat4x4_translationfv(translation, &cameraPos);
	hpm_mat4x4_identityfv(view);

	/*	*/
	[self->texCircle bind: 0];
	[self->texGrid bind: 1];
	
	/*  */
	while(1){
		Motion motion = {0.0f}; 
		while(SDL_WaitEventTimeout(&event, timeout)){
			switch(event.type){
				case SDL_QUIT:
					return; /*  Exit.  */
				case SDL_KEYDOWN:
					break;
				case SDL_KEYUP:
					if(event.key.keysym.sym == SDLK_RETURN && ( event.key.keysym.mod & SDLK_LCTRL ) ){
						self->options->fullscreen = ~self->options->fullscreen & 0x1;
						SDL_SetWindowFullscreen(self->window, self->options->fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
					}
					if(event.key.keysym.sym == SDLK_f){
						zoom = 1.0f;
						hpm_mat4x4_scalef(scale, zoom, zoom, 0);
						needMatrixUpdate = true;
					}
					break;
				case SDL_MOUSEMOTION:

					/*	Move around.	*/
					if(event.button.button == 2 || event.button.button == 3){
						const float speed  = 0.1f * ( 1.0f / zoom ) ;
						cameraPos[0] += (event.motion.xrel * speed);
						cameraPos[1] += -(event.motion.yrel * speed);
						hpm_mat4x4_translationfv(translation, &cameraPos);
						needMatrixUpdate = true;
					}
					/*	Add mouse influence.	*/
					if(event.button.button == 1){
						const float speed  = 0.5f;
						const float radius = 20.0f;
						hpmvec3f worldpos = {0};

						
						/*	Compute the world space position.	*/
						int rect[4] = {0, 0, screen[0], screen[1]};
						if(hpm_mat4x4_unprojf(event.motion.x, event.motion.y, 1.0f, proj, view, rect, &worldpos)){
							motion.velocity.s[0] = (float)event.motion.xrel;
							motion.velocity.s[1] = (float)event.motion.yrel;
							motion.radius = radius;
							
							motion.pos.s[0] = worldpos[0];
							motion.pos.s[1] = worldpos[1];
							NSLog(@"-Pos%fx%f\n", worldpos[0], worldpos[1]);
						}
					}
					break;
				case SDL_MOUSEBUTTONDOWN:
					if(event.button.button == 1 && event.button.clicks > 1){
						const float speed  = 0.5f;
						zoom = HPM_CLAMP(zoom + speed, minZoom, maxZoom);
						hpm_mat4x4_scalef(scale, zoom, zoom, 0);
						needMatrixUpdate = true;
					}
					break;
				case SDL_MOUSEBUTTONUP:
					break;
				case SDL_MOUSEWHEEL:{
					const float speed  = 0.05f;
					zoom = HPM_CLAMP(zoom + (float)event.wheel.y * speed, minZoom, maxZoom);
					hpm_mat4x4_scalef(scale, zoom, zoom, 0);
					needMatrixUpdate = true;
					
					printf("%f.\n", zoom);
					[self->shadGrid setUniformf: [self->shadGrid getUniformLocation:"zoom"]: zoom];
					[self->shadParticle setUniformf: [self->shadParticle getUniformLocation:"zoom"]: zoom];
					}break;
				case SDL_WINDOWEVENT:
				switch(event.window.event){
				case SDL_WINDOWEVENT_CLOSE:
					return;
				case SDL_WINDOWEVENT_SIZE_CHANGED:
				case SDL_WINDOWEVENT_RESIZED:
					visible = 1;
					screen[0] = (float)event.window.data1;
					screen[1] = (float)event.window.data2;
					glViewport(0, 0, screen[0], screen[1]);
					NSLog(@"%dx%d\n", (int)screen[0], (int)screen[1]);
					
					hpm_mat4x4_orthfv(proj, -screen[0] / orthdiv, screen[0] / orthdiv, -screen[1] / orthdiv, screen[1] / orthdiv, -0.0f, 1.0f);
					needMatrixUpdate = true;

					[self->shadGrid setUniform2fv: [self->shadGrid getUniformLocation: "screen"]: screen];
					break;
				case SDL_WINDOWEVENT_HIDDEN:
				case SDL_WINDOWEVENT_MINIMIZED:
					visible = 0;
					break;
				case SDL_WINDOWEVENT_EXPOSED:
				case SDL_WINDOWEVENT_SHOWN:
					visible = 1;
					break;
				}
				break;
			default:
				break;
			}
		}
		
		/*	Update matrix.	*/
		if(needMatrixUpdate){
			hpm_mat4x4_multiply_mat4x4fv(scale, translation, view);
			hpm_mat4x4_multiply_mat4x4fv(proj, view, viewproj);
			[self->shadParticle setUniformMatrix: [self->shadParticle getUniformLocation:"view"]: (const float*)viewproj];
			[self->shadSimpleParticle setUniformMatrix: [self->shadSimpleParticle getUniformLocation:"view"]: (const float*)viewproj];
			[self->shadVectorField setUniformMatrix: [self->shadVectorField getUniformLocation:"view"]: (const float*)viewproj];
			[self->shadGrid setUniformMatrix: [self->shadGrid getUniformLocation:"view"]: (const float*)viewproj];
			needMatrixUpdate = false;
		}
		
		/*  Draw particle.	*/
		if(background || visible){
			
			/*	Update deltatime.	*/
			delta = ((float)(SDL_GetPerformanceCounter() - ntime) / (float)SDL_GetPerformanceFrequency()) * options->speed;
			ntime = SDL_GetPerformanceCounter();
			
			/*  Draw grid.  */
			glDisable(GL_BLEND);
			glDisable(GL_CULL_FACE);
			[self->shadGrid bind];
			[self->geoGridPlane bind];
			[self->geoGridPlane draw];
			
			/*  Draw particles. */
			glEnable(GL_BLEND);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			if(zoom > 1)
				[self->shadParticle bind];
			else
				[self->shadSimpleParticle bind];
			[self->geoParticles bind];
			[self->geoParticles draw];
			
			/*	Draw vector field.	*/
			if(options->debug){
				[self->shadVectorField bind];
				[self->geoVectorField bind];
				[self->geoVectorField draw];
			}

			/*	Swap framebuffer.	*/
			SDL_GL_SwapWindow(self->window);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			
			/*	Update particles.	*/
			glFinish();
			[self updateParticle: &motion: delta];
		}
	}
}

-(void) updateParticle: (const Motion*) motion: (float)delta{
	/*  Update simulation.  */
	cl_int err;
	cl_uint i;
	const size_t nArgSize[] = {
		sizeof(cl_mem),		/*	Particle memory.	*/
		sizeof(cl_mem),		/*	Vector Field memory.	*/
		sizeof(cl_int2),	/*	*/
		sizeof(cl_int2),	/*	*/
		sizeof(cl_float),	/*	delta time.	*/
		sizeof(cl_int),		/*	particle density.	*/
		sizeof(*motion),	/*	pointer motion.	*/
	};
	const void* hostArgRef[] = {
		&self->clparticles,			/*	*/
		&self->vectorfield,			/*	*/
		&self->options->width,		/*	*/
		&self->options->width,		/*	*/
		&delta,						/*	*/
		&self->options->density,	/*	*/
		motion,						/*	*/
	};
	const int nArgs = sizeof(nArgSize) / sizeof(nArgSize[0]);
	
	/*	Aquire OpenGL buffer from OpenGL.	*/
	[VecFieldCL aquireGLObject: self->clqueue: self->clparticles];
	
	/*	Set kernel function arguments.	*/
	for(i = 0; i < nArgs; i++){
		err = clSetKernelArg(self->clfunc, i, nArgSize[i], hostArgRef[i]);
		if(err != CL_SUCCESS){
			@throw [NSException
				exceptionWithName:@"NSErrorException"
				reason:[NSString stringWithFormat:@"OpenCL - %s - %d", [VecFieldCL getCLStringError: err], err]
				userInfo:nil];
		}
	}
	
	/*	Work items and works groups.	*/
	const size_t global[2] = {options->width / 2, options->height / 2};
	
	/*	Execute particle simulatin.	*/
	err = clEnqueueNDRangeKernel(self->clqueue, self->clfunc, 2, NULL, global, NULL, 0, 0, 0);
	if(err != CL_SUCCESS){
		@throw [NSException
			exceptionWithName:@"NSErrorException"
			reason:[NSString stringWithFormat:@"clEnqueueNDRangeKernel - %s - %d", [VecFieldCL getCLStringError: err], err]
			userInfo:nil];
	}
	
	/*	Wait intill the computation is done.	*/
	err = clFinish(self->clqueue);
	if(err != CL_SUCCESS){
		@throw [NSException
			exceptionWithName:@"NSErrorException"
			reason:[NSString stringWithFormat:@"clFinish - %s - %d", [VecFieldCL getCLStringError: err], err]
			userInfo:nil];
	}
	[VecFieldCL releaseGLObject: self->clqueue: self->clparticles];
}

-(SDL_Window*) createWindow{

	int width; int height;
	SDL_DisplayMode current;
	char title[256];

	/*  Get display size.   */
	SDL_GetCurrentDisplayMode(0, &current);
	
	/*	Compute default window resolution.	*/
	width = current.w / 2;
	height = current.h / 2;
	
	/*  Create Window.  */
	SDL_Window* pwindow = SDL_CreateWindow("", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE | (options->fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0));
	if(!pwindow){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"Failed to create OpenGL window - %s", SDL_GetError()] autorelease]
		userInfo:nil];
	}
	
	/*  Set window title.  */
	NSProcessInfo* proc = [NSProcessInfo processInfo];
	sprintf(title, "%s - %s", [[proc processName] cString], [VecField getVersion]);
	SDL_SetWindowTitle(pwindow, title);
	SDL_ShowWindow(pwindow);
	
	return pwindow;
}

-(void) createGLContext{
	
	int glvalue;
	
	/*	Enable debug context.	*/
	if(self->options->debug)
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_GetAttribute(SDL_GL_CONTEXT_FLAGS, &glvalue) | SDL_GL_CONTEXT_DEBUG_FLAG);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, SDL_TRUE);
	
	/*  Create context.*/
	SDL_GLContext pcontext = SDL_GL_CreateContext(self->window);
	if(pcontext == NULL){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to create OpenGL context - %s", SDL_GetError()] autorelease]
		userInfo:nil];
	}
	
	/*  Make contex current.	*/
	if(SDL_GL_MakeCurrent(self->window, pcontext) != 0){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to make GL context current - %s", SDL_GetError()] autorelease]
		userInfo:nil];
	}
	
	/*  Check if Core profile is used.  */
	if(SDL_GL_GetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, &glvalue) == SDL_GL_CONTEXT_PROFILE_CORE)
		glewExperimental = GL_TRUE;
	
	/*  Initialize GLEW.  */
	GLenum glew = glewInit();
	if(glew != GLEW_OK){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"Failed to init GLEW - %s", glewGetErrorString(glew)] autorelease]
		userInfo:nil];
	}
	
	/*	Setup the default rendering pipeline settings.	*/
	glDisable(GL_DEPTH_TEST);
	glDepthMask(GL_TRUE);
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_FALSE);
	glDisable(GL_BLEND);
	glDisable(GL_STENCIL_TEST);
	glEnable(GL_CULL_FACE);
	glCullFace(GL_FRONT);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glClearColor(0.05f, 0.05f, 0.05f, 1.0);
	
	/*	Enable vysnc.	*/
	if(self->options->vsync)
		SDL_GL_SetSwapInterval(1);
	
	/*  Check if to enable OpenGL debug.  */
	if(self->options->debug)
		[Debug enableGLDebug];
	self->glcontext = pcontext;
}

-(void) createCLContext: (SDL_GLContext) glcontext: (SDL_Window*) window{

	/*  Create Context and command queue.   */
	self->context = [VecFieldCL createCLcontext: &self->numDevices: &self->devices: window: glcontext];
	self->clqueue = [VecFieldCL createCommandQueue: self->context: *self->devices];
}

+(void) initDependices{

	/*  Init default hpm.   */
	int status = hpm_init (HPM_DEFAULT);
	if(!status){
		@throw [NSException 
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to intialize hpm library - %d", status] autorelease]
		userInfo:nil];
	}

	/*  Initialie SDL.  */
	status = SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_EVENTS);
	if(status != 0){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to intialize SDL library : %d - %s", status, SDL_GetError()] autorelease]
		userInfo:nil];
	}

	/*  Load ZipFile.   */
	if(shaderZip == nil){
		@try{
			NSString* path = [[[NSString alloc] initWithFormat:@"%s/%s", sharedir, shaderfile] autorelease];
			shaderZip = [ZipFile loadFile:  [path cString]];
		}@catch(NSException* ex){
			/*	Try loading file from current file directory.	*/
			NSString* procPath = [ [[NSBundle mainBundle] bundlePath] autorelease];
			NSString* path = [[[NSString alloc] initWithFormat:@"%@/%s", procPath, shaderfile] autorelease];
			if([[ex name] isEqualToString: @"NSFileNotFoundException"])
				shaderZip = [ZipFile loadFile: [path cString]];
			else
				@throw ex;
		}
	}
}

+(const char*) getVersion{
	return VF_STR_VERSION;
}

@end
