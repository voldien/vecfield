#import<Foundation/Foundation.h>
#import"Resource.h"

@implementation Resource : NSObject{
	int nrReferences;
}

-(id) init{
	self = [super init];
	if(self != nil){
		/*  */
		self->nrReferences = 1;
	}
	return self;
}

-(void) dealloc{
	[super dealloc];
}

-(void) release{
	if([self numReferences] <= 1)
		[super release];
}

-(int) numReferences{
	return nrReferences;
}

@end
