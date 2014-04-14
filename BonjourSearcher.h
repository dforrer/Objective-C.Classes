/**
 * VERSION:	1.02
 * AUTHOR:	Daniel Forrer
 * FEATURES:
 */

#import <Cocoa/Cocoa.h>

@interface BonjourSearcher : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

/* 
 * NSMutableArray of NSNetService:
 * in this Array we store all the announced AND resolved
 * services 
 */

@property (nonatomic,readonly,strong) NSMutableArray * resolvedServices;
@property (nonatomic,readonly,strong) NSString * myServiceName;


- (id) initWithServiceType: (NSString *) type
			  andDomain: (NSString *) domain;

- (id) initWithServiceType: (NSString *) type
			  andDomain: (NSString *) domain
		andMyName: (NSString *) name;

- (NSNetService*) getNetServiceWithName: (NSString *) name;

@end
