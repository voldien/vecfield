#import"VecField.h"
#import<Foundation/Foundation.h>

int main(int argc, const char** argv){
   
    @try{
        
        /*  Create Vector field and run simulation.    */
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        VecField* field = [VecField createVecField: argc: argv];
        [field startSimulation];
        [pool drain];

    }@catch(NSException* ex){
        fprintf(stderr, "Error occurred : [%s] - %s.\n", [ [ex name] cString], [[ex reason] cString]);
        #ifdef _DEBUG
        NSArray* stack = [NSThread callStackSymbols];
        stack = [ex callStackSymbols];
        fprintf(stderr, "\n----------- Stack Trace ---------\n");
        for(NSString* s in stack){
            fprintf(stderr, "%s\n", [s cString]);            
        }
        #endif
        return EXIT_FAILURE;
    }
        
	return EXIT_SUCCESS;
}
