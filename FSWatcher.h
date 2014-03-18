/**
 * VERSION:	1.00
 * AUTHOR:	Daniel Forrer
 * FEATURES:
 */

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface FSWatcher : NSObject
- (id) init;
- (void) shouldObserveFiles: (BOOL) b;
- (void) startWatching;
- (void) stopWatching;
- (void) setPaths:(NSArray *) paths;

@property (nonatomic, readonly, strong) NSArray * trackedPaths;

@end

/*
 nonatomic vs. atomic - "atomic" is the default. Always use "nonatomic". I don't know why, but the book I read said there is "rarely a reason" to use "atomic". (BTW: The book I read is the BNR "iOS Programming" book.)
 
 readwrite vs. readonly - "readwrite" is the default. When you @synthesize, both a getter and a setter will be created for you. If you use "readonly", no setter will be created. Use it for a value you don't want to ever change after the instantiation of the object.
 
 strong vs. strong
 
 */
