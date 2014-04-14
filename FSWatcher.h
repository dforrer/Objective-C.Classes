/**
 * VERSION:	1.00
 * AUTHOR:	Daniel Forrer
 * FEATURES:
 */

#ifdef __OBJC__

#import <Cocoa/Cocoa.h>
#define NSLog(FORMAT, ...) fprintf( stderr, "%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String] );
#define DebugLog( s, ... ) NSLog( @"<%@:(%d)> \t%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#endif



@interface FSWatcher : NSObject
- (id) init;
- (void) shouldObserveFiles: (BOOL) b;	// By Default YES
- (void) shouldIgnoreSelf: (BOOL) b;
- (void) startWatching;
- (void) stopWatching;
- (void) setPaths:(NSArray *) paths;

@property (nonatomic, readonly, strong) NSArray * trackedPaths;
@property (nonatomic, readonly) BOOL observeFiles;
@property (nonatomic, readonly) BOOL ignoreSelf;

@end

/*
 nonatomic vs. atomic - "atomic" is the default. Always use "nonatomic". I don't know why, but the book I read said there is "rarely a reason" to use "atomic". (BTW: The book I read is the BNR "iOS Programming" book.)
 
 readwrite vs. readonly - "readwrite" is the default. When you @synthesize, both a getter and a setter will be created for you. If you use "readonly", no setter will be created. Use it for a value you don't want to ever change after the instantiation of the object.
 
 strong vs. strong
 
 */
