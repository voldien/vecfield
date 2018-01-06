#import"Opt.h"
#import"VecField.h"
#include<getopt.h>

static void defaultOptions(VecFieldOptions* options){
	options->fullscreen = 0;
	options->debug = 0;
	options->verbose = 0;
	options->width = 512;
	options->height = 512;
	options->bgrendering = 0;
	options->vsync = 0;
	options->density = 1;
}

@implementation Opt : NSObject

+(void) readArguments:(int) argc: (const char**) argv:(VecFieldOptions*) option{

	const char* shortopt = "vVdf";
	static struct option longoption[] = {
		{"version",			no_argument,		0, 'v'},	/*	Print version.	*/
		{"debug",			no_argument,		0, 'd'},	/*	Enable debug mode.	*/
		{"verbose",			no_argument,		0, 'V'},	/*	Enable debug mode.	*/
		{"fullscreen",		no_argument,		0, 'f'},	/*	Fullscreen mode.	*/

		/*  Long option.    */
		{"bgrendering",		no_argument,		0, '_'},	/*	Enable rendering in the background.	*/
		{"vsync",			no_argument,		0, '_'},	/*	Enable Vsync.	*/
		{"density",			required_argument,	0, '_'},	/*	Set particle density.	*/
		{NULL, 0, NULL, 0},
	};

	int c;
	int index;

	/* Check argument.  */
	if(option == NULL){
		@throw [NSException
			exceptionWithName:@"NSNullReferenceException"
			reason:@"option parameter must not be null"
			userInfo:nil];
	}

	/*  Set default options.    */
	defaultOptions(option);

	/*  Iterate through each argument.  */
	while((c = getopt_long(argc, (char *const *)argv, shortopt, longoption, &index)) != EOF){
		switch(c){
			case 'v':
				printf("version %s.\n", [VecField getVersion]);
				exit(EXIT_SUCCESS);
				break;
			case 'd':
				option->debug = 1;
				break;
			case 'V':
				option->verbose = 1;
				break;
			case 'f':
				option->fullscreen = 1;
				break;
			case '_':   /*  Long options only.  */
				if(strcmp(longoption[index].name, "bgrendering") == 0)
					option->bgrendering = 1;
				if(strcmp(longoption[index].name, "vsync") == 0)
					option->vsync = 1;
				if(strcmp(longoption[index].name, "density") == 0)
					option->density = strtol(optarg, NULL, 10);
				break;
			default:
				break;
		}
	}
	
	/*	Reset getopt.	*/
	optarg = NULL;
	optind = 0;
	opterr = 0;
}

@end
