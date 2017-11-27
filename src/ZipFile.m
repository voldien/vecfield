#import"ZipFile.h"
#import<Foundation/Foundation.h>
#include<zip.h>
#include<errno.h>

@implementation ZipFile : Resource

-(void) release{
    zip_close((struct zip*)self->pfile);
}

-(id) init{
    self = [super init];

    if(self != nil){
        self->pfile = NULL;
    }
    return self;
}

-(void) dealloc{
    [super dealloc];
}

-(long int) readFile: (const char*) cpath: (void**) pbuf{
    
    struct zip_file * zfile;
    struct zip_stat stat;
    long int nbytes;
    int err;
    char buf[1024];
    
    /*	Check if path argument is valid.	*/
    if(!cpath || !pbuf || !*pbuf){
        @throw [NSException
        exceptionWithName:@"NSNullReferenceException"
        reason:@"path or the pbuf argument must not be a null argument"
        userInfo:nil];
    }
    
    /*	Fetch information about the file.   */
    err = zip_stat((struct zip*)pfile, cpath, 0, &stat);
    if(err != 0){
        zip_error_to_str(buf, sizeof(buf), err, errno);
        @throw [NSException
        exceptionWithName:@"NSFileNotFoundException"
        reason:[NSString stringWithFormat:@"%s - %@", cpath, [NSString stringWithUTF8String:buf]]
        userInfo:nil];
    }
    
    /*	Open file inside zip.	*/
    zfile = zip_fopen((struct zip*)pfile, cpath, 0);
    if(!zfile){
        @throw [NSException
        exceptionWithName:@"NSErrorException"
        reason:@"unknown error"
        userInfo:nil];
    }
    
    /*	Allocate size for file.	*/
    *pbuf = malloc(stat.size);
    *	assert(*pbuf);
    * 
    *	/*	Read whole file.    */
    nbytes = zip_fread(zfile, *pbuf, stat.size);
    
    /*	*/
    zip_fclose(zfile);
    
    return nbytes;
}

-(long int) readString: (const char*) cpath: (void**) pbuf{
    
    long int nbytes;
    
    nbytes = [self readFile: cpath: pbuf];
    if(nbytes > 0){
        *pbuf = realloc(*pbuf, nbytes + 1);
        ((char*)(*pbuf))[nbytes] = '\0';
    }
    
    return nbytes;
}

+(ZipFile*) loadFile: (const char*) path{
    
    int err;
    struct zip* zip;
    ZipFile* zipfile;
    
    /*  Check path argument.    */
    if(!path){
        @throw [NSException
        exceptionWithName:@"NSNullReferenceException"
        reason:@"path must be non-null terminated string"
        userInfo:nil];
    }
    
    /*	Attempt to open the file by file path.	*/
    zip = zip_open(path, 0, &err);
    if(zip == NULL){
        char buf[4096];
        const int nbuf = sizeof(buf);
        zip_error_to_str(buf, nbuf, err, errno);
        if(err == ZIP_ER_NOENT){
            @throw [NSException
            exceptionWithName:@"NSFileNotFoundException"
            reason:[NSString stringWithUTF8String:buf]
            userInfo:nil];
        }else{
            @throw [NSException
            exceptionWithName:@"NSErrorExecption"
            reason:[NSString stringWithUTF8String:buf]
            userInfo:nil];
        }
    }
    
    /* Create zipfile object. */
    zipfile = [[[ZipFile alloc] init] autorelease];
    zipfile->pfile = zip;

    return zipfile;
}

@end
