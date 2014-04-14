/**
 * VERSION:	1.02
 * AUTHOR:	Daniel Forrer
 * FEATURES:
 */

// HEADER
#import "BonjourSearcher.h"


//#include <arpa/inet.h>


@implementation BonjourSearcher
{
	NSNetServiceBrowser *  serviceBrowser;
	NSMutableArray * services;
}

@synthesize resolvedServices;
@synthesize myServiceName;

/**
 * Initializer
 */
- (id) initWithServiceType: (NSString *) type
			  andDomain: (NSString *) domain
{
	if ((self = [super init]))
	{
		NSLog(@"BonjourServiceSearcher: init");
		services = [[NSMutableArray alloc] init];
		resolvedServices = [[NSMutableArray alloc] init];
		serviceBrowser = [[NSNetServiceBrowser alloc] init];
		myServiceName = [[NSHost currentHost] localizedName];
		NSLog(@"myServiceName: %@", myServiceName);
		[serviceBrowser setDelegate:self];
		/*
		 The following line would search for all bonjour services:
		 [serviceBrowser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@""];
		 */
		[serviceBrowser searchForServicesOfType: type inDomain: domain];
	}
	return self;
}

/**
 * Initializer
 */
- (id) initWithServiceType: (NSString *) type
			  andDomain: (NSString *) domain
		andMyName: (NSString *) name
{
	if ((self = [super init]))
	{
		NSLog(@"BonjourServiceSearcher: init");
		services = [[NSMutableArray alloc] init];
		resolvedServices = [[NSMutableArray alloc] init];
		serviceBrowser	= [[NSNetServiceBrowser alloc] init];
		myServiceName = name;
		NSLog(@"myServiceName: %@", myServiceName);
		[serviceBrowser setDelegate:self];
		/*
		 The following line would search for all bonjour services:
		 [serviceBrowser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@""];
		 */
		[serviceBrowser searchForServicesOfType: type inDomain: domain];
	}
	return self;
}

/**
 * OVERRIDE: predefined in
 * <NSNetServiceBrowser>-Interface
 */
- (void) netServiceBrowser: (NSNetServiceBrowser *)aNetServiceBrowser
		  didFindService: (NSNetService *)aNetService
			 moreComing: (BOOL)moreComing
{
	// Compare the Name of the new service with local computer name
	// so that we don't connect to ourselfs!
	if (![[aNetService name] isEqualToString: myServiceName])
	{
		if (![services containsObject:aNetService])
		{
			NSLog(@"NetService added to services Array: %@",aNetService);
			[services addObject:aNetService];
			[aNetService setDelegate:self];
			[aNetService resolveWithTimeout:3];
		}
	}
}

/**
 * OVERRIDE
 */
- (void) netServiceBrowser: (NSNetServiceBrowser *)aNetServiceBrowser
		didRemoveService: (NSNetService *)aNetService
			 moreComing: (BOOL)moreComing
{
	if ([services containsObject:aNetService])
	{
		NSLog(@"BonjourServiceSearcher: didRemoveService");
		[self willChangeValueForKey:@"services"];
		[services removeObject:aNetService];
		[resolvedServices removeObject:aNetService];
		[self didChangeValueForKey:@"services"];
	}
}

/**
 * OVERRIDE: NSNetServiceDelegate
 */
- (void) netServiceDidResolveAddress: (NSNetService *)aNetService
{
	NSLog(@"BonjourServiceSearcher: didResolveService: \nname: %@, \nhostname: %@",[aNetService name], [aNetService hostName]);
	[resolvedServices addObject:aNetService];
}

/**
 * OVERRIDE: NSNetServiceDelegate
 */
- (void) netService: (NSNetService *)aNetService
	 didNotResolve: (NSDictionary *)errorDict
{
	NSLog(@"Resolve failed");
	[services removeObject:aNetService];
}


- (NSNetService*) getNetServiceWithName: (NSString*) name
{
	for (NSNetService * ns in resolvedServices)
	{
		if ([[ns name] isEqualToString:name])
		{
			return ns;
		}
	}
	return nil;
}


@end
