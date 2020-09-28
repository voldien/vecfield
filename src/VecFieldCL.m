#import"VecFieldCL.h"
#import"VecField.h"
#import"ZipFile.h"
#import"Geometry.h"
#import"Debug.h"
#include<Foundation/NSException.h>
#include<SDL2/SDL.h>
#include<SDL2/SDL_syswm.h>
#include<CL/cl.h>
#include<CL/cl_gl.h>
#include<CL/cl_platform.h>
#include<CL/cl_gl_ext.h>
#include<errno.h>

const char* get_cl_error_str(unsigned int errorcode){
	static const char* errorString[] = {
		"CL_SUCCESS",
		"CL_DEVICE_NOT_FOUND",
		"CL_DEVICE_NOT_AVAILABLE",
		"CL_COMPILER_NOT_AVAILABLE",
		"CL_MEM_OBJECT_ALLOCATION_FAILURE",
		"CL_OUT_OF_RESOURCES",
		"CL_OUT_OF_HOST_MEMORY",
		"CL_PROFILING_INFO_NOT_AVAILABLE",
		"CL_MEM_COPY_OVERLAP",
		"CL_IMAGE_FORMAT_MISMATCH",
		"CL_IMAGE_FORMAT_NOT_SUPPORTED",
		"CL_BUILD_PROGRAM_FAILURE",
		"CL_MAP_FAILURE",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"CL_INVALID_VALUE",
		"CL_INVALID_DEVICE_TYPE",
		"CL_INVALID_PLATFORM",
		"CL_INVALID_DEVICE",
		"CL_INVALID_CONTEXT",
		"CL_INVALID_QUEUE_PROPERTIES",
		"CL_INVALID_COMMAND_QUEUE",
		"CL_INVALID_HOST_PTR",
		"CL_INVALID_MEM_OBJECT",
		"CL_INVALID_IMAGE_FORMAT_DESCRIPTOR",
		"CL_INVALID_IMAGE_SIZE",
		"CL_INVALID_SAMPLER",
		"CL_INVALID_BINARY",
		"CL_INVALID_BUILD_OPTIONS",
		"CL_INVALID_PROGRAM",
		"CL_INVALID_PROGRAM_EXECUTABLE",
		"CL_INVALID_KERNEL_NAME",
		"CL_INVALID_KERNEL_DEFINITION",
		"CL_INVALID_KERNEL",
		"CL_INVALID_ARG_INDEX",
		"CL_INVALID_ARG_VALUE",
		"CL_INVALID_ARG_SIZE",
		"CL_INVALID_KERNEL_ARGS",
		"CL_INVALID_WORK_DIMENSION",
		"CL_INVALID_WORK_GROUP_SIZE",
		"CL_INVALID_WORK_ITEM_SIZE",
		"CL_INVALID_GLOBAL_OFFSET",
		"CL_INVALID_EVENT_WAIT_LIST",
		"CL_INVALID_EVENT",
		"CL_INVALID_OPERATION",
		"CL_INVALID_GL_OBJECT",
		"CL_INVALID_BUFFER_SIZE",
		"CL_INVALID_MIP_LEVEL",
		"CL_INVALID_GLOBAL_WORK_SIZE",
	};

	/*	compute error index code. 	*/
	const int errorCount = sizeof(errorString) / sizeof(errorString[0]);
	const int index = -errorcode;

	/*	return error string.	*/
	return (index >= 0 && index < errorCount) ? errorString[index] : "Unspecified Error";
}

@implementation VecFieldCL

+(const char*) getCLStringError: (unsigned int) errorcode{
	return get_cl_error_str(errorcode);
}

+(cl_context) createCLcontext:(int*) ndevices: (cl_device_id**) devices: (SDL_Window*) window: (SDL_GLContext) glcontext{
	
	cl_int ciErrNum;
	cl_context context;
	cl_platform_id* platforms;
	SDL_SysWMinfo sysinfo;
	cl_device_id gpu_id;
	clGetGLContextInfoKHR_fn clGetGLContextInfoKHR;
	
	/*  Check if argument is non null reference.	*/
	if(ndevices == NULL || devices == NULL || window == NULL || glcontext == NULL){
		@throw [NSException
		exceptionWithName:@"NSNullReferenceException"
		reason:[NSString stringWithUTF8String:get_cl_error_str(ciErrNum)]
		userInfo:nil];
	}
	
	/*  Get window information.	*/
	SDL_VERSION(&sysinfo.version);
	SDL_GetWindowWMInfo(window, &sysinfo);
	
	/*  Context properties.	*/
	cl_context_properties props[] = {
		CL_CONTEXT_PLATFORM, (cl_context_properties)NULL,
		CL_GL_CONTEXT_KHR, (cl_context_properties)glcontext,
		#ifdef SDL_VIDEO_DRIVER_X11
		CL_GLX_DISPLAY_KHR, (cl_context_properties)sysinfo.info.x11.display,
		#endif
		(cl_context_properties)NULL
	};

	unsigned int nDevices;
	unsigned int x;
	unsigned int nPlatforms;
	unsigned int nselectPlatform = 0;

	/*	Get Number of platform ids.	*/
	ciErrNum = clGetPlatformIDs(0, NULL, &nPlatforms);
	if(ciErrNum != CL_SUCCESS){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to get number of OpenCL platforms - %s", get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}
	
	/*  Get plaform ids.	*/
	platforms = (cl_platform_id*)malloc(sizeof(*platforms) * nPlatforms);
	ciErrNum = clGetPlatformIDs(nPlatforms, platforms, NULL);
	if(ciErrNum != CL_SUCCESS){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to get OpenCL platforms - %s", get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}
	
	/*	Iterate through each platform in till the
	 *	platform assoicated with OpenGL context is found. */
	for(x = 0; x < nPlatforms; x++){
		size_t pvar;
		
		/*	Get extension function from the platform.	*/
		clGetGLContextInfoKHR = (clGetGLContextInfoKHR_fn)clGetExtensionFunctionAddressForPlatform(platforms[nselectPlatform], "clGetGLContextInfoKHR");
		if(clGetGLContextInfoKHR == NULL){
			@throw [NSException
			exceptionWithName:@"NSErrorException"
			reason:[[[NSString alloc] initWithFormat:@"clGetExtensionFunctionAddressForPlatform failed"] autorelease]
			userInfo:nil];
		} 
		props[1] = (cl_context_properties)platforms[x];

		/*	Get associcated OpenGL context GPU device.	*/
		ciErrNum = clGetGLContextInfoKHR(props, CL_CURRENT_DEVICE_FOR_GL_CONTEXT_KHR, sizeof(cl_device_id), &gpu_id, &pvar);
		if(ciErrNum != CL_SUCCESS){
			@throw [NSException
			exceptionWithName:@"NSErrorException"
			reason:[[[NSString alloc] initWithFormat:@"failed to get OpenGL context info - %s", get_cl_error_str(ciErrNum)] autorelease]
			userInfo:nil];
		}
		
		/*	Check if argument */
		if(pvar > 0){
			/*	Check.	*/
			if(gpu_id == NULL){
				@throw [NSException
				exceptionWithName:@"NSErrorException"
				reason:[[[NSString alloc] initWithFormat:@"failed to get GPU device - %s", get_cl_error_str(ciErrNum)] autorelease]
				userInfo:nil];
			}
			*ndevices = pvar / sizeof(cl_device_id);
			
			/* Assign devices.	*/
			*devices = (cl_device_id*)malloc(pvar);
			memcpy(*devices, gpu_id, pvar);
			*devices[0] = gpu_id;
			break;
		}
	}

	/*	Create context.	*/
	const void* pfn_notify = [Debug getPfnNotifyCallBack];
	context = clCreateContext(props, *ndevices, &gpu_id, pfn_notify, NULL, &ciErrNum);
	
	/*  Error check.    */
	if(context == NULL || ciErrNum != CL_SUCCESS){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to create OpenCL context - %s", get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}
	free(platforms);
	return context;
}

+(cl_program) createProgram: (cl_context) context: (unsigned int) nDevices: (cl_device_id*) device: (const char*) cfilename{
	cl_int ciErrNum;
	cl_program program;
	char* source;
	
	if(device == NULL || nDevices < 1){
		@throw [NSException
		exceptionWithName:@"NSInvalidArgumentException"
		reason:[[[NSString alloc] initWithFormat:@"Failed to create program CL shader %s - \n %s", cfilename, get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}
	
	/*  Load from zipfile.  */
	[ shaderZip readString: cfilename: (void**)&source];

	/*	*/
	program = clCreateProgramWithSource(context, 1, (const char **)&source, NULL, &ciErrNum);
	if(program == NULL || ciErrNum != CL_SUCCESS){
		@throw [NSException
		exceptionWithName:@"NSBadArgumentException"
		reason:[[[NSString alloc] initWithFormat:@"Failed to create program CL shader %s - \n %s", cfilename, get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}

	/*	Compile and build CL program.   */ //  "-O0 -x clc -w -g -cl-kernel-arg-info"
	ciErrNum = clBuildProgram(program, nDevices, device, NULL, NULL, NULL);
	if(ciErrNum != CL_SUCCESS){
		if(ciErrNum == CL_BUILD_PROGRAM_FAILURE){
			char build_log[900];
			size_t build_log_size = sizeof(build_log);
			size_t build_log_ret;

			/*	Fetch build log.	*/
			clGetProgramBuildInfo(program, device[0], CL_PROGRAM_BUILD_LOG, build_log_size, build_log, &build_log_ret);
		
			/*	Throw error,	*/
			@throw [NSException
				exceptionWithName:@"NSErrorException"
				reason:[[[NSString alloc] initWithFormat:@"failed to compile CL shader %s - %s - %s", cfilename, (const char*)build_log, get_cl_error_str(ciErrNum)] autorelease]
				userInfo:nil];
		}else{
			/*  */
			@throw [NSException
			exceptionWithName:@"NSErrorException"
			reason:[[[NSString alloc] initWithFormat:@"failed to compile CL shader %s- %s", cfilename, get_cl_error_str(ciErrNum)] autorelease]
			userInfo:nil];			
		}
	}

	free(source);
	return program;
}

+(cl_kernel) createKernel: (cl_program) program: (const char*) name{
	
	cl_int ciErrNum;
	cl_kernel kernel;

	kernel = clCreateKernel(program, name, &ciErrNum);

	/*  Check error.    */
	if(ciErrNum != CL_SUCCESS || !kernel){
			@throw [NSException
			exceptionWithName:@"NSErrorException"
			reason:[[[NSString alloc] initWithFormat:@"failed to create OpeNCL kernel from program - %s", get_cl_error_str(ciErrNum)] autorelease]
			userInfo:nil];
	}
	return kernel;
}

+(cl_command_queue) createCommandQueue: (cl_context) context: (cl_device_id) device{
	
	cl_int ciErrNum;
	cl_command_queue queue;
	cl_command_queue_properties pro = 0;
	
	/*  Create command.	*/
	queue = clCreateCommandQueueWithProperties(context,
			device,
			&pro,
			&ciErrNum);
	
	/*  Check error.    */
	if(ciErrNum != CL_SUCCESS){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to create command queue - %s", get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}
	return queue;
}

+(cl_mem) createGLWRMem: (cl_context) context: (Geometry*) geometry{

	cl_int ciErrNum;
	
	if(!glIsBufferARB([geometry getVBOUID])){
		@throw [NSException
		exceptionWithName:@"NSInvalidArgumentException"
		reason:@"Invalid"
		userInfo:nil];
	}
	
	/*	Create memory reference.	*/
	cl_mem mem = clCreateFromGLBuffer(context, CL_MEM_READ_WRITE, (GLuint)[geometry getVBOUID], &ciErrNum);
	
	/*  Check error.    */
	if(ciErrNum != CL_SUCCESS || mem == NULL){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to create OpenCL/GL buffer object - %s", get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}
	return mem;
}

+(cl_mem) createReadOnlyMem: (cl_context) context: (int) size: (void*) pbuffer{

	cl_int ciErrNum;
	
	/*	Create OpenCL memory object.	*/
	cl_mem mem = clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, size, pbuffer, &ciErrNum);
	
	/*  Check error.    */
	if(ciErrNum != CL_SUCCESS){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to create OpenCL readonly buffer object - %s", get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}
	return mem;
}

+(void) aquireGLObject: (cl_command_queue) queue: (cl_mem) mem{
	
	cl_int ciErrNum;
	
	/*	*/
	ciErrNum = clEnqueueAcquireGLObjects(queue, 1, (const cl_mem*)&mem, 0, NULL, NULL);
	
	if(ciErrNum != CL_SUCCESS){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to aquire OpenCL/GL buffer object - %s", get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}
}

+(void) releaseGLObject: (cl_command_queue) queue: (cl_mem) mem{
	
	cl_int ciErrNum;
	
	ciErrNum = clEnqueueReleaseGLObjects(queue, 1, (const cl_mem*)&mem, 0, NULL, NULL);
	
	if(ciErrNum != CL_SUCCESS){
		@throw [NSException
		exceptionWithName:@"NSErrorException"
		reason:[[[NSString alloc] initWithFormat:@"failed to release OpenCL/GL buffer object - %s", get_cl_error_str(ciErrNum)] autorelease]
		userInfo:nil];
	}
}


@end
