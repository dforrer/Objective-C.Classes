/**
 * VERSION:	1.0
 * AUTHOR:	Daniel Forrer
 * FEATURES:
 */


#import <Cocoa/Cocoa.h>

@interface FileEncryptor : NSObject

+ (void) encryptAtPath:(NSString*)fromPath toPath:(NSString*)toPath withAES256:(NSString*) password;

@end