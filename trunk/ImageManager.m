//
//  Searcher.m
//  RandomWeb
//
//  Created by Gabriel Handford on Wed Jul 21 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "ImageManager.h"
#import "ImageProcessor.h"
#import "RWOptions.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "RWLog.h"
#import "FileUtil.h"

static ImageManager *sharedInstance = nil;
static NSLock *sharedLock = nil;
static BOOL hasBeenInitialized = NO;
static BOOL hasCheckedCache = NO;

@implementation ImageManager

+(ImageManager*) sharedInstance {
	[sharedLock lock];
	if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
	}
	[sharedLock unlock];
    return sharedInstance;
}

+ (void)initialize {
	[super initialize];
	if (hasBeenInitialized) return;
	hasBeenInitialized = YES;
	sharedLock = [[NSLock alloc] init];
}

-(id) init {
	return [self initWithDelegate:nil];
}

-(id) initWithDelegate:(id)d {
	self = [super init];
	
	if (self) {
		delegateList = [[NSMutableArray alloc] initWithCapacity:2];
		dirCache = [[ImageDirectoryCache alloc] init];
		
		//NSString *basePath = [[RWOptions sharedInstance] getBaseImagePath];
		//database = [[SQLDatabase databaseWithFile:[basePath stringByAppendingPathComponent:@"RandomWeb.db"]] retain];
		
		lastTransferDate = [[NSDate distantPast] retain];
		lastTypeChangeDate = [[NSDate distantPast] retain];
		lastStatusUpdate = [[NSDate distantPast] retain];
		imageArray = [[NSMutableArray alloc] initWithCapacity:10];
		transfering = NO;
		canceled = NO;
		bytesTransfered = 0;
		imagesDownloaded = 0;
		adaptiveMinWait = 5;		
		
		if (d) [self addDelegate:d];
	}
	return self;
}

-(void) dealloc {
	//if (database) [database release];
	if (delegateList) [delegateList release];
	if (dirCache) [dirCache release];
	if (client) [client release];
	if (imageArray) [imageArray release];	
	if (lastTransferDate) [lastTransferDate release];
	if (lastTypeChangeDate) [lastTypeChangeDate release];
	if (lastStatusUpdate) [lastStatusUpdate release];
	if (currentSearchItem) [currentSearchItem release];
	if (status) [status release];
	[super dealloc];
}

-(void) checkCache {
	RWLog(@"In check cache");
	@synchronized(self) {
		if (hasCheckedCache) return;
		hasCheckedCache = YES;
		RWLog(@"Removing temp dir");
		[ImageDirectoryCache removeTempDir];
		RWLog(@"Checking base directory");
		[ImageDirectoryCache checkDirectories:self];
		[self setStatus:@"Finding local images..."];
		RWLog(@"Checking cache...");
		[ImageDirectoryCache checkTotalCacheSize:[[RWOptions sharedInstance] getBaseImagePath]];

	}
}

-(void) reload {
	[sharedLock lock];
	[lastTypeChangeDate release];
	lastTypeChangeDate = [[NSDate distantPast] retain];
	[sharedLock unlock];
}

-(void) reloadCache {
	[sharedLock lock];
	[imageArray removeAllObjects];
	[dirCache load:currentSearchItem];
	[self setCanceled:YES];
	[self setCanceled:NO];
	[sharedLock unlock];
}

-(BOOL) checkSearchItemNeedsReload {
	if (currentSearchItem) {
		if ([currentSearchItem needsReload]) {
			RWLog(@"Search item needed reloading, doing it now");
			[self reloadCache];
			return YES;
		}
	}
	return NO;
}

-(void) handleInvalidImage:(NSString*)path {
	[currentSearchItem handleInvalidImage:path];
}

-(BOOL) checkSearchItem {
	BOOL changed = NO;
	[sharedLock lock];
	if (fabs([lastTypeChangeDate timeIntervalSinceNow]) > ([[RWOptions sharedInstance] getTypeChangeInterval] * 60.0)) {
		RWLog(@"Selecting a new random search item");
		
		SearchParamItem *newItem = [[RWOptions sharedInstance] getRandomItem:currentSearchItem];
		changed = [self setSearchItem:newItem];
	}
	[sharedLock unlock];
	return changed;
}


-(BOOL) setSearchItem:(SearchParamItem*)item {
	if (!item) {
		currentSearchItem = nil;
		return YES;
	}
	[item isCanceled:NO];
	[lastTypeChangeDate release];
	lastTypeChangeDate = [[NSDate date] retain];

	if (currentSearchItem && [item isEqual:currentSearchItem]) return NO;
	
	[imageArray removeAllObjects];
	
	@synchronized(self) {
		if (currentSearchItem) [currentSearchItem release];
		currentSearchItem = [item retain];
	}
	[dirCache load:currentSearchItem];
	return YES;
}

-(SearchParamItem*) getSearchItem {
	return currentSearchItem;
}

-(ImageDirectoryCache*) getDirectoryCache {
	return dirCache;
}

-(void) addDelegate:(id)d {
	@synchronized(delegateList) {
		if (d && ![delegateList containsObject:d]) [delegateList addObject:d];
	}
}

-(void) removeDelegate:(id)d {
	@synchronized(delegateList) {
		if (d) [delegateList removeObject:d];
	}
}

-(BOOL) isTransferring {
	return transfering;
}

-(int) count {
	@synchronized(imageArray) {
		return [imageArray count];
	}
	return 0;
}

-(int) cacheCount {
    @synchronized(imageArray) {
		return [dirCache count];
	}
	return 0;
}

-(void) notifyTransferAttempt {
	@synchronized(self) {
		[lastTransferDate release];
		lastTransferDate = [[NSDate date] retain];
	}
}

-(void) addToImageArray:(NSArray*)args {
	[self addToImageArray:[args objectAtIndex:0] destPath:[args objectAtIndex:1]];
}

-(void) addToImageArray:(NSString*)srcPath destPath:(NSString*)destPath {
	[dirCache addToCacheDir:srcPath destPath:destPath];
	[imageArray addObject:destPath];
}

-(NSString*) getFromImageCache {
	NSString *path = [dirCache getRandomImage];
	if (path) {
		RWLog(@"Returning random image from cache dir: %@", path);
		return path;
	}
	return nil;
}

-(NSString*) getFromImageArray {
	if (canceled) return nil;
	@synchronized(imageArray) {
		if ([imageArray count] > 0) {
			NSString *path = [[imageArray objectAtIndex:0] retain];
			RWLog(@"Getting newly downloaded image: %@", path);
			[imageArray removeObjectAtIndex:0];
			return [path autorelease];
		} else {
			return [self getFromImageCache];
			
		}
	}
	return nil;
}

-(void) setStatus:(NSString*)s {
	@try {
		int i, size;
		if (!s) s = @"";
		@synchronized(delegateList) {
			for(i = 0, size = [delegateList count]; i < size; i++) {
				id delegate = [delegateList objectAtIndex:i];
				if (delegate) [delegate setStatus:[NSString stringWithFormat:@"%@", s]];
			}
		}
	} @catch(NSException *nse) {
		RWLog(@"Error: %@", nse);
	}
}

-(BOOL) checkSearch {
	if (!currentSearchItem || [currentSearchItem getWaitBetweenTransfer] == 0)
		return NO;
		
	if (!currentSearchItem) return NO;
	
	if (transfering) return NO;
	
	NSDate *lastSearch = [currentSearchItem getLastSearchDate];
	if (lastSearch == nil) lastSearch = lastTransferDate;
	
	BOOL agressiveMode = ([dirCache count] < [[RWOptions sharedInstance] getMinImageCount] && [currentSearchItem isAggressive]);
	int minWait = [currentSearchItem getWaitBetweenTransfer]*60;
	
	if (agressiveMode) {
		if ([currentSearchItem isHighPriority]) minWait = 10;
		else minWait = adaptiveMinWait;
	}
	
	int seconds = minWait - fabs([lastSearch timeIntervalSinceNow]);
	if (seconds > 0) {
		int minutes = (int)floor((double)seconds/60.0f);
		int secondsLeft = seconds - (minutes*60);
		int dlCount = [currentSearchItem getLastDownloadCount];
		NSString *statusMsg = @"";
		if (dlCount > 0) statusMsg = [NSString stringWithFormat:@"[%02d:%02d] (%d)", minutes, secondsLeft, dlCount];
		else statusMsg = [NSString stringWithFormat:@"[%02d:%02d]", minutes, secondsLeft];
		[self setStatus:statusMsg];
	}
	
	if (seconds <= 0) {
			
		// Check to see if your off the network
		if (imagesDownloaded == 0 && ![currentSearchItem isHighPriority]) {
			adaptiveMinWait *= 2;
			if (adaptiveMinWait > ([currentSearchItem getWaitBetweenTransfer]*60)) 
				adaptiveMinWait = ([currentSearchItem getWaitBetweenTransfer]*60);
			
			/**
			[self setStatus:@"Checking connection status"];
			if (![self serverIsReachable:@"images.google.com"]) {
				[self setStatus:@"Can't connect to search host"];
				return NO;
			}
			*/
		}
		if ([currentSearchItem vetoSearch]) {
			//[self setStatus:@"Waiting..."];
			[self notifyTransferAttempt];
			return NO;
		}
		
		
		return [self triggerSearch];
	}
	return NO;
}


-(BOOL) startSearch:(id) item {
	[self setStatus:@"Searching..."];
	[self notifyTransferAttempt];
	imagesDownloaded = 0;
	bytesTransfered = 0;
		
	if (!canceled) {
		@synchronized(self) {
			if (client) [client release];
			client = [[SearchDownloadClient alloc] initWithSearchListener:self downloadListener:self];
		}
		return [client downloadImages:[[RWOptions sharedInstance] getMaxImagePerSearch] search:item];
	}
	return NO;
}

-(BOOL) triggerSearch {
	@synchronized(self) {
		RWLog(@"Trigger search start");
		if (!transfering) {
			[self notifyTransferAttempt];
			SearchParamItem *item = currentSearchItem;
			
			if (![item isSearchExhausted]) {
				transfering = [self startSearch:item];
			}
		}
	}
	RWLog(@"Trigger search end");
	return transfering;
}

-(void) setCanceled:(BOOL)b {
	RWLog(@"Searcher, setCanceled(%d)", (int)b);
	@synchronized(self) {
		canceled = b;
		if (canceled) {
			if (currentSearchItem) [currentSearchItem isCanceled:YES];
			if (client) [client setCanceled:YES];
		} else {
			transfering = NO;
		}
	}
}

-(BOOL) serverIsReachable:(NSString*)server {
    BOOL isValid;
    SCNetworkConnectionFlags flags = 0;
    isValid = SCNetworkCheckReachabilityByName([server cString], &flags);
    if (isValid && ((flags & kSCNetworkFlagsReachable) && !(flags &
        kSCNetworkFlagsConnectionRequired))) {
        return YES;
    }

    return NO;
}

-(void) didStartDownload:(NSURL*)url count:(int)index path:(NSString*)savePath { 
	bytesTransfered = 0;
	[self setStatus:[NSString stringWithFormat:@"Connecting to [%@]", [url host]]];
	if (index >= 0) RWLog(@"Starting image download %d/%d", index+1, transferImageCount);
}

/**
-(void) didSkipImage:(NSURL*)url count:(int)index {
	RWLog(@"Skipping image: %@", url);
	[self setStatus:NULL];
	[self checkIfFinished:index];
}
*/

-(void) didAbort {
	[self stoppedTransferring];
}

-(void) didFinishDownload:(NSURL*)url count:(int)index path:(NSString*)savePath {
	NSString *destPath = savePath;
	if ([[savePath pathExtension] isEqualToString: @"tmp"]) {	
		destPath = [savePath stringByDeletingPathExtension];
		RWLog(@"Using destination path: %@", destPath);
	}

	imagesDownloaded++;
	RWLog(@"Finished image download (%@), was %d bytes", savePath, bytesTransfered);
	NSArray *args = [NSArray arrayWithObjects: savePath, destPath, nil]; 
	SEL sel = @selector(addToImageArray:);
	[self performSelectorOnMainThread:sel withObject:args waitUntilDone:YES];
	
	[self setStatus:NULL];
	[self checkIfFinished:index];
}

-(void) checkResults {
	if (!client) return;
	SearchResult *result = [client getLastResult];
	[currentSearchItem checkResults:result];
	[[RWOptions sharedInstance] saveSearchParamItem:currentSearchItem sync:YES];
}

-(void) checkIfFinished:(int)index {
	if (canceled) return;
	if (index == -1) return;

	if (index >= (transferImageCount-1)) {
		RWLog(@"Setting download count on search item: %d", imagesDownloaded);
		[currentSearchItem setLastDownloadCount:imagesDownloaded];
		[self didFinishDownloads:NO];
	}
}

-(void) didFinishDownloads:(BOOL)interrupted {
	[self stoppedTransferring];
	if (!interrupted) [self checkResults];
}

-(void) didStartSearch:(NSURL*)url {
	[self setStatus:[NSString stringWithFormat:@"Searching: %@", [url host]]];
	RWLog(@"Starting search...");
}

-(void) didFinishSearch:(int)count { 
	if (count > 0) {
		[self setStatus:[NSString stringWithFormat:@"Finished searching, scanning %d images", count]];
	} else if (count != -1) {
		[self stoppedTransferring];
	}
	RWLog(@"Finished search");
	transferImageCount = count;	
}

-(void) stoppedTransferring {
	[self setStatus:NULL];
	//SEL sel = @selector(notifyTransferAttempt);
	//[self performSelectorOnMainThread:sel withObject:nil waitUntilDone:YES];
	[self notifyTransferAttempt];
	transfering = NO;
}

-(void) didFindMatch:(NSURL*)url count:(int)count {
	[self setStatus:[NSString stringWithFormat:@"%d matches", count]];
}

-(void) didErrorOnSearch:(NSError*)error {
	RWLog(@"Error searching: %@", error);
	[self stoppedTransferring];
	
}
 
-(void) didErrorOnDownload:(NSError*)error count:(int)c { 
	RWLog(@"Error on download: %@", error);
	[self setStatus:NULL];
	[self checkIfFinished:c];
} 

-(void) didLoadData:(NSURL*)url length:(unsigned)l total:(long long)t { 
	bytesTransfered += l;
	int total = [[NSNumber numberWithLongLong:t] intValue];
	if (fabs([lastStatusUpdate timeIntervalSinceNow]) > 0.2) {
		NSString *stat = @"";
		if (total > 0) stat = [NSString stringWithFormat:@"(%d / %d) [%@]", bytesTransfered, total, (!url || ![url host] ? @"" : [url host])];
		else  stat = [NSString stringWithFormat:@"(%d) [%@]", bytesTransfered, (!url || ![url host] ? @"" : [url host])];
		[self setStatus:stat];
		[lastStatusUpdate release];
		lastStatusUpdate = [[NSDate date] retain];
	}
}



@end
