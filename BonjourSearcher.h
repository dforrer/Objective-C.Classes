/**
 * VERSION:	1.01
 * AUTHOR:	Daniel Forrer
 * FEATURES:
 */

#import <Cocoa/Cocoa.h>
#include <arpa/inet.h>


@interface BonjourSearcher : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

/* 
 * NSMutableArray of NSNetService:
 * in this Array we store all the announced AND resolved
 * services 
 */

@property (nonatomic,readonly,strong) NSMutableArray * resolvedServices;


- (id) initWithServiceType: (NSString *) type
			  andDomain: (NSString *) domain;


@end
