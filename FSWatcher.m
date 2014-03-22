/**
 * VERSION:	1.00
 * AUTHOR:	Daniel Forrer
 * FEATURES:
 */


#import "FSWatcher.h"


@implementation FSWatcher
{
	FSEventStreamRef eeventStream;
	BOOL observeFiles;
}



@synthesize trackedPaths;


/*
 Initializer
 */
- (id) init
{
	if (self = [super init])
	{
		observeFiles = TRUE;
	}
	return self;
}


- (void) shouldObserveFiles: (BOOL) b
{
	observeFiles = b;
	[self setPaths: trackedPaths];
}

/*
 Stops, releases, recreates and restarts the FSEventStream
 */

- (void) setPaths:(NSArray *) paths
{
	// Stop and delete the previous FSWatcher
	//---------------------------------------
	
	if ( [trackedPaths count] != 0 )
	{
		[self stopWatching];
		FSEventStreamInvalidate(eeventStream);
		FSEventStreamRelease(eeventStream);
	}

	// Check if "paths" is empty
	//--------------------------
	
	if ( [paths count] == 0 )
	{
		return;
	}
	
	// Switch between "Observe folders only" / "Observe Files and Folders"
	//--------------------------------------------------------------------
	
	int flags;
	if (observeFiles)
	{
		flags = kFSEventStreamCreateFlagUseCFTypes|kFSEventStreamCreateFlagWatchRoot|kFSEventStreamCreateFlagFileEvents;
	}
	else
	{
		flags = kFSEventStreamCreateFlagUseCFTypes|kFSEventStreamCreateFlagWatchRoot;
	}
	
	// Recreate the FSEventStream
	//---------------------------
	
	trackedPaths = paths;
	CFTimeInterval latency = 0.2;
	FSEventStreamContext context = {0,(__bridge void *)self,NULL,NULL,NULL};
	eeventStream = FSEventStreamCreate(kCFAllocatorDefault,&callback,&context,(__bridge CFArrayRef)trackedPaths,kFSEventStreamEventIdSinceNow,latency, flags);
	
	// Restart the FSEventStream
	//--------------------------
	
	[self startWatching];
}



/**
 * Schedules the Watcher in den mainRunLoop
 * and starts the stream
 */
- (void) startWatching
{
	//DebugLog(@"Watcher started: %@",trackedPaths);
	FSEventStreamScheduleWithRunLoop(eeventStream,[[NSRunLoop mainRunLoop] getCFRunLoop],kCFRunLoopDefaultMode);
	FSEventStreamStart(eeventStream);
}



/**
 * Removes the "FSEventStreamRef
 * eeventStream" from the mainRunLoop.
 */
- (void) stopWatching
{
	//DebugLog(@"Watcher is no longer watching the directorie(s)");
	FSEventStreamStop(eeventStream);
	FSEventStreamUnscheduleFromRunLoop(eeventStream, [[NSRunLoop mainRunLoop] getCFRunLoop],kCFRunLoopDefaultMode);
}



/**
 * callback for FSEvents set in
 * "initWithPaths"
 */
static void callback(ConstFSEventStreamRef streamRef,
				 void *clientCallBackInfo,
				 size_t numEvents,
				 void *eventPaths,
				 const FSEventStreamEventFlags eventFlags[],
				 const FSEventStreamEventId eventIds[])
{
	// First, make a copy of the event path so we can modify it.
	//----------------------------------------------------------
	
	NSArray * paths = (__bridge NSArray *)(eventPaths);

	// Loop through all FSEvents
	//--------------------------
	
	for ( int i = 0 ; i < numEvents ; i++ )
	{
		/* Single & means BITWISE AND
		 *     0101 (decimal 5)
		 * AND 0011 (decimal 3)
		 *   = 0001 (decimal 1)
		 */
		
		if ( eventFlags[i] & kFSEventStreamEventFlagItemIsDir )
		{
			NSURL * u = [NSURL fileURLWithPath:[paths objectAtIndex:i] isDirectory:YES];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"fsWatcherEventIsDir" object:u];

		}
		else if (eventFlags[i] & kFSEventStreamEventFlagItemIsFile)
		{
			// Filter out .DS_Store Files
			//---------------------------
			if (![[[paths objectAtIndex:i] lastPathComponent] isEqualToString:@".DS_Store"])
			{
				NSURL * u = [NSURL fileURLWithPath:[paths objectAtIndex:i] isDirectory:NO];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"fsWatcherEventIsFile" object:u];
			}
			
		}
		else if (eventFlags[i] & kFSEventStreamEventFlagItemIsSymlink)
		{
			// Filter out .DS_Store Files
			//---------------------------
			if (![[[paths objectAtIndex:i] lastPathComponent] isEqualToString:@".DS_Store"])
				{
					NSURL * u = [NSURL fileURLWithPath:[paths objectAtIndex:i]];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"fsWatcherEventIsSymlink" object:u];
				}
				
		}
		else if ( eventFlags[i] & kFSEventStreamEventFlagMustScanSubDirs )
		{
			if (eventFlags[i] & kFSEventStreamEventFlagUserDropped)
			{
				printf("BAD NEWS! We dropped events.\n");
			}
			else if (eventFlags[i] & kFSEventStreamEventFlagKernelDropped)
			{
				printf("REALLY BAD NEWS! The kernel dropped events.\n");
			}
			
		}
		else if (eventFlags[i] & kFSEventStreamEventFlagRootChanged)
		{
			printf("The Root-folder has been moved!");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"fsWatcherRootChanged" object:nil];
		}
	}
}

@end

/*
 enum {
 kFSEventStreamEventFlagNone = 0x00000000,
 kFSEventStreamEventFlagMustScanSubDirs = 0x00000001,
 kFSEventStreamEventFlagUserDropped = 0x00000002,
 kFSEventStreamEventFlagKernelDropped = 0x00000004,
 kFSEventStreamEventFlagEventIdsWrapped = 0x00000008,
 kFSEventStreamEventFlagHistoryDone = 0x00000010,
 kFSEventStreamEventFlagRootChanged = 0x00000020,
 kFSEventStreamEventFlagMount = 0x00000040,
 kFSEventStreamEventFlagUnmount = 0x00000080,
 
 // These flags are only set if you specified the
 // FileEventsflags when creating the stream.
 
 kFSEventStreamEventFlagItemCreated = 0x00000100,
 kFSEventStreamEventFlagItemRemoved = 0x00000200,
 kFSEventStreamEventFlagItemInodeMetaMod = 0x00000400,
 kFSEventStreamEventFlagItemRenamed = 0x00000800,
 kFSEventStreamEventFlagItemModified = 0x00001000,
 kFSEventStreamEventFlagItemFinderInfoMod = 0x00002000,
 kFSEventStreamEventFlagItemChangeOwner = 0x00004000,
 kFSEventStreamEventFlagItemXattrMod = 0x00008000,
 kFSEventStreamEventFlagItemIsFile = 0x00010000,
 kFSEventStreamEventFlagItemIsDir = 0x00020000,
 kFSEventStreamEventFlagItemIsSymlink = 0x00040000
 };
 
 */

