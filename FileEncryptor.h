/**
 * VERSION:	1.0
 * AUTHOR:	Daniel Forrer
 * FEATURES:
 */


#include <CommonCrypto/CommonDigest.h>
#import <Cocoa/Cocoa.h>
/*
 GET RNEncryptor from this link:
 https://github.com/RNCryptor/RNCryptor
*/
#import "RNCryptor.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

@interface FileEncryptor : NSObject

+ (void) encryptAtPath:(NSString*)fromPath toPath:(NSString*)toPath withAES256:(NSString*) password;

@end